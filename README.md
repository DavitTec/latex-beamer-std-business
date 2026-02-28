# LaTeX Standard Business Beamer Presentation Template

[![GitHub tag (latest by date)](https://img.shields.io/github/v/tag/DavitTec/latex-beamer-std-business?style=for-the-badge&logo=github)](https://github.com/DavitTec/latex-beamer-std-business/tag)
[![GitHub open issues](https://img.shields.io/github/issues-raw/DavitTec/latex-beamer-std-business?style=for-the-badge&label=Open%20Issues)](https://github.com/DavitTec/latex-beamer-std-business/issues)
[![GitHub top language](https://img.shields.io/github/languages/top/DavitTec/latex-beamer-std-business?style=for-the-badge)](https://github.com/DavitTec/latex-beamer-std-business)
[![GitHub license](https://img.shields.io/github/license/DavitTec/latex-beamer-std-business?style=for-the-badge)](https://github.com/DavitTec/latex-beamer-std-business)

This is a minimalist LaTeX template using **beamer.cls** for professional business presentations. It supports customisable presenter/audience details, tones (formal/informal), letterhead/logo, signatures, colours, and title slides. Ideal for proposals, reports, or formal business meetings.

![Sample Business Presentation](./assets/sample-business-presentation.png)

## Features

- Clean, multi-slide layout with optional theme toggles.
- Customise metadata (presenter, audience, tone) via [metadata.tex](metadata.tex).
- Support for letterhead (with on/off switch), logo, and signature images.
- Colour schemes for presenter details (using xcolor).
- Fixed positioning for title slides and footers.
- Title/subtitle lines.
- Database/JSON compatible structure (via \def macros).
- Limitations: Basic beamer.cls—no advanced animations; use extensions for complex needs.

## Getting Started

### Prerequisites

- LaTeX distribution (TeX Live on Linux Mint MATE).
- Optional: Visual Studio Code Insiders with LaTeX Workshop extension, or Texmaker.
- pnpm for any Node.js scripts (e.g., generating metadata from JSON).

### Usage

1. Clone the repo:

   ```bash
   git clone https://github.com/DavitTec/latex-beamer-std-business.git
   cd latex-beamer-std-business
   ```

2. Update metadata.tex with your details (e.g., presenter, audience, tone).

3. Place images in src/ (letterhead.png, logo.png, signature.png).

4. Compile:

   ```bash
   mkdir -p build
   pdflatex -output-directory=build main.tex
   ```

Output: build/main.pdf.

For continuous build in VS Code Insiders: Use LaTeX Workshop (Ctrl+Alt+B).

## File Structure

```bash
latex-beamer-std-business/
├─ main.tex           # Main LaTeX file with preamble and includes.
├─ content.tex        # Presentation body, title slide, sections, and closing.
├─ metadata.tex       # Customisable vars (presenter, audience, tones, images).
├─ src/               # Images (letterhead.png, logo.png, signature.png).
├─ config/            # (Future) config.json for overrides.
├─ build/             # Compiled outputs (gitignore this).
├─ docs/              # (Future) TODO.md for features.
├─ README.md          # This file.
├─ LICENSE            # MIT License.
```

## Customisation

- Tone/Style: Set \def\tone{formal} in metadata.tex.
- Colours: Edit \definecolor in metadata.tex.
- Positions: Adjust \usetheme or \vspace in main.tex for layouts.
- Build Script: See [TODO.md](docs/TODO.md) for planned bash/JS script.

## License

MIT License. See [LICENSE](LICENSE) file.

Copyright © Davit Technologies 2026

Version: 3.0.0
