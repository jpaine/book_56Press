#!/usr/bin/env python3
"""
Detect chapter files in the chapters directory with flexible naming.
Supports multiple naming patterns and returns sorted list.
"""

import os
import sys
import re
from pathlib import Path

def detect_chapters(chapters_dir="book_content/chapters"):
    """
    Auto-detect chapter files with flexible naming patterns.
    
    Supported patterns:
    - chapter_1.md, chapter_2.md
    - chapter_01.md, chapter_02.md
    - ch1.md, ch2.md
    - chapter_1_draft.md
    - 01.md, 02.md
    
    Args:
        chapters_dir: Path to chapters directory
        
    Returns:
        List of chapter file paths, sorted by chapter number
    """
    chapters_path = Path(chapters_dir)
    
    if not chapters_path.exists():
        return []
    
    chapters = []
    
    # Pattern to extract chapter number from filename
    patterns = [
        (r'chapter[_\s]*(\d+)', 1),  # chapter_1, chapter_01, chapter 1
        (r'ch[_\s]*(\d+)', 1),       # ch1, ch_1, ch 1
        (r'^(\d+)\.md$', 1),         # 01.md, 1.md
        (r'^(\d+)_', 1),             # 01_title.md
    ]
    
    for file_path in chapters_path.iterdir():
        if not file_path.is_file():
            continue
        
        filename = file_path.name.lower()
        
        # Skip conclusion and non-markdown files
        if 'conclusion' in filename:
            continue
        
        if not filename.endswith('.md'):
            continue
        
        # Try to extract chapter number
        chapter_num = None
        for pattern, group in patterns:
            match = re.search(pattern, filename)
            if match:
                try:
                    chapter_num = int(match.group(group))
                    break
                except (ValueError, IndexError):
                    continue
        
        if chapter_num is not None:
            chapters.append((chapter_num, str(file_path)))
    
    # Sort by chapter number
    chapters.sort(key=lambda x: x[0])
    
    # Return just the file paths
    return [path for _, path in chapters]

def main():
    """CLI interface"""
    if len(sys.argv) > 1:
        chapters_dir = sys.argv[1]
    else:
        chapters_dir = "book_content/chapters"
    
    chapters = detect_chapters(chapters_dir)
    
    if chapters:
        for chapter in chapters:
            print(chapter)
        return 0
    else:
        print("No chapters found", file=sys.stderr)
        return 1

if __name__ == "__main__":
    sys.exit(main())
