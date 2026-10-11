#!/usr/bin/env python3
"""Redraws the side-view art of every catalog car in the new-generation style.

Each car keeps its id, paint colour, wheel spoke count and wheel centres (read from the current
OtoPatron/scripts/data/car_look.gd and art/cars/<id>.svg), so CarLook, CarPortrait._wheels, prices and saves
are untouched. Only the silhouette and details change.

Run from the repository root:  python3 tools/gen_fleet_svg.py   then   python3 tools/gen_car_look.py (must report no diff)
"""
import math
import re
import sys

ROOT = "OtoPatron/"
ART = ROOT + "art/cars/"

HEAD = '<svg xmlns="http://www.w3.org/2000/svg" width="960" height="480" viewBox="0 0 640 320">\n'
GLASS = '<linearGradient id="glass" x2=".4" y2="1"><stop stop-color="#5f8398"/><stop offset=".55" stop-color="#1c3a4b"/><stop offset="1" stop-color="#0e202c"/></linearGradient>'
RIM = '<radialGradient id="rim"><stop stop-color="#dce3e9"/><stop offset=".8" stop-color="#8798a4"/><stop offset="1" stop-color="#293b49"/></radialGradient>'
DARK = "#15222c"


def tpl(name, body, glass, glass_bottom, details="", head="", tail="", extras="", front_lip=""):
    return dict(name=name, body=body, glass=glass, glass_bottom=glass_bottom, details=details, head=head, tail=tail, extras=extras, front_lip=front_lip)


def seams(xs, y1, y2):
    return '<path d="' + " ".join(f"M{x} {y1} L{x + d} {y2}" for x, d in xs) + '" stroke="#0b141a" stroke-width="1.6" opacity=".5" fill="none"/>'


def handles(items):
    return "".join(f'<rect x="{x}" y="{y}" width="{w}" height="3" rx="1.5" fill="#dfe9ef" opacity=".92"/>' for x, y, w in items)


def led_head(x1, y1, x2, y2):
    # slim LED headlamp with a day-running line
    return (f'<path d="M{x1} {y1} L{x2} {y2} L{x2 - 2} {y2 + 7} L{x1 + 3} {y1 + 7} Z" fill="#f6f8dc" stroke="#c4d1d6" stroke-width="1"/>'
            f'<path d="M{x1 + 4} {y1 + 9} L{x2 - 3} {y2 + 9}" stroke="#dff3ff" stroke-width="2" opacity=".9" fill="none"/>')


def led_tail(x, y, h):
    return (f'<rect x="{x}" y="{y}" width="8" height="{h}" rx="3" fill="#e2474a"/>'
            f'<rect x="{x + 1}" y="{y + 3}" width="2.5" height="{h - 6}" rx="1" fill="#ffb3b0" opacity=".85"/>')


def shoulder(y_rear, y_front, x1=60, x2=540):
    return (f'<path d="M{x1} {y_rear} Q{(x1 + x2) // 2} {(y_rear + y_front) // 2 - 12} {x2} {y_front}" fill="none" stroke="#ffffff" stroke-width="2" opacity=".38"/>'
            f'<path d="M{x1 + 6} {y_rear + 44} Q{(x1 + x2) // 2} {(y_rear + y_front) // 2 + 30} {x2 - 6} {y_front + 38}" fill="none" stroke="#0b141a" stroke-width="3" opacity=".22"/>')


def sill(y=236, x1=36, x2=606):
    return f'<path d="M{x1} {y} L{x2} {y}" stroke="{DARK}" stroke-width="10"/>'


T = {}
T["hatch"] = tpl("hatch",
    "M56 242 L52 196 Q50 150 70 126 Q92 96 148 92 L322 92 Q352 93 372 114 L414 158 Q440 166 500 176 Q536 183 542 210 L544 242 Z",
    ["M104 150 Q110 112 150 103 L236 103 L236 150 Z", "M250 103 L322 103 Q342 104 354 118 L388 150 L250 150 Z"], 150,
    shoulder(170, 178) + seams([(243, 0), (372, 6)], 150, 228) + handles([(256, 166, 22), (322, 168, 20)]) + sill(),
    led_head(498, 177, 536, 186), led_tail(52, 150, 46),
    front_lip='<path d="M512 226 L541 226" stroke="#0b141a" stroke-width="7" opacity=".85"/>')

