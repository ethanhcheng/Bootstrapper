# 2026-05-29 - bootstrap-init-update-flags

## Request Summary
- User wants a CLI command (`bootstrapper`) for the bootstrapper skill with `--update` (update the bootstrapper in the working directory against the updated repo) and `--init` (initialize a new directory with the bootstrapper).
- Resolution after surfacing prior-work conflict to the user:
  - Command name: keep the existing `bootstrap` launcher (do NOT rename to `bootstrapper`). The `bootstrap` global command from `plans/2026-05-21-bootstrap-cli-launcher.md` is already installed and working.
  - `--update`: already existed in the canonical script (`MODE=update`). No code change needed; documented it on the launcher/README/SKILL.
  - `--init`: add as an explicit synonym for the existing install mode (the bare invocation). Bare call still scaffolds.

## Conflict Surfaced (per CLAUDE.md plans-as-reference rule)
- Prior implementation (`2026-05-21-bootstrap-cli-launcher`) chose the name `bootstrap` and used the bare invocation for init; there was no `--init` flag.
- User asked for name `bootstrapper` and explicit `--init`. Surfaced via AskUserQuestion. User chose: keep `bootstrap`, add `--init` as a synonym.

## Full Implementation Plan
- Edit the canonical embedded script `skills/agent-governance-scaffold/scripts/bootstrap_agent_governance.sh`:
  - Add `--init` line to `usage()`.
  - Add an `--init)` case arm that sets `MODE="install"` (falls through the existing `install|update)` dispatch branch).
- Leave the repo-root wrapper unchanged (thin `exec "$@"` passthrough).
- Leave the installed `~/.local/bin/bootstrap` launcher behavior unchanged — it `exec`s `"$@"`, so `--init` works immediately with no reinstall. Only the generated header comment text was refreshed in the installer source for doc accuracy.
- Docs: README "Global bootstrap Command" block, BOOTSTRAPPER_SPEC commands block, SKILL.md, and `scripts/install-bootstrap-command.sh` launcher header.

## Execution Trace
- Affected files:
  - `skills/agent-governance-scaffold/scripts/bootstrap_agent_governance.sh` (code: `--init` synonym)
  - `scripts/install-bootstrap-command.sh` (generated launcher header text)
  - `README.md`, `BOOTSTRAPPER_SPEC.md`, `skills/agent-governance-scaffold/SKILL.md` (docs)
  - `plans/2026-05.md`, `plans/INDEX.md`, this doc (plans trail)
- Call chain: `bootstrap` launcher -> `scripts/bootstrap_agent_governance.sh` (repo-root wrapper) -> embedded canonical script (arg parser + MODE dispatch).
- Downstream dependents: none. Only the canonical script's arg parser gained a synonym; no downstream bootstrapped repo behavior changes.
- Integration hop note: the alignment checker diffs the installed local Codex skill against the embedded skill. Editing the embedded script makes the installed Codex skill drift until `scripts/update-local-codex-skill.sh` is run. Expected, not a regression.

## Edge Cases / Risks / Assumptions
- `--init` with no path -> TARGET_DIR defaults to `$PWD` (existing behavior). Verified.
- `--init /path` -> scaffolds that path; nonexistent path errors via existing guard. Verified existing path created.
- Bare invocation (no flag) -> still install mode. Verified unchanged.
- `--init` combined with `--force-spec` -> install mode honors FORCE_SPEC as before (no new conflict; the only guarded combo is check+force-spec).
- Risk: installed Codex skill drift until explicit refresh (documented above).
- Assumption: user keeps the `bootstrap` name; `bootstrapper` was not created.

## Verification
- Commands run:
  - `bash -n skills/agent-governance-scaffold/scripts/bootstrap_agent_governance.sh` -> parses OK.
  - `./scripts/bootstrap_agent_governance.sh --help` -> shows `--init` line.
  - `./scripts/bootstrap_agent_governance.sh --init <tmp>` -> full scaffold created (CLAUDE.md present); `--check-updates <tmp>` -> "Scaffold is up to date".
  - bare `./scripts/bootstrap_agent_governance.sh <tmp2>` -> still installs.
  - live `bootstrap --init` in a temp dir -> scaffolded without reinstall (launcher passthrough confirmed).
  - `./scripts/verify-plans-workflow.sh` and `./scripts/sync-agent-rules.sh --check` -> see results below.

## Outcome
- Status: implemented-verified
- Follow-up items: run `./scripts/update-local-codex-skill.sh` to refresh the installed Codex skill so it byte-matches the embedded skill (writes to `~/.codex`; left to operator).
- Monthly plan updated: yes
- `plans/INDEX.md` updated: yes
