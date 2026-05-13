#!/bin/bash
# Re-render press-kit.html to press-kit.pdf using your local fonts.
#
# Run this on your Mac (or any machine with internet + Cinzel installed via Google Fonts CDN).
# WeasyPrint will fetch Cinzel and Crimson Text from Google Fonts at render time, producing
# the on-brand version of the PDF.
#
# Usage:
#   cd marketing/
#   chmod +x render-press-kit.sh
#   ./render-press-kit.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Make sure WeasyPrint is installed
if ! python3 -c "import weasyprint" 2>/dev/null; then
  echo "Installing WeasyPrint..."
  pip3 install weasyprint
fi

echo "Rendering press-kit.pdf..."
python3 -c "
from weasyprint import HTML
HTML('press-kit.html', base_url='.').write_pdf('press-kit.pdf')
print('Done. press-kit.pdf written.')
"

# Quick sanity check
python3 -c "
from pypdf import PdfReader
r = PdfReader('press-kit.pdf')
print(f'Pages: {len(r.pages)}')
fonts = set()
for page in r.pages:
    if '/Resources' in page and '/Font' in page['/Resources']:
        for f in page['/Resources']['/Font'].values():
            obj = f.get_object()
            if '/BaseFont' in obj:
                fonts.add(str(obj['/BaseFont']))
print(f'Embedded fonts:')
for f in sorted(fonts):
    print(f'  {f}')
" 2>/dev/null || echo "(skip font check — pypdf not installed)"
