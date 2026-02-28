#!/bin/bash
# scripts/latex-to-markdown.sh
# Version: 2.1.4
# Description: Converts LaTeX Beamer slides to clean Markdown.
#              slide-01.tex → slide-99.tex only. Title extracted from \begin{frame}{...}
#              New functions only: parse filename + extract frame title/subtitle + full frontmatter + rich metadata.json
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
  # shellcheck disable=SC1091
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
# Function: Parse slide-01.tex → num=01 (title now comes from inside frame)
# ==================================================================
parse_slide_filename() {
  local slide_file="${1}"
  local filename
  filename="$(basename "${slide_file}" .tex)"
  local slide_num="00"

  if [[ "${filename}" =~ ^slide-([0-9]{2})$ ]]; then
    slide_num="${BASH_REMATCH[1]}"
  fi
  echo "${slide_num}"
}

# ==================================================================
# Function: Extract real frame title + optional subtitle from slide.tex
# ==================================================================
extract_frame_title_and_subtitle() {
  local slide_file="${1}"
  local title="Untitled Slide"
  local subtitle=""

  # Extract title from \begin{frame}{...}
  title=$(sed -n 's/.*\\begin{frame}{\([^}]*\)}.*/\1/p' "${slide_file}" | head -1)
  title="${title//\\&/&}"   # clean \& → &

  # Extract optional subtitle
  subtitle=$(sed -n 's/.*\\framesubtitle{\([^}]*\)}.*/\1/p' "${slide_file}" | head -1)
  subtitle="${subtitle//\\&/&}"

  if [ -z "${title}" ]; then
    title="Untitled Slide"
  fi
  echo "${title}:${subtitle}"
}

# ==================================================================
# Function: Build FULL temp document from main.tex + metadata.tex + ONE slide
# ==================================================================
build_full_temp_document() {
  local slide_file="${1}"
  local temp_file="${2}"

  cp "${LATEX_DIR}/${LATEX_MAIN}" "${temp_file}"

  sed -i '
    /^\\input{\\MyPath\/metadata\.tex}$/{
      r '"${LATEX_DIR}/metadata.tex"'
      d
    }
  ' "${temp_file}"

  sed -i '/^% Document[[:space:]]*$/,$d' "${temp_file}"

  cat << 'INSERT_MARKER' >> "${temp_file}"
% -----INSERT  BELOW THIS LINE---------------------------------------------
\begin{document}    % inserted
% inserted SLIDE HERE
INSERT_MARKER

  cat "${slide_file}" >> "${temp_file}"

  cat << 'END_DOCUMENT' >> "${temp_file}"

\end{document}    % inserted
END_DOCUMENT
}

# ==================================================================
# Function: Dedicated Pandoc conversion
# ==================================================================
convert_with_pandoc() {
  local input_file="${1}"
  local output_file="${2}"
  if pandoc \
    --from latex \
    --to markdown \
    --standalone \
    --markdown-headings=atx \
    --wrap=none \
    --resource-path="${LATEX_DIR}" \
    --output "${output_file}" \
    "${input_file}"; then
    local size=0
    [ -f "${output_file}" ] && size=$(stat -c %s "${output_file}" 2>/dev/null || echo 0)
    echo "success:${output_file}:${size}"
  else
    echo "fail::0"
  fi
}

