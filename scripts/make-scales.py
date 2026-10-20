#!/usr/bin/env python3
"""Draws themes/xaden/static/img/scales.svg: the large dragon scales of the hero background (REQ-019).

The scale is the one of the former tile (144 x 129.6, pointed, centre ridge). The rows do not run straight:
they wave like a serpent (a sine curve, the same for every row), and each scale is turned to stand across its row.
Usage: scripts/make-scales.py > themes/xaden/static/img/scales.svg   (deterministic; no dependencies)
"""
import math

W, H = 1400, 900
SW, SH = 144, 129.6          # width and length of a scale
ROW = SH / 2                 # rows overlap by half
AMP, WAVE = 46, 620          # height and length of the wave


def main():
    out = [f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {W} {H}" width="{W}" height="{H}">', "<defs>",
           '<g id="s" transform="translate(-72)">'
           '<path d="M0 0C0 64.8 50.4 106.3 72 129.6C93.6 106.3 144 64.8 144 0Z" fill="#0f0b13" stroke="#26252b" stroke-width="2"/>'
           '<path d="M28.8 54.4Q36 90.7 72 116.6M115.2 54.4Q108 90.7 72 116.6" fill="none" stroke="#232227" stroke-width="1.5" stroke-linecap="round"/>'
           '<path d="M72 49.2V108.9" fill="none" stroke="#3d2026" stroke-width="2" stroke-linecap="round"/></g>',
           "</defs>"]
    k = 2 * math.pi / WAVE
    rows = int((H + 2 * AMP) / ROW) + 3
    # the lowest row first: the tips of the upper rows lie over the rows below
    for r in range(rows, -3, -1):
        x = -SW + (SW / 2 if r % 2 else 0)
        while x < W + SW:
            y = r * ROW - AMP + AMP * math.sin(k * x)
            tilt = math.degrees(math.atan(AMP * k * math.cos(k * x)))
            out.append(f'<use href="#s" transform="translate({x:.0f} {y:.0f}) rotate({tilt:.0f})"/>')
            x += SW
    out.append("</svg>")
    print("\n".join(out))


main()
