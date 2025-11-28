#!/usr/bin/env bash
# Master validation script

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

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --verbose|-v)
            VERBOSE=true
            shift
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

echo -e "${BLUE}🔍 Running validation checks...${NC}"
echo ""

total_errors=0
total_warnings=0

# Run all checks
checks=(
    "check_dependencies.sh:Dependencies"
    "check_structure.sh:Structure"
    "check_content.sh:Content"
)

if [ -d "$PROJECT_ROOT/output" ] && [ "$(ls -A $PROJECT_ROOT/output 2>/dev/null)" ]; then
    checks+=("check_outputs.sh:Outputs")
fi

for check_info in "${checks[@]}"; do
    IFS=':' read -r check_script check_name <<< "$check_info"
    
    echo -e "${BLUE}━━━ $check_name Check ━━━${NC}"
    
    if [ "$VERBOSE" = true ]; then
        "$PROJECT_ROOT/checks/$check_script"
    else
        "$PROJECT_ROOT/checks/$check_script" 2>&1 | grep -E "(✅|❌|⚠️|Checking|Error|Warning)" || true
    fi
    
    exit_code=${PIPESTATUS[0]}
    
    if [ $exit_code -ne 0 ]; then
        total_errors=$((total_errors + 1))
    fi
    
    echo ""
done

# Summary
echo -e "${BLUE}━━━ Summary ━━━${NC}"
if [ $total_errors -gt 0 ]; then
    echo -e "${RED}❌ Validation failed with errors${NC}"
    exit 1
else
    echo -e "${GREEN}✅ All validation checks passed${NC}"
    exit 0
fi
