# Øgreid Design Framework (ODF)

## Project Overview
This project develops design skills for use with Claude, focusing on evolving PowerPoint templates and visual assets for Øgreid.

## What We Do
- Build and refine Claude skills for design automation
- Create and evolve PowerPoint templates using Øgreid's visual identity
- Maintain a library of brand assets (logos, illustrations, banners)

## Asset Structure
- `logos/` — Øgreid logos (symbol, wordmark variants)
- `illustrations/` — Illustrations without backgrounds
- `illustrations-bg/` — Illustrations with backgrounds
- `banners/` — LinkedIn and general banners
- `anniversary/` — Anniversary-related assets

## Design Guidelines
- Follow Øgreid's visual identity and brand guidelines
- Use existing assets from the asset folders when building templates
- Keep templates clean, professional, and consistent
- Prefer PNG for transparency, JPG for photos

## Skill File Format — Common Traps
- `.skill` files MUST be zip archives containing `<skill-name>/SKILL.md`
- `SKILL.md` MUST start with YAML frontmatter (`---` block with `name` and `description`)
- Missing frontmatter causes upload error: "SKILL.md must start with YAML frontmatter (---)"
- When zipping, use **forward slashes** in paths (e.g. `ogreid-portfolio/SKILL.md`), not backslashes
- Always use `zipfile.ZIP_DEFLATED` compression
- Workflow: extract zip → edit SKILL.md → repack zip (never edit the .skill file directly as text)

## Working docs
- **ALL scratch, preview, and work-in-progress files go in `workingdocs/`** — never the project root.
- Examples: letter previews (`letter-*.html`, `letter-*.pdf`), test renders, draft screenshots, experiments.
- `workingdocs/` is gitignored. The project root stays clean and committable.
- When generating a file for the user to review (HTML previews, PDFs, mockups), create it under `workingdocs/<descriptive-name>.ext`.

## Development Notes
- Google Gemini API key is stored in `.env` (never commit secrets)
- Test templates with real content before finalizing
