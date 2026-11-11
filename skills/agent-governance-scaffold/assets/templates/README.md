# Project

This repository carries repo-local agent governance, planning workflow files, and implementation history. Open it in Codex, Cursor, Claude Code, or another agent-capable tool and the same repo-local working conventions travel with the repo.

## Canonical Docs

- `BOOTSTRAPPER_SPEC.md`: project-specific behavior and requirements.
- `AGENTS.md`, `CLAUDE.md`, `.codex/PROJECT_RULES.md`: agent entry-point policy files.
- `rulesets/CONSOLIDATED_RULESET.md`: generated shared ruleset.
- `plans/`: append-only implementation and verification trail.
- `projectbootstrapper.txt`: legacy note retained for reference only, not the source of truth.

## Repo Layout

- `.claude/rules/`: the only place rules are edited.
- `.cursor/rules/`, `.codex/rules/`, and `rulesets/`: generated copies; regenerate after rule edits.
- `scripts/`: helper scripts for syncing rules and maintaining the plans workflow.
- `plans/`: one dated, self-describing doc per change, plus optional seed notes.

## Working Model

1. Fill in `BOOTSTRAPPER_SPEC.md`; the rules defer to it for the stack, the commands, and what each work tier means here.
2. Record each change in `plans/` with `scripts/create-implementation-doc.sh YYYY-MM-DD short-name`.
3. Re-run `scripts/sync-agent-rules.sh` after editing `.claude/rules/`.
4. Run `scripts/verify-plans-workflow.sh` before pushing.
