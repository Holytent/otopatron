"""Keep the shipped offline launch page identical to the release entry point."""
import hashlib
import json
from pathlib import Path
import re
import sys


def sync_release(directory):
    web = Path(directory)
    html = (web / 'index.html').read_text(encoding='utf-8')
    version = json.loads((web / 'release.json').read_text(encoding='utf-8'))['version']
    if f'V{version}' not in html:
        raise ValueError('Entry point and release.json versions differ')
    pack = re.search(r"config.mainPack = '([^']+)'", html)[1]
    bundle = re.search(r'launch-bundle-[a-f0-9]+[.]js', html)[0]
    for asset in [pack, bundle]:
        if not (web / asset).is_file():
            raise ValueError(f'Missing release asset: {asset}')
    worker_path = web / 'sw-safari.js'
    worker = worker_path.read_text(encoding='utf-8')
    revision = hashlib.sha256(html.encode('utf-8')).hexdigest()[:16]
    worker, count = re.subn(r'^const LAUNCH_HTML = .*;$', lambda _: 'const LAUNCH_HTML = ' + json.dumps(html, ensure_ascii=False) + ';', worker, flags=re.M)
    if count != 1:
        raise ValueError('Expected one embedded launch document')
    worker = re.sub(r"^const REVISION = '[^']+';", f"const REVISION = '{revision}';", worker, flags=re.M)
    worker = re.sub(r'app-icon-v\d+[.]png', 'app-icon-v' + version.replace('.', '') + '.png', worker)
    worker_path.write_text(worker, encoding='utf-8')
    (web / 'index.service.worker.js').write_text(f"// OtoPatron Safari revision {revision}\nimportScripts('sw-safari.js');\n", encoding='utf-8')
    print(f'{web}: fallback synchronized to {version}, {pack}, {bundle}')


if __name__ == '__main__':
    for directory in sys.argv[1:]:
        sync_release(directory)
