# Codex Project Rules (Mirrored)

Canonical sources:
- Shared policy: `/rulesets/CONSOLIDATED_RULESET.md`
- Agent bindings: `/rulesets/AGENT_BINDINGS.md`
- Plans: `/plans/`
- Bootstrapper spec: `/BOOTSTRAPPER_SPEC.md`
- Repo guide: `/README.md`

## Project-Specific Inputs
- Read `/BOOTSTRAPPER_SPEC.md` before changing bootstrapper behavior or repo automation.
- Use `/README.md` for clone/setup workflow and GitHub publishing steps.
- Treat `/projectbootstrapper.txt` as a legacy note only unless its contents are promoted into `/BOOTSTRAPPER_SPEC.md`.

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
