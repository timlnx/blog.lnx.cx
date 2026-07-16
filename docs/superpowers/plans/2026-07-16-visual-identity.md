> ## SIGN-OFF — 2026-07-16
>
> **Tim reviewed the finished work and approved it. All tasks in this plan are
> to be considered complete and satisfied except where explicitly called out
> below.** This plan was followed for its first few tasks and then abandoned
> as ceremony — the work continued directly, and the design moved well past
> what is written here. Read this document as a record of intent, not as a
> description of what shipped.
>
> **Explicitly called out — not done, by decision:**
>
> - **Chrome vertical budget (15% of the fold).** Measured at 22.2% (document
>   starts at 178px of 800). Tim's executive decision: approved as-is. The 15%
>   figure was invented at spec time, before the title bar and bookmarks bar
>   existed; the number was wrong, not the design. Criterion retired.
> - **The Windows test and the swoon test.** Never ran — both wanted a fresh
>   unprimed reviewer and none was dispatched. Superseded by Tim reviewing the
>   real thing in a real browser across a whole session.
> - **Motif scrollbar.** Deliberately deferred at spec time. Still deferred.
> - **Tag buttons are inert `<button>` elements.** The one surviving violation
>   of the zero-inert-controls rule. Parked by Tim for a future session.
>
> **What actually shipped**, versus the A/B this plan describes: option A was
> retired, option B won and kept going. The final design is a Mosaic window on
> an X11 root weave — WM title bar carrying the masthead, load-bearing browser
> chrome with the nav as a bookmarks bar under an etched rule, the document as
> a sunken well, and the footer as a second window on the desktop. The palette
> ships light (CDE grey-blue) and dark (Motif) from CSS custom properties via
> `prefers-color-scheme`. The throbber is Carl.

# Visual Identity — Early-Web Desktop Grammar Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build two comparable visual options for blog.lnx.cx — A (Mosaic-era type and palette, no chrome) and B (A plus a load-bearing Mosaic toolbar) — so Tim can pick by eye at :4001 vs :4002.

**Architecture:** A new `_sass/minima/_motif.scss` partial holds the palette primitives and the Motif bevel mixins; the existing `minima.scss` variables and the `_base` / `_layout` partials are reworked to consume them. Option A is built entirely on the `design-a` branch. Option B is `git merge design-a` into `design-b`, plus one new include (`_includes/chrome.html`) and one new partial (`_sass/minima/_chrome.scss`). No file exceeds one clear responsibility.

**Tech Stack:** Jekyll 4, Sass (dart-sass via jekyll-sass-converter), Liquid, headless Chrome for verification. No JS. No new gems.

## Global Constraints

Copied verbatim from `docs/superpowers/specs/2026-07-16-visual-identity-design.md`:

- **No JavaScript.** Not for menus, not for windows, not for the throbber. If a feature needs JS, the feature is cut. CSS-only interactivity is permitted.
- **No new dependencies.** The Gemfile does not change. No new fonts, no CSS frameworks, no build steps.
- **Modern elements are allowed where Tim's subjective judgment says they are.** Space Grotesk and Fira Code stay.
- **Page weight is explicitly not a constraint.** Do not optimize for bytes.
- **Single 2px bevels only.** Never CSS `outset`/`inset` keywords, never a Win95 double bevel (white outer + grey inner).
- **Chrome must be load-bearing.** Zero inert controls. Every button resolves to a real URL.
- Body text contrast ≥ 4.5:1. No horizontal scroll at 375px. `h-entry` microformats and `feed.xml` must survive.

## Environment (already set up — do not recreate)

| Tree | Branch | URL |
| --- | --- | --- |
| `/Users/tbielawa/Projects/blog.lnx.cx` | `visual-identity` | :4000 (baseline) |
| `/Users/tbielawa/Projects/blog.lnx.cx-worktrees/design-a` | `design-a` | :4001 |
| `/Users/tbielawa/Projects/blog.lnx.cx-worktrees/design-b` | `design-b` | :4002 |

All three servers are already running with `-l` (live reload) and rebuild on save.
Scratchpad (all captures land here):
`/private/tmp/claude-501/-Users-tbielawa-Projects-blog-lnx-cx/6aa3ee9a-b113-4758-b966-e0382d948057/scratchpad`

Baseline screenshot already captured: `<scratchpad>/baseline-home.png`.

Server logs (for Sass errors):
- :4001 → `<tasks>/be6lgtt8f.output`
- :4002 → `<tasks>/b8odzzlbp.output`
- where `<tasks>` is `/private/tmp/claude-501/-Users-tbielawa-Projects-blog-lnx-cx/6aa3ee9a-b113-4758-b966-e0382d948057/tasks`

**Screenshot command** (the `--virtual-time-budget` is required — the live-reload
websocket keeps the page from settling and the capture hangs without it):

```bash
timeout 10 /Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome \
  --headless=new --disable-gpu --no-sandbox --virtual-time-budget=1000 \
  --screenshot=OUT.png --window-size=1280,1500 --hide-scrollbars \
  http://127.0.0.1:PORT/
```

---

## File Structure

