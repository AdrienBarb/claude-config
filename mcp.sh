#!/usr/bin/env bash
set -euo pipefail
: "${CONTEXT7_API_KEY:?Exporte CONTEXT7_API_KEY avant de lancer ce script}"
: "${TREG_TOKEN:?Exporte TREG_TOKEN avant de lancer ce script}"
claude mcp add --scope user context7 -- npx -y @upstash/context7-mcp --api-key "$CONTEXT7_API_KEY"
claude mcp add --scope user --transport http treg https://treg.to/mcp/ --header "Authorization: Bearer $TREG_TOKEN"
claude mcp add --scope user -e "PATH=/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin" rea -- npx -y rea-agents@6.5.0 mcp
claude mcp add --scope user --transport http mobbin https://api.mobbin.com/mcp
