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
- `scripts/install-bootstrap-command.sh` to install a global `bootstrap` launcher (`~/.local/bin/bootstrap`) that scaffolds the current directory from this clone.
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
./scripts/install-bootstrap-command.sh
bootstrap
bootstrap --init
bootstrap --update
bootstrap --check-updates
```

## Inputs

- Required environment variables: none.
- Optional flags: `--check-updates`, `--auto-update`, and `--target /path/to/repo`.
- Secrets handling rules: do not commit tokens, machine-local secrets, or user-private state into this repo or the embedded skill.

## Implementation Rules

- Keep portable governance improvements in the embedded skill; do not pull personal desktop/runtime config into this repo.
- Rules stay stack-neutral. Anything specific to one language, framework, or project belongs in that project's `BOOTSTRAPPER_SPEC.md`, not in the shared rule files.
- Any change to shipped content (rules, templates, helper scripts) bumps `SCAFFOLD_VERSION`, or downstream repos never see it.
- The scaffold never deletes a file in a target repo. A file retired by a new version is added to `RETIRED_FILES` in `scripts/sync-agent-rules.sh`, which reports it for a person to remove.
- Treat `skills/agent-governance-scaffold/` as the canonical scaffold source and the repo root as its self-hosted consumer.
- Preserve repo-owned target history and create-if-missing docs when bootstrapping downstream repos.
- The installed local Codex skill is fully managed, but it should only be refreshed through the explicit repo-root updater after the embedded repo copy is validated.

## Verification

- `./scripts/check-bootstrapper-alignment.sh` reports the repo root aligned with the embedded skill.
- `./scripts/check-bootstrapper-alignment.sh --target /path/to/local/bootstrapper` reports whether another local Bootstrapper copy is behind this repo clone.
- `./scripts/bootstrap_agent_governance.sh --check-updates /path/to/repo` reports current or drifted status for a downstream target.
- `./scripts/bootstrap_agent_governance.sh /path/to/non-git-folder` succeeds on an empty folder and on a repo that still has the older `plans/INDEX.md` and monthly files, and leaves those files untouched.
- `./skills/agent-governance-scaffold/scripts/sync-templates-from-self.sh --check` reports the templates match the repo-root governance files.
- `./scripts/update-local-codex-skill.sh` followed by `diff -qr` makes the installed local skill byte-match the embedded repo skill.
- `./scripts/install-bootstrap-command.sh` installs `~/.local/bin/bootstrap`; a bare `bootstrap` in an empty directory then produces the full scaffold and `bootstrap --check-updates` reports it up to date.

## Non-Goals

- Do not turn this repo into a mirror of personal machine config such as Hyprland, Waybar, or app-state files.
- Do not make the installed local skill the long-term canonical source.

## Open Questions

- Whether non-Codex agent packaging should eventually be exported from the same repo structure.
