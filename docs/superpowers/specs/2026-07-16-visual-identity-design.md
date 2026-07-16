# Visual Identity Refresh — Early-Web Desktop Grammar

**Date:** 2026-07-16
**Branch:** `visual-identity`
**Status:** SHIPPED — reviewed and approved by Tim 2026-07-16

> **Sign-off:** Tim reviewed the finished work and approved all visuals. Every
> requirement here is considered met and satisfied except those explicitly
> called out in the plan's sign-off block
> (`docs/superpowers/plans/2026-07-16-visual-identity.md`): the chrome vertical
> budget (retired — the number was wrong, not the design), the Windows and
> swoon tests (never ran; superseded by real review in a real browser), the
> Motif scrollbar (still deferred), and the inert tag buttons (parked).
>
> This document records the thinking that got us there. The design outgrew it:
> option A was retired, B won, and light/dark shipped via `prefers-color-scheme`
> — none of which is described below.

## Problem

The blog's stated identity is "very early internet, coded by design." Its actual
visual layer is not that. It is stock Jekyll minima — the 2016 default theme —
with a green wash applied to the header and footer:

- Space Grotesk (2018 geometric grotesque) as the body face
- `border-radius: 6px` tag buttons, `3px` code blocks
- minima's default link blue `#2a7ae2`
- a flex-column body and a `#078607` green at 55% alpha over white

The *build* is period-correct in spirit — Jekyll, templates, no JS, no
dependencies. The *look* is a modern minimal theme wearing green. The gap
between those two is the thing being closed.

This is a correction, not a costume.

## Governing Constraints

These are absolute and override any aesthetic argument:

1. **No JavaScript.** Not for menus, not for windows, not for the throbber. If a
   feature needs JS, the feature is cut. CSS-only interactivity is permitted.
2. **No new dependencies.** The Gemfile does not change. No new fonts, no CSS
   frameworks, no build steps.
3. **Modern elements are allowed where Tim's subjective judgment says they are.**
   Not everything must be period-accurate. Space Grotesk and Fira Code stay.
   Authenticity serves the look; it does not govern it.

Explicitly *not* a constraint: page weight. We are not counting bytes.

## The Thesis

**The chrome is the operating system. The document is the author.**

A browser is the machine that renders someone else's document in its own
typeface. Mosaic's UI was Helvetica while its document area was Times — two
faces, because two systems were drawing them. That split is the structure of the
era, not a detail.

So:

| Layer | Speaks | Rationale |
| --- | --- | --- |
| Chrome | Helvetica (system stack, no webfont) | It is the 1994 workstation |
| Document body | Space Grotesk | It is Tim's voice, rendered inside the frame |
| Document code | Fira Code | Same reasoning — the document's own type |

Space Grotesk is itself a grotesque; Helvetica is a neo-grotesque. They are
cousins in the same genre, so the pairing reads as intentional rather than as a
collision. The anachronism becomes the joke: a 1994 browser displaying a
document from 2026 — which is literally what happens when someone loads the
site.

**The split is defined by the presence of chrome.** Option A has no chrome
layer, therefore everything in A is the document and everything in A is set in
Space Grotesk. Helvetica appears only in B, and only inside the toolbar. This
means A and B differ in two respects, not one — chrome, and the typographic
split that chrome brings with it. That is intentional: the two are the same
decision, and separating them would produce an incoherent A.

## Lineage

**NCSA Mosaic / Arena**, not a window manager, and explicitly not Windows or Mac.

Mosaic on X11 was built with **Motif widgets**, so choosing the browser inherits
Motif's grammar by construction. There is no conflict between "browser chrome"
and "Motif chisel" — they are the same choice.

### Differentiating from Win95 (the primary failure mode)

The `border: 2px outset` teal-desktop look is a meme (98.css, XP.css). Two
specific decisions keep us clear of it:

- **Palette.** CDE/Motif grey-blue (`#AEB2C3` family), not Win95's `#c0c0c0`
  neutral grey. This reads SGI/Sun workstation.
- **Bevel.** Motif uses a *single* 2px bevel with a computed light/dark pair.
  Win95 uses a *double* bevel (white outer, grey inner). Single bevel = Motif.
  Avoid CSS `outset`/`inset` keywords — browsers render them inconsistently and
  the result looks Win95.

