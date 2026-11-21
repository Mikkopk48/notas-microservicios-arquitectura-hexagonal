#!/usr/bin/env bash
# Regenera README.md con una galería de los PNG exportados por Excalidraw.
# Lo ejecuta el hook pre-commit, así cada commit de Obsidian Git actualiza el README.
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

TITLE="Notas · Microservicios y arquitectura por capas vs. hexagonal"

urlenc() { python3 -c 'import sys,urllib.parse;print(urllib.parse.quote(sys.argv[1]))' "$1"; }

# Nota con frontmatter excalidraw-plugin + PNG del mismo nombre, en orden alfabético
mapfile -t pngs < <(
  grep -rlZ --include='*.md' --exclude-dir=.git --exclude-dir=.obsidian -m1 '^excalidraw-plugin:' . |
  while IFS= read -r -d '' md; do
    png="${md%.md}.png"; [[ -f "$png" ]] && printf '%s\n' "${png#./}"
  done | LC_ALL=C sort
)

{
  echo "# $TITLE"
  echo
  if (( ${#pngs[@]} == 0 )); then
    echo "_Todavía no hay imágenes exportadas._"; echo
  else
    for p in "${pngs[@]}"; do
      name="$(basename "$p" .png)"
      echo "## $name"
      echo
      echo "[![$name]($(urlenc "$p"))]($(urlenc "$p"))"
      echo
    done
  fi
  echo "---"
  echo "_README generado automáticamente por \`scripts/update-readme.sh\`._"
} > README.md
