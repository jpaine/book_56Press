# Ebook Generation Engine

A GitHub repository template for automated ebook generation. When cloned for a new book project, an interactive setup script configures the book, then automatically generates professional EPUB, PDF, and Word documents from a standardized Markdown book structure.

## 🚀 Quick Start (5 minutes)

### Step 1: Clone This Repository
```bash
git clone https://github.com/jpaine/book_56Press.git my-book-project
cd my-book-project
```

### Step 2: Install Dependencies
```bash
# Install Python dependencies
pip install -r requirements.txt

# Install system tools (if not already installed)
# macOS:
brew install pandoc
pip install weasyprint

# Linux:
sudo apt install pandoc
pip install weasyprint
```

### Step 3: Run Setup
```bash
./scripts/setup_project.sh
```
This interactive script will:
- Ask you questions about your book (title, author, publisher, etc.)
- Create the `book_content/` folder structure
- Generate `config.yaml` with your book settings
- Create placeholder markdown files

### Step 4: Add Your Content
Edit the markdown files created in `book_content/`:
- **Front matter**: `book_content/front_matter/` (title, copyright, dedication, preface)
- **Chapters**: `book_content/chapters/` (your chapter files)
- **Back matter**: `book_content/back_matter/` (acknowledgments, appendices)

**Chapter naming**: Use `chapter_1.md`, `chapter_2.md`, etc. (or `ch1.md`, `01.md` - flexible naming supported)

### Step 5: Generate Your Book
```bash
./scripts/generate_all.sh
```

This generates:
- **EPUB**: `output/[book_title]_Professional.epub` (for Kindle, Apple Books, etc.)
- **PDF**: `output/[book_title]_Print_Professional.pdf` (for KDP Print, IngramSpark)
- **Word**: `output/[book_title]_Print_Professional.docx` (for further editing)

### Step 6: Review and Publish
- Check files in `output/` folder
- Test EPUB in Kindle Previewer or Apple Books
- Review PDF formatting
- Upload to your publishing platform (Amazon KDP, Apple Books, etc.)

## 📋 Installation Requirements

### Required Tools