### Era-correct deep cuts (what makes nerds swoon)

Recognition is the goal. These are the details that reward someone who ran FVWM
in 1997, and getting them *exactly* right is the difference between swoon and
cringe:

- `Document Title:` and `Document URL:` as labeled, sunken Motif text fields —
  Mosaic's real UI had both, stacked
- Browser-default link colors of the era: `#0000ee` unvisited, `#551a8b` visited
- The X11 root weave (the `xsetroot` grey stipple) behind the content column
- Motif scrollbar with arrows at both ends (`::-webkit-scrollbar`, CSS only)
- Content area white — the document, distinct from the furniture

## The Two Options

Both share the thesis, the palette, and the type split. They differ only in
chrome, which is what makes the comparison informative.

### A — Type and palette (`design-a`, :4001)

No chrome. The floor. Establishes how much comes from palette and edge treatment
alone.

- Space Grotesk body on a Mosaic-era palette; white content area, grey-blue
  furniture
- Every `border-radius` becomes a chisel; square corners throughout
- Era-correct link colors replace minima's blue
- Etched rules replace the green wash
- Tightened spacing

### B — Mosaic toolbar (`design-b`, :4002)

Everything in A, plus load-bearing browser chrome.

Structure, top to bottom:

```
┌──────────────────────────────────────┬───┐
│ [ Home ][ About ][ Projects ][ Feed ]│ ◐ │
├──────────────────────────────────────┴───┤
│ Document Title: <real page title>        │
│ Document URL:   <real page url>          │
├──────────────────────────────────────────┤
│ <document>                               │
```

**No File/Edit menubar.** It cannot work without JS, and a dead menu is worse
than no menu.

### The chrome honesty rule

Every piece of chrome must be load-bearing. Nothing ships as a prop.

- Toolbar buttons are the real site nav wearing Mosaic's clothes — real
  `<a href>`, one per `header_pages` entry
- `Document Title:` prints `{{ page.title }}`; `Document URL:` prints
  `{{ page.url }}` — telling the literal truth about where you are, a breadcrumb
  wearing a URL bar's clothes
- The throbber links home, as Mosaic's NCSA globe did

A toolbar button that is a real link is charming. A Back button that does
nothing is a bad website. Same pixels, opposite outcome. This rule is what keeps
the recursion — browser chrome inside a browser — on the right side of that
line.

## Success Criteria

Mechanically checkable:

1. Gemfile unchanged; zero JS added; no new font files. (A and B)
2. Body text contrast ≥ 4.5:1. The grey-on-grey era is easy to get wrong. (A and B)
3. No horizontal scroll at 375px. Chrome degrades rather than breaking. (A and B)
4. Valid HTML; `h-entry` microformats intact; `feed.xml` still builds. (A and B)
5. Chrome costs ≤ 15% of vertical space above the fold at 1280×800. (B only)
6. Zero inert controls — every button resolves to a real URL. (B only)

Judged:

7. **The Windows test.** A screenshot must read as X11/Mosaic, not Win95.
   Verified by a fresh reviewer with no exposure to this conversation, who
   therefore cannot be primed into the answer.
8. **The swoon test.** The deep cuts are precise, not approximate. A reviewer who
   knows the era should be able to name what they are looking at.

## Failure Criteria

Any of these means the direction is wrong, not merely unfinished:

- It reads as Windows 95. (The most likely failure.)
- It reads as a costume — theme-y, ironic, or a novelty skin over a blog.
- Chrome lies: a control implies an action it cannot perform.
- Long-form reading gets worse. The posts are the point.
- JS gets added for any reason.

## Verification

Progress is measured against the captured `:4000` baseline:

- Screenshots at 1280 and 375 across home, a post, and a page, for baseline / A / B
- Headless Chrome with `--virtual-time-budget=1000` (the live-reload websocket
  prevents normal load-settling; without a budget the capture hangs)
- Three servers run concurrently: `:4000` baseline, `:4001` A, `:4002` B, in
  peer worktrees at `../blog.lnx.cx-worktrees/`

## Open Details

Deferred to implementation, not blocking:

- **Where the Technitribe green survives.** It is the brand color but not
  era-correct as a link or chrome color. Candidate homes: the throbber, tag
  buttons, active states. May also be retired.
- **Motif scrollbar** is a stretch deep cut, not required for a verdict.