| File | Responsibility | Task |
| --- | --- | --- |
| `_sass/minima/_motif.scss` | **Create.** Palette primitives + bevel mixins + root weave mixin. The single source of era grammar. | 1 |
| `_sass/minima.scss` | **Modify.** Variable definitions; add `minima/motif` to the import list *first* so mixins exist for later partials. | 1 |
| `_sass/minima/_base.scss` | **Modify.** Links, code, tables, blockquote, document area. De-round. | 2 |
| `_sass/minima/_layout.scss` | **Modify.** Header, nav, footer, post list, tag buttons. De-round. | 3 |
| `_includes/chrome.html` | **Create (B only).** The Mosaic toolbar markup. Liquid-driven, load-bearing. | 7 |
| `_sass/minima/_chrome.scss` | **Create (B only).** Toolbar styling. | 7 |
| `_layouts/default.html` | **Modify (B only).** Swap the `header.html` include for `chrome.html` — in B the chrome *replaces* the header rather than stacking above it. | 7 |

---

### Task 1: Motif foundation — palette and bevel mixins

Establishes the era grammar every later task consumes. Nothing renders differently
yet except the palette variables; this task is the interface, not the paint.

**Files:**
- Create: `_sass/minima/_motif.scss`
- Modify: `_sass/minima.scss` (lines 13-24 variables, lines 52-56 imports)
- Branch: `design-a`, worktree `/Users/tbielawa/Projects/blog.lnx.cx-worktrees/design-a`

**Interfaces:**
- Consumes: nothing (first task)
- Produces, relied on by Tasks 2, 3, 4, 7 — exact names:
  - Variables: `$motif-face`, `$motif-light`, `$motif-dark`, `$motif-shadow`, `$document-bg`, `$link-color`, `$link-visited`, `$link-active`, `$chrome-font-family`
  - Mixins: `bevel-raised($width: 2px)`, `bevel-sunken($width: 2px)`, `root-weave`

- [ ] **Step 1: Understand what this task does and does not change**

This task adds new variables and mixins, and it also changes the values of some
existing variables. Those two halves behave differently, and conflating them
will make you think the task failed when it succeeded:

- **The new variables emit nothing yet.** Sass produces no CSS for a variable
  nothing consumes. `$link-color` (`#0000ee`) will still be absent from compiled
  output when this task is done. Task 2 is what makes it appear. Correct, not a
  failure.
- **The changed existing values render immediately.** `$text-color`,
  `$background-color`, and `$grey-color` are consumed throughout `_base.scss`
  and `_layout.scss`, so retuning them moves the page right away. Expect the
  compiled CSS to differ from baseline.

One consequence worth knowing so it does not alarm you: `$green-color` loses its
alpha channel here (`#0786078b` → `#078607`). The header and footer use it as a
background, so they go from translucent light green to **solid dark green** for
the duration of Tasks 1-2. This looks worse than what you started with. It is
transient — Task 3 replaces those backgrounds with the Motif face — and it is
the accepted cost of retiring the green wash in one move rather than two.

Record the starting state so Task 2 has something to move against:

```bash
curl -s http://127.0.0.1:4001/assets/main.css | grep -c "#0000ee"
```

Expected now: `0`. Expected still `0` at the end of this task. The gate for this
task is Step 4: does it compile.

- [ ] **Step 2: Create the Motif partial**

Create `_sass/minima/_motif.scss`:

```scss
// Motif/CDE grammar. NCSA Mosaic on X11 was a Motif app, so the browser
// lineage and the widget lineage are the same choice.
//
// Palette is CDE grey-blue, NOT Win95 neutral #c0c0c0. This is the primary
// defense against the site reading as Windows.
$motif-face:   #aeb2c3;  // widget face
$motif-light:  #d4d7e0;  // top/left bevel
$motif-dark:   #6d7183;  // bottom/right bevel
$motif-shadow: #4a4d5a;  // deep etch / keylines

$document-bg:  #ffffff;  // the document area — distinct from the furniture

// The literal browser defaults of the era.
$link-color:   #0000ee;
$link-visited: #551a8b;
$link-active:  #ee0000;

// The chrome speaks Helvetica; it is the 1994 workstation. No webfont.
$chrome-font-family: Helvetica, "Nimbus Sans", "Liberation Sans", Arial, sans-serif;

// Motif's chisel is a SINGLE 2px bevel with a computed light/dark pair.
// Win95 uses a DOUBLE bevel (white outer, grey inner) — that difference is
// the whole tell. Never use the CSS outset/inset keywords: browsers render
// them inconsistently and the result reads Win95.
@mixin bevel-raised($width: 2px) {
  border-style: solid;
  border-width: $width;
  border-color: $motif-light $motif-dark $motif-dark $motif-light;
}

@mixin bevel-sunken($width: 2px) {
  border-style: solid;
  border-width: $width;
  border-color: $motif-dark $motif-light $motif-light $motif-dark;
}

// The X11 root weave — the 50% stipple `xsetroot -def` left behind.
// A 1px checkerboard at 2px tile.
@mixin root-weave {
  background-color: #5b6070;
  background-image: repeating-conic-gradient(#6b7183 0% 25%, #545967 0% 50%);
  background-size: 2px 2px;
}
```

