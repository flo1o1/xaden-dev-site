#!/usr/bin/env python3
"""Draws themes/xaden/static/img/scales.svg: the scales of a dragon's body for the hero background (REQ-019).

The scales do not form a flat tile. A height field of a few muscles (shoulder, haunch, calf, belly) steers them:
they point backwards, toward the tail, follow the contours around a muscle, point down on the leg, grow on
the top of a muscle and shrink on its flanks, and are lit from the upper left.
Usage: scripts/make-scales.py > themes/xaden/static/img/scales.svg   (deterministic; no dependencies)
"""
import math
import random

W, H = 1200, 700
random.seed(7)

# muscles: centre x, y, spread x, y, height
MUSCLES = [(1010, 330, 170, 140, 1.0), (740, 250, 120, 100, 0.7), (880, 520, 70, 110, 0.8), (1080, 520, 120, 80, 0.5)]
BACK = math.radians(14)          # backwards = toward the tail: right, a little down
BASE = (math.cos(BACK), math.sin(BACK))
LIGHT = (0.5, 0.6)               # light from the upper left


def height(x, y):
    h = gx = gy = 0.0
    for cx, cy, sx, sy, a in MUSCLES:
        e = a * math.exp(-((x - cx) ** 2 / (2 * sx ** 2) + (y - cy) ** 2 / (2 * sy ** 2)))
        h += e
        gx += -e * (x - cx) / sx ** 2
        gy += -e * (y - cy) / sy ** 2
    return h, gx, gy


def leg(x, y):
    """1 on the leg, 0 elsewhere: a column below the haunch, leaning a little to the left."""
    lx = 900 - (y - 480) * 0.2
    ramp = min(1, max(0, (y - 420) / 100))
    return ramp * math.exp(-((x - lx) ** 2) / (2 * 62 ** 2))


def field(x, y):
    h, gx, gy = height(x, y)
    steep = math.hypot(gx, gy)
    alpha = min(1.0, steep * 130)               # how strongly the scales follow the contour
    dx, dy = BASE
    if steep > 1e-9:
        nx, ny = gx / steep, gy / steep
        dot = dx * nx + dy * ny
        dx, dy = dx - alpha * dot * nx, dy - alpha * dot * ny
    wl = leg(x, y)
    dx, dy = dx * (1 - wl) + 0.05 * wl, dy * (1 - wl) + 1.0 * wl
    n = math.hypot(dx, dy)
    return dx / n, dy / n, h, gx, gy, alpha


def size(h, alpha):
    length = 74 * (0.8 + 0.45 * min(1.0, h))
    return length, length * (0.95 - 0.25 * alpha)


# shade levels: fill, stroke
SHADES = [("#0a070d", "#1d1c21"), ("#0f0b13", "#26252b"), ("#150f19", "#2f2b33"), ("#1c141f", "#3a3138"), ("#27181e", "#53343a")]


def shade(h, gx, gy):
    lit = 0.45 + 0.3 * min(1.0, h) + 70 * (gx * LIGHT[0] + gy * LIGHT[1])
    return max(0, min(len(SHADES) - 1, int(lit * len(SHADES))))


def main():
    # dart throwing: the minimum distance follows the scale size, so the scales overlap like roof tiles everywhere
    scales = []
    for _ in range(60000):
        x, y = random.uniform(400, W + 40), random.uniform(-40, H + 40)
        dx, dy, h, gx, gy, alpha = field(x, y)
        length, width = size(h, alpha)
        if all((x - o[0]) ** 2 + (y - o[1]) ** 2 >= (0.5 * (length + o[4]) * 0.4) ** 2 for o in scales):
            scales.append((x, y, dx, dy, length, width, shade(h, gx, gy)))

    # tail-most first, so that every tip lies over the scales behind it
    scales.sort(key=lambda s: -(s[0] * s[2] + s[1] * s[3]))

    out = [f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {W} {H}" width="{W}" height="{H}">', "<defs>"]
    out.append('<g id="s"><path d="M0-.5C.5-.5.82-.15 1 0C.82.15.5.5 0 .5Z" vector-effect="non-scaling-stroke"/>'
               '<path d="M.3-.3Q.6-.2.9 0M.3.3Q.6.2.9 0" fill="none" stroke="#232227" stroke-width="1.2" vector-effect="non-scaling-stroke"/>'
               '<path d="M.28 0H.86" fill="none" stroke="#3d2026" stroke-width="1.8" stroke-linecap="round" vector-effect="non-scaling-stroke"/></g>')
    out.append("<style>" + "".join(f".c{i}{{fill:{f};stroke:{s};stroke-width:1.5}}" for i, (f, s) in enumerate(SHADES)) + "</style>")
    out.append("</defs>")
    for x, y, dx, dy, length, width, sh in scales:
        # matrix maps the unit scale (u along the flow, v across) to the page
        a, b, c, d = dx * length, dy * length, -dy * width, dx * width
        out.append(f'<use href="#s" class="c{sh}" transform="matrix({a:.0f} {b:.0f} {c:.0f} {d:.0f} {x:.0f} {y:.0f})"/>')
    out.append("</svg>")
    print("\n".join(out))


main()
