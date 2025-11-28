#!/usr/bin/env python3
"""
Fix broken links in EPUB file by:
1. Removing broken references from toc.ncx
2. Creating nav.xhtml for EPUB 3 compliance
3. Fixing content.opf (add nav, fix guide)
4. Repackaging EPUB
"""

import os
import sys
import zipfile
import xml.etree.ElementTree as ET
from pathlib import Path
import tempfile
import shutil

def extract_epub(epub_path, extract_dir):
    """Extract EPUB to directory"""
    with zipfile.ZipFile(epub_path, 'r') as zip_ref:
        zip_ref.extractall(extract_dir)

def get_existing_files(extract_dir):
    """Get list of existing xhtml files"""
    text_dir = Path(extract_dir) / "EPUB" / "text"
    if not text_dir.exists():
        return set()
    return {f.name for f in text_dir.glob("*.xhtml")}

def fix_toc_ncx(extract_dir, existing_files):
    """Remove broken references from toc.ncx"""
    toc_path = Path(extract_dir) / "EPUB" / "toc.ncx"
    if not toc_path.exists():
        return
    
    # Read file as text to handle namespace issues
    content = toc_path.read_text(encoding='utf-8')
    
    # Parse with namespace handling
    tree = ET.parse(toc_path)
    root = tree.getroot()
    
    # Register namespace
    ET.register_namespace('', 'http://www.daisy.org/z3986/2005/ncx/')
    
    # Find navMap
    nav_map = root.find('{http://www.daisy.org/z3986/2005/ncx/}navMap')
    if nav_map is None:
        # Try without namespace
        nav_map = root.find('navMap')
    
    if nav_map is None:
        print("   ⚠️  Could not find navMap in toc.ncx")
        return
    
    removed_count = 0
    
    def remove_broken_navpoints(element):
        """Recursively remove navPoints with broken links"""
        nonlocal removed_count
        # Find all navPoint children
        nav_points = list(element.findall('{http://www.daisy.org/z3986/2005/ncx/}navPoint') or 
                         element.findall('navPoint') or [])
        
        for nav_point in nav_points:
            # Check content
            content = (nav_point.find('{http://www.daisy.org/z3986/2005/ncx/}content') or 
                      nav_point.find('content'))
            
            if content is not None:
                src = content.get('src', '')
                if src:
                    # Extract filename from src (e.g., "text/ch008.xhtml" -> "ch008.xhtml")
                    filename = src.split('/')[-1].split('#')[0]
                    if filename not in existing_files:
                        # Remove this navPoint
                        element.remove(nav_point)
                        removed_count += 1
                        continue
            
            # Recursively check nested navPoints
            remove_broken_navpoints(nav_point)
    
    remove_broken_navpoints(nav_map)
    
    tree.write(toc_path, encoding='utf-8', xml_declaration=True)
    print(f"   ✅ Removed {removed_count} broken references from toc.ncx")

def create_nav_xhtml(extract_dir, existing_files):
    """Create nav.xhtml for EPUB 3 compliance"""
    nav_path = Path(extract_dir) / "EPUB" / "nav.xhtml"
    
    # Read toc.ncx to build nav structure
    toc_path = Path(extract_dir) / "EPUB" / "toc.ncx"
    if not toc_path.exists():
        return
    
    tree = ET.parse(toc_path)
    root = tree.getroot()
    ns = {'ncx': 'http://www.daisy.org/z3986/2005/ncx/'}
    
    nav_content = '''<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" xmlns:epub="http://www.idpf.org/2007/ops">
<head>
    <title>Table of Contents</title>
    <meta charset="utf-8"/>
</head>
<body>
    <nav epub:type="toc" id="toc">
        <h1>Table of Contents</h1>
        <ol>
'''
    
    # Build nav structure from toc.ncx
    nav_points = root.findall('.//ncx:navPoint', ns)
    if not nav_points:
        nav_points = root.findall('.//navPoint')
    
    for nav_point in nav_points:
        nav_label = nav_point.find('navLabel')
        content = nav_point.find('content')
        if nav_label is not None and content is not None:
            label_text = nav_label.find('text')
            if label_text is not None:
                label = label_text.text or ''
                src = content.get('src', '')
                filename = src.split('/')[-1].split('#')[0]
                if filename in existing_files:
                    # Escape HTML
                    label = label.replace('&', '&amp;').replace('<', '&lt;').replace('>', '&gt;')
                    nav_content += f'            <li><a href="{src}">{label}</a></li>\n'
    
    nav_content += '''        </ol>
    </nav>
</body>
</html>'''
    
    nav_path.write_text(nav_content, encoding='utf-8')
    print(f"   ✅ Created nav.xhtml")

