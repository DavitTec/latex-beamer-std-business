#!/bin/bash
# scripts/check-dependencies.sh
# Version: 1.0.0
# Dependency Check Script
# Verifies all required tools are available
# Usage: ./scripts/check-dependencies.sh

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}Checking Dependencies...${NC}"
echo "=============================="
echo ""

# Counter
missing=0

# Check Pandoc
echo -n "Checking Pandoc... "
if command -v pandoc &> /dev/null; then
    version=$(pandoc --version | head -1)
    echo -e "${GREEN}✓${NC}"
    echo "  $version"
else
    echo -e "${RED}✗ NOT FOUND${NC}"
    echo "  Install: https://pandoc.org/installing.html"
    missing=$((missing + 1))
fi

# Check Bash
echo -n "Checking Bash... "
if [ -n "$BASH_VERSION" ]; then
    echo -e "${GREEN}✓${NC}"
    echo "  $BASH_VERSION"
else
    echo -e "${RED}✗ NOT FOUND${NC}"
    missing=$((missing + 1))
fi

# Check sed
echo -n "Checking sed... "
if command -v sed &> /dev/null; then
    version=$(sed --version 2>/dev/null | head -1 || echo "GNU sed")
    echo -e "${GREEN}✓${NC}"
    echo "  Available"
else
    echo -e "${RED}✗ NOT FOUND${NC}"
    missing=$((missing + 1))
fi

# Check awk
echo -n "Checking awk... "
if command -v awk &> /dev/null; then
    echo -e "${GREEN}✓${NC}"
    echo "  Available"
else
    echo -e "${RED}✗ NOT FOUND${NC}"
    missing=$((missing + 1))
fi

# Check cat
echo -n "Checking cat... "
if command -v cat &> /dev/null; then
    echo -e "${GREEN}✓${NC}"
    echo "  Available"
else
    echo -e "${RED}✗ NOT FOUND${NC}"
    missing=$((missing + 1))
fi

echo ""
echo "=============================="

if [ $missing -eq 0 ]; then
    echo -e "${GREEN}All dependencies found! Ready to convert.${NC}"
    echo ""
    echo "Run: ./scripts/convert-all.sh"
    exit 0
else
    echo -e "${RED}Missing $missing dependencies${NC}"
    echo ""
    echo "Install Pandoc:"
    echo "  macOS:  brew install pandoc"
    echo "  Linux:  sudo apt-get install pandoc"
    echo "  Other:  https://pandoc.org/installing.html"
    exit 1
fi
