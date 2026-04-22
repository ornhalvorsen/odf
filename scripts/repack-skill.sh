#!/usr/bin/env bash
# Repack an Øgreid skill folder into its .skill zip archive.
#
# Usage:
#   scripts/repack-skill.sh <skill-name>
#
# Example:
#   scripts/repack-skill.sh ogreid-portfolio
#
# Assumes the source folder is extracted to /tmp/<skill-name>-extract/<skill-name>/
# and writes the output to ./<skill-name>.skill in the project root.
#
# Per CLAUDE.md rules:
#   - archive must contain <skill-name>/SKILL.md
#   - paths must use forward slashes
#   - use ZIP_DEFLATED compression
#   - SKILL.md must start with YAML frontmatter (---)

set -euo pipefail

SKILL_NAME="${1:?skill name required — e.g. 'ogreid-portfolio'}"

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC_DIR="/tmp/${SKILL_NAME}-extract"
OUT_FILE="${REPO_ROOT}/${SKILL_NAME}.skill"

[ -f "${SRC_DIR}/${SKILL_NAME}/SKILL.md" ] || { echo "SKILL.md not found at ${SRC_DIR}/${SKILL_NAME}/SKILL.md" >&2; exit 1; }

# Verify frontmatter
head -1 "${SRC_DIR}/${SKILL_NAME}/SKILL.md" | grep -q '^---$' \
  || { echo "SKILL.md missing YAML frontmatter (must start with ---)" >&2; exit 1; }

cd "$SRC_DIR"
python3 -c "
import zipfile, os
out = '${OUT_FILE}'
with zipfile.ZipFile(out, 'w', zipfile.ZIP_DEFLATED) as z:
    for root, dirs, files in os.walk('${SKILL_NAME}'):
        for f in files:
            path = os.path.join(root, f)
            arc = path.replace(os.sep, '/')
            z.write(path, arc)
            print('added', arc)
"

echo
unzip -l "$OUT_FILE"
