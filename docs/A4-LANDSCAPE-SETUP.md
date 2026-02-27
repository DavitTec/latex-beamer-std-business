# A4 Landscape Setup Guide

This LaTeX Beamer presentation has been configured for A4 landscape format with professional footer styling and optimized scaling for all visual elements.

## Key Configuration Changes

### 1. Document Format
- **Document Class**: Standard Beamer with beamerposter package
- **Page Size**: A4 (210mm × 297mm)
- **Orientation**: Landscape
- **Scale Factor**: 3 (adjusted for optimal readability)

```latex
\documentclass[11pt]{beamer}
\usepackage[size=a4,orientation=landscape,scale=3]{beamerposter}
```

### 2. Additional Packages
- **babel**: British English language support
- **pgf-pie**: Enhanced pie chart support for budget/allocation visualizations

```latex
\usepackage[british]{babel}
\usepackage{pgf-pie}
```

### 3. Font Size Adjustments
All content has been rescaled to fit A4 landscape properly:

```latex
\setbeamerfont{title}{size=\Large}
\setbeamerfont{subtitle}{size=\large}
\setbeamerfont{frametitle}{size=\large}
\setbeamerfont{normal text}{size=\small}
```

### 4. Custom Footer with Logo & Company Name

The footer includes:
- Company logo (left side)
- Company name (branding)
- Frame numbering (right side, e.g., "5/21")

```latex
\setbeamertemplate{footline}{
  \hbox{%
    \begin{beamercolorbox}[wd=1\paperwidth,ht=0.5cm,dp=0.25cm]{palette primary}
      \hspace{0.3cm}
      \includegraphics[height=0.4cm]{\companylogo}%
      \hspace{0.3cm}
      \textcolor{white}{\small\companyname}%
      \hfill%
      \insertframenumber/\inserttotalframenumber%
      \hspace{0.3cm}
    \end{beamercolorbox}%
  }
}
```

## Visual Element Scaling

All charts, tables, and diagrams have been optimized to prevent overflow while maintaining professional appearance:

### Charts (PGFPlots)
- **Scale Factor**: 0.75–0.9
- **Width**: 5.5–8.5cm
- **Height**: 4–4.2cm
- **Font Sizes**: \small or \footnotesize for axis labels

Example:
```latex
\begin{tikzpicture}[scale=0.85]
    \begin{axis}[
        width=5.5cm,
        height=4.2cm,
        ylabel style={font=\small},
        tick label style={font=\footnotesize},
        ...
    ]
```

### Pie Charts
- **Scale Factor**: 0.75
- **Radius**: 1.8 (adjusted from 2.0)
- **Legend**: Text-based for clarity

Example:
```latex
\begin{tikzpicture}[scale=0.75]
    \pie[
        text=legend,
        radius=1.8,
        color={blue!60, green!60, orange!60, red!60}
    ]{...}
```

### Tables
- **Wrapping**: Wrapped in `{\small}` or `{\tiny}` blocks
- **Spacing**: Reduced vertical spacing (0.2–0.3cm between elements)
- **Columns**: Two-column layouts for balanced content

Example:
```latex
{\small
\begin{tabular}{lc}
    \toprule
    \textbf{KPI} & \textbf{Target} \\
    \midrule
    ...
```

### Timeline Diagrams
- **Scale Factor**: 0.75
- **Elements**: Simplified milestone boxes with reduced font sizes

## Customisation Instructions

### Adding Your Company Logo

1. Place your logo file (PNG or PDF) in the `images/` directory
2. Name it `logo.png` or update the filename reference
3. The logo will automatically appear in the footer

**Location**: `assets/logo.png   NOTE: you may have to change to relative paths`
**Size in Footer**: 0.4cm height (automatically scaled)

### Changing Company Name

Edit `metadata.tex`:
```latex
\renewcommand{\companyname}{Your Company Name}
```

The name will appear in the footer on every slide.

### Adjusting Scale Factor

If content is too small or too large, modify the beamerposter scale in `main.tex`:

```latex
\usepackage[size=a4,orientation=landscape,scale=1.5]{beamerposter}
```

- **Smaller content**: Use `scale=1.2` or `scale=1.3`
- **Larger content**: Use `scale=1.6` or `scale=1.7`

Recompile and check for proper fit.

### Modifying Colors

Edit the color scheme in `main.tex`:

```latex
\setbeamercolor{structure}{fg=blue!70!black}
\setbeamercolor{palette primary}{bg=blue!70!black,fg=white}
```

### Adding New Slides

Create a new file in `content/` (e.g., `slide22-appendix.tex`):

```latex
% Slide 22: Additional Content
\begin{frame}{Your Title}
    Your content here
\end{frame}
```

Then add to `main.tex`:
```latex
\input{content/slide22-appendix.tex}
```

## Compilation Guide

### Online (Recommended)
1. Go to [Overleaf.com](https://www.overleaf.com)
2. Create a new project
3. Upload all files from `latex-beamer-bizpres/`
4. Click "Recompile" to generate PDF

### Local Compilation

**Requirements**:
- LaTeX distribution (TeX Live, MiKTeX, or MacTeX)
- Required packages: beamer, tikz, pgfplots, pgf-pie, fontawesome5, babel

**Commands**:
```bash
# Using pdflatex (requires two passes)
pdflatex main.tex
pdflatex main.tex

# Using latexmk (recommended)
latexmk -pdf main.tex
```

## No Overflow - Design Principles

This presentation uses several techniques to prevent content overflow:

1. **Consistent Spacing**: All elements use reduced vertical spacing
2. **Smart Typography**: Font size adjustments (small, tiny) for complex content
3. **Layout Balance**: Two-column designs prevent horizontal crowding
4. **Chart Optimization**: Scaled TikZ/PGFPlots with appropriate dimensions
5. **Element Grouping**: Logical grouping prevents dense layouts

## Troubleshooting

### Content Overflowing
- Reduce chart width/height
- Decrease font sizes (use `{\tiny}` instead of `{\small}`)
- Split content across two slides
- Reduce scale factor in beamerposter options

### Logo Not Appearing
- Verify file exists: `images/logo.png`
- Check file format (PNG or PDF recommended)
- Ensure filename matches the path in metadata.tex

### Charts Look Distorted
- Adjust `[scale=X]` factor in tikzpicture
- Modify axis width/height parameters
- Check for conflicting font size settings

## Tips for Professional Presentations

1. **Keep Text Concise**: Use bullet points, not paragraphs
2. **Use High-Quality Graphics**: Replace placeholder images
3. **Maintain Consistency**: Use the same color scheme throughout
4. **Visual Hierarchy**: Use bold for key points, smaller text for details
5. **Practice Your Pitch**: Slides should support your presentation, not replace it

## File Organisation

```
latex-beamer-bizpres/
├── main.tex                    # Main presentation
├── metadata.tex                # Title and footer info
├── A4-LANDSCAPE-SETUP.md       # This file
├── README.md                   # General documentation
├── compile.sh                  # Compilation script
├── images/                     # Logo and graphics
└── content/                    # 21 slide files
    ├── slide01-title.tex
    ├── slide02-introduction.tex
    ├── ... (through slide21)
```

## Next Steps

1. Add your company logo to `images/logo.png`
2. Update company name in `metadata.tex`
3. Replace Lorem ipsum content with your data
4. Customize colors if desired
5. Compile and review in your preferred viewer
6. Practice your investor pitch!

For questions or issues, refer to:
- [Beamer User Guide](https://ctan.org/pkg/beamer)
- [TikZ Documentation](https://ctan.org/pkg/pgf)
- [LaTeX Stack Exchange](https://tex.stackexchange.com)