# ==================================================================
# Function: Clean ALL Beamer divs (:::::::: frame, columns, block, alertblock, etc.)
# ==================================================================
clean_beamer_divs() {
  local file="${1}"
  sed -i '
    /^:\{3,\}.*/d
    /^[0-9.]\+\s*\[\]\{style=/d
    s/\{style="[^"]*"\}//g
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
    /^\\begin{alertblock}/d
    /^\\end{alertblock}/d
  ' "${file}"
  rm -f "${file}.bak" 2>/dev/null || true
}

# ==================================================================
# Function: Strip Pandoc YAML frontmatter
# ==================================================================
strip_yaml_frontmatter() {
  local file="${1}"
  sed -i '/^---$/,/^---$/d' "${file}"
}

# ==================================================================
# Function: Add clean site-ready frontmatter (title from frame + subtitle)
# ==================================================================
add_slide_frontmatter() {
  local file="${1}"
  local num="${2}"
  local title="${3}"
  local subtitle="${4}"
  local temp="${file}.tmp"
  cat > "${temp}" << EOF
---
title: "${title}"
subtitle: "${subtitle}"
layout: slide
slide_number: ${num}
slide_id: ${num}
---

EOF
  cat "${file}" >> "${temp}"
  mv "${temp}" "${file}"
}

# ==================================================================
# Function: Fix graphics links (kept for completeness)
# ==================================================================
fix_graphics_links() {
  local file="${1}"
  sed -i 's|!\[\]\(([^)]*)\)|![Image](\1)|g' "${file}"
}

# ==================================================================
# Function: Extract real metadata from metadata.tex
# ==================================================================
extract_latex_metadata() {
  local meta_file="${LATEX_DIR}/metadata.tex"
  local title="${PROJECT_TITLE}"
  local author=""
  local date=""
  local institute=""

  if [ -f "${meta_file}" ]; then
    title=$(sed -n 's/.*\\title{\([^}]*\)}.*/\1/p' "${meta_file}" | head -1 || echo "${title}")
    author=$(sed -n 's/.*\\author{\([^}]*\)}.*/\1/p' "${meta_file}" | head -1 || echo "")
    date=$(sed -n 's/.*\\date{\([^}]*\)}.*/\1/p' "${meta_file}" | head -1 || echo "")
    institute=$(sed -n 's/.*\\institute{\([^}]*\)}.*/\1/p' "${meta_file}" | head -1 || echo "")
  fi
  echo "${title}:${author}:${date}:${institute}"
}

# ==================================================================
# Function: Create index (uses real frame title)
# ==================================================================
create_slide_index() {
  local index_file="${1}"
  cat > "${index_file}" << EOF
# ${PROJECT_TITLE} - Markdown Index

This directory contains Markdown versions of the LaTeX Beamer ${PROJECT_TITLE} slides.

## Slide List

EOF

  for slide_file in "${LATEX_DIR}"/content/slide-[0-9][0-9].tex; do
    if [ -f "${slide_file}" ]; then
      local num
      num="$(parse_slide_filename "${slide_file}")"
      local details
      details="$(extract_frame_title_and_subtitle "${slide_file}")"
      IFS=: read -r title _ <<< "${details}"
      echo "- [Slide ${num}: ${title}](slide${num}.md)" >> "${index_file}"
    fi
  done
}

# ==================================================================
# Function: Create rich metadata.json (all 8 keys per slide)
# ==================================================================
create_metadata_json() {
  local metadata_file="${1}"
  local latex_meta
  latex_meta="$(extract_latex_metadata)"
  IFS=: read -r pres_title pres_author pres_date pres_institute <<< "${latex_meta}"

  cat > "${metadata_file}" << EOF
{
  "title": "${pres_title}",
  "author": "${pres_author}",
  "date": "${pres_date}",
  "institute": "${pres_institute}",
  "total_slides": ${successful},
  "format": "markdown",
  "converted_from": "LaTeX Beamer",
  "conversion_date": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "slides": [
EOF

  local first=true
  for slide_file in "${LATEX_DIR}"/content/slide-[0-9][0-9].tex; do
    if [ -f "${slide_file}" ]; then
      local num
      num="$(parse_slide_filename "${slide_file}")"
      local details
      details="$(extract_frame_title_and_subtitle "${slide_file}")"
      IFS=: read -r title subtitle <<< "${details}"
      local md_filename="slide${num}.md"
      local num_int=$((10#${num}))

      if [ "${first}" = true ]; then
        first=false
      else
        echo "    ," >> "${metadata_file}"
      fi
      cat >> "${metadata_file}" << EOF
    {
      "number": ${num_int},
      "slide_id": "${num}",
      "slide_number": "${num}",
      "title": "${title}",
      "subtitle": "${subtitle}",
      "layout": "slide",
      "slide_type": "default",
      "slide_note": "",
      "filename": "${md_filename}",
      "path": "slides/${md_filename}"
    }
EOF
    fi
  done

  cat >> "${metadata_file}" << EOF
  ]
}
EOF
}

echo ""
echo "Converting LaTeX slides to Markdown..."
echo "========================================"

slide_count=0
successful=0

for slide_file in "${LATEX_DIR}"/content/slide-[0-9][0-9].tex; do
  if [ -f "${slide_file}" ]; then
    slide_count=$((slide_count + 1))
    slide_num="$(parse_slide_filename "${slide_file}")"
    details="$(extract_frame_title_and_subtitle "${slide_file}")"
    IFS=: read -r slide_title slide_subtitle <<< "${details}"

    TEMP_SLIDE="${TEMP_DIR}/temp_slide_${slide_num}.tex"
    output_file="${MARKDOWN_DIR}/slide${slide_num}.md"

    build_full_temp_document "${slide_file}" "${TEMP_SLIDE}"
    echo -e "${YELLOW}Processing${NC} ${slide_num}: ${slide_title} ..."

    result=$(convert_with_pandoc "${TEMP_SLIDE}" "${output_file}")
    IFS=: read -r status _ out_size <<< "${result}"

    if [ "${status}" = "success" ] && [ "${out_size}" -gt 100 ]; then
      strip_yaml_frontmatter "${output_file}"
      #BUG:clean_beamer_divs "${output_file}"
      fix_graphics_links "${output_file}"
      add_slide_frontmatter "${output_file}" "${slide_num}" "${slide_title}" "${slide_subtitle}"

      echo -e "${GREEN}✓ Converted${NC} $(basename "${slide_file}" .tex) → ${output_file} (Title: ${slide_title})"
      successful=$((successful + 1))
    else
      echo -e "${RED}✗ Failed${NC} to convert $(basename "${slide_file}" .tex)"
      echo "   → Check temp file: ${TEMP_SLIDE}"
    fi
  fi
done

echo ""
echo "========================================"
echo -e "${GREEN}Conversion Summary:${NC}"
echo "Total slides found: ${slide_count}"
echo "Successfully converted: ${successful}"
echo "Output directory: ${MARKDOWN_DIR}"
echo ""

# Create index + metadata
INDEX_FILE="${MARKDOWN_DIR}/_index.md"
create_slide_index "${INDEX_FILE}"
echo -e "${GREEN}✓ Created index file: ${INDEX_FILE}${NC}"

METADATA_FILE="${MARKDOWN_DIR}/_metadata.json"
create_metadata_json "${METADATA_FILE}"
echo -e "${GREEN}✓ Created metadata file: ${METADATA_FILE}${NC}"

# Optional cleanup
# rm -rf "${TEMP_DIR}"

echo ""
echo -e "${GREEN}✓ Conversion complete!${NC}"
echo ""
echo "Next steps:"
echo "1. Open slide01.md – real frame title in frontmatter + rich metadata.json"
echo "2. All 8 keys you asked for are now in _metadata.json"
echo "3. Run your next script on Linux Mint Mate"
echo ""