# Codex Project Rules

- Entry point: `AGENTS.md`.
- Process and quality rules: `rulesets/CONSOLIDATED_RULESET.md`. `.codex/rules/` holds the same rules as individual files.
- Project spec: `BOOTSTRAPPER_SPEC.md`. Repo guide: `README.md`. Change records: `plans/`.

Rules are edited in `.claude/rules/` only. `scripts/sync-agent-rules.sh` regenerates `.cursor/rules/`, `.codex/rules/`, and `rulesets/` from them; do not hand-edit those copies.
