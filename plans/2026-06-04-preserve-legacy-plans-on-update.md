# 2026-06-04 - preserve-legacy-plans-on-update

## Request Summary
- Fix a data-loss bug in the scaffold installer: `plans/legacy-plans.md` was
  copied with `copy_managed_file` (unconditional `install -m 0644`), so every
  `--update` / `--auto-update` / `install` run overwrote a target repo's real
  accumulated planning history with the 306B placeholder.
- Discovered while refactoring the Jiggamumps repo to the scaffold model, where
  the installer clobbered 25,428B of `legacy-plans.md` history (restored from git).

## Change
- `skills/agent-governance-scaffold/scripts/bootstrap_agent_governance.sh`:
  `install_scaffold()` now uses `copy_if_missing` for `plans/legacy-plans.md`,
  matching how `README.md`, `BOOTSTRAPPER_SPEC.md`, and `plans/IDEAS.md`
  (project-owned, content-accumulating files) are already handled.

## Execution Trace
- Affected file: the embedded canonical bootstrap script only.
- `plans/README.md` and `plans/IMPLEMENTATION_TEMPLATE.md` remain
  `copy_managed_file` (structural scaffold docs, intended to be refreshed).
- Downstream: installed skill copies (`~/.codex`, `~/.claude`) and any vendored
  copies get the fix on the next skill deploy (`update-local-codex-skill.sh`).

## Edge Cases / Risks / Assumptions
- Fresh scaffold (no `legacy-plans.md`): placeholder still installed — verified.
- Existing repo with real history: preserved — verified.
- Assumption: `legacy-plans.md` is always project-owned accumulated history, so
  it should never be overwritten by the scaffold once present.

## Verification
- `bash -n` on the script: pass.
- TEST 1 (existing history): ran `--update` against a temp repo containing a
  sentinel `legacy-plans.md`; sentinel preserved. PASS.
- TEST 2 (fresh): ran `--update` against an empty temp repo; "Legacy Planning
  Archive" placeholder installed. PASS.

## Outcome
- Status: implemented-verified.
- Follow-up items: deploy to installed skill copies when convenient; the
  Jiggamumps vendored copy will refresh on its next scaffold update.
- Monthly plan updated: yes (`plans/2026-06.md`).
- `plans/INDEX.md` updated: yes.
