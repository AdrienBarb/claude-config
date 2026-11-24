#!/usr/bin/env bash
set -euo pipefail
SRC="$(cd "$(dirname "$0")" && pwd)"
DEST="$HOME/.claude"
command -v bun >/dev/null || { echo "bun manque : installe-le (https://bun.sh) puis relance ce script."; exit 1; }
mkdir -p "$DEST"
STAMP="$(date +%Y%m%d%H%M%S)"
for f in settings.json settings.local.json keybindings.json; do
  [ -f "$DEST/$f" ] && cp "$DEST/$f" "$DEST/$f.bak-$STAMP"
done
rsync -a --exclude .git --exclude install.sh --exclude mcp.sh --exclude .gitignore --exclude README.md "$SRC/" "$DEST/"
BUN_BIN="$(command -v bun)"
for f in settings.json settings.local.json; do
  sed -i.tmp -e "s#__HOME__#$HOME#g" -e "s#__BUN__#$BUN_BIN#g" "$DEST/$f" && rm "$DEST/$f.tmp"
done
PM="$DEST/local-plugins/product-manager-skills"
if [ ! -d "$PM" ]; then
  git clone -q https://github.com/deanpeters/Product-Manager-Skills.git "$PM"
  git -C "$PM" checkout -q 1b5a524
fi
(cd "$DEST/scripts" && bun install)
echo "Config installée dans $DEST. Lance ./mcp.sh pour ajouter les serveurs MCP."
