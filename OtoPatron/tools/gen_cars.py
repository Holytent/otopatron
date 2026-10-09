"""OtoPatron özgün araç illüstrasyonlarını üretir (PIL). Gerçek marka/model tasarımı içermez."""
import math
import os
from PIL import Image, ImageDraw, ImageFilter

OUT = os.path.join(os.path.dirname(__file__), "..", "art", "cars")
W, H, S = 640, 320, 3  # S: süper örnekleme

SHAPES = {
    "sedan": dict(body=[(40, 225), (48, 182), (130, 170), (195, 110), (228, 96), (400, 96), (452, 132), (560, 152), (602, 182), (606, 225)],
                  win=[[(208, 152), (234, 114), (298, 114), (298, 152)], [(310, 152), (310, 114), (392, 114), (428, 152)]], wr=46),
    "hatch": dict(body=[(60, 225), (62, 172), (100, 152), (175, 102), (212, 92), (372, 92), (452, 142), (560, 156), (592, 186), (594, 225)],
                  win=[[(190, 152), (216, 110), (290, 110), (290, 152)], [(302, 152), (302, 110), (372, 110), (424, 152)]], wr=46),
    "suv": dict(body=[(46, 232), (50, 152), (92, 142), (132, 100), (184, 82), (432, 82), (502, 130), (578, 150), (604, 186), (606, 232)],
                win=[[(160, 142), (190, 98), (290, 98), (290, 142)], [(302, 142), (302, 98), (424, 98), (480, 142)]], wr=54),
    "coupe": dict(body=[(40, 225), (56, 192), (150, 180), (240, 122), (304, 108), (384, 110), (474, 162), (584, 178), (608, 206), (608, 225)],
                  win=[[(250, 164), (290, 124), (350, 122), (350, 164)], [(360, 164), (360, 122), (396, 124), (450, 164)]], wr=46),
    "pickup": dict(body=[(40, 225), (40, 154), (255, 154), (262, 102), (292, 88), (382, 88), (432, 102), (472, 142), (572, 154), (606, 188), (606, 225)],
                   win=[[(272, 148), (296, 102), (352, 102), (352, 148)], [(362, 148), (362, 102), (398, 102), (440, 148)]], wr=50),
    "van": dict(body=[(40, 228), (40, 98), (62, 80), (380, 80), (452, 100), (522, 150), (586, 166), (606, 192), (606, 228)],
                win=[[(400, 150), (400, 100), (440, 108), (498, 150)], [(250, 150), (250, 100), (390, 100), (390, 150)]], wr=48),
}


def chaikin(pts, it=2):
    for _ in range(it):
        n = []
        for i in range(len(pts)):
            p, q = pts[i], pts[(i + 1) % len(pts)]
            n.append((0.75 * p[0] + 0.25 * q[0], 0.75 * p[1] + 0.25 * q[1]))
            n.append((0.25 * p[0] + 0.75 * q[0], 0.25 * p[1] + 0.75 * q[1]))
        pts = n
    return pts


def sc(pts):
    return [(x * S, y * S) for x, y in pts]


def shade(c, f):
    return tuple(max(0, min(255, int(v * f))) for v in c)


