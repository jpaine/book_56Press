# Book Structure Template

This document shows the required folder structure for your book project.

## Required Structure

```
book_content/
├── front_matter/
│   ├── title_page.md          # Required: Book title, subtitle, publisher
│   ├── copyright_page.md      # Required: Copyright, disclaimers, ISBN
│   ├── dedication.md          # Required: Dedication page
│   ├── table_of_contents.md   # Required: Table of contents
│   └── preface.md             # Required: Preface/introduction
│
├── chapters/
│   ├── chapter_1.md           # Your chapters (flexible naming)
│   ├── chapter_2.md           # Supports: chapter_1.md, ch1.md, 01.md, etc.
│   ├── chapter_3.md
│   └── conclusion.md          # Optional: Conclusion chapter
│
└── back_matter/
    ├── acknowledgments.md     # Required: Acknowledgments
    ├── appendix_a.md          # Optional: Appendices
    └── references.md          # Optional: References/bibliography
```

## File Naming

### Chapters
The engine supports flexible chapter naming:
- `chapter_1.md`, `chapter_2.md`
- `chapter_01.md`, `chapter_02.md`
- `ch1.md`, `ch2.md`
- `chapter_1_draft.md`
- `01.md`, `02.md`

Chapters are automatically detected and sorted by number.

### Conclusion
If you have a conclusion, name it:
- `conclusion.md` (recommended)

## Content Guidelines

### Front Matter
- **title_page.md**: Book title, subtitle, publisher, date
- **copyright_page.md**: Copyright notice, disclaimers, ISBN placeholder
- **dedication.md**: Personal dedication (can be blank)
- **table_of_contents.md**: Will be auto-generated, but you can customize
- **preface.md**: Introduction to your book and methodology

### Chapters
- Use standard Markdown formatting
- Headings: `# Chapter Title`, `## Section`, `### Subsection`
- The first `#` heading in each chapter becomes the chapter title

### Back Matter
- **acknowledgments.md**: Thank you section
- **appendix_*.md**: Any appendices you want to include
- **references.md**: Bibliography or reference list

## Cover Image

Place your cover image at:
- `book_content/cover_epub.png` (recommended)
- Or specify custom path in `config.yaml`

Cover should be:
- **Dimensions**: 1600x2560 pixels (2:3 ratio)
- **Format**: PNG or JPG
- **Size**: Under 2MB for KDP
