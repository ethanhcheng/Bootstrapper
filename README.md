# Bootstrapper

This repository is the canonical GitHub source for the portable agent-governance scaffold. It carries the installable Codex skill, the repo-root wrapper commands, and a self-hosted copy of the shared scaffold at the repo root so all three layers stay aligned.

## Canonical Sources

- `skills/agent-governance-scaffold/`: canonical embedded skill, templates, and bootstrap script.
- `scripts/bootstrap_agent_governance.sh`: stable repo-root wrapper for bootstrapping or updating target repos.
- `scripts/apply-bootstrapper-to-target.sh`: compatibility wrapper for applying the scaffold into an existing folder.
- `scripts/check-bootstrapper-alignment.sh`: checks repo-root, embedded-skill, local-skill, and optional target-repo alignment.
- `scripts/update-local-codex-skill.sh`: refreshes `~/.codex/skills/agent-governance-scaffold` from this repo clone.
- `plans/`: append-only implementation and verification trail for Bootstrapper itself.

## Repo Layout

- `skills/agent-governance-scaffold/`: installable Codex skill with templates and the canonical embedded bootstrap script.
- `.cursor/rules/` and `.claude/rules/`: editable source rule files.
- `.codex/rules/` and `rulesets/`: generated mirrors; regenerate after rule edits.
- `scripts/`: repo-root wrapper commands plus the shared scaffold maintenance scripts.
- `plans/`: monthly checklists and dated implementation docs for Bootstrapper work.

## Working Model

1. Clone this repository.
2. Run `./scripts/check-bootstrapper-alignment.sh` to see whether the repo root and local installed skill match the embedded canonical copy.
3. Use `./scripts/check-bootstrapper-alignment.sh --target /path/to/local/bootstrapper` to compare any other local Bootstrapper copy against this repo clone.
4. Use `./scripts/bootstrap_agent_governance.sh /path/to/repo` to scaffold or update another repo or existing non-git folder from this clone.
5. Use `./scripts/apply-bootstrapper-to-target.sh /path/to/folder` if you want the older “apply into an existing folder” entrypoint name.
6. Use `./scripts/bootstrap_agent_governance.sh --check-updates /path/to/repo` and `--auto-update` for routine downstream maintenance.
7. After validating repo updates, run `./scripts/update-local-codex-skill.sh` to refresh the installed Codex skill from this clone, then restart Codex.