- [ ] **Step 3: Wire it into the variable file**

In `_sass/minima.scss`, replace lines 13-24 (the `$text-color` through
`$green-color-darker` block) with:

```scss
$text-color:       #000000 !default;
$background-color: #ffffff !default;

// Transitional: _base.scss still references this until Task 2 replaces the
// links block with the era palette ($link-color / $link-visited). Task 2
// deletes this line. Keeping its original value means Task 1 changes no
// rendering, which is the point of Task 1.
$brand-color:      #2a7ae2 !default;

// Technitribe green survives as an accent only — it is the brand, but it is
// not era-correct as a link or chrome color. Candidate home: the throbber.
$green-color:      #078607 !default;
$green-color-light: lighten($green-color, 15%) !default;
$green-color-dark:  darken($green-color, 25%) !default;
$green-color-darker: darken($green-color, 35%) !default;

// Retained: _layout.scss and _base.scss still reference these.
$grey-color:       #6d7183 !default;
$grey-color-light: lighten($grey-color, 25%) !default;
$grey-color-dark:  darken($grey-color, 15%) !default;
```

Then replace the import block at the bottom (lines 52-56). **`motif` must come
first** — the later partials call its mixins, and Sass resolves in order:

```scss
@import
  "minima/motif",
  "minima/base",
  "minima/layout",
  "minima/syntax-highlighting"
;
```

- [ ] **Step 4: Assert the build is clean — this is the real gate**

```bash
sleep 3
curl -s http://127.0.0.1:4001/assets/main.css | grep -c "#0000ee"
```

Expected: `0` — **still zero**, because nothing consumes `$link-color` yet, per
Step 1.

The gate is that it compiles:

```bash
curl -s -o /dev/null -w '%{http_code}\n' http://127.0.0.1:4001/assets/main.css
tail -5 /private/tmp/claude-501/-Users-tbielawa-Projects-blog-lnx-cx/6aa3ee9a-b113-4758-b966-e0382d948057/tasks/be6lgtt8f.output
```

Expected: `200`, and no `Error:` / `SassError` in the log. A Sass syntax error
returns 500 and prints to the server log.

- [ ] **Step 5: Commit**

```bash
cd /Users/tbielawa/Projects/blog.lnx.cx-worktrees/design-a
git add _sass/minima/_motif.scss _sass/minima.scss
git commit -m "Add Motif grammar: CDE palette, single-bevel mixins, root weave

Mosaic on X11 was a Motif app, so the browser lineage and the widget
lineage are one choice. Palette is CDE grey-blue rather than Win95
neutral grey, and bevels are single 2px rather than Win95's double.
Those two decisions are what keep this from reading as Windows."
```

---

### Task 2: Base — links, code, and de-rounding

**Files:**
- Modify: `_sass/minima/_base.scss` (links 106-126, blockquote 132-143, code 150-171, tables 232-255)
- Branch: `design-a`

**Interfaces:**
- Consumes: `$link-color`, `$link-visited`, `$link-active`, `$motif-face`, `$motif-light`, `$motif-dark`, `$document-bg`, `bevel-sunken()` from Task 1
- Produces: nothing new for later tasks

- [ ] **Step 1: Write the assertion — round corners currently exist**

```bash
curl -s http://127.0.0.1:4001/assets/main.css | grep -c "border-radius"
```

Expected: `2` or more (code blocks at 3px, tag buttons at 6px, nav at 5px). This
must reach `0` across Tasks 2 and 3.

- [ ] **Step 2: Replace the links block**

In `_sass/minima/_base.scss`, replace lines 106-126 with:

```scss
/**
 * Links — the literal browser defaults of 1994.
 */
a {
  color: $link-color;
  text-decoration: underline;

  &:visited {
    color: $link-visited;
  }

  &:active {
    color: $link-active;
  }

  &:hover {
    color: $link-color;
    text-decoration: underline;
  }

  .social-media-list &:hover {
    text-decoration: none;

    .username {
      text-decoration: underline;
    }
  }
}
```

Note: era links are **underlined by default**. minima removed the underline; we
put it back. That is the single loudest era signal on the page.

- [ ] **Step 3: Replace the code block styling**

Replace lines 150-171 with:

```scss
/**
 * Code — sunken Motif well, square corners.
 */
pre,
code {
  @include relative-font-size(0.9375);
  @include bevel-sunken(2px);
  background-color: #f4f4f4;
}

code {
  padding: 1px 5px;
}

pre {
  padding: 8px 12px;
  overflow-x: auto;

  > code {
    border: 0;
    padding-right: 0;
    padding-left: 0;
  }
}
```

- [ ] **Step 4: Replace the blockquote block**

Replace lines 132-143 with:

```scss
blockquote {
  color: #333;
  border-left: 4px solid $motif-dark;
  padding-left: math.div($spacing-unit, 2);
  @include relative-font-size(1);
  letter-spacing: 0;
  font-style: italic;

  > :last-child {
    margin-bottom: 0;
  }
}
```

