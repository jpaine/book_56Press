#!/usr/bin/env bash
# Generate Professional EPUB

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

# Escape single quotes in strings
def escape(s):
    return str(s).replace("'", "'\\''")

print(f"BOOK_TITLE='{escape(book.get('title', ''))}'")
print(f"BOOK_SUBTITLE='{escape(book.get('subtitle', ''))}'")
print(f"BOOK_AUTHOR='{escape(book.get('author', ''))}'")
print(f"BOOK_PUBLISHER='{escape(book.get('publisher', ''))}'")
print(f"BOOK_DATE='{escape(book.get('date', ''))}'")
print(f"BOOK_LANGUAGE='{escape(book.get('language', 'en-US'))}'")
print(f"BOOK_DESCRIPTION='{escape(book.get('description', ''))}'")
print(f"BOOK_RIGHTS='{escape(book.get('rights', ''))}'")
print(f"HAS_CONCLUSION='{structure.get('has_conclusion', False)}'")
print(f"COVER_IMAGE='{escape(structure.get('cover_image', ''))}'")
print(f"OUTPUT_DIR='{output.get('output_dir', 'output')}'")
print(f"EPUB_CSS='{styles.get('epub_css', 'styles/ebook_styles.css')}'")
PYEOF
)

# Get output filename from config or generate from title
EPUB_FILENAME_CONFIG=$(python3 << EOF
import yaml
with open("$CONFIG_FILE", 'r') as f:
    config = yaml.safe_load(f)
print(config.get('output', {}).get('epub_filename', ''))
EOF
)

if [ -z "$EPUB_FILENAME_CONFIG" ] || [ "$EPUB_FILENAME_CONFIG" = '""' ]; then
    EPUB_FILENAME=$(echo "$BOOK_TITLE" | "$PROJECT_ROOT/tools/sanitize_filename.py")
    EPUB_FILENAME="${EPUB_FILENAME}_Professional.epub"
else
    EPUB_FILENAME=$(basename "$EPUB_FILENAME_CONFIG")
fi

OUTPUT_PATH="$PROJECT_ROOT/$OUTPUT_DIR"
mkdir -p "$OUTPUT_PATH"

OUTPUT_FILE="$OUTPUT_PATH/$EPUB_FILENAME"

# Cleanup function
cleanup() {
    rm -f "$PROJECT_ROOT/temp_book_for_epub.md"
}
trap cleanup EXIT

echo "📖 Generating Professional EPUB..."
echo ""

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

cat > "$PROJECT_ROOT/temp_book_for_epub.md" << EOF
---
title: "$BOOK_TITLE"
subtitle: "$BOOK_SUBTITLE"
publisher: "$BOOK_PUBLISHER"
date: "$BOOK_DATE"
language: $BOOK_LANGUAGE
description: "$BOOK_DESCRIPTION"
rights: "$BOOK_RIGHTS"
---

EOF

# Add front matter
echo "   → Adding front matter..."

echo '<section class="title-page" epub:type="titlepage">' >> "$PROJECT_ROOT/temp_book_for_epub.md"
cat "$PROJECT_ROOT/book_content/front_matter/title_page.md" >> "$PROJECT_ROOT/temp_book_for_epub.md"
echo '</section>' >> "$PROJECT_ROOT/temp_book_for_epub.md"
echo "" >> "$PROJECT_ROOT/temp_book_for_epub.md"

echo '<section class="copyright-page" epub:type="copyright-page">' >> "$PROJECT_ROOT/temp_book_for_epub.md"
cat "$PROJECT_ROOT/book_content/front_matter/copyright_page.md" >> "$PROJECT_ROOT/temp_book_for_epub.md"
echo '</section>' >> "$PROJECT_ROOT/temp_book_for_epub.md"
echo "" >> "$PROJECT_ROOT/temp_book_for_epub.md"

echo '<section class="dedication" epub:type="dedication">' >> "$PROJECT_ROOT/temp_book_for_epub.md"
cat "$PROJECT_ROOT/book_content/front_matter/dedication.md" >> "$PROJECT_ROOT/temp_book_for_epub.md"
echo '</section>' >> "$PROJECT_ROOT/temp_book_for_epub.md"
echo "" >> "$PROJECT_ROOT/temp_book_for_epub.md"

echo '<section class="toc" epub:type="frontmatter toc">' >> "$PROJECT_ROOT/temp_book_for_epub.md"
cat "$PROJECT_ROOT/book_content/front_matter/table_of_contents.md" >> "$PROJECT_ROOT/temp_book_for_epub.md"
echo '</section>' >> "$PROJECT_ROOT/temp_book_for_epub.md"
echo "" >> "$PROJECT_ROOT/temp_book_for_epub.md"