T["sedan"] = tpl("sedan",
    "M42 242 L40 196 Q42 180 62 175 L132 166 Q168 132 214 114 Q232 106 262 105 L362 105 Q392 107 412 126 L452 164 L550 178 Q586 184 595 214 L594 242 Z",
    ["M158 163 Q184 136 218 123 Q232 118 252 117 L252 163 Z", "M266 117 L362 117 Q382 118 394 132 L426 163 L266 163 Z"], 163,
    shoulder(176, 180) + seams([(259, 0), (400, 6)], 163, 228) + handles([(274, 176, 22), (338, 178, 20)]) + sill(),
    led_head(540, 179, 580, 190), led_tail(40, 178, 36),
    front_lip='<path d="M556 228 L588 228" stroke="#0b141a" stroke-width="7" opacity=".85"/>')

T["fastback"] = tpl("fastback",
    "M42 242 L40 202 Q42 182 62 176 L120 166 Q170 128 236 110 Q262 102 300 101 L350 101 Q384 103 410 124 L452 164 L548 178 Q584 184 594 214 L594 242 Z",
    ["M150 162 Q186 130 238 115 Q262 110 292 110 L292 162 Z", "M306 110 L350 110 Q372 112 388 128 L424 162 L306 162 Z"], 162,
    shoulder(176, 180) + seams([(299, 0), (398, 6)], 162, 228) + handles([(314, 176, 22), (352, 178, 20)]) + sill(),
    led_head(540, 180, 580, 190), '<rect x="40" y="176" width="9" height="30" rx="3" fill="#e2474a"/><rect x="41" y="179" width="3" height="24" rx="1" fill="#ffb3b0" opacity=".85"/>',
    front_lip='<path d="M556 228 L588 228" stroke="#0b141a" stroke-width="7" opacity=".85"/>')

T["wagon"] = tpl("wagon",
    "M44 242 L40 188 Q38 140 58 118 Q76 100 110 100 L378 100 Q402 102 418 122 L452 162 L548 176 Q584 184 592 214 L592 242 Z",
    ["M94 150 Q92 118 112 109 L186 109 L186 150 Z", "M198 109 L286 109 L286 150 L198 150 Z", "M298 109 L378 109 Q394 110 404 124 L432 150 L298 150 Z"], 150,
    shoulder(168, 176) + seams([(192, 0), (292, 0), (404, 5)], 150, 228) + handles([(202, 162, 20), (300, 164, 20)]) + sill(),
    led_head(538, 177, 578, 188), led_tail(40, 142, 52),
    extras='<path d="M96 96 L378 96" stroke="#c9d6dd" stroke-width="3" opacity=".9"/><path d="M130 96 L130 100 M340 96 L340 100" stroke="#c9d6dd" stroke-width="3"/>',
    front_lip='<path d="M554 228 L586 228" stroke="#0b141a" stroke-width="7" opacity=".85"/>')

T["suv"] = tpl("suv",
    "M46 244 L42 190 Q40 140 60 112 Q72 96 100 96 L372 96 Q398 98 414 118 L452 164 L546 178 Q586 186 594 218 L594 244 Z",
    ["M96 148 Q96 114 118 105 L190 105 L190 148 Z", "M202 105 L290 105 L290 148 L202 148 Z", "M302 105 L372 105 Q390 107 402 121 L432 148 L302 148 Z"], 148,
    shoulder(172, 180) + seams([(196, 0), (296, 0), (404, 5)], 148, 230) + handles([(206, 160, 22), (304, 162, 22)]) +
    '<path d="M30 226 L612 226 L612 250 L30 250 Z" fill="#1a262f" opacity=".92"/><path d="M30 226 L612 226" stroke="#ffffff" stroke-width="1.5" opacity=".18"/>',
    led_head(540, 179, 580, 190), led_tail(41, 150, 46),
    extras='<path d="M104 90 L368 90" stroke="#c9d6dd" stroke-width="3.5" opacity=".92"/><path d="M130 90 L130 97 M340 90 L340 97" stroke="#c9d6dd" stroke-width="3.5"/>',
    front_lip='<path d="M552 230 L590 230" stroke="#0b141a" stroke-width="8" opacity=".9"/>')