The `letter-spacing: -1px` is dropped — it was fighting Space Grotesk's metrics.

- [ ] **Step 5: Replace the table block**

Replace lines 232-255 with:

```scss
table {
  margin-bottom: $spacing-unit;
  width: 100%;
  text-align: $table-text-align;
  color: $text-color;
  border-collapse: collapse;
  @include bevel-sunken(2px);

  tr {
    &:nth-child(even) {
      background-color: #eef0f4;
    }
  }
  th, td {
    padding: math.div($spacing-unit, 3) math.div($spacing-unit, 2);
  }
  th {
    background-color: $motif-face;
    @include bevel-raised(2px);
  }
  td {
    border: 1px solid $motif-dark;
  }
}
```

- [ ] **Step 6: Verify build clean and capture**

```bash
sleep 3
curl -s -o /dev/null -w '%{http_code}\n' http://127.0.0.1:4001/assets/main.css
curl -s http://127.0.0.1:4001/assets/main.css | grep -c "#0000ee"
```

Expected: `200`, and `#0000ee` count ≥ `1` (links now consume it).

- [ ] **Step 7: Retire the transitional `$brand-color`**

Task 1 kept `$brand-color` alive only because the links block you just replaced
was still using it. Nothing references it now, so it must not linger as a dead
variable. In `_sass/minima.scss`, delete the comment and the line:

```scss
// Transitional: _base.scss still references this until Task 2 replaces the
// links block with the era palette ($link-color / $link-visited). Task 2
// deletes this line. Keeping its original value means Task 1 changes no
// rendering, which is the point of Task 1.
$brand-color:      #2a7ae2 !default;
```

Confirm nothing still needs it before deleting — expect no output:

```bash
cd /Users/tbielawa/Projects/blog.lnx.cx-worktrees/design-a
grep -rF -- '$brand-color' _sass/ assets/
```

Then confirm the build survives the removal:

```bash
sleep 3
curl -s -o /dev/null -w '%{http_code}\n' http://127.0.0.1:4001/assets/main.css
```

Expected: `200`. A `500` means something still referenced it — restore the line
and report rather than hunting.

- [ ] **Step 8: Commit**

```bash
cd /Users/tbielawa/Projects/blog.lnx.cx-worktrees/design-a
git add _sass/minima/_base.scss _sass/minima.scss
git commit -m "Base: era link colors, sunken code wells, square corners

Links go back to underlined #0000ee / #551a8b visited - the literal
browser defaults of the era, and the loudest single signal available.
Code and tables become sunken Motif wells."
```

---

### Task 3: Layout — header, nav, footer, tag buttons

Kills the green wash and the last of the rounding.

**Files:**
- Modify: `_sass/minima/_layout.scss` (tag button 6-17, header 31-53, nav 55-129, footer 136-140, post-meta 229-242)
- Branch: `design-a`

**Interfaces:**
- Consumes: `$motif-face`, `$motif-light`, `$motif-dark`, `$motif-shadow`, `bevel-raised()`, `bevel-sunken()` from Task 1
- Produces: nothing new for later tasks

- [ ] **Step 1: Replace the tag button**

Replace lines 6-17 with:

```scss
.tag-button {
  background-color: $motif-face;
  @include bevel-raised(2px);
  color: $text-color;
  padding: 2px 8px;
  text-align: center;
  text-decoration: none;
  display: inline-block;
  margin: 3px 2px;
  font-size: 12px;
  font-family: $chrome-font-family;
}
```

Tag buttons are the one place chrome font leaks into A — they are widgets, not
prose. `border-radius: 6px` is gone.

- [ ] **Step 2: Replace the site header**

Replace lines 31-53 with:

```scss
/**
 * Site header — a document header, not browser chrome. Option A has no
 * chrome layer, so this stays in the document's own face.
 */
.site-header {
  border-top: 0;
  border-bottom: 2px solid $motif-shadow;
  background-color: $motif-face;
  min-height: $spacing-unit * 1.865;
  position: relative;
}

.site-title {
  @include relative-font-size(1.625);
  font-weight: 500;
  line-height: $base-line-height * $base-font-size * 2.25;
  letter-spacing: 0;
  margin-bottom: 0;
  float: left;
  text-decoration: none;

  &,
  &:visited {
    color: $text-color;
  }
}
```

- [ ] **Step 3: De-round the mobile nav**

In the `.site-nav` block, inside the `@include media-query($on-palm)` section,
replace these two lines:

```scss
    border: 1px solid $grey-color-light;
    border-radius: 5px;
```

with:

```scss
    @include bevel-raised(2px);
```

Also in `.site-nav`, set the link color so nav is legible on the grey-blue face —
replace the `.page-link` color line `color: $text-color;` with:

```scss
    color: $text-color;
    text-decoration: none;
```

- [ ] **Step 4: Replace the footer**

Replace lines 136-140 with:

```scss
.site-footer {
  border-top: 2px solid $motif-shadow;
  padding: $spacing-unit 0;
  background-color: $motif-face;
}
```

And replace the `.footer-col-wrapper` color (line ~155) `color: $green-color-darker;`
with:

```scss
  color: $text-color;
```

