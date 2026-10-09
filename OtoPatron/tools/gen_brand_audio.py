"""OtoPatron logo/ikon ve özgün ses varlıklarını üretir (PIL + numpy). Tüm içerik özgündür."""
import math
import os
import wave

import numpy as np
from PIL import Image, ImageDraw, ImageFont

ROOT = os.path.join(os.path.dirname(__file__), "..")
ART = os.path.join(ROOT, "art")
AUDIO = os.path.join(ROOT, "audio")
FONT = os.path.join(ROOT, "fonts", "NotoSans.ttf")
ACCENT = (61, 123, 255)
ACCENT2 = (108, 182, 255)
GOLD = (243, 201, 105)
SILVER = (234, 240, 255)
NAVY = (15, 22, 38)
BG = (7, 11, 20)


def font(size, wght=800):
    f = ImageFont.truetype(FONT, size)
    try:
        f.set_variation_by_axes([wght, 100])  # Weight, Width
    except Exception:
        pass
    return f


def emblem(size):
    """Mavi halkalı rozet + gümüş araç silüeti + hız çizgileri + altın yıldız."""
    S = 4
    n = size * S
    im = Image.new("RGBA", (n, n), (0, 0, 0, 0))
    d = ImageDraw.Draw(im)
    # degrade halka: iç içe daireler
    for i in range(24):
        t = i / 23
        col = tuple(int(ACCENT[k] * (1 - t) + ACCENT2[k] * t) for k in range(3))
        r = .485 - i * .0016
        d.ellipse([n * (.5 - r), n * (.5 - r), n * (.5 + r), n * (.5 + r)], fill=col + (255,))
    d.ellipse([n * .075, n * .075, n * .925, n * .925], fill=NAVY + (255,))
    d.ellipse([n * .115, n * .115, n * .885, n * .885], outline=ACCENT2 + (90,), width=int(n * .006))
    # araç silüeti (gümüş)
    body = [(.22, .62), (.24, .54), (.35, .50), (.42, .40), (.49, .37), (.60, .37), (.68, .48), (.78, .52), (.82, .60), (.82, .64), (.22, .64)]
    d.polygon([(x * n, y * n) for x, y in body], fill=SILVER + (255,))
    d.polygon([(x * n, y * n) for x, y in [(.445, .50), (.49, .415), (.545, .415), (.545, .50)]], fill=NAVY + (255,))
    d.polygon([(x * n, y * n) for x, y in [(.56, .50), (.56, .415), (.60, .415), (.655, .50)]], fill=NAVY + (255,))
    for wx in (.34, .70):
        d.ellipse([(wx - .08) * n, (.64 - .08) * n, (wx + .08) * n, (.64 + .08) * n], fill=NAVY + (255,), outline=ACCENT2 + (255,), width=int(n * .016))
        d.ellipse([(wx - .03) * n, (.64 - .03) * n, (wx + .03) * n, (.64 + .03) * n], fill=ACCENT2 + (255,))
    # hız çizgileri
    for k, (y, ln) in enumerate([(.45, .12), (.52, .16), (.59, .10)]):
        d.line([(n * (.20 - ln), n * y), (n * .20, n * y)], fill=ACCENT2 + (200 - k * 40,), width=int(n * .012))
    # altın yıldız
    pts = []
    for k in range(10):
        r = n * (.06 if k % 2 == 0 else .026)
        ang = -math.pi / 2 + k * math.pi / 5
        pts.append((n * .5 + r * math.cos(ang), n * .25 + r * math.sin(ang)))
    d.polygon(pts, fill=GOLD + (255,))
    d.line([(n * .22, n * .73), (n * .78, n * .73)], fill=ACCENT + (220,), width=int(n * .012))
    return im.resize((size, size), Image.LANCZOS)


def spaced(d, xy_center, text, f, fill, spacing):
    widths = [d.textlength(ch, font=f) for ch in text]
    total = sum(widths) + spacing * (len(text) - 1)
    x = xy_center[0] - total / 2
    for ch, w in zip(text, widths):
        d.text((x, xy_center[1]), ch, font=f, fill=fill)
        x += w + spacing


