#!/bin/bash
# scripts/latex-to-markdown.sh
# Version: 1.0
# Description: Converts LaTeX Beamer presentation slides to Markdown 
#              format using Pandoc. This script processes each slide,
#              extracts content, and generates clean Markdown files for 
#              use in the static site generator.
# Usage: ./scripts/latex-to-markdown.sh

set -e

# Enforce execution from package root
if [ ! -f "./package.json" ]; then
  echo "ERROR: Please run this script from the package root directory (where package.json is located)."
  exit 1
fi

# Load environment variables from .env if it exists
if [ -f ".env" ]; then
  echo "Loading environment from .env..."
  set -a
  source ".env"
  set +a
fi

# Default values (overridden by .env if set)
PROJECT_TITLE="${PROJECT_TITLE:-latex-beamer-bizpres}"
LATEX_DIR="${LATEX_DIR:-./src/latex}"
LATEX_MAIN="${LATEX_MAIN:-main.tex}"
BUILD_DIR="${BUILD_DIR:-./build}"
CONTENT_DIR="${CONTENT_DIR:-./content}"
MARKDOWN_DIR="${CONTENT_DIR}/slides"
TEMP_DIR="${CONTENT_DIR}/.temp"

LATEX_DIR="${LATEX_DIR}/${PROJECT_TITLE}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color


echo -e "${YELLOW}LaTeX Beamer to Markdown Conversion${NC}"
echo "========================================"

# Check if LaTeX directory exists
if [ ! -d "$LATEX_DIR" ]; then
    echo -e "${RED}Error: LaTeX directory '$LATEX_DIR' not found${NC}"
    exit 1
fi

# Check if Pandoc is installed
if ! command -v pandoc &> /dev/null; then
    echo -e "${RED}Error: Pandoc is not installed${NC}"
    echo "Install Pandoc from: https://pandoc.org/installing.html"
    exit 1
fi

echo -e "${GREEN}✓ Pandoc found: $(pandoc --version | head -1)${NC}"

# Create necessary directories
mkdir -p "$MARKDOWN_DIR"
mkdir -p "$TEMP_DIR"

echo ""
echo "Converting LaTeX slides to Markdown..."
echo "========================================"

# Counter for slides
slide_count=0
successful=0

# First, combine all slide content into a single LaTeX file for processing
COMBINED_TEX="${TEMP_DIR}/combined.tex"

# Create a minimal LaTeX document structure
cat > "$COMBINED_TEX" << 'EOF'
\documentclass{beamer}
\usepackage[utf8]{inputenc}
\usepackage[T1]{fontenc}

\title{Business Plan Presentation}
\begin{document}

EOF

# Append all slide content
for slide_file in "$LATEX_DIR"/content/slide*.tex; do
    if [ -f "$slide_file" ]; then
        # Extract just the frame content
        sed '/^%/d' "$slide_file" >> "$COMBINED_TEX"
        echo "" >> "$COMBINED_TEX"
    fi
done

echo '\end{document}' >> "$COMBINED_TEX"

# Convert each individual slide using Pandoc
for slide_file in "$LATEX_DIR"/content/slide*.tex; do
    if [ -f "$slide_file" ]; then
        slide_count=$((slide_count + 1))

        # Extract slide number and name from filename
        filename=$(basename "$slide_file" .tex)
        slide_num=$(echo "$filename" | sed 's/slide*//')

        # Create output filename (zero-padded)
        output_file=$(printf "%s/slide_%02d.md" "$MARKDOWN_DIR" "$slide_num")

        # Convert LaTeX to Markdown
        if pandoc \
            --from latex \
            --to markdown \
            --standalone \
            --output "$output_file" \
            "$slide_file" 2>/dev/null; then

            # Clean up the markdown output
            # Remove LaTeX-specific commands that Pandoc might leave
            sed -i.bak '
                /^\\begin{frame}/d
                /^\\end{frame}/d
                /^\\framesubtitle/d
                /^%.*$/d
                /^\\begin{tikz/,/^\\end{tikz/c\
[Chart/Diagram - See LaTeX source]
                /^\\begin{columns}/d
                /^\\end{columns}/d
                /^\\column{/d
                /^\\begin{block}/d
                /^\\end{block}/d
            ' "$output_file"

            # Remove backup file
            rm -f "${output_file}.bak"

            echo -e "${GREEN}✓ Converted${NC} $filename → $output_file"
            successful=$((successful + 1))
        else
            echo -e "${RED}✗ Failed${NC} to convert $filename"
        fi
    fi
done

echo ""
echo "========================================"
echo -e "${GREEN}Conversion Summary:${NC}"
echo "Total slides found: $slide_count"
echo "Successfully converted: $successful"
echo "Output directory: $MARKDOWN_DIR"
echo ""

# Create an index file
INDEX_FILE="${MARKDOWN_DIR}/_index.md"
cat > "$INDEX_FILE" << 'EOF'
# Business Plan Presentation - Markdown Index

This directory contains Markdown versions of the LaTeX Beamer business plan presentation slides.

## Slide List

EOF

for i in $(seq 1 $successful); do
    slide_file=$(printf "${MARKDOWN_DIR}/slide_%02d.md" "$i")
    if [ -f "$slide_file" ]; then
        # Extract title from the markdown file
        title=$(head -n 5 "$slide_file" | grep "^#" | head -1 | sed 's/^# //')
        echo "- [Slide $i: $title]($slide_file)" >> "$INDEX_FILE"
    fi
done

echo -e "${GREEN}✓ Created index file: $INDEX_FILE${NC}"

# Create metadata JSON for easy access
METADATA_FILE="${MARKDOWN_DIR}/_metadata.json"
cat > "$METADATA_FILE" << EOF
{
  "title": "Business Plan Presentation",
  "total_slides": $successful,
  "format": "markdown",
  "converted_from": "LaTeX Beamer",
  "conversion_date": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "slides": [
EOF

for i in $(seq 1 $successful); do
    slide_file=$(printf "slide_%02d.md" "$i")
    comma=$([ $i -lt $successful ] && echo "," || echo "")
    cat >> "$METADATA_FILE" << EOF
    {
      "number": $i,
      "filename": "$slide_file",
      "path": "slides/$slide_file"
    }$comma
EOF
done

cat >> "$METADATA_FILE" << EOF
  ]
}
EOF

echo -e "${GREEN}✓ Created metadata file: $METADATA_FILE${NC}"

# Cleanup temporary directory
#rm -rf "$TEMP_DIR"

echo ""
echo -e "${GREEN}✓ Conversion complete!${NC}"
echo ""
echo "Next steps:"
echo "1. Review the converted markdown files in: $MARKDOWN_DIR"
echo "2. Run: ./scripts/markdown-to-html.sh"
echo "3. Access HTML slides in: $CONTENT_DIR/html"
echo ""
