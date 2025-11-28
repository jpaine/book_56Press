#!/usr/bin/env python3
"""
Sanitize book title for use in filenames.
Converts title to a safe filename format.
"""

import sys
import re
import unicodedata

def sanitize_filename(title):
    """
    Convert a book title to a safe filename.
    
    Args:
        title: Book title string
        
    Returns:
        Sanitized filename string
    """
    if not title:
        return "book"
    
    # Convert to lowercase
    filename = title.lower()
    
    # Remove accents and special characters
    filename = unicodedata.normalize('NFKD', filename)
    filename = filename.encode('ascii', 'ignore').decode('ascii')
    
    # Replace spaces and special chars with underscores
    filename = re.sub(r'[^\w\s-]', '', filename)
    filename = re.sub(r'[-\s]+', '_', filename)
    
    # Remove leading/trailing underscores
    filename = filename.strip('_')
    
    # Limit length
    if len(filename) > 100:
        filename = filename[:100]
    
    # Ensure it's not empty
    if not filename:
        filename = "book"
    
    return filename

if __name__ == "__main__":
    if len(sys.argv) > 1:
        title = " ".join(sys.argv[1:])
        print(sanitize_filename(title))
    else:
        # Read from stdin
        title = sys.stdin.read().strip()
        print(sanitize_filename(title))