def logo():
    W, H = 1024, 600
    im = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    em = emblem(360)
    im.alpha_composite(em, ((W - 360) // 2, 0))
    d = ImageDraw.Draw(im)
    f1, f2 = font(118, 850), font(38, 600)
    w_oto = d.textlength("OTO", font=f1)
    w_pat = d.textlength("PATRON", font=f1)
    x0 = (W - (w_oto + w_pat + 10)) / 2
    d.text((x0, 372), "OTO", font=f1, fill=SILVER + (255,))
    d.text((x0 + w_oto + 10, 372), "PATRON", font=f1, fill=ACCENT2 + (255,))
    d.line([(W / 2 - 150, 520), (W / 2 + 150, 520)], fill=ACCENT + (255,), width=3)
    spaced(d, (W / 2, 534), "GALERİ SİMÜLATÖRÜ", f2, SILVER + (230,), 10)
    im.save(os.path.join(ART, "logo.png"), optimize=True)


def icons():
    for size, name in ((512, "icon.png"), (1024, "icon_1024.png")):
        im = Image.new("RGBA", (size, size), BG + (255,))
        em = emblem(int(size * .86))
        im.alpha_composite(em, (int(size * .07), int(size * .07)))
        im.save(os.path.join(ROOT, name), optimize=True)
    fg = Image.new("RGBA", (432, 432), (0, 0, 0, 0))
    fg.alpha_composite(emblem(290), (71, 71))
    fg.save(os.path.join(ART, "icon_fg.png"), optimize=True)
    Image.new("RGBA", (432, 432), BG + (255,)).save(os.path.join(ART, "icon_bg.png"))


# ---------------- SES ----------------
SR = 22050


def write_wav(name, data):
    data = np.clip(data, -1, 1)
    pcm = (data * 32767 * .9).astype("<i2")
    with wave.open(os.path.join(AUDIO, name), "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(SR)
        w.writeframes(pcm.tobytes())


def tone(freq, dur, kind="sine", decay=6.0, vol=1.0):
    t = np.arange(int(SR * dur)) / SR
    if kind == "sine":
        s = np.sin(2 * np.pi * freq * t)
    elif kind == "soft":
        s = np.sin(2 * np.pi * freq * t) + .35 * np.sin(4 * np.pi * freq * t) + .12 * np.sin(6 * np.pi * freq * t)
    else:
        s = np.sign(np.sin(2 * np.pi * freq * t)) * .4
    env = np.exp(-decay * t) * np.minimum(1, t / .004)
    return s * env * vol


def seq(notes, gap):
    total = int(SR * (gap * (len(notes) - 1) + max(n[1] for n in notes) + .05))
    out = np.zeros(total)
    for i, (f, d, k, dec) in enumerate(notes):
        s = tone(f, d, k, dec)
        o = int(i * gap * SR)
        out[o:o + len(s)] += s[:total - o]
    return out / max(1, np.abs(out).max()) * .8


def sfx():
    write_wav("click.wav", tone(880, .06, "soft", 60) * .7)
    write_wav("coin.wav", seq([(1318, .25, "soft", 9), (1760, .4, "soft", 7)], .07))
    write_wav("success.wav", seq([(523, .3, "soft", 6), (659, .3, "soft", 6), (784, .3, "soft", 6), (1046, .6, "soft", 4)], .09))
    write_wav("error.wav", seq([(220, .18, "square", 10), (165, .3, "square", 8)], .12) * .6)
    write_wav("levelup.wav", seq([(392, .3, "soft", 5), (523, .3, "soft", 5), (659, .3, "soft", 5), (784, .3, "soft", 5), (1046, .9, "soft", 3)], .11))
    write_wav("notify.wav", seq([(988, .25, "soft", 8), (1318, .45, "soft", 6)], .1))
    # telefon zili: iki kısa darbe
    ring = np.zeros(int(SR * 1.4))
    for st in (0.0, 0.22):
        s = tone(440, .16, "soft", 3) + tone(480, .16, "soft", 3)
        o = int(st * SR)
        ring[o:o + len(s)] += s
    write_wav("ring.wav", ring / np.abs(ring).max() * .6)
    # kasa açılışı: yükselen süpürme + vuruş
    t = np.arange(int(SR * 1.1)) / SR
    sweep = np.sin(2 * np.pi * (200 * t + 500 * t ** 2)) * np.minimum(1, t * 6) * np.exp(-1.2 * t)
    hit = tone(110, .5, "soft", 7)
    out = sweep * .6
    o = int(.7 * SR)
    out[o:o + len(hit)] += hit[:len(out) - o] * .9
    write_wav("crate.wav", out / np.abs(out).max() * .85)


def music():
    """Lo-fi / chill-house tarzı 16 ölçülük kesintisiz döngü: davul, bas, Rhodes akorları, hafif pluck."""
    sr = 32000
    bpm = 88
    beat = 60.0 / bpm
    bars = 16
    n = int(sr * beat * 4 * bars)
    rng = np.random.default_rng(11)
    out = np.zeros(n)

    def add(buf, start_s, sig, gain=1.0):
        o = int(start_s * sr)
        for i0 in range(0, len(sig), 1):
            break
        idx = (np.arange(len(sig)) + o) % n
        np.add.at(buf, idx, sig * gain)

    def env(length, atk=.004, dec=3.0):
        t = np.arange(int(sr * length)) / sr
        return np.minimum(1, t / atk) * np.exp(-dec * t)

    def sine(f, length, dec=3.0, harm=((1, 1.0),), atk=.004):
        t = np.arange(int(sr * length)) / sr
        s = sum(a_ * np.sin(2 * np.pi * f * h * t) for h, a_ in harm)
        return s * env(length, atk, dec)

    def rhodes(f, length):
        t = np.arange(int(sr * length)) / sr
        trem = 1 + .12 * np.sin(2 * np.pi * 4.5 * t)
        s = (np.sin(2 * np.pi * f * t) + .5 * np.sin(2 * np.pi * f * 2.0 * t) * np.exp(-3 * t) + .18 * np.sin(2 * np.pi * f * 4.0 * t) * np.exp(-8 * t))
        s += .6 * np.sin(2 * np.pi * (f * 1.003) * t)
        return s * trem * env(length, .006, 1.8)

    def note(name):
        names = {"C": 0, "D": 2, "E": 4, "F": 5, "G": 7, "A": 9, "B": 11}
        o = int(name[-1])
        semi = names[name[0]] + (1 if "#" in name else 0) + 12 * (o + 1)
        return 440.0 * 2 ** ((semi - 69) / 12)

    prog = [
        (["A3", "C4", "E4", "G4", "B4"], "A2"),
        (["F3", "A3", "C4", "E4", "G4"], "F2"),
        (["E3", "G3", "B3", "D4"], "C2"),
        (["D3", "G3", "B3", "E4"], "G2"),
    ]
    bar_len = beat * 4
    kick_env = np.zeros(n)

    for bar in range(bars):
        t0 = bar * bar_len
        chord, root = prog[(bar // 2) % 4]
        # akor: 1. vuruş ve 2.5. vuruş (senkop)
        for off, g in ((0.0, .55), (beat * 2.5, .42)):
            for nm in chord:
                add(out, t0 + off, rhodes(note(nm), beat * 2.4), g * .22)
        # bas
        rf = note(root)
        for off, ln, g in ((0.0, beat * 1.4, .9), (beat * 2.5, beat * 0.9, .7), (beat * 3.25, beat * .6, .55)):
            add(out, t0 + off, sine(rf, ln, 3.5, ((1, 1.0), (2, .25))), g * .55)
        # davul
        for off in (0.0, beat * 2.0, beat * 2.75 if bar % 2 else beat * 1.75):
            tk = np.arange(int(sr * .3)) / sr
            kick = np.sin(2 * np.pi * (48 * tk + 90 * (1 - np.exp(-tk * 30)) / 30)) * np.exp(-9 * tk)
            add(out, t0 + off, kick, .9)
            o = int((t0 + off) * sr)
            kick_env[o:o + int(sr * .18)] = np.maximum(kick_env[o:o + int(sr * .18)], np.linspace(1, 0, int(sr * .18)))[:len(kick_env[o:o + int(sr * .18)])]
        for off in (beat, beat * 3):
            tn = np.arange(int(sr * .2)) / sr
            sn = (rng.standard_normal(len(tn)) * np.exp(-22 * tn)) * .6 + np.sin(2 * np.pi * 190 * tn) * np.exp(-25 * tn) * .4
            add(out, t0 + off, sn, .5)
        for k in range(8):
            sw = beat * .5 * (1.0 if k % 2 == 0 else 1.18) * (k // 2 * 2 + 0) / 1.0
            off = k * beat * .5 + (beat * .06 if k % 2 else 0)
            th = np.arange(int(sr * .06)) / sr
            hat = rng.standard_normal(len(th)) * np.exp(-60 * th)
            hat = np.diff(np.concatenate([[0], hat]))
            add(out, t0 + off, hat, .32 if k % 2 == 0 else .2)
        # hafif pluck melodi (ölçü başına 2-3 nota)
        scale = ["E5", "G5", "A5", "B5", "D5", "C5"]
        for k in range(3):
            if rng.random() < .65:
                nm = scale[rng.integers(0, len(scale))]
                add(out, t0 + beat * (rng.integers(0, 8) * .5), sine(note(nm), 1.0, 5.0, ((1, 1.0), (3, .12))), .09)
    # side-chain etkisi (kick sırasında diğerlerini hafif kıs)
    out *= (1 - .18 * kick_env)
    # vinil hışırtısı
    out += rng.standard_normal(n) * .004
    # sıcaklık için hafif alçak geçiren
    k = 5
    out = np.convolve(np.concatenate([out[-k:], out, out[:k]]), np.ones(k) / k, mode="same")[k:-k]
    out = np.tanh(out * 1.4)
    out = out / np.abs(out).max() * .6
    pcm = (out * 32767).astype("<i2")
    with wave.open(os.path.join(AUDIO, "ambient.wav"), "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(sr)
        w.writeframes(pcm.tobytes())


def chat_sfx():
    # gelen mesaj: yumuşak iki kısa "pop"
    write_wav("msg_in.wav", seq([(660, .09, "soft", 28), (880, .12, "soft", 24)], .06) * .7)
    # giden mesaj: kısa yükselen blip
    write_wav("msg_out.wav", seq([(520, .07, "soft", 30), (780, .09, "soft", 28)], .05) * .6)


if __name__ == "__main__":
    os.makedirs(AUDIO, exist_ok=True)
    logo()
    icons()
    sfx()
    chat_sfx()
    music()
    print("logo, ikon, ses üretildi")
