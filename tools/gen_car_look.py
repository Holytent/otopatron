#!/usr/bin/env python3
"""Regenerates OtoPatron/scripts/data/car_look.gd from the car SVG art.

Paint = the flat stop of the "paint" gradient, spokes = number of spoke strokes per wheel.
Run from the repository root:  python3 tools/gen_car_look.py
"""
import re
ROOT = "OtoPatron/"
db = open(ROOT + "scripts/data/car_db.gd", encoding="utf-8").read()
ids = re.findall(r'\{"id": "(\w+)"', db)
rows = []
for cid in ids:
    svg = open(f"{ROOT}art/cars/{cid}.svg", encoding="utf-8").read()
    paint = re.search(r'<linearGradient id="paint"[^>]*>(.*?)</linearGradient>', svg, re.S).group(1)
    colour = [c for o, c in re.findall(r'<stop(?: offset="([\d.]+)")? stop-color="(#[0-9a-fA-F]{6})"', paint) if o == ".18"][0].lower()
    spokes = len(re.findall(r'<path d="M[\d.]+ [\d.]+ L[\d.]+ [\d.]+" stroke="#', svg)) // 2
    rows.append(f'\t"{cid}": ["{colour}", {spokes}],')
path = ROOT + "scripts/data/car_look.gd"
text = open(path, newline="", encoding="utf-8").read()
start = text.index("const LOOKS: Dictionary = {") + len("const LOOKS: Dictionary = {")
end = text.index("\n}", start)
open(path, "w", newline="", encoding="utf-8").write(text[:start] + "\r\n" + "\r\n".join(rows) + text[end - 1:].replace("\r\n}", "\r\n}", 1))
print(len(rows), "cars written")
