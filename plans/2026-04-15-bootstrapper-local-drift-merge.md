# 2026-04-15 - bootstrapper-local-drift-merge

## Request Summary
- Compare the freshly pulled Bootstrapper repo clone against the machine-local Bootstrapper copy and merge any omitted local workflow updates into the repo source of truth.
- Make sure the repo plans history includes the earlier local-machine scaffold work that was missing from GitHub.
- Verify that the CLI workflow can both detect local Bootstrapper drift and refresh the installed Codex `agent-governance-scaffold` skill from the repo copy.

## Full Agent Implementation Plan
- Read the bootstrapper plans trail and compare the repo clone against both `/Users/ethan/Bootstrapper` and `~/.codex/skills/agent-governance-scaffold`.
- Isolate the behavior that existed only in the local Bootstrapper copy and decide what still belongs in the newer embedded-skill architecture.
- Merge the missing behavior into the repo clone without overwriting the user's separate local `~/Bootstrapper` copy.
- Verify the repaired bootstrap flow on incomplete existing folders, verify the compatibility wrapper, refresh the installed Codex skill from the repo clone, and rerun the alignment checker against the local Bootstrapper copy.

## Execution Trace
- Affected files:
  - `skills/agent-governance-scaffold/scripts/bootstrap_agent_governance.sh`
  - `skills/agent-governance-scaffold/SKILL.md`
  - `scripts/apply-bootstrapper-to-target.sh`
  - `README.md`
  - `BOOTSTRAPPER_SPEC.md`
  - `plans/2026-03.md`
  - `plans/2026-03-13-apply-bootstrapper-to-existing-folder.md`
  - `plans/2026-04.md`
  - `plans/2026-04-15-bootstrapper-local-drift-merge.md`
  - `plans/INDEX.md`
- Downstream dependents:
  - The installed local Codex skill at `~/.codex/skills/agent-governance-scaffold`
  - The separate local Bootstrapper copy at `/Users/ethan/Bootstrapper`
  - Downstream repos or folders bootstrapped from this repo clone
- Integration points:
  - `scripts/bootstrap_agent_governance.sh` delegates to the embedded skill bootstrap script
  - `scripts/apply-bootstrapper-to-target.sh` now preserves the older existing-folder entrypoint name
  - `scripts/check-bootstrapper-alignment.sh --target <path>` detects drift in another local Bootstrapper copy
  - `scripts/update-local-codex-skill.sh` syncs the installed Codex skill from this repo clone
- Current monthly checklist entry:
  - `2026-04-15 - bootstrapper-local-drift-merge`

## Edge Cases / Risks / Assumptions
- Edge cases:
  - Existing target folders may already contain `plans/<current-month>.md` but still be missing the required scaffold headings.
  - The separate local `~/Bootstrapper` copy contains historical March work plus uncommitted changes, so it should be inspected and compared but not overwritten automatically.
  - The installed Codex skill can lag behind the repo clone even when the repo itself is current.
- Risks:
  - `~/Bootstrapper` is still behind the repo clone until it is updated explicitly.
  - The compatibility wrapper restores the older command name, so future changes should keep both entrypoints aligned.
- Assumptions:
  - The embedded repo skill remains the canonical source of truth, and the older March target-spec template does not need to return because the embedded generic `BOOTSTRAPPER_SPEC.md` template now covers that role.
  - The right fix is to merge missing behavior into GitHub and refresh the installed skill, not to overwrite the user's separate local Bootstrapper copy during this turn.

## Verification
- Commands run:
  - `bash -n skills/agent-governance-scaffold/scripts/bootstrap_agent_governance.sh`
  - `bash -n scripts/bootstrap_agent_governance.sh`
  - `bash -n scripts/apply-bootstrapper-to-target.sh`
  - `bash -n scripts/check-bootstrapper-alignment.sh`
  - `bash -n scripts/update-local-codex-skill.sh`
  - `tmpdir=$(mktemp -d /tmp/bootstrapper-merge-test.XXXXXX)` with a pre-existing incomplete `plans/$(date +%Y-%m).md`, followed by `./scripts/bootstrap_agent_governance.sh "$tmpdir"`
  - `tmpdir=$(mktemp -d /tmp/bootstrapper-apply-test.XXXXXX)` with a pre-existing incomplete `plans/$(date +%Y-%m).md`, followed by `./scripts/apply-bootstrapper-to-target.sh "$tmpdir"`
  - `tmpcodex=$(mktemp -d /tmp/codex-home-test.XXXXXX)` followed by `CODEX_HOME="$tmpcodex" ./scripts/update-local-codex-skill.sh`
  - `./scripts/update-local-codex-skill.sh`
  - `./scripts/check-bootstrapper-alignment.sh --target /Users/ethan/Bootstrapper`
- Results:
  - Syntax checks passed for the updated embedded bootstrap script, wrappers, alignment checker, and local-skill updater.
  - The repo bootstrap command now succeeds on a non-empty folder even when the current monthly plan file already exists and only contains its title.
  - The compatibility `apply-bootstrapper-to-target.sh` wrapper succeeds on the same incomplete-plan edge case.
  - The local-skill updater works in a temp `CODEX_HOME` and now also refreshed the real installed Codex skill under `~/.codex`.
  - The alignment checker now reports `OK: local-codex-skill` and correctly flags `/Users/ethan/Bootstrapper` as the remaining behind copy because it still lacks the April scaffold version and `plans/2026-04.md`.

## Outcome
- Status:
  - `implemented-verified`
- Follow-up items:
  - Decide when to update `/Users/ethan/Bootstrapper` from this repo clone, since it still contains older March-era governance plus local changes.
  - Restart Codex if you want future sessions to load the newly refreshed installed skill immediately.
- Monthly plan updated:
  - Yes
- `plans/INDEX.md` updated:
  - Yes
