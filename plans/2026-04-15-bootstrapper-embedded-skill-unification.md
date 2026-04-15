# 2026-04-15 - bootstrapper-embedded-skill-unification

## Request Summary
- Make `/home/ethan/Bootstrapper` the single GitHub source of truth for the repo root scaffold, the installable Codex skill, and downstream target repos.
- Vendor the installed `agent-governance-scaffold` skill into `Bootstrapper`, upgrade portable scaffold improvements, add repo-root wrapper/check/update commands, and validate that downstream drift is detectable.

## Full Agent Implementation Plan
### Summary
- Make `/home/ethan/Bootstrapper` the single GitHub source of truth for all three layers:
  - the portable bootstrapper repo root
  - the installable Codex skill at `skills/agent-governance-scaffold/`
  - downstream bootstrapped target repos such as `/home/ethan/.config`
- Current fact: the installed local skill and the current `Bootstrapper` repo already matched on the shared scaffold files they both contained.
- Current gap: `Bootstrapper` was missing the installable skill packaging and repo-contained bootstrap script/layout that existed only in `/home/ethan/.codex/skills/agent-governance-scaffold`.
- Constraint: do not overwrite the installed local skill until the repo copy carries every portable improvement from the local skill and the generic scaffold upgrades.

### Implementation Changes
- Add `skills/agent-governance-scaffold/` to `Bootstrapper` by vendoring the installed skill structure:
  - `SKILL.md`
  - `agents/openai.yaml`
  - `assets/templates/`
  - `scripts/bootstrap_agent_governance.sh`
- Treat the embedded skill as the canonical scaffold source inside the repo.
- Upgrade that embedded skill with portable improvements:
  - repo-relative governance references
  - resource-conscious helper guidance
  - `plans/IDEAS.md` support and seed-note workflow
  - path-agnostic scaffold version detection
  - managed updates for scaffolded planning workflow files
- Make the repo root a self-hosted consumer of the embedded skill.
- Add repo-root commands:
  - `./scripts/bootstrap_agent_governance.sh`
  - `./scripts/check-bootstrapper-alignment.sh`
  - `./scripts/update-local-codex-skill.sh`

### Public Interfaces
- Canonical installable skill path in GitHub: `skills/agent-governance-scaffold/`
- Stable repo-root target bootstrap command: `./scripts/bootstrap_agent_governance.sh [--check-updates|--auto-update] /path/to/repo`
- Stable repo-root alignment check command: `./scripts/check-bootstrapper-alignment.sh [--target /path/to/repo]`
- Stable repo-root local skill refresh command: `./scripts/update-local-codex-skill.sh`
- Local installed skill destination: `$CODEX_HOME/skills/agent-governance-scaffold`, defaulting to `~/.codex/skills/agent-governance-scaffold`

### Managed vs Owned Rules
- Embedded skill fully owns its own contents under `skills/agent-governance-scaffold/`.
- Local installed skill is fully managed and may be overwritten to match the repo after validation.
- Repo root self-hosting must match the embedded skill for shared scaffold outputs:
  - entry-point docs and rules
  - helper scripts
  - scaffolded planning workflow files
- Repo root keeps its own monthly plans and implementation docs as repo-owned history.
- Target repos keep repo-owned docs/history according to bootstrap policy:
  - overwrite managed governance, rule, and script files
  - preserve create-if-missing repo docs and append-only plans history

### Test Plan
- Verify the embedded skill directory is complete and installable.
- Verify shared scaffold outputs in the repo root match what the embedded skill produces for managed files.
- Verify `./scripts/check-bootstrapper-alignment.sh` reports repo-root, local-skill, and optional target-repo alignment.
- Verify `./scripts/bootstrap_agent_governance.sh --check-updates /home/ethan/.config` works from the repo root and uses the embedded skill.
- After repo validation, verify `./scripts/update-local-codex-skill.sh` makes the installed local skill byte-match the embedded repo skill.

