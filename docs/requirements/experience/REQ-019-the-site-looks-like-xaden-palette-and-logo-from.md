---
id: REQ-019
type: quality
epic: experience
priority: should
status: approved
updated: 2026-10-13
---

# The site looks like Xaden: palette and logo from the logo, a dark fantasy mood

## Quality goal

The site shows the Xaden logo and uses the logo's own colors (black, charcoal, steel, crimson, bronze) in a dark fantasy mood inspired by the Empyrean novels; the mood never costs readability.

## Acceptance criteria

- Given every page, then the header shows the logo and the browser tab shows a favicon made from it, all from the PNG logo
- Given the site colors, then each is taken from the logo (black #000000, charcoal #42414d, steel #7c7b89, crimson #93272d, bronze #a9714b in the logo `xaden.png`), with lighter tints only where contrast needs them
- Given the background pattern, then it is large dragon scales (pointed, with a center ridge), not small round fish scales, in rows that wave like a serpent instead of a straight grid, and it appears only in the hero, on the logo side, never behind running text
- Given the artwork (background, dividers, patterns), then it is drawn for this site, with no assets of the novels, and decorative motion stops under reduced-motion
- Given the home page, then a soft shadow of the logo sways behind it, and with a mouse or trackpad small shadows trail the pointer, behind all content; under reduced-motion the logo shadow stands still and the pointer shadows are off, and without JavaScript only the pointer shadows are missing
- Given any text, then REQ-013 contrast and keyboard rules still hold
