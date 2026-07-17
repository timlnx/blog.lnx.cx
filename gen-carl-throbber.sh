#!/bin/bash
# Regenerate the Carl throbber pixmap and its hover-throb sprite strip.
set -euo pipefail

SRC="assets/opengraph/og-image-carl-300x300.png"
OUT_STATIC="assets/carl-throbber.png"
OUT_STRIP="assets/carl-throb.png"

# Crop of the og image that holds Carl's whole head, and the saturation bump
# that keeps his eyes alive through the resize. Both come from the original
# pixmap recipe; leave them alone unless the og image itself is replaced.
CROP="276x276+12+8"
MODULATE="105,200"

# The tile is 32 wide and 50 tall. Carl is only ever 32 wide; the extra height
# is deliberate margin above and below his face so the throb has somewhere to
# grow. The frames are the cycle: rest, mid, peak, mid.
TILE="32x50"
SCALES=(32 35 38 35)

usage() {
    cat <<EOF
Usage: $(basename "$0") [-h|--help]

Regenerate Carl's throbber pixmap and the sprite strip the hover throb runs on,
from the tracked og image. Writes:

  $OUT_STATIC   32x50, the resting frame the <img> points at
  $OUT_STRIP      128x50, the four frames the CSS steps() marches across

The first frame of the strip is byte-identical to the resting pixmap, so
uncovering the strip on hover shows nothing until the animation starts.

Each frame is quantized separately, with its own 16-color table and its own
Floyd-Steinberg dither. That is on purpose: the palette and the dither drift
frame to frame while Carl pulses, which is the shimmer period encoders produced
when they quantized every frame on its own. Adding -remap or -dither None here
would share one table across the frames and silently remove the effect.

Takes no arguments.

Options:
  -h, --help    Show this help and exit
EOF
}

# --- parse args ---
while [ $# -gt 0 ]; do
    case "$1" in
        -h|--help) usage; exit 0 ;;
        *) echo "$(basename "$0"): unexpected argument: $1" >&2; usage >&2; exit 1 ;;
    esac
done

# --- run from the repo root regardless of where we were invoked from ---
# CDPATH is cleared so a user's CDPATH cannot make cd echo a different path.
HERE="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
cd "$HERE"

# --- validate before writing anything ---
if ! command -v magick >/dev/null 2>&1; then
    echo "$(basename "$0"): ImageMagick 'magick' not found on PATH" >&2
    exit 1
fi
if [ ! -f "$SRC" ]; then
    echo "$(basename "$0"): source image not found: $SRC" >&2
    exit 1
fi

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

# --- render each frame from the source at its own size ---
# Always from the 300x300 original, never by scaling the 32px pixmap: upscaling
# a pixmap re-quantizes the grid unevenly and the animation crawls.
FRAMES=()
i=0
for n in "${SCALES[@]}"; do
    magick "$SRC" \
        -crop "$CROP" +repage \
        -modulate "$MODULATE" \
        -resize "${n}x${n}" \
        -colors 16 \
        -background none -gravity center -extent "$TILE" \
        -define png:exclude-chunk=date,tIME \
        "$TMP/frame-$i.png"
    FRAMES+=("$TMP/frame-$i.png")
    i=$((i + 1))
done

cp "${FRAMES[0]}" "$OUT_STATIC"
magick "${FRAMES[@]}" +append -define png:exclude-chunk=date,tIME "$OUT_STRIP"

# --- verify the first frame still matches the pixmap ---
# The <img> shows OUT_STATIC and the strip animates underneath it, so if the
# first frame drifts from the pixmap Carl pops the instant you hover.
# 'compare -metric AE' prints "0 (0)", not "0", so take the first field.
magick "$OUT_STRIP" -crop "${TILE}+0+0" +repage "$TMP/first.png"
drift="$(magick compare -metric AE "$TMP/first.png" "$OUT_STATIC" null: 2>&1 | sed 's/ .*//')"
if [ "$drift" != "0" ]; then
    echo "$(basename "$0"): strip frame 0 differs from $OUT_STATIC by $drift px" >&2
    exit 1
fi

echo "Wrote $OUT_STATIC  ($(identify -format '%wx%h, %k colors' "$OUT_STATIC"))" >&2
echo "Wrote $OUT_STRIP     ($(identify -format '%wx%h, %k colors' "$OUT_STRIP"))" >&2
