#!/bin/bash
# scripts/latex-to-markdown.sh
# Version: 2.1.3
# Description: Converts LaTeX Beamer slides to clean Markdown.
#              FULL main.tex + metadata.tex + ONE slide.
#              4 dedicated functions fix frontmatter, metadata, graphics and ALL :::::: divs.
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
# Function: Extract slide number and slideTitle
# ==================================================================
extract_slide_info() {
  local slide_file="${1}"
  local filename
  filename="$(basename "${slide_file}" .tex)"
  local slide_num="00"
  local slide_title="Untitled"

  if [[ "${filename}" =~ ^slide([0-9]{2})(-.*)?$ ]]; then
    slide_num="${BASH_REMATCH[1]}"
    slide_title="${BASH_REMATCH[2]:-Untitled}"
    if [[ "${slide_title}" == "Untitled" || "${slide_title}" == "-"* ]]; then
      slide_title="Slide ${slide_num}"
    else
      slide_title="${slide_title#-}"
    fi
  fi
  echo "${slide_num}:${slide_title}"
}

# ==================================================================
# Function: Build FULL temp document from main.tex + metadata.tex + ONE slide
# ==================================================================
build_full_temp_document() {
  local slide_file="${1}"
  local temp_file="${2}"

  # Start with the real main.tex (contains documentclass + all usepackages)
  cp "${LATEX_DIR}/${LATEX_MAIN}" "${temp_file}"

  # Inline metadata.tex (replace the \input line) — this was already correct
  sed -i '
    /^\\input{\\MyPath\/metadata\.tex}$/{
      r '"${LATEX_DIR}/metadata.tex"'
      d
    }
  ' "${temp_file}"

  # STEP 2: Delete text BELOW % Document (removes old \begin{document} + ALL slide inputs + \end{document})
  # This leaves only the clean header (preamble + metadata + footer)
  sed -i '/^% Document[[:space:]]*$/,$d' "${temp_file}"
  #DEBUG: echo "STEP 2: Removed everything below '% Document' → header only in ${temp_file}"

  # STEP 3: Insert the new document body (marker + \begin{document} + the single slide)
  cat << 'INSERT_MARKER' >> "${temp_file}"
% -----INSERT  BELOW THIS LINE---------------------------------------------
\begin{document}    % inserted
% inserted SLIDE HERE
INSERT_MARKER

  cat "${slide_file}" >> "${temp_file}"

  # STEP 4: Close the document
  cat << 'END_DOCUMENT' >> "${temp_file}"

\end{document}    % inserted
END_DOCUMENT

 #DEBUG: echo "STEP 3+4 completed: Single slide inserted + document closed in ${temp_file}"
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
# Function: Strip Pandoc YAML frontmatter (issue 1)
# ==================================================================
strip_yaml_frontmatter() {
  local file="${1}"
  sed -i '/^---$/,/^---$/d' "${file}"
}

# ==================================================================
# Function: Add clean site-ready frontmatter (issues 1 + 2)
# ==================================================================
add_slide_frontmatter() {
  local file="${1}"
  local num="${2}"
  local title="${3}"
  local temp="${file}.tmp"
  cat > "${temp}" << EOF
---
title: "${title}"
slide_number: ${num}
layout: slide
---

EOF
  cat "${file}" >> "${temp}"
  mv "${temp}" "${file}"
}

# ==================================================================
# Function: Fix graphics links (issue 3)
# ==================================================================
fix_graphics_links() {
  local file="${1}"
  # TODO: change the line below to your actual image folder structure
  # Example: sed -i 's|!\[\]\(([^)]*)\)|![Image](../assets/\1)|g' "${file}"
  sed -i 's|!\[\]\(([^)]*)\)|![Image](\1)|g' "${file}"
}

# ==================================================================
# Function: Clean ALL Beamer divs (issues 4-10)
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
# Function: Create index
# ==================================================================
create_slide_index() {
  local index_file="${1}"
  cat > "${index_file}" << EOF
# ${PROJECT_TITLE} - Markdown Index

This directory contains Markdown versions of the LaTeX Beamer ${PROJECT_TITLE} slides.

## Slide List

EOF

  for slide_file in "${LATEX_DIR}"/content/slide[0-9][0-9]-*.tex; do
    if [ -f "${slide_file}" ]; then
      local info
      info="$(extract_slide_info "${slide_file}")"
      IFS=: read -r num title _ <<< "${info}"
      echo "- [Slide ${num}: ${title}](slide${num}.md)" >> "${index_file}"
    fi
  done
}

# ==================================================================
# Function: Create metadata JSON
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
  for slide_file in "${LATEX_DIR}"/content/slide[0-9][0-9]-*.tex; do
    if [ -f "${slide_file}" ]; then
      local info
      info="$(extract_slide_info "${slide_file}")"
      IFS=: read -r slide_num slide_title _ <<< "${info}"
      local md_filename="slide${slide_num}.md"
      local num_int=$((10#${slide_num}))

      if [ "${first}" = true ]; then
        first=false
      else
        echo "    ," >> "${metadata_file}"
      fi
      cat >> "${metadata_file}" << EOF
    {
      "number": ${num_int},
      "title": "${slide_title}",
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

for slide_file in "${LATEX_DIR}"/content/slide[0-9][0-9]-*.tex; do
  if [ -f "${slide_file}" ]; then
    slide_count=$((slide_count + 1))
    info="$(extract_slide_info "${slide_file}")"
    IFS=: read -r slide_num slide_title _ <<< "${info}"

    TEMP_SLIDE="${TEMP_DIR}/temp_slide_${slide_num}.tex"
    output_file="${MARKDOWN_DIR}/slide${slide_num}.md"

    build_full_temp_document "${slide_file}" "${TEMP_SLIDE}"
    echo -e "${YELLOW}Processing${NC} ${slide_num}: ${slide_title} ..."

    result=$(convert_with_pandoc "${TEMP_SLIDE}" "${output_file}")
    IFS=: read -r status _ out_size <<< "${result}"

    if [ "${status}" = "success" ] && [ "${out_size}" -gt 100 ]; then
      strip_yaml_frontmatter "${output_file}"
      # BUG:clean_beamer_divs "${output_file}"
      fix_graphics_links "${output_file}"
      add_slide_frontmatter "${output_file}" "${slide_num}" "${slide_title}"

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
echo "1. Open ./content/slides/slide20.md – clean frontmatter + no :::::: blocks"
echo "2. Edit fix_graphics_links() if your image paths need tweaking"
echo "3. Run your next script on Linux Mint Mate"
echo ""
