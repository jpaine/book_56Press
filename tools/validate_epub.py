#!/usr/bin/env python3
"""
EPUB validation wrapper with better error reporting.
"""

import sys
import subprocess
import re

def validate_epub(epub_path):
    """
    Validate EPUB file using epubcheck.
    
    Args:
        epub_path: Path to EPUB file
        
    Returns:
        0 if valid, 1 if invalid, 2 if epubcheck not available
    """
    # Check if epubcheck is available
    try:
        result = subprocess.run(['epubcheck', '--version'], 
                               capture_output=True, 
                               text=True,
                               timeout=5)
    except (FileNotFoundError, subprocess.TimeoutExpired):
        print("⚠️  epubcheck not available. Install for EPUB validation.", file=sys.stderr)
        return 2
    
    # Run epubcheck
    try:
        result = subprocess.run(['epubcheck', epub_path],
                               capture_output=True,
                               text=True,
                               timeout=30)
        
        if result.returncode == 0:
            print("✅ EPUB validation passed")
            return 0
        else:
            # Parse errors and warnings
            output = result.stdout + result.stderr
            
            # Count errors and warnings
            errors = len(re.findall(r'ERROR', output))
            warnings = len(re.findall(r'WARNING', output))
            
            if errors > 0:
                print(f"❌ EPUB validation failed: {errors} error(s), {warnings} warning(s)", file=sys.stderr)
                # Print first few errors
                error_lines = [line for line in output.split('\n') if 'ERROR' in line]
                for line in error_lines[:5]:
                    print(f"   {line}", file=sys.stderr)
                if len(error_lines) > 5:
                    print(f"   ... and {len(error_lines) - 5} more errors", file=sys.stderr)
            elif warnings > 0:
                print(f"⚠️  EPUB validation passed with {warnings} warning(s)")
            
            return 1 if errors > 0 else 0
            
    except subprocess.TimeoutExpired:
        print("❌ EPUB validation timed out", file=sys.stderr)
        return 1
    except Exception as e:
        print(f"❌ EPUB validation error: {e}", file=sys.stderr)
        return 1

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: validate_epub.py <epub_file.epub>", file=sys.stderr)
        sys.exit(1)
    
    epub_path = sys.argv[1]
    sys.exit(validate_epub(epub_path))