- [ ] **Step 5: Fix post-meta contrast**

Replace lines 229-237 with:

```scss
.post-meta {
  font-size: $small-font-size;
  color: #4a4d5a;
}

.post-meta-updated {
  font-size: $small-font-size;
  color: #4a4d5a;
}
```

The old `$grey-color: #729fcf` on white was ~2.6:1 — a real contrast failure that
predates this work. `#4a4d5a` on white is ~8.6:1.

- [ ] **Step 6: Assert all rounding is gone**

```bash
sleep 3
curl -s http://127.0.0.1:4001/assets/main.css | grep -c "border-radius"
```

Expected: `0`. If non-zero, run
`curl -s http://127.0.0.1:4001/assets/main.css | grep -n "border-radius"`
and remove the stragglers.

- [ ] **Step 7: Commit**

```bash
cd /Users/tbielawa/Projects/blog.lnx.cx-worktrees/design-a
git add _sass/minima/_layout.scss
git commit -m "Layout: chisel the furniture, drop the green wash

Header and footer take the CDE face with a hard shadow keyline. Tag
buttons become raised Motif widgets. Also fixes a pre-existing contrast
failure - post-meta was #729fcf on white, about 2.6:1."
```

---

### Task 4: Root weave and the document column

Separates furniture from document — the move that makes it read as a browser
rendering a page rather than a page with a grey hat.

**Files:**
- Modify: `_sass/minima/_base.scss` (body ~17-30, wrapper ~178-193)
- Branch: `design-a`

**Interfaces:**
- Consumes: `root-weave`, `$document-bg`, `$motif-shadow` from Task 1
- Produces: nothing new for later tasks

- [ ] **Step 1: Apply the weave to the body**

In `_sass/minima/_base.scss`, in the `body` rule, replace
`background-color: $background-color;` with:

```scss
  @include root-weave;
```

- [ ] **Step 2: Make the content column a white document**

Replace the `.page-content` responsibility by giving the wrapper inside main a
document surface. In `_sass/minima/_base.scss`, after the `.wrapper` rule, add:

```scss
/**
 * The document surface. The weave is the root window; this is the page
 * being rendered on top of it.
 */
.page-content > .wrapper {
  background-color: $document-bg;
  border: 2px solid $motif-shadow;
  padding-top: $spacing-unit;
  padding-bottom: $spacing-unit;
}
```

- [ ] **Step 3: Verify no horizontal overflow at 375px**

```bash
sleep 3
timeout 10 /Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome \
  --headless=new --disable-gpu --no-sandbox --virtual-time-budget=1000 \
  --screenshot=/tmp/a-375.png --window-size=375,800 --hide-scrollbars \
  http://127.0.0.1:4001/
```

Then confirm no overflow by comparing scroll width to client width:

```bash
timeout 10 /Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome \
  --headless=new --disable-gpu --no-sandbox --virtual-time-budget=1000 \
  --window-size=375,800 --dump-dom http://127.0.0.1:4001/ > /tmp/a-375.html
```

Expected: screenshot renders, content column fits, no clipped text.

- [ ] **Step 4: Capture A at 1280 for the record**

```bash
timeout 10 /Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome \
  --headless=new --disable-gpu --no-sandbox --virtual-time-budget=1000 \
  --screenshot=/private/tmp/claude-501/-Users-tbielawa-Projects-blog-lnx-cx/6aa3ee9a-b113-4758-b966-e0382d948057/scratchpad/option-a-home.png --window-size=1280,1500 \
  --hide-scrollbars http://127.0.0.1:4001/
```

- [ ] **Step 5: Commit**

```bash
cd /Users/tbielawa/Projects/blog.lnx.cx-worktrees/design-a
git add _sass/minima/_base.scss
git commit -m "Add X11 root weave and float the document column on it

The weave is the root window; the white column is the document being
rendered on top. This is what separates furniture from content and makes
it read as a browser rather than a blog wearing a grey hat."
```

---

### Task 5: Verify Option A against the criteria

No code. This is the gate before B, and it is where A either stands on its own or
proves it needs chrome.

**Files:** none (verification only)

- [ ] **Step 1: Run the mechanical criteria**

```bash
cd /Users/tbielawa/Projects/blog.lnx.cx-worktrees/design-a
echo "--- Gemfile unchanged (expect no output) ---"
git diff visual-identity --stat -- Gemfile Gemfile.lock
echo "--- zero JS (expect 0) ---"
curl -s http://127.0.0.1:4001/ | grep -c "<script" || true
echo "--- no border-radius (expect 0) ---"
curl -s http://127.0.0.1:4001/assets/main.css | grep -c "border-radius" || true
echo "--- no outset/inset keywords (expect 0) ---"
curl -s http://127.0.0.1:4001/assets/main.css | grep -cE "border.*(outset|inset)" || true
echo "--- feed builds (expect 200) ---"
curl -s -o /dev/null -w '%{http_code}\n' http://127.0.0.1:4001/feed.xml
echo "--- h-entry survives (expect >=1) ---"
curl -s http://127.0.0.1:4001/2026/07/12/famoe-ly-i-wanted-a-practice-setlist-what-i-got-was-much-more.html | grep -c "h-entry" || true
```

