#!/usr/bin/env bash
# Validate config.yaml file

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CONFIG_FILE="${1:-$PROJECT_ROOT/config.yaml}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

errors=0
warnings=0

echo "Validating config.yaml..."

# Check if config file exists
if [ ! -f "$CONFIG_FILE" ]; then
    echo -e "${RED}❌ Config file not found: $CONFIG_FILE${NC}"
    exit 1
fi

# Check if Python is available for YAML parsing
if ! command -v python3 &> /dev/null; then
    echo -e "${YELLOW}⚠️  Python3 not found. Basic validation only.${NC}"
    # Basic checks without YAML parsing
    if ! grep -q "book:" "$CONFIG_FILE"; then
        echo -e "${RED}❌ Missing 'book:' section${NC}"
        errors=$((errors + 1))
    fi
    exit $errors
fi

# Use Python to validate YAML and check required fields
python3 << EOF
import sys
import yaml
from pathlib import Path

try:
    with open("$CONFIG_FILE", 'r') as f:
        config = yaml.safe_load(f)
    
    errors = 0
    warnings = 0
    
    # Check required sections
    required_sections = ['book', 'structure', 'output', 'styles']
    for section in required_sections:
        if section not in config:
            print(f"❌ Missing required section: {section}")
            errors += 1
    
    # Check required book fields
    if 'book' in config:
        required_book_fields = ['title', 'publisher', 'date']
        for field in required_book_fields:
            if field not in config['book'] or not config['book'][field]:
                print(f"❌ Missing required book field: {field}")
                errors += 1
    
    # Check file paths exist
    if 'styles' in config:
        for key, path in config['styles'].items():
            full_path = Path("$PROJECT_ROOT") / path
            if not full_path.exists():
                print(f"⚠️  Style file not found: {path}")
                warnings += 1
    
    # Check cover image if specified
    if 'structure' in config and 'cover_image' in config['structure']:
        cover_path = config['structure']['cover_image']
        if cover_path:
            full_path = Path("$PROJECT_ROOT") / cover_path
            if not full_path.exists():
                print(f"⚠️  Cover image not found: {cover_path}")
                warnings += 1
    
    # Check output directory
    if 'output' in config and 'output_dir' in config['output']:
        output_dir = Path("$PROJECT_ROOT") / config['output']['output_dir']
        if not output_dir.exists():
            print(f"ℹ️  Output directory will be created: {config['output']['output_dir']}")
    
    sys.exit(errors)
    
except yaml.YAMLError as e:
    print(f"❌ YAML syntax error: {e}")
    sys.exit(1)
except Exception as e:
    print(f"❌ Validation error: {e}")
    sys.exit(1)
EOF

exit_code=$?

if [ $exit_code -eq 0 ]; then
    echo -e "${GREEN}✅ Config file is valid${NC}"
    exit 0
else
    echo -e "${RED}❌ Config validation failed${NC}"
    exit $exit_code
fi