echo '<section class="preface" epub:type="preface">' >> "$PROJECT_ROOT/temp_book_for_epub.md"
cat "$PROJECT_ROOT/book_content/front_matter/preface.md" >> "$PROJECT_ROOT/temp_book_for_epub.md"
echo '</section>' >> "$PROJECT_ROOT/temp_book_for_epub.md"
echo "" >> "$PROJECT_ROOT/temp_book_for_epub.md"

# Add chapters
echo "   → Adding chapters..."
chapter_num=1
while IFS= read -r chapter; do
    if [ -n "$chapter" ]; then
        echo "<section class=\"chapter\" epub:type=\"chapter\" id=\"chapter-$chapter_num\">" >> "$PROJECT_ROOT/temp_book_for_epub.md"
        cat "$chapter" >> "$PROJECT_ROOT/temp_book_for_epub.md"
        echo '</section>' >> "$PROJECT_ROOT/temp_book_for_epub.md"
        echo "" >> "$PROJECT_ROOT/temp_book_for_epub.md"
        chapter_num=$((chapter_num + 1))
    fi
done <<< "$CHAPTERS"

# Add conclusion
if [ "$HAS_CONCLUSION" = "True" ] && [ -f "$PROJECT_ROOT/book_content/chapters/conclusion.md" ]; then
    echo '<section class="chapter" epub:type="chapter conclusion" id="conclusion">' >> "$PROJECT_ROOT/temp_book_for_epub.md"
    cat "$PROJECT_ROOT/book_content/chapters/conclusion.md" >> "$PROJECT_ROOT/temp_book_for_epub.md"
    echo '</section>' >> "$PROJECT_ROOT/temp_book_for_epub.md"
    echo "" >> "$PROJECT_ROOT/temp_book_for_epub.md"
fi

# Add back matter (appendices, references, acknowledgments)
if [ -f "$PROJECT_ROOT/book_content/back_matter/acknowledgments.md" ]; then
    echo '<section class="acknowledgments" epub:type="acknowledgments" id="acknowledgments">' >> "$PROJECT_ROOT/temp_book_for_epub.md"
    cat "$PROJECT_ROOT/book_content/back_matter/acknowledgments.md" >> "$PROJECT_ROOT/temp_book_for_epub.md"
    echo '</section>' >> "$PROJECT_ROOT/temp_book_for_epub.md"
    echo "" >> "$PROJECT_ROOT/temp_book_for_epub.md"
fi

# Generate EPUB
echo "   → Converting to EPUB..."

COVER_FLAG=""
if [ -n "$COVER_IMAGE" ] && [ "$COVER_IMAGE" != '""' ] && [ -f "$PROJECT_ROOT/$COVER_IMAGE" ]; then
    COVER_FLAG="--epub-cover-image=$PROJECT_ROOT/$COVER_IMAGE"
fi

CSS_PATH="$PROJECT_ROOT/$EPUB_CSS"

pandoc "$PROJECT_ROOT/temp_book_for_epub.md" \
    -o "$OUTPUT_FILE" \
    $COVER_FLAG \
    --css="$CSS_PATH" \
    --toc \
    --toc-depth=3 \
    --epub-chapter-level=2 \
    --metadata title="$BOOK_TITLE" \
    --metadata subtitle="$BOOK_SUBTITLE" \
    --metadata publisher="$BOOK_PUBLISHER" \
    --metadata date="$BOOK_DATE" \
    --metadata language="$BOOK_LANGUAGE" \
    --metadata description="$BOOK_DESCRIPTION" \
    --metadata rights="$BOOK_RIGHTS"

if [ $? -eq 0 ]; then
    echo "✅ EPUB created: $OUTPUT_FILE"
    
    # Fix EPUB links if tool available
    if [ -f "$PROJECT_ROOT/tools/fix_epub_links.py" ]; then
        echo "   → Fixing EPUB links..."
        python3 "$PROJECT_ROOT/tools/fix_epub_links.py" "$OUTPUT_FILE" || echo "   ⚠️  Link fixing failed (continuing...)"
    fi
    
    # Validate EPUB if epubcheck available
    if command -v epubcheck &> /dev/null; then
        echo "   → Validating EPUB..."
        epubcheck "$OUTPUT_FILE" || echo "   ⚠️  Validation found issues"
    fi
    
    ls -lh "$OUTPUT_FILE"
    exit 0
else
    echo "❌ EPUB generation failed"
    exit 1
fi
