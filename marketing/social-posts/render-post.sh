#!/bin/bash
# Render any social-posts/*.html to a 1080x1080 PNG suitable for Instagram upload.
#
# On your Mac (where Cinzel can fetch from Google Fonts), this script produces
# the on-brand version of the post with actual Cinzel rendering.
#
# Usage:
#   cd marketing/social-posts/
#   chmod +x render-post.sh
#   ./render-post.sh                       # renders all *.html in this folder
#   ./render-post.sh post-1-launch.html    # renders one specific file

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Install deps if missing
if ! python3 -c "import weasyprint" 2>/dev/null; then
  echo "Installing WeasyPrint..."
  pip3 install weasyprint
fi
if ! command -v pdftoppm >/dev/null 2>&1; then
  echo "pdftoppm not found. On macOS: brew install poppler"
  exit 1
fi

render_one() {
  local html="$1"
  local base="${html%.html}"
  echo "Rendering $html → $base.png ..."

  python3 -c "
from weasyprint import HTML
HTML('$html', base_url='.').write_pdf('$base.pdf')
"

  # 96 DPI gives true 1080x1080 since the @page is sized in CSS pixels
  pdftoppm -r 96 -png "$base.pdf" "$base"
  # pdftoppm appends -1 by default — clean that up
  if [ -f "$base-1.png" ]; then
    mv -f "$base-1.png" "$base.png"
  fi

  rm -f "$base.pdf"
  echo "  ✓ $base.png"
}

if [ $# -gt 0 ]; then
  render_one "$1"
else
  for html in *.html; do
    [ -f "$html" ] || continue
    render_one "$html"
  done
fi

echo ""
echo "Done. Upload the .png file(s) to Instagram."
