# Recipe: Add a new portfolio company

End-to-end steps for adding a company to the portfolio skill and generating its 4 icon variants (color / bw / red / green).

## Inputs you need upfront

| Field | Where to find it | Example (Trafsys) |
|---|---|---|
| Name | — | Trafsys AS |
| Slug | lowercase, hyphenated | `trafsys` |
| Org number | [brreg.no](https://brreg.no) or their website | 947 080 687 |
| Location | Their website "Kontakt" page | Bønes (Bergen) |
| Sector / one-liner | Their website homepage | Traffic management tech for roads and tunnels |
| Logo SVG | Their website — usually inline in the header | (see Step 2) |
| Logo's source color hex | Inspect SVG `fill="#xxxxxx"` | `#163B64` |

---

## Step 1 — Gather the company info

Read their site, note sector + location, find org nr on brreg.no if not listed.

## Step 2 — Extract the logo SVG

Most Norwegian business sites inline their logo as an SVG in the header. Grab it:

```bash
curl -sL https://www.<domain> | python3 -c "
import sys, re
html = sys.stdin.read()
m = re.search(r'<a[^>]*class=\"logo\"[^>]*>(<svg.*?</svg>)', html, re.DOTALL)
if m:
    print(m.group(1))
" > /tmp/<slug>-logo.svg
```

Adjust the regex if their logo isn't wrapped in `<a class="logo">` — look at the page source and match their structure.

Verify the file looks like a real SVG (starts with `<svg ...>`) and find the fill color:

```bash
grep -oE 'fill="#[A-F0-9]+"' /tmp/<slug>-logo.svg | sort | uniq -c
```

If the logo uses **multiple** colors, you'll need to decide manually which to treat as the "brand" color to re-tint. The script below only handles single-color logos cleanly. For multi-color logos, render the color version as-is and manually create bw/red/green versions.

## Step 3 — Generate the 4 icon variants

```bash
scripts/generate-portfolio-icons.sh <slug> /tmp/<slug>-logo.svg <SOURCE_HEX_NO_HASH>
```

Example:
```bash
scripts/generate-portfolio-icons.sh trafsys /tmp/trafsys-logo.svg 163B64
```

Outputs 4 PNGs to `/tmp/<slug>-render/` at 512px wide, preserving aspect ratio, transparent background. The script prints the `cp` commands to install them.

**Review the PNGs** before installing — open them in Preview or use `open /tmp/<slug>-render/color.png`. Common issues:
- Empty/blank PNG → the SVG's `fill=` color didn't match what you passed as source hex
- Cut off at edges → SVG has content outside its viewBox; adjust `INNER_W` in the script
- Multiple colors lost → only the source color you specified gets re-tinted

## Step 4 — Install icons

```bash
cp /tmp/<slug>-render/color.png assets/icons/color/<slug>.png
cp /tmp/<slug>-render/bw.png    assets/icons/bw/<slug>.png
cp /tmp/<slug>-render/red.png   assets/icons/red/<slug>.png
cp /tmp/<slug>-render/green.png assets/icons/green/<slug>.png
```

## Step 5 — Extract the portfolio skill for editing

```bash
mkdir -p /tmp/ogreid-portfolio-extract
unzip -o ogreid-portfolio.skill -d /tmp/ogreid-portfolio-extract
```

Edit `/tmp/ogreid-portfolio-extract/ogreid-portfolio/SKILL.md`. Add:

**(a)** A new section under `## Portfolio Companies` (alphabetical order):

```markdown
### <Company> — <Sector>
<One-sentence description.>
| Entity | Org Nr | Location |
|--------|--------|----------|
| <Legal Entity Name> | <org nr> | <City> |
```

**(b)** A row in the Quick Lookup table at the bottom:

```markdown
| <Brand> | <Legal Entity Name> | <org nr> |
```

## Step 6 — Extract and update the design skill (icon slug table)

```bash
mkdir -p /tmp/ogreid-design-extract
unzip -o ogreid-design.skill -d /tmp/ogreid-design-extract
```

Edit `/tmp/ogreid-design-extract/ogreid-design/SKILL.md`. Find the "Available Companies" table under §10 "Portfolio Company Icons" and add:

```markdown
| `<slug>` | <Company> |
```

## Step 7 — Repack both skills

```bash
scripts/repack-skill.sh ogreid-portfolio
scripts/repack-skill.sh ogreid-design
```

The script verifies YAML frontmatter is intact and uses `ZIP_DEFLATED` with forward-slash paths (per `CLAUDE.md`).

## Step 8 — Commit + push

The GitHub raw URLs (`https://raw.githubusercontent.com/ornhalvorsen/odf/main/assets/icons/...`) only work once the icons are pushed.

```bash
git add assets/icons/*/<slug>.png ogreid-portfolio.skill ogreid-design.skill
git commit -m "Add <Company> to portfolio"
git push
```

## Step 9 — Re-upload to Claude

`.skill` files don't auto-sync. Open Claude → Skills → delete the old `ogreid-portfolio` (and `ogreid-design` if updated) and upload the new `.skill` files.

---

## Troubleshooting

| Symptom | Fix |
|---|---|
| "Chrome not found" | Edit `CHROME=` at top of `generate-portfolio-icons.sh` |
| Empty/tiny PNG (≈500 bytes) | Source hex mismatch — grep the SVG for its actual `fill=` color |
| Icon has unexpected background | SVG has a `<rect>` background layer — remove it from the SVG before rendering |
| Skill upload rejected | Check SKILL.md starts with `---` frontmatter (repack-skill.sh verifies this) |
| "Skill unchanged" in Claude | Re-upload is required; the local file doesn't auto-sync |

## Files touched by this recipe

- `assets/icons/color/<slug>.png`
- `assets/icons/bw/<slug>.png`
- `assets/icons/red/<slug>.png`
- `assets/icons/green/<slug>.png`
- `ogreid-portfolio.skill` (via `/tmp/ogreid-portfolio-extract/ogreid-portfolio/SKILL.md`)
- `ogreid-design.skill` (via `/tmp/ogreid-design-extract/ogreid-design/SKILL.md`)
