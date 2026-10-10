#!/usr/bin/env python3
"""Writes the SVG art of the catalog expansion cars into OtoPatron/art/cars/.

The art follows the structure of the existing cars (960x480 file, 640x320 viewBox): paint gradient, glass,
body clip with details, wheel arches, lights and two wheels. Wheel centres match CarPortrait._wheels so the
dirt and damage overlays line up: the sedan and van use the default (147, 480, r42), the sport body (150, 483, r42).

Run from the repository root:  python3 tools/gen_car_svg.py   then   python3 tools/gen_car_look.py
"""
import math

ROOT = "OtoPatron/art/cars/"
HEAD = '<svg xmlns="http://www.w3.org/2000/svg" width="960" height="480" viewBox="0 0 640 320">\n'
GLASS = '<linearGradient id="glass" x2=".4" y2="1"><stop stop-color="#52758a"/><stop offset="1" stop-color="#112633"/></linearGradient>'
RIM = '<radialGradient id="rim"><stop stop-color="#dce3e9"/><stop offset=".8" stop-color="#8798a4"/><stop offset="1" stop-color="#293b49"/></radialGradient>'
BELT = '<path d="M28 181 Q280 175 615 190" fill="none" stroke="#eef5fa" stroke-width="2" opacity=".6"/>'
SILL = '<path d="M33 224 L608 224" stroke="#15242d" stroke-width="9"/>'
SEAMS = '<path d="M254 165 L254 218 M400 166 L403 217" stroke="#20323e" opacity=".55"/>'
HANDLES = '<rect x="270" y="175" width="24" height="4" rx="2" fill="#d8e3e9"/><rect x="377" y="177" width="24" height="4" rx="2" fill="#d8e3e9"/>'
ARCHES = '<path d="M99 239 A48 48 0 0 1 195 239 M432 239 A48 48 0 0 1 528 239" fill="#18242e"/>'
SPORT_ARCHES = '<path d="M102 239 A48 48 0 0 1 198 239 M435 239 A48 48 0 0 1 531 239" fill="#18242e"/>'
TAIL = '<rect x="51" y="184" width="12" height="19" rx="3" fill="#e2474a"/>'
HEAD_LIGHT = '<path d="M542 182 L576 195 L573 204 L543 197 Z" fill="#f4f6d6" stroke="#bdcbd2"/><path d="M554 215 L583 215" stroke="#172731" stroke-width="8"/>'


def wheel(cx, cy, spokes):
    parts = [f'<circle cx="{cx}" cy="{cy}" r="42" fill="#14212b" stroke="#26333d" stroke-width="3"/>',
             f'<circle cx="{cx}" cy="{cy}" r="32" fill="url(#rim)"/>']
    for k in range(spokes):
        a = 2 * math.pi * k / spokes
        parts.append(f'<path d="M{cx} {cy} L{cx + 28 * math.cos(a):.1f} {cy + 28 * math.sin(a):.1f}" stroke="#eef3f6" stroke-width="4"/>')
    parts.append(f'<circle cx="{cx}" cy="{cy}" r="7" fill="#455866"/>')
    return "".join(parts)


def car(paint, body, glass, details, arches, lights, wheels, spokes):
    return (HEAD +
            f' <defs><linearGradient id="paint" x2="0" y2="1"><stop stop-color="#edf5fa"/><stop offset=".18" stop-color="{paint}"/>'
            f'<stop offset=".74" stop-color="{paint}"/><stop offset="1" stop-color="#18242f"/></linearGradient>{GLASS}{RIM}'
            f'<clipPath id="body"><path d="{body}"/></clipPath></defs>\n'
            ' <ellipse cx="320" cy="275" rx="284" ry="10" fill="#112032" opacity=".13"/>\n'
            f' <path d="{body}" fill="url(#paint)" stroke="#263641" stroke-width="2.5" stroke-linejoin="round"/>\n'
            f' <path d="{glass}" fill="url(#glass)" stroke="#c7d5de" stroke-width="3"/>\n'
            f' <g clip-path="url(#body)">{details}</g>\n'
            f' {arches}\n {lights}\n '
            + "".join(wheel(cx, 235, spokes) for cx in wheels) + "</svg>")