## Execution Trace
- Affected files:
  - Repo root scaffold outputs: `AGENTS.md`, `CLAUDE.md`, `.codex/PROJECT_RULES.md`, editable rule files, generated Codex/ruleset mirrors, `plans/README.md`, `plans/INDEX.md`, `plans/IDEAS.md`, `.agent-governance-manifest.json`
  - Repo root operator docs and commands: `README.md`, `BOOTSTRAPPER_SPEC.md`, `projectbootstrapper.txt`, `scripts/bootstrap_agent_governance.sh`, `scripts/check-bootstrapper-alignment.sh`, `scripts/update-local-codex-skill.sh`
  - Embedded skill contents under `skills/agent-governance-scaffold/`, including templates, bootstrap script, and plans verification script
- Downstream dependents:
  - The installed local Codex skill at `~/.codex/skills/agent-governance-scaffold`
  - Downstream target repos bootstrapped from this clone, including `/home/ethan/.config`
  - Agent sessions that rely on the repo root's shared scaffold files being current
- Integration points:
  - Repo-root wrapper delegates to `skills/agent-governance-scaffold/scripts/bootstrap_agent_governance.sh`
  - Repo-root alignment checker compares embedded skill vs repo root, local installed skill, and optional target repo
  - Local skill updater syncs the embedded skill into `~/.codex/skills/agent-governance-scaffold`
  - Downstream target drift is detected through both `--check-updates` and the alignment checker
- Current monthly checklist entry:
  - `2026-04-15 - bootstrapper-embedded-skill-unification`

## Edge Cases / Risks / Assumptions
- Edge cases:
  - The first self-host bootstrap failed until `plans/README.md`, `plans/IMPLEMENTATION_TEMPLATE.md`, and `plans/legacy-plans.md` were promoted from create-if-missing to managed scaffold updates.
  - The installed local skill was intentionally left behind until the repo canonical copy was updated and verified.
  - Downstream target repos can be version-behind while still passing their own local ruleset/plans checks; the alignment checker now surfaces those file-level drifts explicitly.
- Risks:
  - `/home/ethan/.config` remains behind the new scaffold until it is updated from `Bootstrapper`.
  - Repo-root docs such as `README.md` and `BOOTSTRAPPER_SPEC.md` are repo-owned and still require manual maintenance when the bootstrapper workflow changes.
- Assumptions:
  - The installed local Codex skill may be fully overwritten from the repo once the embedded canonical copy is validated.
  - Personal runtime config and machine-specific state stay out of `Bootstrapper`.

## Verification
- Commands run:
  - `./scripts/create-implementation-doc.sh 2026-04-15 bootstrapper-embedded-skill-unification`
  - `bash -n skills/agent-governance-scaffold/scripts/bootstrap_agent_governance.sh`
  - `bash -n skills/agent-governance-scaffold/assets/templates/scripts/verify-plans-workflow.sh`
  - `bash -n scripts/bootstrap_agent_governance.sh`
  - `bash -n scripts/check-bootstrapper-alignment.sh`
  - `bash -n scripts/update-local-codex-skill.sh`
  - `./scripts/bootstrap_agent_governance.sh /home/ethan/Bootstrapper`
  - `./scripts/check-bootstrapper-alignment.sh`
  - `./scripts/bootstrap_agent_governance.sh --check-updates /home/ethan/.config`
  - `./scripts/update-local-codex-skill.sh`
  - `./scripts/check-bootstrapper-alignment.sh --target /home/ethan/.config`
  - `./scripts/bootstrap_agent_governance.sh --check-updates /home/ethan/Bootstrapper`
- Results:
  - The repo root now self-hosts the shared scaffold from `skills/agent-governance-scaffold`.
  - The local installed Codex skill now byte-matches the embedded repo skill.
  - The repo-root wrapper reports `/home/ethan/Bootstrapper` up to date.
  - The alignment checker reports repo-root and local-skill alignment, and it flags `/home/ethan/.config` as a behind downstream target with concrete file-level drift.

## Outcome
- Status:
  - `implemented-verified`
- Follow-up items:
  - Run `./scripts/bootstrap_agent_governance.sh --auto-update /home/ethan/.config` when you want the active config repo to adopt the new scaffold version.
  - Restart Codex so future sessions pick up the refreshed installed local skill from `~/.codex/skills/agent-governance-scaffold`.
- Monthly plan updated:
  - Yes
- `plans/INDEX.md` updated:
  - Yes