def render(cid, shape, color):
    sh = SHAPES[shape]
    im = Image.new("RGBA", (W * S, H * S), (0, 0, 0, 0))
    shadow = Image.new("RGBA", im.size, (0, 0, 0, 0))
    ImageDraw.Draw(shadow).ellipse([30 * S, 232 * S, 620 * S, 272 * S], fill=(0, 0, 0, 150))
    im.alpha_composite(shadow.filter(ImageFilter.GaussianBlur(10 * S)))
    d = ImageDraw.Draw(im)
    body = chaikin(sh["body"], 2)
    d.polygon(sc(body), fill=shade(color, 0.78) + (255,))
    # üst yarı daha açık renk (ışık yansıması)
    light = Image.new("RGBA", im.size, (0, 0, 0, 0))
    ImageDraw.Draw(light).polygon(sc(body), fill=color + (255,))
    mask = Image.new("L", im.size, 0)
    ImageDraw.Draw(mask).rectangle([0, 0, W * S, 196 * S], fill=255)
    a = light.split()[3]
    light.putalpha(Image.composite(a, Image.new("L", im.size, 0), mask))
    im.alpha_composite(light)
    d = ImageDraw.Draw(im)
    for w in sh["win"]:
        d.polygon(sc(chaikin(w, 1)), fill=(24, 32, 46, 255))
        hl = [(w[0][0] + 8, w[0][1]), (w[1][0] + 8, w[1][1]), (w[1][0] + 22, w[1][1]), (w[0][0] + 22, w[0][1])]
        d.polygon(sc(hl), fill=(90, 120, 160, 70))
    d.line(sc([(300, 150), (300, 226)]), fill=shade(color, 0.55) + (255,), width=2 * S)
    d.rectangle([40 * S, 214 * S, 606 * S, 226 * S], fill=shade(color, 0.5) + (255,))
    d.rounded_rectangle([566 * S, 170 * S, 598 * S, 186 * S], radius=6 * S, fill=(255, 236, 170, 255))
    d.rounded_rectangle([44 * S, 176 * S, 62 * S, 190 * S], radius=4 * S, fill=(220, 50, 60, 255))
    wr = sh["wr"]
    for cx in (150, 490):
        cy = 226
        d.ellipse([(cx - wr - 8) * S, (cy - wr - 8) * S, (cx + wr + 8) * S, (cy + wr + 8) * S], fill=(12, 14, 18, 255))
        d.ellipse([(cx - wr) * S, (cy - wr) * S, (cx + wr) * S, (cy + wr) * S], fill=(28, 30, 36, 255))
        r2 = wr * 0.62
        d.ellipse([(cx - r2) * S, (cy - r2) * S, (cx + r2) * S, (cy + r2) * S], fill=(176, 184, 196, 255))
        r3 = wr * 0.2
        d.ellipse([(cx - r3) * S, (cy - r3) * S, (cx + r3) * S, (cy + r3) * S], fill=(60, 66, 78, 255))
        for k in range(5):
            ang = k * 2 * math.pi / 5
            d.line([(cx * S, cy * S), ((cx + math.cos(ang) * r2 * 0.9) * S, (cy + math.sin(ang) * r2 * 0.9) * S)],
                   fill=(60, 66, 78, 255), width=3 * S)
    im = im.resize((W, H), Image.LANCZOS)
    im.save(os.path.join(OUT, cid + ".png"), optimize=True)


CARS = [('karya_pico', 'hatch', (70, 150, 170)), ('orvan_dot', 'hatch', (150, 190, 70)), ('aldora_kesa', 'hatch', (214, 170, 60)), ('aldora_brix', 'sedan', (120, 150, 190)), ('tivora_lune', 'hatch', (230, 120, 60)), ('veltra_orin', 'hatch', (200, 70, 60)), ('brenor_city', 'hatch', (180, 90, 150)), ('veltra_taro', 'sedan', (70, 110, 90)), ('tivora_grano', 'van', (236, 236, 238)), ('kordan_zeph', 'suv', (90, 120, 160)), ('kordan_mavo', 'sedan', (150, 150, 156)), ('sorvik_bora', 'pickup', (110, 120, 70)), ('lavin_station', 'sedan', (170, 120, 80)), ('marlen_sora', 'sedan', (60, 66, 90)), ('kordan_rally', 'suv', (200, 100, 40)), ('marlen_drift', 'coupe', (190, 40, 60)), ('sorvik_hale', 'suv', (60, 64, 70)), ('veltra_cabra', 'coupe', (90, 200, 120)), ('nyvo_ion', 'hatch', (60, 170, 160)), ('auren_vesta', 'sedan', (30, 34, 44)), ('dalmor_rex', 'pickup', (150, 60, 40)), ('marlen_gran', 'sedan', (110, 110, 130)), ('auren_kyro', 'suv', (176, 140, 70)), ('nyvo_arc', 'sedan', (230, 232, 236)), ('sorvik_ridge', 'suv', (80, 100, 80)), ('dalmor_volt', 'coupe', (40, 90, 190)), ('auren_solis', 'coupe', (240, 196, 80)), ('veltra_regalia', 'sedan', (36, 28, 46)), ('valtorre_gt', 'coupe', (200, 30, 30)), ('kordan_atlas', 'suv', (40, 50, 60)), ('aurelia_prestige', 'sedan', (200, 200, 210)), ('nyvo_halo', 'sedan', (30, 60, 120)), ('zephyra_one', 'coupe', (230, 180, 30)), ('imperion_royale', 'sedan', (20, 20, 24)), ('ravena_rova', 'suv', (173, 170, 140)), ('aldora_trail', 'suv', (140, 163, 169)), ('karya_bora', 'suv', (75, 107, 86)), ('orvan_trek', 'suv', (188, 112, 70)), ('nyvo_terra', 'suv', (219, 222, 219)), ('auren_stride', 'suv', (58, 78, 98)), ('dalmor_peak', 'suv', (117, 99, 76)), ('imperion_range', 'suv', (30, 43, 54))]

if __name__ == "__main__":
    os.makedirs(OUT, exist_ok=True)
    for cid, shape, col in CARS:
        render(cid, shape, col)
    print(len(CARS), "araç görseli üretildi")
