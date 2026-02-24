# TODO for LaTeX Presentation Template v1.0.0

> NOTE: Taken form Letter Template Project
>

## High Priority

- feat: Add footer with page numbers/company info (use fancyhdr \fancyfoot[C]{...}; toggle via metadata \def\usefooter{yes}). Test multipage.
- bug: Confirm/resolve any overlaps from large \vspace\* in \opening (add \enlargethispage if needed).
- chore: Integrate pnpm script for metadata generation from config.json (see scripts/generate-metadata.js).

## Medium Priority

- feat: Attachments/enclosures (\encl{list}; add to metadata.tex with conditional display after closing).
- feat: Multipage auto-detection (use ifthen with \pageref{lastpage} >1 to toggle \pagestyle{plain}).
- feat: PDF attachments embedding (add \usepackage{attachfile}; \attachfile{file.pdf} in content.tex).

## Low Priority

- feat: Explore monorepo integration with latex-workshop (use git submodules or lerna for subrepos).
- feat: Add bash build script (build.sh with pdflatex and cleanup).
- feat: pnpm script for DB fetch (e.g., Node.js with SQLite to JSON, then generate metadata.tex).

Track progress with GitHub issues. 

