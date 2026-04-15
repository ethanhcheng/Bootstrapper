# Bootstrapper Spec

This file is the project-specific source of truth for what the Bootstrapper repo should build, generate, or automate. The governance files define process and quality gates; this file defines the actual bootstrapper behavior.

## Current Goal

- Keep `/home/ethan/Bootstrapper` as the single GitHub source of truth for:
  - the portable bootstrapper repo root
  - the installable Codex skill at `skills/agent-governance-scaffold/`
  - downstream bootstrapped target repos such as `/home/ethan/.config`
- Let any machine clone this repo, check alignment against other local Bootstrapper copies, bootstrap an existing target repo or non-git folder, and explicitly refresh the installed local Codex skill from the same canonical source.

## Agent Instructions

- Read this file before changing bootstrapper behavior or repo automation.
- Use `README.md` for clone, alignment, and operator workflow steps.
- Treat `projectbootstrapper.txt` as legacy reference material unless its contents are copied here.
- Record significant changes in `plans/` and keep the implementation trail append-only.

## Purpose

- Provide one portable, Git-tracked source for agent-governance scaffolding that can be cloned and reused across machines and repos.
- Keep the embedded Codex skill, the repo-root wrapper scripts, and the shared scaffold outputs in sync so drift is visible and recoverable.

## Supported Environments

- Linux: primary development and validation environment.
- macOS:
- Windows:

## Project Outputs

- `skills/agent-governance-scaffold/` as the canonical installable Codex skill.
- `scripts/bootstrap_agent_governance.sh` as the stable repo-root bootstrap/update entrypoint.
- `scripts/apply-bootstrapper-to-target.sh` as the compatibility entrypoint for applying the scaffold into existing folders.
- `scripts/check-bootstrapper-alignment.sh` for repo-root, local-skill, and optional target-repo drift checks.
- `scripts/update-local-codex-skill.sh` for explicit local skill refreshes.
- Repo-root governance files, mirrored rules, and plans workflow files that self-host the shared scaffold.

## Commands

```bash
./scripts/check-bootstrapper-alignment.sh
./scripts/check-bootstrapper-alignment.sh --target /path/to/local/bootstrapper
./scripts/check-bootstrapper-alignment.sh --target /path/to/repo
./scripts/bootstrap_agent_governance.sh /path/to/repo
./scripts/apply-bootstrapper-to-target.sh /path/to/existing-folder
./scripts/bootstrap_agent_governance.sh --check-updates /path/to/repo
./scripts/bootstrap_agent_governance.sh --auto-update /path/to/repo
./scripts/update-local-codex-skill.sh
```

## Inputs

- Required environment variables: none.
- Optional flags: `--check-updates`, `--auto-update`, and `--target /path/to/repo`.
- Secrets handling rules: do not commit tokens, machine-local secrets, or user-private state into this repo or the embedded skill.

## Implementation Rules

- Keep portable governance improvements in the embedded skill; do not pull personal desktop/runtime config into this repo.
- Treat `skills/agent-governance-scaffold/` as the canonical scaffold source and the repo root as its self-hosted consumer.
- Preserve repo-owned target history and create-if-missing docs when bootstrapping downstream repos.
- The installed local Codex skill is fully managed, but it should only be refreshed through the explicit repo-root updater after the embedded repo copy is validated.

## Verification

- `./scripts/check-bootstrapper-alignment.sh` reports the repo root aligned with the embedded skill.
- `./scripts/check-bootstrapper-alignment.sh --target /path/to/local/bootstrapper` reports whether another local Bootstrapper copy is behind this repo clone.
- `./scripts/bootstrap_agent_governance.sh --check-updates /path/to/repo` reports current or drifted status for a downstream target.
- `./scripts/bootstrap_agent_governance.sh /path/to/non-git-folder` succeeds even when `plans/<current-month>.md` already exists but is missing required scaffold headings.
- `./scripts/update-local-codex-skill.sh` followed by `diff -qr` makes the installed local skill byte-match the embedded repo skill.

## Non-Goals

- Do not turn this repo into a mirror of personal machine config such as Hyprland, Waybar, or app-state files.
- Do not make the installed local skill the long-term canonical source.

## Open Questions

- Whether non-Codex agent packaging should eventually be exported from the same repo structure.
