#!/bin/bash
set -u

data="$1"
shift
cache="$data/docs"
catalog="$HOME/.claude/plugins/marketplaces/claude-plugins-official/plugins"
max_age_days=7

stop() {
  echo "STOP: $1"
  exit 1
}

mkdir -p "$cache" || stop "cannot create $cache"

for arg in "$@"; do
  case "$arg" in
    src:*)
      path="$catalog/${arg#src:}"
      [ -e "$path" ] || stop "Anthropic's plugin catalog no longer has ${arg#src:} (looked in $catalog)"
      echo "SOURCE $path"
      ;;
    # Only Anthropic's two documentation sites are ever downloaded and read as instructions.
    doc:https://code.claude.com/docs/*|doc:https://platform.claude.com/docs/*)
      url="${arg#doc:}"
      file="$cache/$(echo "${url#https://}" | tr '/' '_')"
      if [ ! -s "$file" ] || [ -n "$(find "$file" -mtime +"$max_age_days")" ]; then
        tmp="$file.tmp"
        if ! curl -fsSL --max-time 30 "$url" -o "$tmp" || [ ! -s "$tmp" ] || [ "$(head -c 1 "$tmp")" = "<" ]; then
          rm -f "$tmp"
          stop "could not download $url"
        fi
        if [ -s "$file" ] && ! cmp -s "$file" "$tmp"; then
          echo "DOC CHANGED since the last download: $url"
        fi
        mv "$tmp" "$file"
      fi
      echo "DOC $file"
      ;;
    *)
      stop "unknown argument: $arg"
      ;;
  esac
done
