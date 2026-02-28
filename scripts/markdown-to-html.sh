#!/bin/bash
# scripts/markdown-to-html.sh
# Version: 1.0
# Description: Convert Markdown slides to HTML for Vite presentation
# Usage: ./scripts/markdown-to-html.sh

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Paths
CONTENT_DIR="./content"
MARKDOWN_DIR="${CONTENT_DIR}/slides"
HTML_DIR="${CONTENT_DIR}/html"
SLIDES_HTML_DIR="${HTML_DIR}/slides"

echo -e "${YELLOW}Markdown to HTML Conversion${NC}"
echo "========================================"

# Check if Markdown directory exists
if [ ! -d "$MARKDOWN_DIR" ]; then
    echo -e "${RED}Error: Markdown directory '$MARKDOWN_DIR' not found${NC}"
    echo "Run './scripts/latex-to-markdown.sh' first"
    exit 1
fi

# Check if Pandoc is installed
if ! command -v pandoc &> /dev/null; then
    echo -e "${RED}Error: Pandoc is not installed${NC}"
    echo "Install Pandoc from: https://pandoc.org/installing.html"
    exit 1
fi

echo -e "${GREEN}✓ Pandoc found: $(pandoc --version | head -1)${NC}"

# Create output directories
mkdir -p "$SLIDES_HTML_DIR"

echo ""
echo "Converting Markdown to HTML..."
echo "========================================"

# Counter for slides
successful=0

# Create CSS stylesheet
CSS_FILE="${HTML_DIR}/slides.css"
cat > "$CSS_FILE" << 'EOFCSS'
/* Slide Presentation Styles */
:root {
    --primary-blue: #4a5f8f;
    --primary-dark: #2c3d5c;
    --accent-green: #3d8b40;
    --neutral-light: #f5f5f5;
    --neutral-dark: #333;
    --border-color: #ddd;
}

* {
    margin: 0;
    padding: 0;
    box-sizing: border-box;
}

body {
    font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
    line-height: 1.6;
    color: var(--neutral-dark);
    background-color: var(--neutral-light);
}

.slide-container {
    max-width: 1280px;
    margin: 0 auto;
    padding: 20px;
}

.slide {
    background: white;
    border-radius: 8px;
    box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
    padding: 40px;
    margin-bottom: 30px;
    page-break-after: always;
    min-height: 600px;
}

.slide h1 {
    color: var(--primary-blue);
    font-size: 2.5em;
    margin-bottom: 20px;
    border-bottom: 3px solid var(--primary-blue);
    padding-bottom: 15px;
}

.slide h2 {
    color: var(--primary-dark);
    font-size: 1.8em;
    margin: 25px 0 15px 0;
}

.slide h3 {
    color: var(--primary-dark);
    font-size: 1.4em;
    margin: 20px 0 10px 0;
}

.slide h4, .slide h5, .slide h6 {
    color: var(--neutral-dark);
    margin: 15px 0 10px 0;
}

.slide p {
    margin-bottom: 15px;
    line-height: 1.8;
}

.slide ul, .slide ol {
    margin: 15px 0 15px 30px;
}

.slide li {
    margin-bottom: 10px;
}

.slide table {
    width: 100%;
    border-collapse: collapse;
    margin: 20px 0;
}

.slide table th {
    background-color: var(--primary-blue);
    color: white;
    padding: 12px;
    text-align: left;
    font-weight: 600;
}

.slide table td {
    border: 1px solid var(--border-color);
    padding: 12px;
}

.slide table tr:nth-child(even) {
    background-color: #f9f9f9;
}

.slide blockquote {
    border-left: 4px solid var(--primary-blue);
    padding-left: 20px;
    margin: 20px 0;
    color: #666;
    font-style: italic;
}

.slide code {
    background-color: #f4f4f4;
    padding: 2px 6px;
    border-radius: 3px;
    font-family: 'Courier New', monospace;
    font-size: 0.9em;
}

.slide pre {
    background-color: #f4f4f4;
    padding: 15px;
    border-radius: 5px;
    overflow-x: auto;
    margin: 15px 0;
}

.slide pre code {
    background: none;
    padding: 0;
}

.slide strong, .slide b {
    color: var(--primary-dark);
    font-weight: 600;
}

.slide em, .slide i {
    font-style: italic;
}

/* Navigation */
.slide-nav {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin: 30px 0 20px 0;
    padding-top: 20px;
    border-top: 1px solid var(--border-color);
}

.slide-nav button {
    background-color: var(--primary-blue);
    color: white;
    border: none;
    padding: 10px 20px;
    border-radius: 5px;
    cursor: pointer;
    font-size: 1em;
    transition: background-color 0.3s ease;
}

.slide-nav button:hover {
    background-color: var(--primary-dark);
}

.slide-nav button:disabled {
    background-color: #ccc;
    cursor: not-allowed;
}

.slide-counter {
    font-weight: 600;
    color: var(--primary-blue);
}

/* Highlight box */
.highlight {
    background-color: #fff3cd;
    border-left: 4px solid #ffc107;
    padding: 15px;
    margin: 15px 0;
    border-radius: 3px;
}

/* Money/Financial values */
.money {
    color: var(--accent-green);
    font-weight: 600;
}

/* Chart placeholder */
.chart-placeholder {
    background-color: #f0f0f0;
    border: 2px dashed var(--border-color);
    padding: 30px;
    text-align: center;
    border-radius: 5px;
    color: #666;
    margin: 20px 0;
}

/* Responsive Design */
@media (max-width: 768px) {
    .slide {
        padding: 20px;
        min-height: auto;
    }

    .slide h1 {
        font-size: 1.8em;
    }

    .slide h2 {
        font-size: 1.4em;
    }

    .slide-nav {
        flex-direction: column;
        gap: 10px;
    }

    .slide-nav button {
        width: 100%;
    }
}

