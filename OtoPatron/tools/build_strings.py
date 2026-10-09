"""strings_table.py -> scripts/data/strings.gd üretir."""
import os, sys
sys.path.insert(0, os.path.dirname(__file__))
import strings_table as st
def q(s): return '"' + s.replace('\\', '\\\\').replace('"', '\\"') + '"'
out = ['class_name Strings', 'extends RefCounted', '## Otomatik üretilir: tools/build_strings.py. Doğrudan düzenleme; tools/strings_table.py dosyasını düzenle.', '', 'const TEXT: Dictionary = {']
seen = {}
for k, tr, en, ar, fr in st.T:
    seen[k] = (tr, en, ar, fr)
for k, (tr, en, ar, fr) in seen.items():
    out.append(f'\t"{k}": {{"tr": {q(tr)}, "en": {q(en)}, "ar": {q(ar)}, "fr": {q(fr)}}},')
out.append('}')
open(os.path.join(os.path.dirname(__file__), '..', 'scripts', 'data', 'strings.gd'), 'w', encoding='utf-8').write('\n'.join(out) + '\n')
