# 2026-05-21 - bootstrap-cli-launcher

## Request Summary
- Add a global `bootstrap` CLI command, callable from any directory, that scaffolds the current directory as a project according to the Bootstrapper rules.
- Today the scaffold is reachable only as a Codex/Claude skill or via `scripts/bootstrap_agent_governance.sh`; the user wants a direct shell entrypoint.

## Full Agent Implementation Plan
- Mirror the existing `aip` launcher convention (`~/.local/bin/aip`, acts on `$PWD`).
- Add `scripts/install-bootstrap-command.sh` (repo-root operator script, sibling of `update-local-codex-skill.sh`):
  - Computes `REPO_ROOT` from its own location so it is portable across machines/clones.
  - Generates `~/.local/bin/bootstrap` (override dir via `BOOTSTRAP_BIN_DIR`) with the canonical script's absolute path baked in.
  - Warns if the bin dir is not on `PATH`.
- The generated `bootstrap` launcher thin-wraps `scripts/bootstrap_agent_governance.sh` and `exec`s it with `"$@"`:
  - bare `bootstrap` -> canonical script defaults `TARGET_DIR` to `$PWD` (install mode).
  - flags pass through: `--check-updates`, `--auto-update`, `--force-spec`, `--update`, and an explicit target path.
- Point the launcher at the repo-root wrapper (the documented canonical entrypoint, which also stamps `SOURCE_COMMIT`).
- Keep the installer at the repo root only; do NOT add it to `assets/templates/scripts/`, so it is not copied into downstream bootstrapped targets.
- Wire docs: README working-model step, BOOTSTRAPPER_SPEC outputs/commands, SKILL Quick Start.

## Execution Trace
- Affected files:
  - `scripts/install-bootstrap-command.sh` (new)
  - `README.md`, `BOOTSTRAPPER_SPEC.md`, `skills/agent-governance-scaffold/SKILL.md` (docs)
  - `plans/2026-05.md`, `plans/INDEX.md`, this doc (plans trail)
  - Generated at install time, outside the repo: `~/.local/bin/bootstrap`
- Downstream dependents:
  - Operators who want a global command; no downstream bootstrapped repos are affected (installer is repo-root only).
  - No change to the embedded skill scaffold contents, so `update-local-codex-skill.sh` / alignment checks are unaffected.
- Integration points:
  - Launcher -> `scripts/bootstrap_agent_governance.sh` -> embedded `skills/agent-governance-scaffold/scripts/bootstrap_agent_governance.sh`.
- Current monthly checklist entry: `plans/2026-05.md` 2026-05-21 - bootstrap-cli-launcher.

## Edge Cases / Risks / Assumptions
- Edge cases:
  - `~/.local/bin` missing -> installer `mkdir -p`s it.
  - bin dir not on PATH -> installer prints a warning with the export line.
  - Repo moved/deleted after install -> launcher prints a clear "cannot find / re-run installer" error and exits 1.
  - Name collision -> verified no existing `bootstrap` on PATH before installing.
  - Bare `bootstrap` in a populated dir -> intended behavior; preserves repo-owned docs and existing monthly plans (confirmed `existing.txt` untouched in temp-dir test).
- Risks:
  - Absolute path is baked into the launcher; moving the clone requires re-running the installer (documented in the launcher header and error message). Same trade-off as `aip`.
- Assumptions:
  - User keeps the clone at `~/Projects/Bootstrapper`; installer adapts automatically if run from a different clone path.

## Verification
- Commands run:
  - `./scripts/install-bootstrap-command.sh`
  - `command -v bootstrap`
  - `bootstrap --help`
  - temp dir: `bootstrap` (scaffold), `find` tree inspection, `bootstrap --check-updates`
  - `./scripts/verify-plans-workflow.sh`
  - `./scripts/sync-agent-rules.sh --check`
- Results:
  - Launcher installed at `~/.local/bin/bootstrap`, resolves on PATH, points at the repo-root canonical script.
  - Bare `bootstrap` scaffolded a fresh temp dir with the full governance tree and preserved a pre-existing `existing.txt`; sync + plans verifiers inside the scaffold exited 0.
  - `bootstrap --check-updates` reported "Scaffold is up to date".

## Outcome
- Status: implemented-verified
- Follow-up items: optional — fold the `bootstrap` install into a future top-level setup script if more global commands are added.
- Monthly plan updated: yes
- `plans/INDEX.md` updated: yes