Note: live-reload injects a `<script>` tag when served with `-l`. If the JS count
is non-zero, re-check against a plain `bundle exec jekyll build` output rather
than the live server before calling it a failure.

- [ ] **Step 2: Capture the comparison set**

Baseline :4000 and A :4001, at 1280 and 375, for home + one post + one page.

- [ ] **Step 3: The Windows test — dispatch a fresh reviewer**

Dispatch a subagent that has **not** seen this conversation. Give it only the
screenshot and this prompt, with no mention of Motif, CDE, Mosaic, or Windows:

> "Here is a screenshot of a personal blog. In one sentence: what visual
> tradition or era does this remind you of? Be specific about the platform if
> you can name one."

Pass if it names X11/Unix/Motif/CDE/Mosaic/early-web. **Fail if it says Windows.**
The reviewer must not be primed — that is the entire value of the check.

- [ ] **Step 4: Report to Tim, do not self-approve**

Present baseline vs A side by side and hold for a verdict before starting B.

---

### Task 6: Port A to design-b

**Files:**
- Modify: all of A's, via merge
- Branch: `design-b`

**Interfaces:**
- Consumes: every variable and mixin from Task 1
- Produces: the A baseline that B's chrome sits on

- [ ] **Step 1: Merge**

```bash
cd /Users/tbielawa/Projects/blog.lnx.cx-worktrees/design-b
git merge design-a -m "Merge option A foundation into design-b

B is A plus chrome. The palette, type split, and chisels are shared;
only the toolbar differs. Keeping them on one lineage means the
comparison isolates chrome as the single variable."
```

- [ ] **Step 2: Verify B still builds and matches A**

```bash
sleep 4
curl -s -o /dev/null -w '%{http_code}\n' http://127.0.0.1:4002/
diff <(curl -s http://127.0.0.1:4001/assets/main.css) \
     <(curl -s http://127.0.0.1:4002/assets/main.css) && echo "A and B CSS identical - correct at this point"
```

Expected: `200`, and the CSS is byte-identical. B diverges only in Task 7.

---

### Task 7: The Mosaic chrome

**Files:**
- Create: `_includes/chrome.html`
- Create: `_sass/minima/_chrome.scss`
- Modify: `_sass/minima.scss` (import list — add `minima/chrome` last)
- Modify: `_layouts/default.html:8` (insert include after header)
- Branch: `design-b`

**Interfaces:**
- Consumes: `$motif-face`, `$motif-light`, `$motif-dark`, `$motif-shadow`, `$chrome-font-family`, `$green-color`, `bevel-raised()`, `bevel-sunken()` from Task 1
- Produces: `.mosaic-chrome`, `.mosaic-toolbar`, `.mosaic-btn`, `.mosaic-throbber`, `.mosaic-fields`, `.mosaic-field`, `.mosaic-field-label`, `.mosaic-field-value`

- [ ] **Step 1: Create the chrome include**

Create `_includes/chrome.html`. Every control here is a real link — the honesty
rule is enforced by there being no element that could be clicked and do nothing:

```html
{%- comment -%}
  Mosaic chrome. Every control is load-bearing:
  - toolbar buttons are the real site nav
  - both fields print true Liquid values
  - the throbber links home, as Mosaic's NCSA globe did
  There is deliberately no File/Edit menubar: it cannot work without JS,
  and a dead menu is worse than no menu.
{%- endcomment -%}
<div class="mosaic-chrome">

  <div class="mosaic-toolbar">
    <a class="mosaic-btn" href="{{ "/" | relative_url }}">Home</a>
    {%- assign default_paths = site.pages | map: "path" -%}
    {%- assign page_paths = site.header_pages | default: default_paths -%}
    {%- for path in page_paths -%}
      {%- assign my_page = site.pages | where: "path", path | first -%}
      {%- if my_page.title -%}
        <a class="mosaic-btn" href="{{ my_page.url | relative_url }}">{{ my_page.title | escape }}</a>
      {%- endif -%}
    {%- endfor -%}
    <a class="mosaic-btn" href="{{ "/feed.xml" | relative_url }}">Feed</a>

    <a class="mosaic-throbber" href="{{ "/" | relative_url }}" aria-label="Home">
      <svg viewBox="0 0 24 24" width="22" height="22" aria-hidden="true">
        <circle cx="12" cy="12" r="10" fill="#078607" stroke="#044a04" stroke-width="1"/>
        <ellipse cx="12" cy="12" rx="4.5" ry="10" fill="none" stroke="#9fe89f" stroke-width="1"/>
        <line x1="2" y1="12" x2="22" y2="12" stroke="#9fe89f" stroke-width="1"/>
        <path d="M4 6.5 H20 M4 17.5 H20" fill="none" stroke="#9fe89f" stroke-width="0.75"/>
      </svg>
    </a>
  </div>

  <div class="mosaic-fields">
    <div class="mosaic-field">
      <span class="mosaic-field-label">Document Title:</span>
      <span class="mosaic-field-value">{{ page.title | default: site.title | escape }}</span>
    </div>
    <div class="mosaic-field">
      <span class="mosaic-field-label">Document URL:</span>
      <span class="mosaic-field-value">{{ site.url }}{{ page.url }}</span>
    </div>
  </div>

</div>
```

