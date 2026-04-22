#!/usr/bin/env bash
# Generate the 4 portfolio-icon variants (color, bw, red, green) from an SVG logo.
#
# Usage:
#   scripts/generate-portfolio-icons.sh <slug> <svg-file> <source-hex>
#
# Example (trafsys logo originally in #163B64):
#   scripts/generate-portfolio-icons.sh trafsys /tmp/trafsys-logo.svg 163B64
#
# Output goes to /tmp/<slug>-render/{color,bw,red,green}.png (512px wide, transparent).
# After reviewing, copy into assets/icons/{variant}/<slug>.png.

set -euo pipefail

SLUG="${1:?slug required — e.g. 'trafsys'}"
SVG_FILE="${2:?svg file path required}"
SOURCE_HEX="${3:?source color hex required (no #) — e.g. '163B64'}"

CHROME="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
[ -x "$CHROME" ] || { echo "Chrome not found at $CHROME" >&2; exit 1; }
[ -f "$SVG_FILE" ] || { echo "SVG file not found: $SVG_FILE" >&2; exit 1; }

OUT_DIR="/tmp/${SLUG}-render"
mkdir -p "$OUT_DIR"
cd "$OUT_DIR"

SVG_CONTENT=$(cat "$SVG_FILE")

# Read intrinsic viewBox height to pick a reasonable canvas height (preserves aspect)
# Defaults to 100px if viewBox can't be parsed.
VB=$(echo "$SVG_CONTENT" | grep -oE 'viewBox="[^"]+"' | head -1 | sed 's/viewBox="//;s/"//')
VB_W=$(echo "$VB" | awk '{print $3}')
VB_H=$(echo "$VB" | awk '{print $4}')
if [[ -n "$VB_W" && -n "$VB_H" ]]; then
  CANVAS_H=$(python3 -c "print(round(512 * $VB_H / $VB_W))")
else
  CANVAS_H=100
fi
INNER_W=420
echo "Canvas: 512×${CANVAS_H} (source viewBox ${VB_W}×${VB_H})"

generate() {
  local variant=$1
  local fill=$2
  local modified=$(echo "$SVG_CONTENT" | sed "s/${SOURCE_HEX}/${fill}/gi")

  cat > render.html <<EOF
<!DOCTYPE html>
<html><head><style>
  html, body { margin: 0; padding: 0; width: 512px; height: ${CANVAS_H}px; background: transparent; overflow: hidden; }
  .wrap { width: 512px; height: ${CANVAS_H}px; display: flex; align-items: center; justify-content: center; }
  .wrap svg { width: ${INNER_W}px; height: auto; }
</style></head>
<body><div class="wrap">${modified}</div></body></html>
EOF

  "$CHROME" \
    --headless=new --disable-gpu \
    --default-background-color=00000000 \
    --hide-scrollbars \
    --window-size=512,${CANVAS_H} \
    --screenshot="${OUT_DIR}/${variant}.png" \
    "file://${OUT_DIR}/render.html" 2>&1 | tail -1
}

generate color "$SOURCE_HEX"
generate bw    000000
generate red   BE4642
generate green 509070

echo
echo "Generated:"
ls -la "${OUT_DIR}"/*.png
echo
echo "To install:"
echo "  cp ${OUT_DIR}/color.png assets/icons/color/${SLUG}.png"
echo "  cp ${OUT_DIR}/bw.png    assets/icons/bw/${SLUG}.png"
echo "  cp ${OUT_DIR}/red.png   assets/icons/red/${SLUG}.png"
echo "  cp ${OUT_DIR}/green.png assets/icons/green/${SLUG}.png"
