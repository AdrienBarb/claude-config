# claude-config

Ma config Claude Code : skills, agents, commands, rules, hooks, statusline et plugins `code` et `pm`.

Installation sur une nouvelle machine (bun requis) :

    git clone git@github.com:AdrienBarb/claude-config.git
    cd claude-config
    ./install.sh
    CONTEXT7_API_KEY=... TREG_TOKEN=... ./mcp.sh

`install.sh` copie tout dans `~/.claude`, sauvegarde les `settings.json`, `settings.local.json` et `keybindings.json` existants en `.bak-<date>`, clone le plugin `pm` et installe les dépendances des scripts.
