#!/bin/bash
# Compilation script for LaTeX Beamer Business Presentation

echo "========================================="
echo "LaTeX Beamer BizPres Compiler"
echo "========================================="
echo ""

# Check if pdflatex is available
if ! command -v pdflatex &> /dev/null
then
    echo "ERROR: pdflatex is not installed!"
    echo "Please install a LaTeX distribution (TeX Live, MiKTeX, or MacTeX)"
    echo ""
    echo "Alternatively, upload these files to Overleaf.com for online compilation"
    exit 1
fi

echo "Compiling presentation..."
echo ""

# First pass
echo "Running pdflatex (1st pass)..."
pdflatex -interaction=nonstopmode main.tex > /dev/null 2>&1

# Second pass (for references and TOC)
echo "Running pdflatex (2nd pass)..."
pdflatex -interaction=nonstopmode main.tex > /dev/null 2>&1

# Clean up auxiliary files
echo "Cleaning up auxiliary files..."
rm -f *.aux *.log *.nav *.out *.snm *.toc *.vrb

echo ""
echo "========================================="
echo "Compilation complete!"
echo "Output file: main.pdf"
echo "========================================="

# Check if PDF was generated
if [ -f "main.pdf" ]; then
    echo "SUCCESS: main.pdf has been generated"
    echo ""
    echo "To view the PDF:"
    echo "  - Linux: xdg-open main.pdf"
    echo "  - macOS: open main.pdf"
    echo "  - Windows: start main.pdf"
else
    echo "ERROR: PDF generation failed"
    echo "Try running: pdflatex main.tex"
    echo "to see detailed error messages"
fi
