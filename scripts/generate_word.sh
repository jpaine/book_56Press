#!/usr/bin/env bash
# Generate Professional Word Document

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
print(f"WORD_TEMPLATE='{styles.get('word_template', 'styles/word_template.docx')}'")
PYEOF
)

# Get output filename from config or generate from title
WORD_FILENAME_CONFIG=$(python3 << EOF
import yaml
with open("$CONFIG_FILE", 'r') as f:
    config = yaml.safe_load(f)
print(config.get('output', {}).get('word_filename', ''))
EOF
)

if [ -z "$WORD_FILENAME_CONFIG" ] || [ "$WORD_FILENAME_CONFIG" = '""' ]; then
    WORD_FILENAME=$(echo "$BOOK_TITLE" | "$PROJECT_ROOT/tools/sanitize_filename.py")
    WORD_FILENAME="${WORD_FILENAME}_Print_Professional.docx"
else
    WORD_FILENAME=$(basename "$WORD_FILENAME_CONFIG")
fi

OUTPUT_PATH="$PROJECT_ROOT/$OUTPUT_DIR"
mkdir -p "$OUTPUT_PATH"

OUTPUT_FILE="$OUTPUT_PATH/$WORD_FILENAME"
TEMPLATE_PATH="$PROJECT_ROOT/$WORD_TEMPLATE"

# Cleanup function
cleanup() {
    rm -f "$PROJECT_ROOT/temp_book_for_word.md"
}
trap cleanup EXIT

echo "📝 Generating Professional Word Document..."
echo ""

# Check template exists
if [ ! -f "$TEMPLATE_PATH" ]; then
    echo "⚠️  Word template not found: $TEMPLATE_PATH"
    echo "   Continuing without template..."
    TEMPLATE_FLAG=""
else
    TEMPLATE_FLAG="--reference-doc=$TEMPLATE_PATH"
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

cat > "$PROJECT_ROOT/temp_book_for_word.md" << EOF
---
title: "$BOOK_TITLE"
subtitle: "$BOOK_SUBTITLE"
publisher: "$BOOK_PUBLISHER"
date: "$BOOK_DATE"
---

EOF

# Add front matter
echo "   → Adding front matter..."

cat "$PROJECT_ROOT/book_content/front_matter/title_page.md" >> "$PROJECT_ROOT/temp_book_for_word.md"
echo "" >> "$PROJECT_ROOT/temp_book_for_word.md"
echo "\\newpage" >> "$PROJECT_ROOT/temp_book_for_word.md"
echo "" >> "$PROJECT_ROOT/temp_book_for_word.md"

cat "$PROJECT_ROOT/book_content/front_matter/copyright_page.md" >> "$PROJECT_ROOT/temp_book_for_word.md"
echo "" >> "$PROJECT_ROOT/temp_book_for_word.md"
echo "\\newpage" >> "$PROJECT_ROOT/temp_book_for_word.md"
echo "" >> "$PROJECT_ROOT/temp_book_for_word.md"

cat "$PROJECT_ROOT/book_content/front_matter/dedication.md" >> "$PROJECT_ROOT/temp_book_for_word.md"
echo "" >> "$PROJECT_ROOT/temp_book_for_word.md"
echo "\\newpage" >> "$PROJECT_ROOT/temp_book_for_word.md"
echo "" >> "$PROJECT_ROOT/temp_book_for_word.md"

cat "$PROJECT_ROOT/book_content/front_matter/table_of_contents.md" >> "$PROJECT_ROOT/temp_book_for_word.md"
echo "" >> "$PROJECT_ROOT/temp_book_for_word.md"
echo "\\newpage" >> "$PROJECT_ROOT/temp_book_for_word.md"
echo "" >> "$PROJECT_ROOT/temp_book_for_word.md"

cat "$PROJECT_ROOT/book_content/front_matter/preface.md" >> "$PROJECT_ROOT/temp_book_for_word.md"
echo "" >> "$PROJECT_ROOT/temp_book_for_word.md"
echo "\\newpage" >> "$PROJECT_ROOT/temp_book_for_word.md"
echo "" >> "$PROJECT_ROOT/temp_book_for_word.md"

# Add chapters
echo "   → Adding chapters..."
while IFS= read -r chapter; do
    if [ -n "$chapter" ]; then
        cat "$chapter" >> "$PROJECT_ROOT/temp_book_for_word.md"
        echo "" >> "$PROJECT_ROOT/temp_book_for_word.md"
        echo "\\newpage" >> "$PROJECT_ROOT/temp_book_for_word.md"
        echo "" >> "$PROJECT_ROOT/temp_book_for_word.md"
    fi
done <<< "$CHAPTERS"

# Add conclusion
if [ "$HAS_CONCLUSION" = "True" ] && [ -f "$PROJECT_ROOT/book_content/chapters/conclusion.md" ]; then
    cat "$PROJECT_ROOT/book_content/chapters/conclusion.md" >> "$PROJECT_ROOT/temp_book_for_word.md"
    echo "" >> "$PROJECT_ROOT/temp_book_for_word.md"
    echo "\\newpage" >> "$PROJECT_ROOT/temp_book_for_word.md"
    echo "" >> "$PROJECT_ROOT/temp_book_for_word.md"
fi

# Add back matter
if [ -f "$PROJECT_ROOT/book_content/back_matter/acknowledgments.md" ]; then
    cat "$PROJECT_ROOT/book_content/back_matter/acknowledgments.md" >> "$PROJECT_ROOT/temp_book_for_word.md"
    echo "" >> "$PROJECT_ROOT/temp_book_for_word.md"
fi

# Generate Word document
echo "   → Converting to Word..."

pandoc "$PROJECT_ROOT/temp_book_for_word.md" \
    -o "$OUTPUT_FILE" \
    $TEMPLATE_FLAG \
    --toc \
    --toc-depth=3 \
    --metadata title="$BOOK_TITLE" \
    --metadata subtitle="$BOOK_SUBTITLE" \
    --metadata publisher="$BOOK_PUBLISHER" \
    --metadata date="$BOOK_DATE"

if [ $? -eq 0 ]; then
    echo "✅ Word document created: $OUTPUT_FILE"
    
    # Post-process Word document if tool available
    if [ -f "$PROJECT_ROOT/tools/format_word.py" ]; then
        echo "   → Formatting Word document..."
        python3 "$PROJECT_ROOT/tools/format_word.py" "$OUTPUT_FILE" || echo "   ⚠️  Formatting failed (continuing...)"
    fi
    
    ls -lh "$OUTPUT_FILE"
    exit 0
else
    echo "❌ Word document generation failed"
    exit 1
fi

