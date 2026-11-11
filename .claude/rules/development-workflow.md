# Development Workflow

## Work Tiers

Choose the lightest tier that fits. When unsure, use the heavier one. `BOOTSTRAPPER_SPEC.md` may name this project's examples of each tier.

| Tier | Covers | Branch and PR | Depth |
|---|---|---|---|
| Ops/data | One-off operational scripts and data entry. Touches no application code, tests, CI, dependencies, or config. | Commit to the default branch. No PR. | Dry run first, then read back the result. |
| Small change | A contained fix or tweak. No API contract, schema, auth, or dependency change. | One branch, one PR, opened when the work is ready. | Gates A and B, proportionate to the change. |
| Feature | A new feature; an API contract, schema, auth or permission, dependency, or shared-utility change; anything that spans sessions. | A branch, plus a draft PR at the first commit. | Gates A and B in full, plus the full review in `code-review.md`. |

## Version Control

1. Start from the current default branch: fetch, then branch from its tip. Branch from another unmerged branch only when the work depends on it, and say so in the PR.
2. One PR per piece of work, not per edit. Follow-up edits to work whose PR is still open go on that branch. Related small changes from the same session share one branch and one PR.
3. One commit per logical step, together with its tests. Each commit leaves the suite in the state that step expects: green, or deliberately red only for a documented test-first step that the next commit turns green.
4. Commit messages say what changed and why, including rejected alternatives and any defect a test was shown to catch.
5. Push when a step is complete, so an interrupted session loses at most one step.
6. Never force-push a branch under review unless the human asks. A rejected push means the remote moved: investigate, do not overwrite.
7. When an open PR conflicts with the default branch, bring the default branch in and resolve both sides. Never discard either side to make the conflict go away.
8. Never merge a pull request. Opening it, updating it, and reporting that it is ready is the agent's job; merging is the human's.
9. No agent attribution anywhere: no `Co-Authored-By` trailers, no "generated with" footers, no agent names in commits, PR titles or bodies, branch names, code comments, or docs.
10. Clean up after yourself: remove the worktrees and local branches you created once their work has merged.

## Gate A: Before Changing Code

1. Trace the execution paths the change touches.
2. List the files to change and everything that depends on them.
3. For a change that crosses layers, list each hop: route, storage or model output, API wrapper, consumer, and where the result is displayed.
4. List the edge cases that apply (see `code-review.md`).

## Gate B: Before Calling It Done

1. Re-trace the changed paths end to end. Confirm imports and signatures.
2. Where an old code path was replaced, confirm existing data and legacy behavior still work.
3. Run the tests (see Verification).
4. For UI changes, exercise the affected pages in a running app. If that was not possible, say so explicitly.
5. Feature tier: run the full review in `code-review.md`.
6. Record what was verified, and how, in the plan doc.

## Verification

- While iterating, run the tests that cover the change.
- Run the full suite once before pushing, and again only if code changed afterwards. CI is the final gate.
- Report results from actual output. Never claim a pass that was not observed.

## Cross-Client Parity

- A backend or contract change is incomplete until every consumer (GUI, API client, companion app) is updated, or the omission is recorded in the plan doc.
- When one shared UI or runtime surface changes, review its counterpart in the same task unless the change is explicitly scoped to one surface.

## Abstraction

- Create seams where replacement is likely: providers, transport, storage, runtime controllers, platform adapters.
- Prefer cohesive classes or focused modules for stateful, lifecycle-heavy logic, and composition over inheritance.
- Keep platform shells thin; move shared behavior into neutral shared modules.
- Every new abstraction must earn its place through replaceability, testability, or platform separation. No speculative wrappers.
- When a new seam replaces old code paths, move every caller, or record the staged migration in the plan doc.

## Plans

`plans/` is the only planning workspace and the durable record of what changed and why.

1. Every PR and every ops/data task gets exactly one new file, `plans/YYYY-MM-DD-short-name.md`, created from `plans/IMPLEMENTATION_TEMPLATE.md` (`scripts/create-implementation-doc.sh YYYY-MM-DD short-name`).
2. The doc describes itself. Its header carries `Status`, `Category`, and a one-line plain-language `Summary`. There is no index or monthly file to update, so two branches never edit the same plans file.
3. Create it with `Status: in-progress` in the first commit. Before asking for review, set the final status (`implemented-verified`, `partial`, or `not-implemented`) and fill in Verification.
4. Keep it a record, not a transcript: the request, what changed and why, files and integration points, edge cases and risks, verification commands with their results, and follow-ups. Do not paste the chat plan or restate the diff.
5. Later edits to the same work update its doc. Docs for finished work are history: append corrections, never rewrite or delete.
6. A change without its plan doc is incomplete. Run `scripts/verify-plans-workflow.sh` before pushing.
7. `plans/INDEX.md` and `plans/YYYY-MM.md`, where they exist, are frozen history from the previous workflow. Do not add to them.
8. Ideas and reference material that are not yet work go in `plans/IDEAS.md`.

## Context Discipline

- One task per session where possible. Plan docs and git history carry context between sessions, so a fresh session loses nothing. When an unrelated task starts in a long-running session, say once that a fresh session would be cheaper.
- Read files in the ranges needed, not wholesale. Search by keyword before opening.