# Lavin Corso: mid-size sedan on the existing sedan body, petrol paint, gold beltline accent.
SEDAN_BODY = "M40 225 L47 183 L135 166 L196 109 Q209 98 233 98 L365 98 Q389 99 404 117 L451 160 L551 175 Q580 181 592 211 L590 234 L42 234 Z"
SEDAN_GLASS = "M155 161 L215 114 L278 114 L278 161 Z M291 114 L367 114 Q380 115 391 130 L420 160 L291 160 Z"
CORSO = car("#3f7d8a", SEDAN_BODY, SEDAN_GLASS,
            BELT + '<path d="M30 190 Q280 184 615 199" fill="none" stroke="#d9b45f" stroke-width="3" opacity=".9"/>' + SILL + SEAMS + HANDLES,
            ARCHES, TAIL + HEAD_LIGHT, (147, 480), 7)

# Marlen Vento: sport coupe on the existing sport body, royal blue with a white and red stripe package.
SPORT_BODY = "M37 235 L43 204 L154 177 L240 127 Q252 118 282 118 L352 118 L432 165 L561 184 L603 213 L601 235 Z"
SPORT_GLASS = "M185 173 L256 133 L289 133 L289 172 Z M302 133 L348 133 L403 172 L302 172 Z"
VENTO = car("#3f5fa8", SPORT_BODY, SPORT_GLASS,
            BELT + '<path d="M30 203 L612 203" fill="none" stroke="#eef5fa" stroke-width="6" opacity=".92"/><path d="M30 214 L612 214" stroke="#e2474a" stroke-width="2.5"/>' + SILL + SEAMS + HANDLES,
            SPORT_ARCHES, TAIL + HEAD_LIGHT, (150, 483), 6)

# Brenor Duty: new panel-van silhouette (cab forward, tall cargo box) with the sedan wheelbase.
VAN_BODY = "M40 228 L42 108 Q43 84 68 84 L402 84 Q428 85 441 104 L486 158 L548 172 Q582 178 592 210 L590 234 L42 234 Z"
VAN_GLASS = "M410 100 L430 100 Q439 101 446 111 L476 154 L410 154 Z"
VAN_DETAILS = ('<path d="M28 168 L615 168" fill="none" stroke="#eef5fa" stroke-width="2" opacity=".6"/>' + SILL +
               '<path d="M96 92 L96 218 M296 92 L296 218 M404 96 L404 218" stroke="#20323e" opacity=".55"/>'
               '<rect x="108" y="116" width="176" height="26" rx="4" fill="#18242f" opacity=".2"/>'
               '<rect x="306" y="158" width="24" height="4" rx="2" fill="#d8e3e9"/><rect x="376" y="160" width="24" height="4" rx="2" fill="#d8e3e9"/>')
VAN_LIGHTS = ('<rect x="40" y="148" width="11" height="36" rx="3" fill="#e2474a"/>'
              '<path d="M552 174 L586 188 L583 198 L554 192 Z" fill="#f4f6d6" stroke="#bdcbd2"/>'
              '<path d="M554 214 L583 214" stroke="#172731" stroke-width="8"/>')
DUTY = car("#c9a53f", VAN_BODY, VAN_GLASS, VAN_DETAILS, ARCHES, VAN_LIGHTS, (147, 480), 5)

for name, svg in (("lavin_corso", CORSO), ("marlen_vento", VENTO), ("brenor_duty", DUTY)):
    with open(f"{ROOT}{name}.svg", "w", newline="\n", encoding="utf-8") as handle:
        handle.write(svg)
    print("wrote", name)
