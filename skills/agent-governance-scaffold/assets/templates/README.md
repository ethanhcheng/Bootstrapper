# Project

This repository carries repo-local agent governance, planning workflow files, and implementation history. Open it in Codex, Cursor, Claude Code, or another agent-capable tool and the same repo-local working conventions travel with the repo.

## Canonical Docs

- `BOOTSTRAPPER_SPEC.md`: project-specific behavior and requirements.
- `AGENTS.md`, `CLAUDE.md`, `.codex/PROJECT_RULES.md`: agent entry-point policy files.
- `rulesets/CONSOLIDATED_RULESET.md`: generated shared ruleset.
- `plans/`: append-only implementation and verification trail.
- `projectbootstrapper.txt`: legacy note retained for reference only, not the source of truth.

## Repo Layout

- `.cursor/rules/` and `.claude/rules/`: editable source rule files.
- `.codex/rules/` and `rulesets/`: generated mirrors; regenerate after rule edits.
- `scripts/`: helper scripts for syncing rules and maintaining the plans workflow.
- `plans/`: monthly checklists, implementation docs, and optional seed notes.

## Working Model

1. Read `BOOTSTRAPPER_SPEC.md` and the repo governance files before making changes.
2. Keep significant work recorded in `plans/`.
3. Re-run `scripts/sync-agent-rules.sh` after editing rule sources.
4. Use `scripts/create-implementation-doc.sh YYYY-MM-DD feature-name` for significant updates.