def fix_content_opf(extract_dir, existing_files):
    """Fix content.opf: add nav, fix guide"""
    opf_path = Path(extract_dir) / "EPUB" / "content.opf"
    if not opf_path.exists():
        return
    
    # Read as text first to preserve formatting
    content = opf_path.read_text(encoding='utf-8')
    
    tree = ET.parse(opf_path)
    root = tree.getroot()
    
    # Register namespaces
    ET.register_namespace('opf', 'http://www.idpf.org/2007/opf')
    ET.register_namespace('dc', 'http://purl.org/dc/elements/1.1/')
    
    # Find manifest
    manifest = (root.find('{http://www.idpf.org/2007/opf}manifest') or 
               root.find('manifest'))
    
    if manifest is None:
        print("   ⚠️  Could not find manifest in content.opf")
        return
    
    # Check if nav already exists
    nav_exists = False
    for item in manifest.findall('{http://www.idpf.org/2007/opf}item') or manifest.findall('item'):
        if item.get('properties') == 'nav' or 'nav.xhtml' in item.get('href', ''):
            nav_exists = True
            break
    
    # Add nav to manifest if it doesn't exist
    if not nav_exists:
        # Use the correct namespace for the item
        ns = {'opf': 'http://www.idpf.org/2007/opf'}
        nav_item = ET.SubElement(manifest, '{http://www.idpf.org/2007/opf}item')
        nav_item.set('id', 'nav')
        nav_item.set('href', 'nav.xhtml')
        nav_item.set('media-type', 'application/xhtml+xml')
        nav_item.set('properties', 'nav')
        print(f"   ✅ Added nav.xhtml to manifest")
    
    # Fix guide element - either remove it or add proper references
    guide = (root.find('{http://www.idpf.org/2007/opf}guide') or 
             root.find('guide'))
    
    if guide is not None:
        # Remove empty guide or add proper references
        if len(guide) == 0:
            # For EPUB 3, guide is optional, but if present should have references
            # We'll remove it since we have nav.xhtml
            root.remove(guide)
            print(f"   ✅ Removed empty guide element")
    
    tree.write(opf_path, encoding='utf-8', xml_declaration=True)
    print(f"   ✅ Fixed content.opf")

def repackage_epub(extract_dir, output_path):
    """Repackage EPUB from directory"""
    # EPUB files must be in specific order: mimetype first, uncompressed
    epub_path = Path(output_path)
    if epub_path.exists():
        epub_path.unlink()
    
    with zipfile.ZipFile(epub_path, 'w', zipfile.ZIP_DEFLATED) as zipf:
        # Add mimetype first, uncompressed
        mimetype_path = Path(extract_dir) / "mimetype"
        if mimetype_path.exists():
            zipf.write(mimetype_path, "mimetype", compress_type=zipfile.ZIP_STORED)
        
        # Add all other files
        for root, dirs, files in os.walk(extract_dir):
            # Skip mimetype (already added)
            if 'mimetype' in files:
                files.remove('mimetype')
            
            for file in files:
                file_path = Path(root) / file
                arcname = file_path.relative_to(extract_dir)
                zipf.write(file_path, arcname)
    
    print(f"   ✅ Repackaged EPUB: {output_path}")

def main():
    epub_path = Path("/Users/jeffreypaine/writing/How to get into YC/output/How to Get into YCombinator.epub")
    
    if not epub_path.exists():
        print(f"❌ EPUB file not found: {epub_path}")
        sys.exit(1)
    
    print(f"📖 Fixing EPUB: {epub_path}")
    print()
    
    # Create temporary extraction directory
    with tempfile.TemporaryDirectory() as temp_dir:
        extract_dir = Path(temp_dir) / "epub"
        
        print("   → Extracting EPUB...")
        extract_epub(epub_path, extract_dir)
        
        print("   → Analyzing existing files...")
        existing_files = get_existing_files(extract_dir)
        print(f"   ✅ Found {len(existing_files)} existing xhtml files")
        
        print("   → Fixing toc.ncx...")
        fix_toc_ncx(extract_dir, existing_files)
        
        print("   → Creating nav.xhtml...")
        create_nav_xhtml(extract_dir, existing_files)
        
        print("   → Fixing content.opf...")
        fix_content_opf(extract_dir, existing_files)
        
        print("   → Repackaging EPUB...")
        repackage_epub(extract_dir, epub_path)
    
    print()
    print("✅ EPUB fixed successfully!")
    print()
    print("📋 Validating with epubcheck...")
    os.system(f'epubcheck "{epub_path}"')

if __name__ == "__main__":
    main()

