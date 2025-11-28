#!/usr/bin/env bash
# Check if required dependencies are installed

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

check_command() {
    local cmd="$1"
    local install_cmd="${2:-}"
    
    if command -v "$cmd" &> /dev/null; then
        local version
        version=$($cmd --version 2>/dev/null | head -n1 || echo "installed")
        echo -e "${GREEN}✅ $cmd found${NC} ($version)"
        return 0
    else
        echo -e "${RED}❌ $cmd not found${NC}"
        if [ -n "$install_cmd" ]; then
            echo "   Install with: $install_cmd"
        fi
        return 1
    fi
}

check_python_package() {
    local package="$1"
    
    if python3 -c "import $package" 2>/dev/null; then
        echo -e "${GREEN}✅ Python package $package found${NC}"
        return 0
    else
        echo -e "${RED}❌ Python package $package not found${NC}"
        echo "   Install with: pip install $package"
        return 1
    fi
}

echo "Checking dependencies..."
echo ""

# Required dependencies
if ! check_command "pandoc"; then
    errors=$((errors + 1))
fi

if ! check_command "python3"; then
    errors=$((errors + 1))
fi

if ! check_command "weasyprint" "pip install weasyprint"; then
    errors=$((errors + 1))
fi

# Required Python packages
if ! check_python_package "yaml"; then
    echo "   Note: yaml is usually included with Python"
    warnings=$((warnings + 1))
fi

if ! check_python_package "docx"; then
    errors=$((errors + 1))
fi

echo ""

# Optional dependencies
echo "Optional dependencies:"
if ! check_command "epubcheck" "brew install epubcheck (macOS) or download from GitHub"; then
    warnings=$((warnings + 1))
fi

if ! check_command "pdfinfo" "part of poppler-utils package"; then
    warnings=$((warnings + 1))
fi

echo ""

if [ $errors -gt 0 ]; then
    echo -e "${RED}❌ $errors required dependency(ies) missing${NC}"
    exit 1
elif [ $warnings -gt 0 ]; then
    echo -e "${YELLOW}⚠️  $warnings optional dependency(ies) missing (will continue)${NC}"
    exit 0
else
    echo -e "${GREEN}✅ All dependencies found${NC}"
    exit 0
fi
