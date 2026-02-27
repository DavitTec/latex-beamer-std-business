# Quick Start Guide - LaTeX Beamer BizPres

## Getting Started in 5 Minutes

### Option 1: Compile Locally

If you have LaTeX installed:

```bash
cd latex-beamer-bizpres
./compile.sh
```

Or manually:

```bash
pdflatex main.tex
pdflatex main.tex
```

### Option 2: Use Overleaf (Recommended for Beginners)

1. Go to [Overleaf.com](https://www.overleaf.com)
2. Create a free account
3. Click "New Project" → "Upload Project"
4. Zip the `latex-beamer-bizpres` folder and upload
5. Click "Recompile" to generate your PDF

## Customization Checklist

### Step 1: Update Metadata (5 min)
Edit `metadata.tex`:
- [ ] Company name
- [ ] Presentation title
- [ ] Your contact email

### Step 2: Customize Content (30-60 min)
Replace placeholder content in each slide:
- [ ] Slide 02: Introduction - Your vision and highlights
- [ ] Slide 03: Company - Your company details and founding info
- [ ] Slide 04: Problem - Your specific problem and solution
- [ ] Slide 06: Market - Your actual TAM/SAM/SOM numbers
- [ ] Slide 07: Traction - Your real metrics and growth data
- [ ] Slide 13: Capital - Your actual funding needs
- [ ] Slide 14: Financials - Your financial projections
- [ ] Slide 15: Team - Your team members and bios
- [ ] Slide 21: Contact - Your actual contact information

### Step 3: Add Visuals (15 min)
- [ ] Add your logo to `images/` folder
- [ ] Uncomment logo line in `metadata.tex`
- [ ] Add product screenshots if available
- [ ] Replace generic charts with your data

### Step 4: Adjust Theme Colors (Optional)
Edit `main.tex` lines 7-10 to change from blue to your brand color:
```latex
\setbeamercolor{structure}{fg=red!70!black}  % Change blue to red
\setbeamercolor{palette primary}{bg=red!70!black,fg=white}
```

## Common Edits

### Change Funding Amount
Find and replace `\money{2.5M}` with your actual amount throughout the files.

### Add/Remove Slides
In `main.tex`, comment out or add:
```latex
% \input{content/slide16-advisors.tex}  % Comment to hide
\input{content/slide99-custom.tex}      % Add new slide
```

### Modify Charts
Edit the TikZ/PGFPlots code in slides like:
- `slide06-market.tex` - Market size chart
- `slide07-traction.tex` - Revenue growth chart
- `slide14-financials.tex` - Financial projections

### Update Timeline
Edit `slide09-timeline.tex` to match your actual project timeline.

## Slide Layout Examples

The presentation showcases various layouts:

- **Two-column layouts**: Slides 02, 04, 06, 07, 11
- **Centered content**: Slides 01, 05, 20, 21
- **Tables**: Slides 08, 14, 17, 18
- **Charts/Graphs**: Slides 06, 07, 14
- **Timelines**: Slides 03, 09
- **Process flows**: Slides 05, 10, 19
- **Comparison tables**: Slide 17
- **Pie charts**: Slides 12, 13

## Tips for Success

1. **Keep text minimal** - Slides should support your speech, not replace it
2. **Use bullet points** - No more than 5-6 per slide
3. **Visual hierarchy** - Most important info should stand out
4. **Consistent fonts** - Already handled by the theme
5. **Practice timing** - Aim for 1-2 minutes per slide (20-40 min total)
6. **Tell a story** - Each slide should flow naturally to the next

## Troubleshooting

### "Command not found: pdflatex"
Install LaTeX:
- **Ubuntu/Debian**: `sudo apt-get install texlive-full`
- **macOS**: Download [MacTeX](https://tug.org/mactex/)
- **Windows**: Download [MiKTeX](https://miktex.org/)

### Missing packages error
Install the required package or use Overleaf (has all packages).

### Compilation errors
- Check for unclosed braces `{ }`
- Check for special characters that need escaping: `& % $ # _ { } ~ ^ \`
- Run `pdflatex main.tex` (without `-interaction=nonstopmode`) to see full errors

### Charts not displaying
Ensure you have `pgfplots` and `tikz` packages installed.

## File Structure Reference

```
latex-beamer-bizpres/
├── main.tex              # Main file - imports everything
├── metadata.tex          # Title, author, date
├── compile.sh            # Compilation script
├── content/
│   └── slide*.tex        # Individual slide files
└── images/               # Put logos and images here
```

## Next Steps

1. Compile the template as-is to see the example
2. Update one slide at a time with your content
3. Recompile frequently to check your changes
4. Practice your presentation
5. Get feedback and iterate

## Resources

- [Beamer Documentation](https://ctan.org/pkg/beamer)
- [TikZ Examples](https://texample.net/tikz/)
- [LaTeX Colors](https://www.overleaf.com/learn/latex/Using_colours_in_LaTeX)
- [Beamer Themes](https://hartwork.org/beamer-theme-matrix/)

---

**Need help?** Check the full README.md for detailed information.