- **Pandoc**: Document converter
  - macOS: `brew install pandoc`
  - Linux: `sudo apt install pandoc`
  - Windows: Download from [pandoc.org](https://pandoc.org/installing.html)

- **Python 3**: For scripts and tools
  - Usually pre-installed on macOS/Linux
  - Windows: Download from [python.org](https://www.python.org/downloads/)

- **WeasyPrint**: PDF generation
  - Install: `pip install weasyprint`

### Python Dependencies

Install required Python packages:
```bash
pip install -r requirements.txt
```

This installs:
- `python-docx` - Word document formatting
- `PyYAML` - Config file parsing

### Optional Tools

- **epubcheck**: EPUB validation
  - macOS: `brew install epubcheck`
  - Download from [GitHub](https://github.com/w3c/epubcheck/releases)

- **pdfinfo**: PDF information (part of poppler-utils)
  - macOS: `brew install poppler`
  - Linux: `sudo apt install poppler-utils`

## 📁 Project Structure

```
ebook_engine/
├── book_content/          # Your book content (created by setup)
│   ├── front_matter/     # Title, copyright, dedication, TOC, preface
│   ├── chapters/         # Your chapters (flexible naming)
│   └── back_matter/      # Acknowledgments, appendices, references
├── config.yaml           # Book configuration (created by setup)
├── output/               # Generated files (EPUB, PDF, Word)
├── scripts/              # Generation scripts
├── tools/                # Python utilities
├── checks/               # Validation scripts
├── styles/               # CSS and templates
└── templates/            # Example files
```

## ⚙️ Configuration

Edit `config.yaml` to customize your book:

```yaml
book:
  title: "Your Book Title"
  subtitle: "Your Book Subtitle"
  author: "Author Name"
  publisher: "Your Publisher"
  date: "2025"
  language: "en-US"
  description: "Book description..."
  rights: "Copyright notice..."

structure:
  chapters: 8              # Number of chapters
  has_conclusion: true     # Whether you have a conclusion
  appendices: []           # List of appendix files
  cover_image: "book_content/cover_epub.png"

output:
  epub_filename: ""        # Auto-generated if empty
  pdf_filename: ""         # Auto-generated if empty
  word_filename: ""        # Auto-generated if empty
  output_dir: "output"

styles:
  epub_css: "styles/ebook_styles.css"
  print_css: "styles/print_styles.css"
  word_template: "styles/word_template.docx"
```

## 📖 Usage Examples

### Generate All Formats
```bash
./scripts/generate_all.sh
```

### Generate Individual Formats
```bash
./scripts/generate_epub.sh   # EPUB only
./scripts/generate_pdf.sh    # PDF only
./scripts/generate_word.sh   # Word only
```

### Validate Everything
```bash
./scripts/validate.sh
```

### Validate Configuration
```bash
./scripts/validate_config.sh
```

### Check Dependencies
```bash
./checks/check_dependencies.sh
```

## 🔍 Quick Reference Card

### Common Commands
```bash
# Setup new project
./scripts/setup_project.sh

# Generate all formats
./scripts/generate_all.sh

# Generate single format
./scripts/generate_epub.sh
./scripts/generate_pdf.sh
./scripts/generate_word.sh

# Validate
./scripts/validate.sh
./scripts/validate.sh --verbose

# Check specific things
./checks/check_dependencies.sh
./checks/check_structure.sh
./checks/check_content.sh
./checks/check_outputs.sh
```

### File Structure Quick Reference
```
book_content/
├── front_matter/     # title_page.md, copyright_page.md, dedication.md, 
                      # table_of_contents.md, preface.md
├── chapters/         # chapter_1.md, chapter_2.md, ..., conclusion.md
└── back_matter/     # acknowledgments.md, appendix_*.md, references.md
```

### Config.yaml Key Fields
- `book.title` - Book title (required)
- `book.publisher` - Publisher name (required)
- `book.date` - Publication date (required)
- `structure.chapters` - Number of chapters
- `structure.has_conclusion` - true/false
- `structure.cover_image` - Path to cover image (optional)

### Troubleshooting Quick Fixes

**"Config file not found"**
- Run `./scripts/setup_project.sh` to create config.yaml

**"No chapters found"**
- Check that chapter files exist in `book_content/chapters/`
- Files should be named: `chapter_1.md`, `ch1.md`, or similar
- See `templates/book_structure.md` for naming patterns

**"WeasyPrint not found"**
- Install: `pip install weasyprint`

**"python-docx not found"**
- Install: `pip install -r requirements.txt`

**"EPUB validation failed"**
- Run `./tools/fix_epub_links.py output/your_book.epub`
- Or check EPUB manually with epubcheck

**"PDF generation failed"**
- Ensure WeasyPrint is installed: `pip install weasyprint`
- Check that CSS file exists: `styles/print_styles.css`

### Output File Locations
- EPUB: `output/[book_title]_Professional.epub`
- PDF: `output/[book_title]_Print_Professional.pdf`
- Word: `output/[book_title]_Print_Professional.docx`

### Complete Workflow: From Clone to Published Book

**1. Initial Setup (One Time Per Book)**
```bash
# Clone the template
git clone https://github.com/jpaine/book_56Press.git my-book-name
cd my-book-name

# Install dependencies
pip install -r requirements.txt

# Run setup (creates folder structure and config)
./scripts/setup_project.sh
```

**2. Write Your Book**
- Edit markdown files in `book_content/`
- Add chapters: `book_content/chapters/chapter_1.md`, `chapter_2.md`, etc.
- Write front matter: title, copyright, preface
- Write back matter: acknowledgments, appendices

**3. Generate Formats (Repeat as Needed)**
```bash
# Generate all formats
./scripts/generate_all.sh

# Or generate individually
./scripts/generate_epub.sh   # EPUB only
./scripts/generate_pdf.sh    # PDF only
./scripts/generate_word.sh  # Word only
```

**4. Validate Before Publishing**
```bash
# Run all validation checks
./scripts/validate.sh

# Check specific things
./checks/check_dependencies.sh  # Verify tools installed
./checks/check_structure.sh     # Verify folder structure
./checks/check_content.sh       # Verify content files
./checks/check_outputs.sh       # Verify generated files
```

**5. Publish**
- Review files in `output/` folder
- Test EPUB in Kindle Previewer or Apple Books
- Review PDF formatting
- Upload to Amazon KDP, Apple Books, or other platforms

## 🎨 Customization

### Custom Styles

You can customize the styling by editing:
- `styles/ebook_styles.css` - EPUB styling
- `styles/print_styles.css` - PDF styling
- `styles/word_template.docx` - Word template

### Custom Chapter Naming

The engine automatically detects chapters with flexible naming:
- `chapter_1.md`, `chapter_2.md`
- `chapter_01.md`, `chapter_02.md`
- `ch1.md`, `ch2.md`
- `01.md`, `02.md`

See `tools/detect_chapters.py` for detection logic.

## 🔧 Troubleshooting

### Dependencies Not Found

Run dependency check:
```bash
./checks/check_dependencies.sh
```

This will tell you what's missing and how to install it.

### Structure Issues

Check your folder structure:
```bash
./checks/check_structure.sh
```

### Content Issues

Validate your content files:
```bash
./checks/check_content.sh
```

### Generation Failures

1. Check config is valid: `./scripts/validate_config.sh`
2. Check dependencies: `./checks/check_dependencies.sh`
3. Try generating individual formats to isolate the issue
4. Check error messages for specific problems

### EPUB Issues

If EPUB has broken links:
```bash
python3 tools/fix_epub_links.py output/your_book.epub
```

If EPUB validation fails:
```bash
python3 tools/validate_epub.py output/your_book.epub
```

### PDF Issues

- Ensure WeasyPrint is installed: `pip install weasyprint`
- Check CSS file exists and is readable
- Try generating HTML first to debug: `pandoc temp_book_for_pdf.md -o test.html`

### Word Issues

- Ensure python-docx is installed: `pip install python-docx`
- Check template file exists: `styles/word_template.docx`
- Word formatting is applied automatically, but you may need to add drop caps and headers manually

## 🌍 Cross-Platform Notes

### macOS
- All tools work natively
- Use Homebrew for package management
- Paths use forward slashes (standard)

### Linux
- All tools work natively
- Use apt/yum for system packages
- Paths use forward slashes (standard)

### Windows
- Use Git Bash or WSL for best compatibility
- Scripts use `#!/usr/bin/env bash` for portability
- Paths are handled automatically
- Some tools may need Windows-specific installation

## 📚 Complete Book Creation Workflow

This engine is designed as **Stage 4** in a data-driven book creation pipeline:

### Stage 1: Data Collection (Outside Engine Scope)
- Collect data from multiple sources
- Process and organize data
- Extract insights and patterns

### Stage 2: Outline Creation (Outside Engine Scope)
- Create book outline based on data
- Structure chapters and sections
- Plan front matter and back matter

### Stage 3: Writing in Style (Outside Engine Scope)
- Write content following established style
- Create markdown files for each chapter
- Write front matter and back matter

### Stage 4: Ebook Generation (This Engine)
1. Clone this repository
2. Run `./scripts/setup_project.sh`
3. Add your content to `book_content/`
4. Run `./scripts/generate_all.sh`
5. Review output in `output/`
6. Publish to KDP, Apple Books, etc.

## 🎯 Features

- **Automated**: Single command generates all formats
- **Validated**: Checks at each step with clear error messages
- **Configurable**: YAML config for easy customization
- **Portable**: Self-contained, can be copied to any project
- **Professional**: Professional typography and formatting
- **Extensible**: Easy to add new formats or customizations
- **Cross-Platform**: Works on macOS, Linux, and Windows

## 📝 License

MIT License - See LICENSE file for details

## 🤝 Contributing

This is a template repository. Fork it and customize for your needs!

## 📖 Documentation

- `templates/book_structure.md` - Folder structure guide
- `templates/config.yaml.example` - Config file example
- `templates/README.example` - Example project README

## 🆘 Support

For issues or questions:
1. Check the troubleshooting section
2. Run validation scripts to identify problems
3. Review error messages for specific guidance

---

**Ready to publish your book?** Follow the Quick Start guide above and you'll have professional EPUB, PDF, and Word files in minutes!

