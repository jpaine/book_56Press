#!/usr/bin/env bash
# Check content files exist and are valid

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

errors=0
warnings=0

check_file_not_empty() {
    local file="$1"
    if [ ! -f "$file" ]; then
        echo -e "${RED}❌ File missing: $file${NC}"
        return 1
    elif [ ! -s "$file" ]; then
        echo -e "${YELLOW}⚠️  File is empty: $file${NC}"
        return 2
    else
        local size
        size=$(wc -c < "$file" | tr -d ' ')
        echo -e "${GREEN}✅ File OK: $file${NC} (${size} bytes)"
        return 0
    fi
}

check_image() {
    local file="$1"
    if [ ! -f "$file" ]; then
        echo -e "${YELLOW}⚠️  Cover image not found: $file${NC}"
        return 1
    fi
    
    # Check if it's an image file
    if file "$file" | grep -qi "image"; then
        local size
        size=$(stat -f%z "$file" 2>/dev/null || stat -c%s "$file" 2>/dev/null || echo "unknown")
        echo -e "${GREEN}✅ Cover image found: $file${NC} (${size} bytes)"
        
        # Check file size (should be < 2MB for KDP)
        if [ "$size" != "unknown" ] && [ "$size" -gt 2097152 ]; then
            echo -e "${YELLOW}⚠️  Cover image is large (>2MB), may cause issues${NC}"
            warnings=$((warnings + 1))
        fi
        return 0
    else
        echo -e "${RED}❌ Not a valid image file: $file${NC}"
        return 1
    fi
}

echo "Checking content files..."
echo ""

# Check chapters
echo "Checking chapters..."
chapters=$("$PROJECT_ROOT/tools/detect_chapters.py" "$PROJECT_ROOT/book_content/chapters" 2>/dev/null || echo "")
if [ -n "$chapters" ]; then
    while IFS= read -r chapter; do
        if [ -n "$chapter" ]; then
            check_file_not_empty "$chapter"
            case $? in
                1) errors=$((errors + 1));;
                2) warnings=$((warnings + 1));;
            esac
        fi
    done <<< "$chapters"
else
    echo -e "${RED}❌ No chapters found${NC}"
    errors=$((errors + 1))
fi

echo ""

# Check conclusion if it exists
if [ -f "$PROJECT_ROOT/book_content/chapters/conclusion.md" ]; then
    check_file_not_empty "$PROJECT_ROOT/book_content/chapters/conclusion.md"
    case $? in
        1) errors=$((errors + 1));;
        2) warnings=$((warnings + 1));;
    esac
fi

echo ""

# Check front matter
echo "Checking front matter..."
FRONT_MATTER_FILES=(
    "title_page.md"
    "copyright_page.md"
    "dedication.md"
    "table_of_contents.md"
    "preface.md"
)

for file in "${FRONT_MATTER_FILES[@]}"; do
    check_file_not_empty "$PROJECT_ROOT/book_content/front_matter/$file"
    case $? in
        1) errors=$((errors + 1));;
        2) warnings=$((warnings + 1));;
    esac
done

echo ""

# Check cover image if specified in config
if [ -f "$PROJECT_ROOT/config.yaml" ]; then
    cover_path=$(grep -A 20 "^structure:" "$PROJECT_ROOT/config.yaml" | grep "cover_image:" | awk '{print $2}' | tr -d '"' || echo "")
    if [ -n "$cover_path" ] && [ "$cover_path" != "null" ]; then
        echo "Checking cover image..."
        check_image "$PROJECT_ROOT/$cover_path"
        if [ $? -eq 1 ]; then
            warnings=$((warnings + 1))
        fi
        echo ""
    fi
fi

# Summary
if [ $errors -gt 0 ]; then
    echo -e "${RED}❌ Content check failed with $errors error(s)${NC}"
    if [ $warnings -gt 0 ]; then
        echo -e "${YELLOW}⚠️  $warnings warning(s)${NC}"
    fi
    exit 1
elif [ $warnings -gt 0 ]; then
    echo -e "${YELLOW}⚠️  Content check passed with $warnings warning(s)${NC}"
    exit 0
else
    echo -e "${GREEN}✅ Content check passed${NC}"
    exit 0
fi
