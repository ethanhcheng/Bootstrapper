# Codex Project Rules (Mirrored)

Canonical sources:
- Shared policy: `rulesets/CONSOLIDATED_RULESET.md`
- Agent bindings: `rulesets/AGENT_BINDINGS.md`
- Plans: `plans/`
- Project spec: `BOOTSTRAPPER_SPEC.md`
- Repo guide: `README.md`

## Project-Specific Inputs
- Read `BOOTSTRAPPER_SPEC.md` before changing project behavior or repo automation.
- Use `README.md` for repo layout and workflow notes.
- Treat `projectbootstrapper.txt` as a legacy note only unless its contents are promoted into `BOOTSTRAPPER_SPEC.md`.

## Effective Policy
- `.codex/rules/*` mirrors the active `.cursor/rules/*` and `.claude/rules/*` files.
- `rulesets/` consolidates the shared governance rules and binding layout.
- Stricter rule wins.
- Enforce pre-change trace and post-change continuity review.
- Keep planning in `plans/` only, with monthly files and optional implementation docs.
- For significant feature work, require both a monthly checklist entry and a dated implementation document with the full agent plan/output copied into it.
- Update planning artifacts before implementation, during meaningful scope changes, and immediately after verification.
- Treat missing `plans/` updates for changed functionality as an incomplete task.
- Significant code changes must leave an append-only audit trail in `plans/`.
- The response style addendum in the shared code review rule is mandatory for Codex responses.

## Plans Workflow
- `plans/YYYY-MM.md` is the general checklist for features implemented during that period.
- `plans/YYYY-MM-DD-feature-name.md` stores dated implementation records.
- `plans/INDEX.md` links monthly files and implementation documents.
- `plans/legacy-plans.md` is archive-only.

## Prior Implementation Context
- At the start of any new task, read `plans/INDEX.md` to see what features have been implemented before.
- Before implementing something similar to prior work, read the matching `plans/YYYY-MM-DD-feature-name.md` to match conventions, surface lessons learned, and avoid duplication.
- Read individual dated docs on demand only. Treat the INDEX as the directory and bodies as on-demand reads.
- If a prior implementation conflicts with the current request, surface the conflict to the user instead of silently overriding it.
