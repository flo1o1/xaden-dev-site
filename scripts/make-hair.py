#!/usr/bin/env python3
"""Draws the writhing shadows behind the hero logo (REQ-019): themes/xaden/layouts/_partials/hair.html and
themes/xaden/tailwind/hair.css. Dark tendrils like Medusa's hair leave the head, bend in an S and sway between
three shapes; the shapes are animated with the CSS property `d` (Chrome, Firefox), elsewhere they stand still.
Usage: scripts/make-hair.py   (deterministic; no dependencies; run it from the repository root)
"""
import math
import random

random.seed(11)
N = 19
R0 = 55                       # tendrils start behind the head


def path(angle, length, amp, sway, phase):
    """Two cubic segments out from the head; the S-curve bends by amp, the direction turns by sway (radians)."""
    a = angle + sway
    dx, dy = math.cos(a), math.sin(a)
    px, py = -dy, dx
    pts = []
    for t, s in ((0, 0), (0.18, amp * phase), (0.42, amp * 1.1 * phase), (0.5, 0), (0.62, -amp * 1.1 * phase),
                 (0.82, -amp * phase), (1.0, -amp * 0.4 * phase)):
        r = R0 + length * t
        pts.append((r * dx + s * px, r * dy + s * py))
    f = lambda p: f"{p[0]:.0f} {p[1]:.0f}"
    return f"M{f(pts[0])}C{f(pts[1])} {f(pts[2])} {f(pts[3])}C{f(pts[4])} {f(pts[5])} {f(pts[6])}"


def main():
    css, paths = [], []
    for i in range(N):
        angle = -math.pi / 2 + (i - (N - 1) / 2) * (2 * math.pi / N) * 0.95     # a fan around the head, open at the bottom
        down = math.sin(angle)                                                    # 1 straight down, -1 straight up
        length = random.uniform(115, 170) * (1 + 0.3 * down)                      # the ones toward the floor are longer, the upper ones shorter
        amp = random.uniform(24, 44)
        sway = random.uniform(0.16, 0.3)
        phase = random.choice((-1, 1))
        a = path(angle, length, amp, -sway, phase)
        b = path(angle, length, amp * 1.15, sway, -phase)
        c = path(angle, length, amp * 0.9, -sway * 0.4, phase)
        width = random.uniform(6, 11)
        dur = random.uniform(5.5, 9.5)
        delay = -random.uniform(0, dur)
        paths.append(f'<path class="hair h{i}" d="{c}" stroke-width="{width:.0f}"/>')
        css.append(f"@keyframes hair{i}{{0%{{d:path(\"{a}\")}}50%{{d:path(\"{b}\")}}100%{{d:path(\"{a}\")}}}}"
                   f".h{i}{{animation:hair{i} {dur:.1f}s ease-in-out {delay:.1f}s infinite}}")
    html = ('{{/* Written by scripts/make-hair.py. The tendrils behind the hero logo (REQ-019); hair.css animates them. */}}\n'
            '<svg class="hair-svg" viewBox="-300 -300 600 600" aria-hidden="true" focusable="false">'
            '<g fill="none" stroke="#050506" stroke-linecap="round" stroke-linejoin="round">'
            + "".join(paths) + '</g></svg>\n')
    open("themes/xaden/layouts/_partials/hair.html", "w").write(html)
    css.append("@media (prefers-reduced-motion: reduce){.hair{animation:none}}")
    open("themes/xaden/tailwind/hair.css", "w").write("/* written by scripts/make-hair.py */\n" + "\n".join(css) + "\n")


main()