- [ ] **Step 2: Create the chrome partial**

Create `_sass/minima/_chrome.scss`:

```scss
/**
 * The chrome is the operating system. It speaks Helvetica.
 * The document below it is the author, and keeps Space Grotesk.
 */
.mosaic-chrome {
  background-color: $motif-face;
  border-bottom: 2px solid $motif-shadow;
  font-family: $chrome-font-family;
  font-size: 12px;
  padding: 4px 6px 6px;
}

.mosaic-toolbar {
  display: flex;
  align-items: center;
  gap: 4px;
  margin-bottom: 5px;
}

.mosaic-btn {
  @include bevel-raised(2px);
  background-color: $motif-face;
  color: $text-color;
  text-decoration: none;
  padding: 3px 10px;
  font-family: $chrome-font-family;
  font-size: 12px;
  line-height: 1.4;
  white-space: nowrap;

  &:visited { color: $text-color; }
  &:hover   { color: $text-color; text-decoration: none; }

  // Motif buttons invert their bevel on press. This is CSS-only.
  &:active {
    @include bevel-sunken(2px);
    padding: 4px 9px 2px 11px;
  }
}

.mosaic-throbber {
  margin-left: auto;
  @include bevel-sunken(2px);
  background-color: #1a1d24;
  line-height: 0;
  padding: 2px;
  flex: none;

  > svg { display: block; }
}

.mosaic-fields {
  display: flex;
  flex-direction: column;
  gap: 3px;
}

.mosaic-field {
  display: flex;
  align-items: baseline;
  gap: 6px;
}

.mosaic-field-label {
  flex: none;
  width: 108px;
  text-align: right;
  color: $text-color;
}

// Sunken Motif text field. Looks editable, is not — it is display-only,
// and it prints the truth.
.mosaic-field-value {
  @include bevel-sunken(2px);
  background-color: #cfd3dd;
  flex: 1 1 auto;
  padding: 2px 5px;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  min-width: 0;
}

@include media-query($on-palm) {
  .mosaic-toolbar {
    flex-wrap: wrap;
  }
  .mosaic-throbber {
    margin-left: 0;
  }
  .mosaic-field-label {
    width: auto;
    text-align: left;
  }
}
```

- [ ] **Step 3: Import the partial**

In `_sass/minima.scss`, extend the import list — `chrome` goes **last** so it can
override:

```scss
@import
  "minima/motif",
  "minima/base",
  "minima/layout",
  "minima/syntax-highlighting",
  "minima/chrome"
;
```

- [ ] **Step 4: Replace the header with the chrome**

**Decision (Tim, at plan time): in B the chrome replaces the site header entirely.**
`Document Title:` already prints the site name, so a separate masthead would say
it twice — and shipping both would render the site nav twice over, once in
`header.html`'s `site-nav` and again in the toolbar.

In `_layouts/default.html`, find this line:

```html
    {%- include header.html -%}
```

and replace it with:

```html
    {%- include chrome.html -%}
```

`header.html` itself is left untouched on disk — option A still uses it, and the
two options share this file only by branch, not by include. Do not delete it.

Accepted tradeoffs, recorded so a reviewer does not re-litigate them:
- The site's name now appears only inside the `Document Title:` field. That is
  the intent, not an oversight.
- B's diff from A is larger than "A plus a toolbar." The comparison is still
  valid — chrome is still the only axis — but B changes more than it adds.

- [ ] **Step 5: Assert the honesty rule — zero inert controls**

Every element in the chrome that looks clickable must have a real `href`:

```bash
sleep 4
echo "--- count chrome controls ---"
curl -s http://127.0.0.1:4002/ | grep -o 'class="mosaic-btn"' | wc -l
echo "--- count those with a real href (must match above) ---"
curl -s http://127.0.0.1:4002/ | grep -o '<a class="mosaic-btn" href="[^"]\+"' | wc -l
echo "--- throbber has href (expect 1) ---"
curl -s http://127.0.0.1:4002/ | grep -c '<a class="mosaic-throbber" href='
echo "--- no menubar shipped (expect 0) ---"
curl -s http://127.0.0.1:4002/ | grep -ci "mosaic-menubar" || true
echo "--- still zero JS beyond livereload ---"
curl -s http://127.0.0.1:4002/ | grep -c "<script" || true
```

Expected: the first two counts are **equal and non-zero**; throbber is `1`;
menubar is `0`.

- [ ] **Step 6: Assert the fields print truth, not placeholders**

```bash
curl -s http://127.0.0.1:4002/2026/07/12/famoe-ly-i-wanted-a-practice-setlist-what-i-got-was-much-more.html \
  | grep -A1 "Document URL:"
```

Expected: the real post URL. If it renders empty or shows `{{`, the Liquid is wrong.

- [ ] **Step 7: Measure chrome height against the 15% budget**

