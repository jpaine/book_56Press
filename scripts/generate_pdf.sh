#!/usr/bin/env bash
# Generate Professional PDF

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Load config
CONFIG_FILE="$PROJECT_ROOT/config.yaml"
if [ ! -f "$CONFIG_FILE" ]; then
    echo "❌ Config file not found: $CONFIG_FILE"
    exit 1
fi

# Parse config using Python
eval $(python3 << 'PYEOF'
import yaml
import sys
import os

config_file = os.environ.get('CONFIG_FILE', '$CONFIG_FILE')
with open(config_file, 'r') as f:
    config = yaml.safe_load(f)

book = config.get('book', {})
structure = config.get('structure', {})
output = config.get('output', {})
styles = config.get('styles', {})

def escape(s):
    return str(s).replace("'", "'\\''")

print(f"BOOK_TITLE='{escape(book.get('title', ''))}'")
print(f"BOOK_SUBTITLE='{escape(book.get('subtitle', ''))}'")
print(f"BOOK_PUBLISHER='{escape(book.get('publisher', ''))}'")
print(f"BOOK_DATE='{escape(book.get('date', ''))}'")
print(f"HAS_CONCLUSION='{structure.get('has_conclusion', False)}'")
print(f"OUTPUT_DIR='{output.get('output_dir', 'output')}'")
print(f"PRINT_CSS='{styles.get('print_css', 'styles/print_styles.css')}'")
PYEOF
)

# Get output filename from config or generate from title
PDF_FILENAME_CONFIG=$(python3 << EOF
import yaml
with open("$CONFIG_FILE", 'r') as f:
    config = yaml.safe_load(f)
print(config.get('output', {}).get('pdf_filename', ''))
EOF
)

if [ -z "$PDF_FILENAME_CONFIG" ] || [ "$PDF_FILENAME_CONFIG" = '""' ]; then
    PDF_FILENAME=$(echo "$BOOK_TITLE" | "$PROJECT_ROOT/tools/sanitize_filename.py")
    PDF_FILENAME="${PDF_FILENAME}_Print_Professional.pdf"
else
    PDF_FILENAME=$(basename "$PDF_FILENAME_CONFIG")
fi

OUTPUT_PATH="$PROJECT_ROOT/$OUTPUT_DIR"
mkdir -p "$OUTPUT_PATH"

OUTPUT_FILE="$OUTPUT_PATH/$PDF_FILENAME"

# Cleanup function
cleanup() {
    rm -f "$PROJECT_ROOT/temp_book_for_pdf.md" "$PROJECT_ROOT/temp_book.html"
}
trap cleanup EXIT

echo "🖨️  Generating Professional PDF..."
echo ""

# Check for WeasyPrint
if ! command -v weasyprint &> /dev/null; then
    echo "❌ WeasyPrint not found. Install with: pip install weasyprint"
    exit 1
fi

# Detect chapters
echo "   → Detecting chapters..."
CHAPTERS=$("$PROJECT_ROOT/tools/detect_chapters.py" "$PROJECT_ROOT/book_content/chapters" || echo "")
if [ -z "$CHAPTERS" ]; then
    echo "❌ No chapters found"
    exit 1
fi

CHAPTER_COUNT=$(echo "$CHAPTERS" | wc -l | tr -d ' ')
echo "   ✅ Found $CHAPTER_COUNT chapter(s)"

# Create temporary combined file
echo "   → Combining book components..."

cat > "$PROJECT_ROOT/temp_book_for_pdf.md" << EOF
---
title: "$BOOK_TITLE"
subtitle: "$BOOK_SUBTITLE"
publisher: "$BOOK_PUBLISHER"
date: "$BOOK_DATE"
---

EOF

# Add front matter
echo "   → Adding front matter..."

echo '<div class="frontmatter title-page">' >> "$PROJECT_ROOT/temp_book_for_pdf.md"
cat "$PROJECT_ROOT/book_content/front_matter/title_page.md" >> "$PROJECT_ROOT/temp_book_for_pdf.md"
echo '</div>' >> "$PROJECT_ROOT/temp_book_for_pdf.md"
echo "" >> "$PROJECT_ROOT/temp_book_for_pdf.md"

echo '<div class="frontmatter copyright-page">' >> "$PROJECT_ROOT/temp_book_for_pdf.md"
cat "$PROJECT_ROOT/book_content/front_matter/copyright_page.md" >> "$PROJECT_ROOT/temp_book_for_pdf.md"
echo '</div>' >> "$PROJECT_ROOT/temp_book_for_pdf.md"
echo "" >> "$PROJECT_ROOT/temp_book_for_pdf.md"