/* Print styles */
@media print {
    body {
        background: white;
    }

    .slide {
        box-shadow: none;
        page-break-inside: avoid;
        break-inside: avoid;
    }

    .slide-nav {
        display: none;
    }
}
EOFCSS

echo -e "${GREEN}✓ Created stylesheet: $CSS_FILE${NC}"

# Create header and footer HTML templates
HEADER_FILE="${HTML_DIR}/_header.html"
cat > "$HEADER_FILE" << 'EOFHEADER'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Business Plan Presentation - Slide</title>
    <link rel="stylesheet" href="../slides.css">
    <style>
        .slide-header {
            background: linear-gradient(135deg, #4a5f8f 0%, #2c3d5c 100%);
            color: white;
            padding: 20px;
            margin: -40px -40px 30px -40px;
            border-radius: 8px 8px 0 0;
        }
        .slide-header h1 {
            border: none;
            color: white;
            margin: 0;
            padding: 0;
        }
    </style>
</head>
<body>
    <div class="slide-container">
        <div class="slide">
EOFHEADER

FOOTER_FILE="${HTML_DIR}/_footer.html"
cat > "$FOOTER_FILE" << 'EOFFOOTER'
        </div>
    </div>
</body>
</html>
EOFFOOTER

echo -e "${GREEN}✓ Created HTML templates${NC}"

# Convert each Markdown file to HTML
for md_file in "$MARKDOWN_DIR"/slide_*.md; do
    if [ -f "$md_file" ]; then
        filename=$(basename "$md_file" .md)
        html_file="${SLIDES_HTML_DIR}/${filename}.html"

        # Create temporary HTML from Pandoc
        TEMP_HTML="${HTML_DIR}/.temp_${filename}.html"

        if pandoc \
            --from markdown \
            --to html \
            --standalone \
            --css ../slides.css \
            --output "$TEMP_HTML" \
            "$md_file" 2>/dev/null; then

            # Combine header, content, and footer
            cat "$HEADER_FILE" > "$html_file"
            # Extract body content from Pandoc output
            sed -n '/<body>/,/<\/body>/p' "$TEMP_HTML" | sed '/<body>/d;/<\/body>/d' >> "$html_file"
            cat "$FOOTER_FILE" >> "$html_file"

            rm -f "$TEMP_HTML"

            echo -e "${GREEN}✓ Converted${NC} $filename → ${filename}.html"
            successful=$((successful + 1))
        else
            echo -e "${RED}✗ Failed${NC} to convert $filename"
        fi
    fi
done

echo ""
echo "========================================"
echo -e "${GREEN}HTML Conversion Summary:${NC}"
echo "Successfully converted: $successful slides"
echo "Output directory: $SLIDES_HTML_DIR"
echo ""

# Create a master index HTML file
INDEX_HTML="${HTML_DIR}/index.html"
cat > "$INDEX_HTML" << 'EOFINDEX'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Business Plan Presentation</title>
    <link rel="stylesheet" href="slides.css">
    <style>
        .presentation-index {
            background: linear-gradient(135deg, #4a5f8f 0%, #2c3d5c 100%);
            color: white;
            padding: 40px;
            border-radius: 8px;
            margin-bottom: 30px;
        }
        .presentation-index h1 {
            border: none;
            color: white;
            margin-bottom: 10px;
        }
        .presentation-index p {
            margin-bottom: 20px;
            opacity: 0.9;
        }
        .slide-list {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
            gap: 20px;
            margin-top: 30px;
        }
        .slide-card {
            background: white;
            border-radius: 5px;
            padding: 20px;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
            transition: transform 0.3s ease, box-shadow 0.3s ease;
        }
        .slide-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
        }
        .slide-card a {
            color: #4a5f8f;
            text-decoration: none;
            font-weight: 600;
        }
        .slide-card a:hover {
            text-decoration: underline;
        }
        .slide-number {
            color: #666;
            font-size: 0.9em;
            margin-bottom: 10px;
        }
    </style>
</head>
<body>
    <div class="slide-container">
        <div class="presentation-index">
            <h1>Business Plan Presentation</h1>
            <p>Professional investor pitch deck with comprehensive business analysis</p>
            <p style="font-size: 0.9em;">Click on any slide to view details</p>
        </div>

        <div class="slide-list">
EOFINDEX

# Add slide links to index
for i in $(seq 1 $successful); do
    slide_file=$(printf "slides/slide_%02d.html" "$i")
    slide_title="Slide $i"

    # Try to extract title from markdown
    md_file=$(printf "${MARKDOWN_DIR}/slide_%02d.md" "$i")
    if [ -f "$md_file" ]; then
        slide_title=$(head -n 10 "$md_file" | grep "^#" | head -1 | sed 's/^# //' || echo "Slide $i")
    fi

    cat >> "$INDEX_HTML" << EOF
            <div class="slide-card">
                <div class="slide-number">Slide $i</div>
                <a href="$slide_file">$slide_title</a>
            </div>
EOF
done

cat >> "$INDEX_HTML" << 'EOFINDEX'
        </div>
    </div>
</body>
</html>
EOFINDEX

echo -e "${GREEN}✓ Created master index: $INDEX_HTML${NC}"

echo ""
echo -e "${GREEN}✓ Conversion complete!${NC}"
echo ""
echo "Next steps:"
echo "1. View index at: $INDEX_HTML"
echo "2. Individual slides in: $SLIDES_HTML_DIR"
echo "3. To integrate with Vite, run: npm run build"
echo ""
