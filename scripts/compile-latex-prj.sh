#!/bin/bash
# script/compile-latex-prj.sh
# Version: 2.0.1
# Compilation script for LaTeX Beamer Business Presentation
# Usage: ./compile-latex-prj.sh (must be run from package root)
#
# Supports .env for custom paths (no absolute paths hardcoded).
# Built with Visual Studio Code Insiders, pnpm, 2-space indent,
# double quotes. Optional: Texmaker. Linux Mint Mate (latest).

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

# Compute paths
LATEX="${LATEX_DIR}/${PROJECT_TITLE}/${LATEX_MAIN}"

# Get version from package.json
VERSION=$(jq -r '.version' "./package.json")
PDF_FILE="${BUILD_DIR}/${PROJECT_TITLE}-v${VERSION}.pdf"

curdir=$(pwd)
echo "Current directory: ${curdir}"

echo "========================================="
echo "LaTeX Beamer BizPres Compiler"
echo "========================================="
echo ""

# Check if pdflatex is available
if ! command -v pdflatex &> /dev/null; then
  echo "ERROR: pdflatex is not installed!"
  echo "Please install a LaTeX distribution (TeX Live, MiKTeX, or MacTeX)"
  echo ""
  echo "Alternatively, upload these files to Overleaf.com for online compilation"
  exit 1
fi

echo "Compiling presentation..."
echo ""

# Check if build directory exists, if not create it
if [ ! -d "${BUILD_DIR}" ]; then
  echo "Creating build directory: ${BUILD_DIR}"
  mkdir -p "${BUILD_DIR}"
else
  echo "Build directory already exists: ${BUILD_DIR}"
fi

# Check if main.tex exists
if [ ! -f "${LATEX}" ]; then
  echo "ERROR: LaTeX source file not found: ${LATEX}"
  echo "Please check the path and filename"
  exit 1
fi

echo "Using LaTeX source: ${LATEX}"
echo "Output will be saved to: ${BUILD_DIR}/main.pdf"
echo ""

# First pass
echo "Current directory for compilation: $(pwd)"
echo "Running pdflatex (1st pass)..."
pdflatex -interaction=nonstopmode -output-directory="${BUILD_DIR}" "${LATEX}" > /dev/null 2>&1

# Second pass (for references and TOC)
echo "Running pdflatex (2nd pass)..."
pdflatex -synctex=1 -interaction=nonstopmode -output-directory="${BUILD_DIR}" "${LATEX}" > /dev/null 2>&1

# Clean up auxiliary files
echo "Cleaning up auxiliary files..."
rm -f "${BUILD_DIR}"/*.aux \
      "${BUILD_DIR}"/*.log \
      "${BUILD_DIR}"/*.nav \
      "${BUILD_DIR}"/*.out \
      "${BUILD_DIR}"/*.snm \
      "${BUILD_DIR}"/*.toc \
      "${BUILD_DIR}"/*.vrb \
      "${BUILD_DIR}"/*.synctex.gz

# Check if main.pdf was generated
if [ ! -f "${BUILD_DIR}/main.pdf" ]; then
  echo ""
  echo "========================================="
  echo "ERROR: main.pdf was not generated"
  echo "========================================="
  echo "ERROR: PDF generation failed"
  echo "Try running: pdflatex -interaction=nonstopmode -output-directory=${BUILD_DIR} ${LATEX}"
  echo "to see detailed error messages"
  exit 1
else
  echo ""
  echo "========================================="
  echo "Compilation complete!"
  echo "SUCCESS: main.pdf has been generated"
  echo "Output file: main.pdf"
  mv "${BUILD_DIR}/main.pdf" "${PDF_FILE}"
  echo "Renamed to: ${PDF_FILE}"
  echo "To view the PDF:"
  echo "  - Linux: xdg-open ${PDF_FILE}"
  echo "  - macOS: open ${PDF_FILE}"
  echo "  - Windows: start ${PDF_FILE}"
  echo "========================================="
fi
