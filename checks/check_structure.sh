#!/usr/bin/env bash
# Check book folder structure

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

errors=0

check_dir() {
    local dir="$1"
    if [ -d "$dir" ]; then
        echo -e "${GREEN}✅ Directory exists: $dir${NC}"
        return 0
    else
        echo -e "${RED}❌ Directory missing: $dir${NC}"
        return 1
    fi
}

check_file() {
    local file="$1"
    if [ -f "$file" ]; then
        echo -e "${GREEN}✅ File exists: $file${NC}"
        return 0
    else
        echo -e "${RED}❌ File missing: $file${NC}"
        return 1
    fi
}

echo "Checking book structure..."
echo ""

# Check main directories
if ! check_dir "$PROJECT_ROOT/book_content"; then
    errors=$((errors + 1))
fi

if ! check_dir "$PROJECT_ROOT/book_content/front_matter"; then
    errors=$((errors + 1))
fi

if ! check_dir "$PROJECT_ROOT/book_content/chapters"; then
    errors=$((errors + 1))
fi

if ! check_dir "$PROJECT_ROOT/book_content/back_matter"; then
    errors=$((errors + 1))
fi

echo ""

# Check required front matter files
echo "Checking front matter files..."
REQUIRED_FRONT_MATTER=(
    "title_page.md"
    "copyright_page.md"
    "dedication.md"
    "table_of_contents.md"
    "preface.md"
)

for file in "${REQUIRED_FRONT_MATTER[@]}"; do
    if ! check_file "$PROJECT_ROOT/book_content/front_matter/$file"; then
        errors=$((errors + 1))
    fi
done

echo ""

# Check for chapters using dynamic detection
echo "Checking chapters..."
if [ -d "$PROJECT_ROOT/book_content/chapters" ]; then
    chapters=$("$PROJECT_ROOT/tools/detect_chapters.py" "$PROJECT_ROOT/book_content/chapters" 2>/dev/null || echo "")
    if [ -n "$chapters" ]; then
        chapter_count=$(echo "$chapters" | wc -l | tr -d ' ')
        echo -e "${GREEN}✅ Found $chapter_count chapter(s)${NC}"
        if [ "$chapter_count" -eq 0 ]; then
            echo -e "${YELLOW}⚠️  No chapters found${NC}"
            errors=$((errors + 1))
        fi
    else
        echo -e "${RED}❌ No chapters found${NC}"
        errors=$((errors + 1))
    fi
else
    errors=$((errors + 1))
fi

echo ""

if [ $errors -gt 0 ]; then
    echo -e "${RED}❌ Structure check failed with $errors error(s)${NC}"
    exit 1
else
    echo -e "${GREEN}✅ Structure check passed${NC}"
    exit 0
fi