T["crossover"] = tpl("crossover",
    "M46 244 L42 192 Q44 166 68 158 L120 150 Q160 108 226 92 Q248 87 282 87 L366 87 Q396 89 414 112 L456 160 L546 176 Q586 184 594 218 L594 244 Z",
    ["M146 148 Q178 114 230 100 Q252 97 284 97 L284 148 Z", "M298 97 L366 97 Q386 99 398 113 L430 148 L298 148 Z"], 148,
    shoulder(170, 178) + seams([(291, 0), (406, 5)], 148, 230) + handles([(304, 160, 22), (350, 162, 22)]) +
    '<path d="M30 222 L612 222 L612 250 L30 250 Z" fill="#1a262f" opacity=".92"/><path d="M30 222 L612 222" stroke="#ffffff" stroke-width="1.5" opacity=".18"/>',
    led_head(540, 177, 580, 188), '<rect x="42" y="174" width="9" height="30" rx="3" fill="#e2474a"/><rect x="43" y="177" width="3" height="24" rx="1" fill="#ffb3b0" opacity=".85"/>',
    front_lip='<path d="M552 230 L590 230" stroke="#0b141a" stroke-width="8" opacity=".9"/>')

T["pickup"] = tpl("pickup",
    "M46 242 L46 152 L246 152 L256 146 Q262 98 300 92 L384 92 Q414 94 432 120 L458 162 L516 174 Q556 182 560 214 L562 242 Z",
    ["M272 146 L282 108 Q286 101 298 100 L336 100 L336 146 Z", "M348 100 L384 100 Q404 102 416 120 L440 146 L348 146 Z"], 146,
    shoulder(174, 178) + seams([(342, 0), (452, 6), (60, 0)], 150, 230) + handles([(298, 162, 20), (362, 164, 20)]) +
    '<path d="M46 152 L246 152" stroke="#ffffff" stroke-width="3" opacity=".4"/><path d="M30 218 L612 218 L612 250 L30 250 Z" fill="#1a262f" opacity=".85"/>',
    led_head(512, 176, 552, 186), led_tail(46, 160, 40),
    front_lip='<path d="M524 230 L560 230" stroke="#0b141a" stroke-width="8" opacity=".9"/>')

T["single_pickup"] = tpl("single_pickup",
    "M44 242 L44 154 L276 154 L286 148 Q294 100 330 94 L392 94 Q420 96 438 122 L462 162 L520 174 Q558 182 562 214 L564 242 Z",
    ["M302 146 L308 108 Q312 102 326 102 L392 102 Q408 104 420 120 L442 146 Z"], 146,
    shoulder(174, 178) + seams([(60, 0), (456, 6)], 150, 230) + handles([(330, 162, 22)]) +
    '<path d="M44 154 L276 154" stroke="#ffffff" stroke-width="3" opacity=".4"/>' + sill(),
    led_head(514, 176, 554, 186), led_tail(44, 160, 40),
    front_lip='<path d="M526 230 L562 230" stroke="#0b141a" stroke-width="8" opacity=".9"/>')

T["truck"] = tpl("truck",
    "M42 244 L42 84 Q42 72 56 72 L410 72 Q422 72 422 84 L422 106 Q422 94 438 94 L540 94 Q566 96 576 120 L598 180 Q604 198 604 216 L602 244 Z",
    ["M442 106 L538 106 Q552 108 558 122 L576 166 L442 166 Z"], 166,
    seams([(160, 0), (290, 0), (420, 0)], 80, 226).replace('stroke-width="1.6"', 'stroke-width="2"') +
    '<path d="M60 150 L410 150 M60 190 L410 190" stroke="#ffffff" stroke-width="1.6" opacity=".18" fill="none"/>' + sill(),
    led_head(570, 176, 600, 184), led_tail(42, 120, 80),
    front_lip='<path d="M570 232 L602 232" stroke="#0b141a" stroke-width="8" opacity=".9"/>')

T["sport"] = tpl("sport",
    "M38 242 L40 220 Q46 204 74 198 L152 188 Q202 162 256 148 Q272 143 296 142 L350 142 Q370 144 388 158 L428 188 L548 200 Q598 208 604 228 L604 242 Z",
    ["M224 184 Q256 158 292 151 L348 151 Q362 153 374 165 L404 184 L224 184 Z"], 184,
    shoulder(204, 204) + seams([(298, 0)], 184, 228) + handles([(306, 192, 22)]) +
    '<path d="M392 208 L444 208 L434 224 L392 224 Z" fill="#0b141a" opacity=".6"/>' + sill(),
    led_head(552, 201, 598, 211), led_tail(38, 198, 26),
    extras='<path d="M34 196 L28 180 L96 180 L104 196 Z" fill="#101c25" stroke="#263641" stroke-width="2"/><path d="M42 196 L40 206" stroke="#263641" stroke-width="3"/>',
    front_lip='<path d="M566 234 L602 234" stroke="#0b141a" stroke-width="8" opacity=".9"/>')

