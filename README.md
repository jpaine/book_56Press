# Ebook Generation Engine

A GitHub repository template for automated ebook generation. When cloned for a new book project, an interactive setup script configures the book, then automatically generates professional EPUB, PDF, and Word documents from a standardized Markdown book structure.

## 🎯 What This Engine Does

**This engine generates professional EPUB, PDF, and Word documents from your markdown files.**

It does NOT:
- ❌ Collect data from sources
- ❌ Analyze or process data
- ❌ Write your content
- ❌ Create your outline

It DOES:
- ✅ Take your written markdown files
- ✅ Apply professional formatting and styling
- ✅ Generate publication-ready EPUB, PDF, and Word files
- ✅ Validate everything works correctly
- ✅ Handle all the technical conversion details

**You write the content → This engine formats and publishes it**

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

This engine is designed as **Stage 4** in a data-driven non-fiction book creation pipeline. Here's the complete process:

### Stage 1: Data Collection & Extraction

**What to do:**
1. **Identify data sources** relevant to your topic:
   - Reddit discussions (r/subreddit, search for keywords)
   - YouTube videos (transcribe relevant videos)
   - Hacker News threads (search and collect discussions)
   - Official sources (company blogs, documentation)
   - Community forums (Discord, Slack, forums)
   - Interview transcripts (if you conduct interviews)
   - Public datasets (CSV, JSON files)

2. **Extract and organize data**:
   - Save Reddit posts/comments as JSON or markdown
   - Transcribe YouTube videos (use tools like Whisper, or manual transcription)
   - Export Hacker News discussions
   - Download official documentation
   - Organize everything into folders by source type

3. **Process the data**:
   - Clean and normalize text
   - Extract key quotes and insights
   - Identify patterns and themes
   - Create structured datasets (JSON, CSV, or markdown)

**Example folder structure for data collection:**
```
data_sources/
├── reddit/
│   ├── post_1.json
│   ├── post_2.json
│   └── ...
├── youtube/
│   ├── video_1_transcript.txt
│   ├── video_2_transcript.txt
│   └── ...
├── hackernews/
│   ├── thread_1.json
│   └── ...
├── official/
│   ├── blog_post_1.md
│   └── ...
└── processed/
    ├── insights.json
    ├── quotes.json
    └── patterns.json
```

**Tools you might use:**
- Web scraping: Python (BeautifulSoup, Scrapy), or browser extensions
- Video transcription: Whisper AI, YouTube auto-captions, or manual
- Data processing: Python scripts, Jupyter notebooks
- Organization: Spreadsheets, databases, or markdown files

### Stage 2: Outline Creation

**What to do:**
1. **Analyze your collected data**:
   - Review all extracted insights
   - Identify main themes and topics
   - Find patterns across different sources
   - Note common questions or problems

2. **Create book outline**:
   - Structure chapters based on themes
   - Plan front matter (title, preface explaining methodology)
   - Plan back matter (appendices with data sources, references)
   - Decide on chapter order and flow

3. **Map data to chapters**:
   - Assign specific data sources to each chapter
   - Identify key quotes and examples for each section
   - Plan where to cite sources

**Example outline structure:**
```
1. Introduction (What the book covers)
2. Chapter 1: [Main Theme 1] (Data from sources X, Y, Z)
3. Chapter 2: [Main Theme 2] (Data from sources A, B, C)
4. Chapter 3: [Main Theme 3] (Data from sources D, E, F)
...
Conclusion: [Synthesis of findings]
Appendix A: Data Sources (List of all sources used)
Appendix B: Methodology (How data was collected)
References: [All citations]
```

### Stage 3: Writing in Style

**What to do:**
1. **Write each chapter** using your collected data:
   - Start with markdown files: `chapter_1.md`, `chapter_2.md`, etc.
   - Incorporate insights from your data analysis
   - Include quotes and examples from sources
   - Cite sources as you write (you'll format references later)
   - Follow your established writing style (data-driven, reflective, systematic)

2. **Write front matter**:
   - `title_page.md` - Book title, subtitle, publisher
   - `copyright_page.md` - Copyright, disclaimers, ISBN placeholder
   - `dedication.md` - Personal dedication (optional)
   - `preface.md` - Explain your methodology, data sources, why you wrote this
   - `table_of_contents.md` - Chapter list (can be auto-generated later)

3. **Write back matter**:
   - `acknowledgments.md` - Thank you section
   - `appendix_*.md` - Detailed data sources, methodology, additional analysis
   - `references.md` - All citations and sources

**Writing tips:**
- Use markdown formatting: `#` for headings, `**bold**` for emphasis
- Keep chapters in separate files
- Name files consistently: `chapter_1.md`, `chapter_2.md`, etc.
- Include data-driven insights, not just opinions
- Reference your sources as you write

### Stage 4: Ebook Generation (This Engine)

**This is where this repository comes in!**

Once you have all your markdown files written, use this engine to generate professional formats:

1. **Clone this repository**:
   ```bash
   git clone https://github.com/jpaine/book_56Press.git my-book-name
   cd my-book-name
   ```

2. **Install dependencies** (one-time setup):
   ```bash
   pip install -r requirements.txt
   brew install pandoc  # macOS, or use package manager for your OS
   pip install weasyprint
   ```

3. **Run setup**:
   ```bash
   ./scripts/setup_project.sh
   ```
   This creates the folder structure and `config.yaml`

4. **Copy your content**:
   - Copy your markdown files to `book_content/chapters/`
   - Copy front matter to `book_content/front_matter/`
   - Copy back matter to `book_content/back_matter/`

5. **Generate formats**:
   ```bash
   ./scripts/generate_all.sh
   ```

6. **Review and publish**:
   - Check `output/` folder for EPUB, PDF, Word files
   - Test EPUB in Kindle Previewer
   - Review PDF formatting
   - Upload to Amazon KDP, Apple Books, etc.

## 🔄 Typical Workflow Summary

**Before using this engine:**
1. ✅ Collect data from multiple sources (Reddit, YouTube, Hacker News, etc.)
2. ✅ Extract and organize insights, quotes, patterns
3. ✅ Create book outline based on data analysis
4. ✅ Write all content in markdown files

**Using this engine:**
5. ✅ Clone this repository
6. ✅ Run setup script
7. ✅ Copy your markdown files into `book_content/`
8. ✅ Generate EPUB, PDF, Word formats
9. ✅ Publish to platforms

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

