#!/bin/bash
# scripts/latex-to-markdown.sh
# Version: 2.0.2
# Description: Converts LaTeX Beamer presentation slides to Markdown using Pandoc.
#              Fixed printf octal bug on slide08+ (08 treated as octal). Now uses direct string construction.
# Usage: pnpm run tex2md

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

# Colours for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}LaTeX Beamer to Markdown Conversion${NC}"
echo "========================================"

# Check directories and tools
if [ ! -d "${LATEX_DIR}" ]; then
  echo -e "${RED}Error: LaTeX directory '${LATEX_DIR}' not found${NC}"
  exit 1
fi

if ! command -v pandoc &> /dev/null; then
  echo -e "${RED}Error: Pandoc is not installed${NC}"
  echo "Install Pandoc from: https://pandoc.org/installing.html"
  exit 1
fi

echo -e "${GREEN}✓ Pandoc found: $(pandoc --version | head -1)${NC}"

# Create directories
mkdir -p "${MARKDOWN_DIR}"
mkdir -p "${TEMP_DIR}"

# ==================================================================
# Function 1: Get total number of slides (keeps 00-99 index format)
# ==================================================================
get_total_slides() {
  local count=0
  shopt -s nullglob
  for slide_file in "${LATEX_DIR}"/content/slide[0-9][0-9]-*.tex; do
    if [ -f "${slide_file}" ]; then
      count=$((count + 1))
    fi
  done
  shopt -u nullglob
  echo "${count}"
}

# ==================================================================
# Function 2: Extract slide number and $slideTitle from filename
# e.g. slide08-product-overview.tex → 08:product-overview
# ==================================================================
extract_slide_info() {
  local slide_file="${1}"
  local filename
  filename="$(basename "${slide_file}" .tex)"
  local slide_num="00"
  local slide_title="Untitled"

  if [[ "${filename}" =~ ^slide([0-9]{2})-(.+)$ ]]; then
    slide_num="${BASH_REMATCH[1]}"
    slide_title="${BASH_REMATCH[2]}"
  elif [[ "${filename}" =~ ^slide([0-9]{2})$ ]]; then
    slide_num="${BASH_REMATCH[1]}"
    slide_title="Slide ${slide_num}"
  fi
  echo "${slide_num}:${slide_title}"
}

# ==================================================================
# Helper: Return sorted list "num:title:file" (handles any 1-99 order)
# ==================================================================
get_sorted_slide_list() {
  local temp_list=()
  shopt -s nullglob
  for slide_file in "${LATEX_DIR}"/content/slide[0-9][0-9]-*.tex; do
    if [ -f "${slide_file}" ]; then
      local info
      info="$(extract_slide_info "${slide_file}")"
      local num="${info%%:*}"
      local title="${info#*:}"
      temp_list+=("${num}:${title}:${slide_file}")
    fi
  done
  shopt -u nullglob
  printf '%s\n' "${temp_list[@]}" | sort -t: -k1,1n
}

# ==================================================================
# Function 3: Create index using slide01.md + $slideTitle
# ==================================================================
create_slide_index() {
  local index_file="${1}"
  cat > "${index_file}" << EOF
# ${PROJECT_TITLE} - Markdown Index

This directory contains Markdown versions of the LaTeX Beamer ${PROJECT_TITLE} slides.

## Slide List

EOF

  local sorted_slides
  sorted_slides="$(get_sorted_slide_list)"
  while IFS= read -r line; do
    if [ -n "${line}" ]; then
      IFS=: read -r num title _ <<< "${line}"
      echo "- [Slide ${num}: ${title}](slide${num}.md)" >> "${index_file}"
    fi
  done <<< "${sorted_slides}"
}

# ==================================================================
# Function 4: Create metadata JSON
# ==================================================================
create_metadata_json() {
  local metadata_file="${1}"
  cat > "${metadata_file}" << EOF
{
  "title": "${PROJECT_TITLE}",
  "total_slides": ${successful},
  "format": "markdown",
  "converted_from": "LaTeX Beamer",
  "conversion_date": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "slides": [
EOF

  local first=true
  while IFS= read -r line; do
    if [ -n "${line}" ]; then
      if [ "${first}" = true ]; then
        first=false
      else
        echo "    ," >> "${metadata_file}"
      fi
      IFS=: read -r slide_num slide_title slide_file <<< "${line}"
      local md_filename="slide${slide_num}.md"
      local num_int=$((10#${slide_num}))
      cat >> "${metadata_file}" << EOF
    {
      "number": ${num_int},
      "title": "${slide_title}",
      "filename": "${md_filename}",
      "path": "slides/${md_filename}"
    }
EOF
    fi
  done <<< "${sorted_slides}"

  cat >> "${metadata_file}" << EOF
  ]
}
EOF
}

echo ""
echo "Converting LaTeX slides to Markdown..."
echo "========================================"

# Process every slide (sorted by number)
sorted_slides="$(get_sorted_slide_list)"
slide_count=0
successful=0

while IFS= read -r line; do
  if [ -n "${line}" ]; then
    slide_count=$((slide_count + 1))
    IFS=: read -r slide_num slide_title slide_file <<< "${line}"

    # Output filename (already zero-padded string, no printf needed)
    output_file="${MARKDOWN_DIR}/slide${slide_num}.md"

    if pandoc \
      --from latex \
      --to markdown \
      --standalone \
      --output "${output_file}" \
      "${slide_file}" 2>/dev/null; then

      # Clean Pandoc output
      sed -i.bak '
        /^\\begin{frame}/d
        /^\\end{frame}/d
        /^\\framesubtitle/d
        /^%.*$/d
        /^\\begin{tikz/,/^\\end{tikz}/c\
[Chart/Diagram - See LaTeX source]
        /^\\begin{columns}/d
        /^\\end{columns}/d
        /^\\column{/d
        /^\\begin{block}/d
        /^\\end{block}/d
      ' "${output_file}"

      rm -f "${output_file}.bak"

      echo -e "${GREEN}✓ Converted${NC} $(basename "${slide_file}" .tex) → ${output_file} (Title: ${slide_title})"
      successful=$((successful + 1))
    else
      echo -e "${RED}✗ Failed${NC} to convert $(basename "${slide_file}" .tex)"
    fi
  fi
done <<< "${sorted_slides}"

echo ""
echo "========================================"
echo -e "${GREEN}Conversion Summary:${NC}"
echo "Total slides found: ${slide_count}"
echo "Successfully converted: ${successful}"
echo "Output directory: ${MARKDOWN_DIR}"
echo ""

# Create index (uses slideTitle from filename)
INDEX_FILE="${MARKDOWN_DIR}/_index.md"
create_slide_index "${INDEX_FILE}"
echo -e "${GREEN}✓ Created index file: ${INDEX_FILE}${NC}"

# Create metadata JSON (now safe inside function)
METADATA_FILE="${MARKDOWN_DIR}/_metadata.json"
create_metadata_json "${METADATA_FILE}"
echo -e "${GREEN}✓ Created metadata file: ${METADATA_FILE}${NC}"

# Optional cleanup
# rm -rf "${TEMP_DIR}"

echo ""
echo -e "${GREEN}✓ Conversion complete!${NC}"
echo ""
echo "Next steps:"
echo "1. Review markdown files in: ${MARKDOWN_DIR}"
echo "2. Run: pnpm run your-next-script"
echo "3. Open in VS Code Insiders on Linux Mint Mate"
echo ""