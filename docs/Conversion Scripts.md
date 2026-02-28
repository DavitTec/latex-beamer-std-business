# Conversion Scripts

This directory contains scripts to convert the LaTeX Beamer business plan presentation into Markdown and HTML formats for web presentation.

## Scripts Overview

### 1. `latex-to-markdown.sh`
Converts LaTeX Beamer slides to Markdown format using Pandoc.

**Usage:**
```bash
./scripts/latex-to-markdown.sh
```

**Output:**
- Markdown files: `./content/slides/slide_*.md`
- Index file: `./content/slides/_index.md`
- Metadata: `./content/slides/_metadata.json`

**Requirements:**
- Pandoc installed (`pandoc --version`)

### 2. `markdown-to-html.sh`
Converts Markdown slides to interactive HTML files.

**Usage:**
```bash
./scripts/markdown-to-html.sh
```

**Output:**
- HTML files: `./content/html/slides/slide_*.html`
- Stylesheet: `./content/html/slides.css`
- Master index: `./content/html/index.html`

**Features:**
- Professional styling with business-appropriate colors
- Responsive design for mobile/tablet/desktop
- Print-friendly CSS
- Interactive navigation
- Accessible HTML structure

### 3. `convert-all.sh`
Master script that runs both conversion steps in sequence.

**Usage:**
```bash
./scripts/convert-all.sh
```

**What it does:**
1. Runs `latex-to-markdown.sh`
2. Runs `markdown-to-html.sh`
3. Displays completion summary

## Installation Requirements

### Pandoc Installation

Pandoc is required for the conversion process.

**macOS (Homebrew):**
```bash
brew install pandoc
```

**Ubuntu/Debian:**
```bash
sudo apt-get install pandoc
```

**Windows (Chocolatey):**
```bash
choco install pandoc
```

**Or download from:**
https://pandoc.org/installing.html

**Verify installation:**
```bash
pandoc --version
```

## Workflow

### Quick Start (Recommended)
```bash
# Run the master conversion script
./scripts/convert-all.sh

# View the generated HTML index
open content/html/index.html  # macOS
xdg-open content/html/index.html  # Linux
start content\html\index.html  # Windows
```

### Step-by-Step Conversion

```bash
# Step 1: Convert LaTeX to Markdown
./scripts/latex-to-markdown.sh
# Review markdown files in ./content/slides/

# Step 2: Convert Markdown to HTML
./scripts/markdown-to-html.sh
# Review HTML files in ./content/html/
```

## Directory Structure

After running the scripts:

```
project/
├── scripts/
│   ├── README.md (this file)
│   ├── convert-all.sh
│   ├── latex-to-markdown.sh
│   └── markdown-to-html.sh
│
├── content/
│   ├── slides/                    # Markdown output
│   │   ├── _index.md
│   │   ├── _metadata.json
│   │   ├── slide_01.md
│   │   ├── slide_02.md
│   │   └── ...
│   │
│   └── html/                      # HTML output
│       ├── index.html             # Master index
│       ├── slides.css             # Stylesheet
│       └── slides/
│           ├── slide_01.html
│           ├── slide_02.html
│           └── ...
│
└── latex-beamer-bizpres/          # Original LaTeX source
    ├── main.tex
    ├── metadata.tex
    └── content/
        └── slide*.tex
```

## Output Details

### Markdown Output

Each slide is converted to a standalone Markdown file with:
- Slide title as H1 heading
- Content formatted as Markdown
- Charts/diagrams noted as comments
- Tables with proper Markdown syntax

**Example structure:**
```markdown
# Slide Title

Content goes here with **bold**, *italic*, and other formatting.

## Subsection

- Bullet point 1
- Bullet point 2
```

### HTML Output

HTML files include:
- Professional styling with gradient header
- Responsive design
- Proper semantic HTML
- Print-friendly stylesheet
- Accessible structure

**Features:**
- Color scheme matches LaTeX presentation
- Mobile-responsive layout
- Print optimization
- Professional typography

### Master Index

The `index.html` provides:
- Overview of all slides
- Grid-based card layout
- Quick navigation to each slide
- Presentation metadata

## Customization

### Modifying Markdown Output

Edit Markdown files in `./content/slides/` directly before HTML conversion.

### Modifying HTML Styling

Edit the CSS in `./content/html/slides.css` to customize:
- Colors
- Typography
- Spacing
- Responsive breakpoints

### Updating Conversion

Edit the shell scripts to customize:
- Output file naming
- Directory structure
- Additional processing

## Troubleshooting

### Pandoc Not Found
```bash
# Install Pandoc first
brew install pandoc  # macOS
# or
sudo apt-get install pandoc  # Linux
```

### Permission Denied
```bash
# Make scripts executable
chmod +x scripts/*.sh
```

### No Markdown Files Generated
1. Verify LaTeX directory exists: `./latex-beamer-bizpres/`
2. Check for LaTeX syntax errors in source files
3. Ensure Pandoc is installed correctly

### HTML Files Look Wrong
1. Check that CSS file exists: `./content/html/slides.css`
2. Verify relative paths in HTML files
3. Clear browser cache and reload

## Integration with Vite

To serve the HTML slides through the Vite development server:

```bash
# Copy HTML to public directory
cp -r content/html/* public/slides/

# Run Vite dev server
npm run dev

# Access at http://localhost:5173/slides/index.html
```

Or create a route in your Vite app to serve the HTML files directly.

## Advanced Usage

### Batch Processing Multiple Presentations

Modify the scripts to handle multiple LaTeX directories:

```bash
#!/bin/bash
for dir in latex-beamer-*; do
    echo "Processing $dir..."
    ./scripts/convert-all.sh "$dir"
done
```

### Custom Pandoc Options

Edit the scripts to add Pandoc filters or options:

```bash
pandoc --from latex --to markdown \
    --filter pandoc-citeproc \
    --lua-filter=custom-filter.lua \
    input.tex -o output.md
```

## Performance

Typical conversion times:
- 21 slides LaTeX to Markdown: ~2-5 seconds
- 21 slides Markdown to HTML: ~3-8 seconds
- Full pipeline: ~5-13 seconds

Times depend on:
- File sizes
- System performance
- Pandoc complexity
- Number of diagrams/tables

## Maintenance

### Updating Scripts

After making changes to scripts:
1. Test conversion with sample slides
2. Verify output quality
3. Update this README

### Version Control

Recommend in `.gitignore`:
```
content/slides/
content/html/
latex-beamer-bizpres/.temp/
scripts/.temp/
```

Keep source LaTeX files in version control.

## Support & Documentation

- [Pandoc Documentation](https://pandoc.org/MANUAL.html)
- [Markdown Syntax](https://daringfireball.net/projects/markdown/)
- [HTML Standards](https://html.spec.whatwg.org/)
- [Bash Scripting Guide](https://www.gnu.org/software/bash/manual/)

## License

These conversion scripts are provided as-is for use with the Business Plan Presentation template.
