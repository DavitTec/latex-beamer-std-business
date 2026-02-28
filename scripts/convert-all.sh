#!/bin/bash
# scripts/convert-all.sh
# Version: 1.0
# Description: Master script to convert LaTeX Beamer slides to Markdown and then to HTML
# Usage: ./scripts/convert-all.sh

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo ""
echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║    LaTeX → Markdown → HTML Conversion Pipeline              ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Get script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Check if scripts exist
if [ ! -f "${SCRIPT_DIR}/latex-to-markdown.sh" ]; then
    echo -e "${RED}Error: latex-to-markdown.sh not found${NC}"
    exit 1
fi

if [ ! -f "${SCRIPT_DIR}/markdown-to-html.sh" ]; then
    echo -e "${RED}Error: markdown-to-html.sh not found${NC}"
    exit 1
fi

# Make scripts executable
chmod +x "${SCRIPT_DIR}/latex-to-markdown.sh"
chmod +x "${SCRIPT_DIR}/markdown-to-html.sh"

echo -e "${YELLOW}Step 1: Converting LaTeX to Markdown...${NC}"
echo "=========================================="
if "${SCRIPT_DIR}/latex-to-markdown.sh"; then
    echo -e "${GREEN}✓ LaTeX to Markdown conversion complete${NC}"
else
    echo -e "${RED}✗ LaTeX to Markdown conversion failed${NC}"
    exit 1
fi

echo ""
echo -e "${YELLOW}Step 2: Converting Markdown to HTML...${NC}"
echo "=========================================="
if "${SCRIPT_DIR}/markdown-to-html.sh"; then
    echo -e "${GREEN}✓ Markdown to HTML conversion complete${NC}"
else
    echo -e "${RED}✗ Markdown to HTML conversion failed${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║           Conversion Pipeline Complete!                     ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo "Generated Content:"
echo "  • Markdown: ./content/slides/"
echo "  • HTML: ./content/html/"
echo "  • Index: ./content/html/index.html"
echo ""
echo "To integrate with Vite:"
echo "  1. Run: npm run build"
echo "  2. The HTML files will be ready for serving"
echo ""