T["van"] = tpl("van",
    "M40 228 L42 108 Q43 84 68 84 L402 84 Q428 85 441 104 L486 158 L548 172 Q582 178 592 210 L590 242 L42 242 Z",
    ["M410 100 L430 100 Q439 101 446 111 L476 154 L410 154 Z"], 154,
    '<path d="M28 168 L615 168" fill="none" stroke="#eef5fa" stroke-width="2" opacity=".5"/>' + sill() +
    '<path d="M96 92 L96 224 M296 92 L296 224 M404 96 L404 224" stroke="#0b141a" stroke-width="1.6" opacity=".5" fill="none"/>'
    '<rect x="108" y="116" width="176" height="26" rx="4" fill="#18242f" opacity=".2"/>' + handles([(306, 160, 24), (376, 162, 22)]),
    led_head(554, 175, 586, 187), led_tail(40, 140, 48),
    front_lip='<path d="M554 232 L584 232" stroke="#0b141a" stroke-width="8" opacity=".9"/>')


def stripe_colours(cid):
    """Stripe colours from CarLook.STRIPES (the 3D showroom reads the same table)."""
    text = open(ROOT + "scripts/data/car_look.gd", encoding="utf-8").read()
    m = re.search(rf'"{cid}": \[(\[.*?\])\],', text)
    return re.findall(r'"(#[0-9a-fA-F]{6})"', m.group(1)) if m else []


def accent_for(cid, cls):
    """Small per-car details so cars of the same body do not look alike."""
    colours = stripe_colours(cid)
    if cid == "lavin_corso":
        return f'<path d="M30 192 Q280 186 615 201" fill="none" stroke="{colours[0]}" stroke-width="3" opacity=".9"/>'
    if cid == "marlen_vento":
        return (f'<path d="M30 205 L612 205" fill="none" stroke="{colours[0]}" stroke-width="6" opacity=".92"/>'
                f'<path d="M30 216 L612 216" fill="none" stroke="{colours[1]}" stroke-width="2.5"/>')
    if cls == "lux":
        return '<path d="M40 181 Q300 173 585 184" fill="none" stroke="#e6edf1" stroke-width="2.4" opacity=".85"/>'
    if cls == "ev":
        return '<path d="M44 200 Q300 192 580 204" fill="none" stroke="#59ddce" stroke-width="2.4" opacity=".9"/>'
    return ""


def wheel(cx, cy, r, spokes):
    out = [f'<circle cx="{cx}" cy="{cy}" r="{r}" fill="#14212b" stroke="#26333d" stroke-width="3"/>',
           f'<circle cx="{cx}" cy="{cy}" r="{r - 4}" fill="#1d2d39"/>',
           f'<circle cx="{cx}" cy="{cy}" r="{r - 7}" fill="url(#rim)"/>']
    reach = round((r - 7) * 0.9, 1)
    for k in range(spokes):
        a = 2 * math.pi * k / spokes
        out.append(f'<path d="M{cx} {cy} L{cx + reach * math.cos(a):.1f} {cy + reach * math.sin(a):.1f}" stroke="#eef3f6" stroke-width="4" stroke-linecap="round"/>')
    out.append(f'<circle cx="{cx}" cy="{cy}" r="7" fill="#455866"/>')
    return "".join(out)