echo '<div class="frontmatter dedication">' >> "$PROJECT_ROOT/temp_book_for_pdf.md"
cat "$PROJECT_ROOT/book_content/front_matter/dedication.md" >> "$PROJECT_ROOT/temp_book_for_pdf.md"
echo '</div>' >> "$PROJECT_ROOT/temp_book_for_pdf.md"
echo "" >> "$PROJECT_ROOT/temp_book_for_pdf.md"

echo '<div class="frontmatter toc">' >> "$PROJECT_ROOT/temp_book_for_pdf.md"
cat "$PROJECT_ROOT/book_content/front_matter/table_of_contents.md" >> "$PROJECT_ROOT/temp_book_for_pdf.md"
echo '</div>' >> "$PROJECT_ROOT/temp_book_for_pdf.md"
echo "" >> "$PROJECT_ROOT/temp_book_for_pdf.md"

echo '<div class="frontmatter preface">' >> "$PROJECT_ROOT/temp_book_for_pdf.md"
cat "$PROJECT_ROOT/book_content/front_matter/preface.md" >> "$PROJECT_ROOT/temp_book_for_pdf.md"
echo '</div>' >> "$PROJECT_ROOT/temp_book_for_pdf.md"
echo "" >> "$PROJECT_ROOT/temp_book_for_pdf.md"

# Add chapters
echo "   → Adding chapters..."
while IFS= read -r chapter; do
    if [ -n "$chapter" ]; then
        echo '<div class="chapter">' >> "$PROJECT_ROOT/temp_book_for_pdf.md"
        cat "$chapter" >> "$PROJECT_ROOT/temp_book_for_pdf.md"
        echo '</div>' >> "$PROJECT_ROOT/temp_book_for_pdf.md"
        echo "" >> "$PROJECT_ROOT/temp_book_for_pdf.md"
    fi
done <<< "$CHAPTERS"

# Add conclusion
if [ "$HAS_CONCLUSION" = "True" ] && [ -f "$PROJECT_ROOT/book_content/chapters/conclusion.md" ]; then
    echo '<div class="chapter">' >> "$PROJECT_ROOT/temp_book_for_pdf.md"
    cat "$PROJECT_ROOT/book_content/chapters/conclusion.md" >> "$PROJECT_ROOT/temp_book_for_pdf.md"
    echo '</div>' >> "$PROJECT_ROOT/temp_book_for_pdf.md"
    echo "" >> "$PROJECT_ROOT/temp_book_for_pdf.md"
fi

# Add back matter
if [ -f "$PROJECT_ROOT/book_content/back_matter/acknowledgments.md" ]; then
    echo '<div class="acknowledgments">' >> "$PROJECT_ROOT/temp_book_for_pdf.md"
    cat "$PROJECT_ROOT/book_content/back_matter/acknowledgments.md" >> "$PROJECT_ROOT/temp_book_for_pdf.md"
    echo '</div>' >> "$PROJECT_ROOT/temp_book_for_pdf.md"
    echo "" >> "$PROJECT_ROOT/temp_book_for_pdf.md"
fi

# Generate PDF via HTML
echo "   → Converting to PDF..."

CSS_PATH="$PROJECT_ROOT/$PRINT_CSS"

# First convert markdown to HTML
pandoc "$PROJECT_ROOT/temp_book_for_pdf.md" \
    -o "$PROJECT_ROOT/temp_book.html" \
    --standalone \
    --metadata title="$BOOK_TITLE" \
    --metadata subtitle="$BOOK_SUBTITLE" \
    --metadata publisher="$BOOK_PUBLISHER"

# Then convert HTML to PDF with WeasyPrint
weasyprint "$PROJECT_ROOT/temp_book.html" \
    "$OUTPUT_FILE" \
    --stylesheet "$CSS_PATH" \
    --presentational-hints

if [ $? -eq 0 ]; then
    echo "✅ PDF created: $OUTPUT_FILE"
    ls -lh "$OUTPUT_FILE"
    
    # Get page count if pdfinfo available
    if command -v pdfinfo &> /dev/null; then
        PAGES=$(pdfinfo "$OUTPUT_FILE" 2>/dev/null | grep "Pages:" | awk '{print $2}' || echo "")
        if [ -n "$PAGES" ]; then
            echo "   📄 Total pages: $PAGES"
        fi
    fi
    
    exit 0
else
    echo "❌ PDF generation failed"
    exit 1
fi

