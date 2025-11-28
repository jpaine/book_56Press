#!/usr/bin/env bash
# Check generated output files

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

# Load output directory from config
OUTPUT_DIR="output"
if [ -f "$PROJECT_ROOT/config.yaml" ]; then
    OUTPUT_DIR=$(grep -A 10 "^output:" "$PROJECT_ROOT/config.yaml" | grep "output_dir:" | awk '{print $2}' | tr -d '"' || echo "output")
fi

OUTPUT_PATH="$PROJECT_ROOT/$OUTPUT_DIR"

check_output_file() {
    local file="$1"
    local min_size="${2:-1000}"  # Default minimum 1KB
    
    if [ ! -f "$file" ]; then
        echo -e "${RED}❌ Output file missing: $file${NC}"
        return 1
    fi
    
    local size
    size=$(stat -f%z "$file" 2>/dev/null || stat -c%s "$file" 2>/dev/null || echo "0")
    
    if [ "$size" -lt "$min_size" ]; then
        echo -e "${YELLOW}⚠️  Output file seems too small: $file${NC} (${size} bytes)"
        return 2
    else
        local size_kb=$((size / 1024))
        echo -e "${GREEN}✅ Output file OK: $file${NC} (${size_kb}KB)"
        return 0
    fi
}

echo "Checking output files..."
echo ""

if [ ! -d "$OUTPUT_PATH" ]; then
    echo -e "${YELLOW}⚠️  Output directory does not exist: $OUTPUT_PATH${NC}"
    echo "   Run generation scripts first"
    exit 0
fi

# Check for EPUB
epub_files=$(find "$OUTPUT_PATH" -name "*.epub" 2>/dev/null || echo "")
if [ -n "$epub_files" ]; then
    echo "EPUB files:"
    while IFS= read -r file; do
        if [ -n "$file" ]; then
            check_output_file "$file" 50000  # EPUB should be at least 50KB
            case $? in
                1) errors=$((errors + 1));;
                2) warnings=$((warnings + 1));;
            esac
            
            # Validate EPUB if epubcheck is available
            if command -v epubcheck &> /dev/null; then
                echo "  Validating EPUB structure..."
                if epubcheck "$file" &> /dev/null; then
                    echo -e "  ${GREEN}✅ EPUB validation passed${NC}"
                else
                    echo -e "  ${YELLOW}⚠️  EPUB validation found issues${NC}"
                    warnings=$((warnings + 1))
                fi
            fi
        fi
    done <<< "$epub_files"
else
    echo -e "${YELLOW}⚠️  No EPUB files found${NC}"
    warnings=$((warnings + 1))
fi

echo ""

# Check for PDF
pdf_files=$(find "$OUTPUT_PATH" -name "*.pdf" 2>/dev/null || echo "")
if [ -n "$pdf_files" ]; then
    echo "PDF files:"
    while IFS= read -r file; do
        if [ -n "$file" ]; then
            check_output_file "$file" 100000  # PDF should be at least 100KB
            case $? in
                1) errors=$((errors + 1));;
                2) warnings=$((warnings + 1));;
            esac
        fi
    done <<< "$pdf_files"
else
    echo -e "${YELLOW}⚠️  No PDF files found${NC}"
    warnings=$((warnings + 1))
fi

echo ""

# Check for Word
docx_files=$(find "$OUTPUT_PATH" -name "*.docx" 2>/dev/null || echo "")
if [ -n "$docx_files" ]; then
    echo "Word files:"
    while IFS= read -r file; do
        if [ -n "$file" ]; then
            check_output_file "$file" 50000  # Word should be at least 50KB
            case $? in
                1) errors=$((errors + 1));;
                2) warnings=$((warnings + 1));;
            esac
        fi
    done <<< "$docx_files"
else
    echo -e "${YELLOW}⚠️  No Word files found${NC}"
    warnings=$((warnings + 1))
fi

echo ""

# Summary
if [ $errors -gt 0 ]; then
    echo -e "${RED}❌ Output check failed with $errors error(s)${NC}"
    if [ $warnings -gt 0 ]; then
        echo -e "${YELLOW}⚠️  $warnings warning(s)${NC}"
    fi
    exit 1
elif [ $warnings -gt 0 ]; then
    echo -e "${YELLOW}⚠️  Output check passed with $warnings warning(s)${NC}"
    exit 0
else
    echo -e "${GREEN}✅ All output files found and valid${NC}"
    exit 0
fi