def build(cid, cls, template, paint, spokes, wheels, roof_dark):
    t = T[template]
    flare = template in ("suv", "crossover", "pickup")
    (x1, x2, r) = wheels
    arch_r = r + 6
    arches = f'<path d="M{x1 - arch_r} 239 A{arch_r} {arch_r} 0 0 1 {x1 + arch_r} 239 M{x2 - arch_r} 239 A{arch_r} {arch_r} 0 0 1 {x2 + arch_r} 239" fill="#101b24"/>'
    flares = "".join(f'<path d="M{cx - arch_r - 5} 241 A{arch_r + 5} {arch_r + 5} 0 0 1 {cx + arch_r + 5} 241" fill="none" stroke="#1a262f" stroke-width="9" stroke-linecap="round"/>' for cx in (x1, x2)) if flare else ""
    roof = f'<rect x="0" y="0" width="640" height="{t["glass_bottom"]}" fill="#16222c" opacity=".94"/>' if roof_dark else ""
    glass = "".join(f'<path d="{g}" fill="url(#glass)" stroke="#0f1b24" stroke-width="3.5" stroke-linejoin="round"/>' for g in t["glass"])
    glass_hi = "".join(f'<path d="{g}" fill="none" stroke="#c7d5de" stroke-width="1.2" opacity=".55"/>' for g in t["glass"])
    return (HEAD +
            f' <defs><linearGradient id="paint" x2="0" y2="1"><stop stop-color="#edf5fa"/><stop offset=".18" stop-color="{paint}"/>'
            f'<stop offset=".74" stop-color="{paint}"/><stop offset="1" stop-color="#18242f"/></linearGradient>{GLASS}{RIM}'
            f'<clipPath id="body"><path d="{t["body"]}"/></clipPath></defs>\n'
            ' <ellipse cx="320" cy="277" rx="288" ry="10" fill="#112032" opacity=".16"/>\n'
            f' <path d="{t["body"]}" fill="url(#paint)" stroke="#263641" stroke-width="2.5" stroke-linejoin="round"/>\n'
            f' <g clip-path="url(#body)">{roof}</g>\n'
            f' {t["extras"]}\n {glass}{glass_hi}\n'
            f' <g clip-path="url(#body)">{t["details"]}{accent_for(cid, cls)}</g>\n'
            f' {flares}{arches}\n {t["head"]}{t["tail"]}{t["front_lip"]}\n '
            + wheel(x1, 235, r, spokes) + wheel(x2, 235, r, spokes) + "</svg>")


def load_fleet():
    db = open(ROOT + "scripts/data/car_db.gd", encoding="utf-8").read()
    look = {m.group(1): (m.group(2), int(m.group(3))) for m in re.finditer(r'"(\w+)": \["(#[0-9a-f]{6})", (\d+)\]', open(ROOT + "scripts/data/car_look.gd", encoding="utf-8").read())}
    fleet = []
    for m in re.finditer(r'^\t\{"id": "(\w+)"(.*)\},?\s*$', db, re.M):
        cid, rest = m.group(1), m.group(2)
        cls = re.search(r'"cls": "(\w+)"', rest).group(1)
        body = re.search(r'"body": "(\w+)"', rest).group(1)
        svg = open(f"{ART}{cid}.svg", encoding="utf-8").read()
        w = re.findall(r'<circle cx="(\d+)" cy="235" r="(\d+)" fill="#14212b"', svg)
        base = int(re.search(r'"base": (\d+)', rest).group(1))
        fleet.append(dict(id=cid, cls=cls, body=body, base=base, wheels=(int(w[0][0]), int(w[1][0]), int(w[0][1])), paint=look[cid][0], spokes=look[cid][1]))
    return fleet


def template_for(car):
    cid, cls, body = car["id"], car["cls"], car["body"]
    if cid == "brenor_duty":
        return "van"
    if cid == "lavin_station":
        return "wagon"
    if cid == "tivora_grano":
        return "single_pickup"
    if body == "sport" or cid == "auren_solis":
        return "sport"
    if body == "suv":
        return "crossover" if car["base"] >= 650000 else "suv"
    if body == "pickup":
        return "pickup"
    if body == "truck":
        return "truck"
    if cls in ("lux", "ev"):
        return "fastback"
    if car["wheels"][:2] == (145, 443):
        return "hatch"
    return "sedan"


def main():
    fleet = load_fleet()
    only = set(sys.argv[1:])
    for car in fleet:
        if only and car["id"] not in only:
            continue
        h = sum(ord(c) for c in car["id"])
        roof_dark = car["cls"] in ("lux", "ev") and h % 2 == 0 or car["cls"] in ("mid", "eco", "suv") and h % 3 == 0
        svg = build(car["id"], car["cls"], template_for(car), car["paint"], car["spokes"], car["wheels"], roof_dark)
        with open(f'{ART}{car["id"]}.svg', "w", newline="\n", encoding="utf-8") as handle:
            handle.write(svg)
    print("wrote", len([c for c in fleet if not only or c["id"] in only]), "cars")


if __name__ == "__main__":
    main()