At 1280×800, chrome must cost ≤ 120px (15% of 800). Screenshot at
`--window-size=1280,800` and measure the chrome band. If over, reduce
`.mosaic-chrome` padding and field gaps first — do not delete the fields, they
are the point.

- [ ] **Step 8: Commit**

```bash
cd /Users/tbielawa/Projects/blog.lnx.cx-worktrees/design-b
git add _includes/chrome.html _sass/minima/_chrome.scss _sass/minima.scss _layouts/default.html
git commit -m "Add load-bearing Mosaic chrome

Document Title and Document URL print real Liquid values - a breadcrumb
wearing a URL bar's clothes. Toolbar buttons are the real site nav.
Throbber links home like Mosaic's NCSA globe did.

No File/Edit menubar: it can't work without JS, and a dead menu is worse
than no menu. Nothing here is a prop - that rule is what keeps browser
chrome inside a browser on the right side of charming."
```

---

### Task 8: Verify Option B and present both

**Files:** none (verification only)

- [ ] **Step 1: Re-run the full mechanical suite against :4002**

Same as Task 5 Step 1, with port 4002, plus the Task 7 Step 5 honesty assertions.

- [ ] **Step 2: Capture the full comparison set**

Baseline :4000, A :4001, B :4002 — at 1280 and 375 — for home, a post, and a page.
Nine captures at each width.

- [ ] **Step 3: The Windows test on B**

Dispatch a fresh, unprimed subagent with B's screenshot and the same
one-sentence prompt from Task 5 Step 3. B is the higher risk: it has the most
chrome and therefore the most surface to read as Windows. Fail if it says Windows.

- [ ] **Step 4: The swoon test**

Dispatch a second fresh subagent:

> "Here is a screenshot of a personal blog. If you recognize specific software or
> UI conventions being referenced, name them and point at the exact details that
> tell you."

Pass if it can name Mosaic, Motif, X11, or CDE **and** cite specifics — the
Document Title/URL fields, the bevels, the weave. Vague gestures at
"retro" or "90s" are a partial pass at best: the goal is recognition, not
nostalgia.

- [ ] **Step 5: Present to Tim**

Show baseline / A / B. Report every criterion with its actual measured value, and
state plainly which ones failed. Do not self-approve — the verdict on "does this
make nerds swoon" is Tim's, and it is the one criterion that cannot be automated.

---

## Resolved review findings

- **`$green-color` alpha drop (`#0786078b` → `#078607`), raised by the Task 1
  reviewer as "deliberate cleanup or accident?"** — Honest answer: incidental. The
  value was written to match the green the throbber needs, and the alpha was not
  consciously carried across. It is nonetheless correct for the end state: the
  throbber wants solid green, and the header/footer that consumed the translucent
  version are replaced in Task 3. **Ruling: accepted.** The transient solid-dark-green
  header on :4001 across Tasks 1-2 is a real regression but a private one — only
  the dev servers show it, and Task 3 supersedes it. Resequencing into Task 2
  would add churn for no benefit. Do not re-litigate.

## Spec deltas — decisions made during planning

The spec left two details open. Both are resolved here; if either is wrong, it is
cheaper to say so now than after Task 7.

- **Where Technitribe green survives:** the throbber, and only the throbber. It
  sits in a sunken well against near-black, which is where an NCSA globe lived,
  and it is the one place a brand color reads as era-correct rather than as a
  violation. Green is removed from the header, footer, and tag buttons entirely.
  If green should also survive elsewhere, that is a Task 3 change.
- **Motif scrollbar:** not implemented. The spec called it "a stretch deep cut,
  not required for a verdict," and it would add a `::-webkit-scrollbar` block
  that renders in exactly one engine family. It can be added after a direction is
  chosen, and it should not influence the A/B call.

One further note: Task 3 lets `$chrome-font-family` into option A, on tag buttons
only. This is a deliberate, narrow exception to "everything in A is the document"
— tag buttons are widgets, not prose. If this reads as a leak rather than an
exception when A is on screen, revert them to Space Grotesk; it is a one-line
change and it does not disturb the thesis.

## Notes for the implementer

- **Line numbers in this plan are from the original files at branch point and
  they drift as you edit.** Every replacement changes the file's length, so the
  next task's cited range is already stale by the time you reach it. Locate the
  block to replace by **matching its content**, shown in each step, and treat the
  line numbers as a hint about where to look. Do not edit a range by number
  without reading what is actually there.
- **The servers are already running.** Do not start new ones. Do not kill them
  unless a build genuinely wedges; if you must, restart with the exact flags in
  the Environment table (including the distinct `--livereload-port` per tree).
- **Sass errors return HTTP 500 on the CSS** and print to the server log. If a
  page looks unstyled mid-task, that is the first thing to check — it usually
  means broken syntax from a half-finished edit, and it self-heals on the next
  correct save.
- **Do not touch `_config.yml`.** It is not reloaded by `jekyll serve` and
  changing it silently desyncs the running servers from the source.
- **Never self-approve the judged criteria.** The Windows test and the swoon test
  require a reviewer with no exposure to this plan. A primed reviewer will tell
  you what you want to hear, which is worth nothing.
