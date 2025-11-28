#!/usr/bin/env bash
# Master script to generate all formats

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

VERBOSE=false
QUIET=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --verbose|-v)
            VERBOSE=true
            shift
            ;;
        --quiet|-q)
            QUIET=true
            shift
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

log() {
    if [ "$QUIET" = false ]; then
        echo "$@"
    fi
}

log_error() {
    echo -e "${RED}$@${NC}" >&2
}

log_success() {
    if [ "$QUIET" = false ]; then
        echo -e "${GREEN}$@${NC}"
    fi
}

log_info() {
    if [ "$QUIET" = false ]; then
        echo -e "${BLUE}$@${NC}"
    fi
}

log_warning() {
    echo -e "${YELLOW}$@${NC}"
}

log ""
log_info "═══════════════════════════════════════════════════════════"
log_info "📚 Ebook Generation Engine - Generate All Formats"
log_info "═══════════════════════════════════════════════════════════"
log ""

# Validate config
log_info "Step 1: Validating configuration..."
if ! "$SCRIPT_DIR/validate_config.sh" "$PROJECT_ROOT/config.yaml" > /dev/null 2>&1; then
    log_error "❌ Config validation failed. Run: ./scripts/validate_config.sh"
    exit 1
fi
log_success "✅ Config valid"
log ""

# Pre-generation validation
log_info "Step 2: Running pre-generation checks..."
if [ "$VERBOSE" = true ]; then
    "$PROJECT_ROOT/scripts/validate.sh" --verbose || true
else
    "$PROJECT_ROOT/scripts/validate.sh" 2>&1 | grep -E "(✅|❌|⚠️|Checking)" || true
fi
log ""

# Generate formats
log_info "Step 3: Generating formats..."
log ""

EPUB_SUCCESS=false
PDF_SUCCESS=false
WORD_SUCCESS=false

# Generate EPUB
log_info "━━━ Generating EPUB ━━━"
if "$SCRIPT_DIR/generate_epub.sh"; then
    EPUB_SUCCESS=true
    log_success "✅ EPUB generation successful"
else
    log_error "❌ EPUB generation failed"
fi
log ""

# Generate PDF
log_info "━━━ Generating PDF ━━━"
if "$SCRIPT_DIR/generate_pdf.sh"; then
    PDF_SUCCESS=true
    log_success "✅ PDF generation successful"
else
    log_error "❌ PDF generation failed"
fi
log ""

# Generate Word
log_info "━━━ Generating Word ━━━"
if "$SCRIPT_DIR/generate_word.sh"; then
    WORD_SUCCESS=true
    log_success "✅ Word generation successful"
else
    log_error "❌ Word generation failed"
fi
log ""

# Post-generation validation
log_info "Step 4: Running post-generation validation..."
"$PROJECT_ROOT/checks/check_outputs.sh" || true
log ""

# Summary
log_info "═══════════════════════════════════════════════════════════"
log_info "📊 Generation Summary"
log_info "═══════════════════════════════════════════════════════════"
log ""

if [ "$EPUB_SUCCESS" = true ]; then
    log_success "✅ EPUB: Generated successfully"
else
    log_error "❌ EPUB: Generation failed"
fi

if [ "$PDF_SUCCESS" = true ]; then
    log_success "✅ PDF: Generated successfully"
else
    log_error "❌ PDF: Generation failed"
fi

if [ "$WORD_SUCCESS" = true ]; then
    log_success "✅ Word: Generated successfully"
else
    log_error "❌ Word: Generation failed"
fi

log ""

# Exit code
if [ "$EPUB_SUCCESS" = true ] && [ "$PDF_SUCCESS" = true ] && [ "$WORD_SUCCESS" = true ]; then
    log_success "🎉 All formats generated successfully!"
    exit 0
elif [ "$EPUB_SUCCESS" = true ] || [ "$PDF_SUCCESS" = true ] || [ "$WORD_SUCCESS" = true ]; then
    log_warning "⚠️  Some formats generated successfully, but some failed"
    exit 0  # Partial success
else
    log_error "❌ All format generation failed"
    exit 1
fi

