"""Apply the Safari-safe PWA files after every Web export / hosting preparation."""
from pathlib import Path
import argparse, hashlib, json, re, shutil
parser = argparse.ArgumentParser()
parser.add_argument('publish_folder', type=Path)
options = parser.parse_args()
target = options.publish_folder.resolve()
project = Path(__file__).resolve().parent.parent
templates = project / 'web/safari'
for name in ['pwa-lifecycle.js', 'mobile-editor.js', 'push-client.js', 'music-client.js', 'accounts.js', 'update-client.js', 'startup-guard.js', 'release.json', 'account-config.json']:
    shutil.copy2(templates / name, target / name)
html = (target / 'index.html').read_text(encoding='utf-8-sig')
if 'src="pwa-lifecycle.js"' not in html:
    html = html.replace('<script src="engine-loader.js">', '<script src="pwa-lifecycle.js"></script>\n<script src="engine-loader.js">') if 'src="engine-loader.js"' in html else html.replace('<script src="index.js">', '<script src="pwa-lifecycle.js"></script>\n<script src="index.js">')
# Navigation is fresh while the previous service worker can still control scripts.
# Content-specific filenames prevent mixing a new game pack with old UI helpers.
def fingerprint_script(match):
    original = re.sub(r'-[0-9a-f]{16}\.js$', '.js', match.group(1))
    source = target / original
    if not source.is_file(): return match.group(0)
    signature = hashlib.sha256(source.read_bytes()).hexdigest()[:16]
    name = source.stem + '-' + signature + '.js'
    shutil.copy2(source, target / name)
    return '<script src="' + name + '"'
html = re.sub(r'<script src="([^"/]+\.js)"', fingerprint_script, html)
def fingerprint_dependencies(match):
    files=json.loads(match.group(1))
    names=[]
    for filename in files:
        tag=fingerprint_script(re.match(r'<script src="([^"/]+\.js)"', '<script src="'+filename+'"'))
        names.append(re.search(r'src="([^"]+)"',tag).group(1))
    return 'const dependencies = '+json.dumps(names)+';'
html = re.sub(r'const dependencies = (\[[^;]+\]);',fingerprint_dependencies,html)
# Execute helpers and engine in their original order, using one network request.
# Keep an external URL so Godot resolves WASM relative to the site, not a blob.
found = re.search(r'const dependencies = (\[[^;]+\]);', html)
if found:
    files = json.loads(found.group(1))
    if len(files) > 1:
        bundled = "\n;\n".join((target / name).read_text(encoding='utf-8-sig') for name in files)
        signature = hashlib.sha256(bundled.encode()).hexdigest()[:16]
        bundle_name = 'launch-bundle-' + signature + '.js'
        (target / bundle_name).write_text(bundled, encoding='utf-8')
        html = re.sub(r'const dependencies = \[[^;]+\];', 'const dependencies = '+json.dumps([bundle_name])+';', html)
# Logo is part of the document; it remains visible even when asset requests fail.
import base64
inline_icon = 'data:image/png;base64,'+base64.b64encode((project/'icon.png').read_bytes()).decode()
html = re.sub(r'(<div class="logo"><img src=")[^"]+(" alt="OtoPatron")', lambda m:m.group(1)+inline_icon+m.group(2), html)
(target / 'index.html').write_text(html, encoding='utf-8')
assets = sorted(p.name for p in target.iterdir() if p.is_file() and p.suffix in {'.js', '.png', '.bin', '.pck'} and p.name not in {'index.service.worker.js', 'sw-safari.js'})
assets = sorted(set(assets + ['pwa-lifecycle.js']))
digest = hashlib.sha256(html.encode())
for filename in assets:
    if (target / filename).is_file():
        digest.update((target / filename).read_bytes())
revision = digest.hexdigest()[:16]
worker = (templates / 'sw-safari.js').read_text(encoding='utf-8-sig')
worker = re.sub(r"const REVISION = '[^']+';", "const REVISION = '" + revision + "';", worker)
worker = worker.replace("const LAUNCH_HTML = '';", 'const LAUNCH_HTML = '+json.dumps(html,ensure_ascii=False)+';')
worker = re.sub(r'const ASSETS = \[[^;]*\];', 'const ASSETS = ' + json.dumps(assets) + ';', worker)
icon = next((name for name in assets if name.startswith('app-icon-v')), 'index.512x512.png')
worker = re.sub(r"app-icon-v\d+\.png", icon, worker)
(target / 'sw-safari.js').write_text(worker, encoding='utf-8')
(target / 'index.service.worker.js').write_text("// OtoPatron Safari revision " + revision + "\nimportScripts('sw-safari.js');\n", encoding='utf-8')
for name in ['pwa-lifecycle.js', 'repair.html', '_headers']:
    shutil.copy2(templates / name, target / name)
manifest_path = target / 'index.manifest.json'
manifest = json.loads(manifest_path.read_text(encoding='utf-8-sig'))
manifest['start_url'] = './'
manifest['id'] = './'
manifest['scope'] = './'
manifest_path.write_text(json.dumps(manifest, ensure_ascii=False), encoding='utf-8')
print('Safari patch applied:', revision)
