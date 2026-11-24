# claude-config

Ma config Claude Code, prête à installer sur une nouvelle machine : skills, agents, commands, rules, `CLAUDE.md`, hooks, statusline, et les plugins `code` et `pm`.

## Avant de quitter l'ancien Mac

Récupère ces deux valeurs et mets-les dans ton gestionnaire de mots de passe. Elles ne sont pas dans ce repo, exprès.

- Clé context7 : dans `~/.claude.json`, champ `mcpServers.context7.args` (le dernier argument, qui commence par `ctx7sk-`).
- Token treg : dans `~/.claude.json`, champ `mcpServers.treg.headers.Authorization` (la partie après `Bearer `).

## Installation sur la nouvelle machine

1. Installe Claude Code, git et bun (https://bun.sh).
2. Clone le repo et lance l'installation :

```bash
git clone git@github.com:AdrienBarb/claude-config.git
cd claude-config
./install.sh
```

3. Ajoute les serveurs MCP en donnant les deux valeurs récupérées plus haut :

```bash
CONTEXT7_API_KEY=... TREG_TOKEN=... ./mcp.sh
```

4. Ouvre Claude Code, tape `/mcp` et connecte mobbin (connexion par le navigateur, pas de clé).

## Ce que font les scripts

`install.sh` :
- copie tout le contenu du repo dans `~/.claude` (sans supprimer ce qui y est déjà) ;
- si `settings.json`, `settings.local.json` ou `keybindings.json` existent déjà, les garde en copie `<fichier>.bak-<date>` avant de les remplacer ;
- remplace `__HOME__` par ton dossier personnel et `__BUN__` par le chemin de bun dans les fichiers de réglages ;
- clone le plugin `pm` depuis https://github.com/deanpeters/Product-Manager-Skills au commit `1b5a524` ;
- installe les dépendances des scripts (`bun install` dans `~/.claude/scripts`).

`mcp.sh` ajoute en portée globale (`--scope user`) les serveurs context7, treg, rea et mobbin. Il s'arrête avec un message si `CONTEXT7_API_KEY` ou `TREG_TOKEN` manque.

## Contenu

- `skills/` : 23 skills.
- `agents/` : 25 agents.
- `commands/` : `react-build`, `react-review`, `react-test`, `debug-ccli`.
- `rules/` : react, typescript, mcp-organization.
- `local-plugins/code` : le plugin `code` (apex, review, spec, tickets, verify, challenge, owner, setup).
- `scripts/` : statusline, command-validator (hook qui bloque les commandes dangereuses), auto-rename-session (hook qui renomme les sessions), claude-code-ai.
- `settings.json`, `settings.local.json`, `keybindings.json`, `CLAUDE.md`.

## Pas inclus

- Le plugin `marketing` et le serveur MCP anytype.
- Les secrets : aucune clé ni token dans ce repo.
- L'agent `fast-websearch` attend un serveur MCP nommé `exa`, qui n'est pas configuré.

## À savoir

- `settings.json` met Claude en mode « bypass permissions » (aucune demande de confirmation). Vérifie que c'est accepté sur un poste d'entreprise.
- C'est une copie, pas une synchronisation. Pour récupérer une mise à jour du repo : `git pull` puis `./install.sh`. Pour garder une modification faite dans `~/.claude`, recopie le fichier dans ce repo, puis commit et push.
