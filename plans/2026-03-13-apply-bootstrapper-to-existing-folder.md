# 2026-03-13 - apply-bootstrapper-to-existing-folder

## Request Summary
- Support cloning this Bootstrapper repo on another machine and applying its governance into an existing non-empty folder.
- Do not require the target folder to already be a git repository.
- Make the installed agent instructions portable so they still make sense after being copied into another folder.

## Full Agent Implementation Plan
- Create a dated implementation record for applying the bootstrapper to existing folders.
- Add a portable installer script that applies governance into a target directory without requiring git.
- Adjust docs and portable rule inputs so cloned Bootstrapper repos can be used on other machines.
- Run verification against both the source repo and a temporary non-empty target folder.

## Execution Trace
- Affected files:
  - `scripts/apply-bootstrapper-to-target.sh`
  - `templates/TARGET_BOOTSTRAPPER_SPEC.md`
  - `README.md`
  - `BOOTSTRAPPER_SPEC.md`
  - `AGENTS.md`
  - `CLAUDE.md`
  - `.codex/PROJECT_RULES.md`
  - `.cursor/rules/development-workflow.mdc`
  - `.claude/rules/development-workflow.md`
  - `.cursor/rules/tech-stack.mdc`
  - `.claude/rules/tech-stack.md`
  - `.codex/rules/development-workflow.md`
  - `.codex/rules/claude-development-workflow.md`
  - `.codex/rules/tech-stack.md`
  - `.codex/rules/claude-tech-stack.md`
  - `rulesets/CONSOLIDATED_RULESET.md`
  - `plans/2026-03.md`
  - `plans/INDEX.md`
- Downstream dependents:
  - Existing folders that receive this bootstrapper
  - Codex, Cursor, and Claude sessions opened inside those target folders
  - Future repositories initialized from previously non-git folders
- Integration points:
  - `scripts/apply-bootstrapper-to-target.sh` copies managed files into the target directory
  - The target directory then uses `scripts/sync-agent-rules.sh` and `scripts/verify-plans-workflow.sh` locally
  - The target folder receives a local `.agent-governance-manifest.json` describing the installation source
- Current monthly checklist entry:
  - `2026-03-13 - apply-bootstrapper-to-existing-folder`

## Edge Cases / Risks / Assumptions
- Edge cases:
  - Target folders may already contain arbitrary files, so the installer preserves unrelated files.
  - Target folders may already contain `plans/<current-month>.md`, so the installer now repairs missing required headings instead of only creating the file when absent.
  - Target folders may not be git repos yet, so the installer avoids requiring `.git/`.
  - Target folders may already have a `BOOTSTRAPPER_SPEC.md`, so the installer preserves it unless `--force-spec` is used.
- Risks:
  - Applying the bootstrapper refreshes scaffold-managed agent files and helper scripts in the target folder, which may overwrite prior governance files if they used the same paths.
  - Reapplying newer Bootstrapper repo versions still requires running the installer again in each target folder.
- Assumptions:
  - The intended behavior is to standardize governance files in the target folder, even when the folder already has other non-governance content.
  - Preserving the target folder's existing README is preferable to replacing it with Bootstrapper repo documentation.

## Verification
- Commands run:
  - `/Users/ethan/Bootstrapper/scripts/sync-agent-rules.sh`
  - `/Users/ethan/Bootstrapper/scripts/sync-agent-rules.sh --check`
  - `/Users/ethan/Bootstrapper/scripts/verify-plans-workflow.sh`
  - `mktemp -d /tmp/bootstrapper-target.XXXXXX` followed by `/Users/ethan/Bootstrapper/scripts/apply-bootstrapper-to-target.sh <temp-dir>`
  - `mktemp -d /tmp/bootstrapper-target-existing.XXXXXX` with an existing `plans/<current-month>.md`, followed by `/Users/ethan/Bootstrapper/scripts/apply-bootstrapper-to-target.sh <temp-dir>`
- Results:
  - Source repo rule sync check passed.
  - Source repo plans workflow verification passed.
  - Applying into a non-empty non-git folder succeeded and preserved the pre-existing file.
  - Applying into a folder with a pre-existing monthly plan file succeeded and backfilled the required headings.

## Outcome
- Status:
  - `implemented-verified`
- Follow-up items:
  - Commit and push the Bootstrapper repo so the new installer is available on other machines.
  - Fill in target-folder `BOOTSTRAPPER_SPEC.md` files after applying the bootstrapper so agents have project-specific instructions.
- Monthly plan updated:
  - Yes
- `plans/INDEX.md` updated:
  - Yes
