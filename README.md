# Bootstrapper

This repository is the portable home for your bootstrapper rules, agent governance, and implementation history. Clone it on any machine, open it with your preferred coding agent, and the same repo-local instructions travel with it.

## Canonical Docs

- `BOOTSTRAPPER_SPEC.md`: project-specific bootstrapper behavior and requirements.
- `AGENTS.md`, `CLAUDE.md`, `.codex/PROJECT_RULES.md`: agent entry-point policy files.
- `rulesets/CONSOLIDATED_RULESET.md`: generated shared ruleset.
- `plans/`: append-only implementation and verification trail.

## Repo Layout

- `.cursor/rules/` and `.claude/rules/`: editable source rule files.
- `.codex/rules/` and `rulesets/`: generated mirrors; regenerate after rule edits.
- `scripts/`: helper scripts for syncing rules and creating implementation docs.
- `projectbootstrapper.txt`: legacy note retained for reference only, not the source of truth.

## Use On Any Machine

1. Clone this repository.
2. Open the folder in Codex, Cursor, Claude Code, or another agent-capable tool.
3. Tell the agent to read `BOOTSTRAPPER_SPEC.md` and the repo governance files before making changes.
4. If you change rules, run `scripts/sync-agent-rules.sh`.
5. For significant work, start with `scripts/create-implementation-doc.sh YYYY-MM-DD feature-name`.

## Initial GitHub Push

```bash
git add .
git commit -m "Initial bootstrapper scaffold"
gh repo create Bootstrapper --private --source=. --push
```

If you do not use `gh`, create an empty GitHub repo in the web UI and push this folder to it.

## Next Step

Fill in `BOOTSTRAPPER_SPEC.md` with the exact bootstrapper behavior you want agents to implement.
