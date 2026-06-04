# Development Workflow

Source of truth: `rulesets/CONSOLIDATED_RULESET.md` (stricter policy wins).

## Repo-Specific Inputs
1. Read `BOOTSTRAPPER_SPEC.md` before planning or implementing project behavior.
2. Use `README.md` for repo layout and workflow notes.
3. Treat `projectbootstrapper.txt` as a legacy reference only unless it has been promoted into `BOOTSTRAPPER_SPEC.md`.

## Gate A: Pre-Change Trace
1. Trace impacted execution paths.
2. List touched files and dependents.
3. List edge cases.
4. Record checklist in `plans/YYYY-MM.md`.
5. List in-scope backlog items from plans that must be audited.
6. List each affected backend/frontend integration hop: route, storage/model output, API wrapper, page/module consumer, and UI display target.

## Gate B: Post-Change Continuity Review
1. Re-trace end-to-end behavior.
2. When old code paths are replaced, verify continuity for existing data and legacy behavior.
3. Verify signatures and imports.
4. Run feasible checks.
5. Verify runtime backend-to-frontend flow so requested data loads and renders in the intended UI.
6. Run full end-to-end UI regression for affected pages/flows.
7. Evaluate against all Full Code Review Dimensions (see `.claude/rules/code-review.md` / `rulesets/CONSOLIDATED_RULESET.md` § Full Code Review Dimensions): resource efficiency, speed, concurrency, memory leaks, edge cases, error handling, security, contract consistency.
8. Record outcomes in `plans/YYYY-MM.md`.
9. Record per-item backlog audit status: `implemented-verified`, `partial`, or `not-implemented`.

## Cross-Client Parity
1. Backend/contract changes are incomplete until every impacted consumer (GUI, API client, companion app) is updated or the scope exception is explicitly documented in `plans/`.
2. Shared UI/runtime surfaces must remain behaviorally aligned; when one shared surface changes, review and update the counterpart in the same task unless the change is explicitly scoped to one surface or platform.
3. Companion/admin clients may diverge intentionally, but they must still reflect backend contract changes relevant to their scope.
4. Backend feature work is not complete until the relevant frontend surfaces reflect the change or the scoped omission is documented in `plans/`.

## Abstraction Requirements
1. Create explicit abstraction seams where upgrades are likely: providers, transport, storage, runtime controllers, and platform adapters.
2. Prefer cohesive classes or focused modules for stateful workflows and lifecycle-heavy logic.
3. Prefer composition over inheritance; use inheritance only for stable shared contracts with multiple implementations.
4. Keep platform shells thin and move shared behavior into neutral shared packages/modules.
5. Every new abstraction must justify itself by replaceability, testability, or platform separation; speculative wrappers are not allowed.
6. When replacing old code paths with a new abstraction, move all callers to the seam or record the staged migration in `plans/`.

## Planning Requirements
1. Append every new task to the active monthly file in `plans/`.
2. Never overwrite historical entries; only append status/results.
3. Add significant implementation docs as `plans/YYYY-MM-DD-feature-name.md`.
4. Update `plans/INDEX.md` when adding implementation docs.
5. If migrating older planning history, keep it only in `plans/legacy-plans.md`.
6. Update planning artifacts before implementation, during meaningful scope changes, and immediately after verification.
7. Treat missing `plans/` updates for changed functionality as an incomplete task.

## Required Plans Workflow
1. `plans/` is the only planning workspace.
2. Each monthly file `plans/YYYY-MM.md` is the general checklist for features implemented during that period.
3. Each significant feature update must have its own dated implementation document: `plans/YYYY-MM-DD-feature-name.md`.
4. The implementation document must include the full implementation plan copied from the agent output for that feature.
5. The implementation document filename must include the date and a concise description of what was updated.
6. The monthly checklist must reference the dated implementation document for the feature.
7. `plans/INDEX.md` must link both active monthly files and implementation documents.
8. A task is not complete unless both the monthly checklist entry and the dated implementation document exist for significant feature work.
9. Significant code changes must leave an append-only audit trail in `plans/` describing what changed, why it changed, and how it was verified.

## Implementation Document Requirements
1. Record the request summary.
2. Copy the full agent implementation plan/output into the document.
3. Record affected files, dependencies, and integration points.
4. Record edge cases, risks, and assumptions.
5. Record verification commands and results.
6. Record final implementation status and follow-up items.

## Plans As Reference Library
1. At the start of any new task, scan `plans/INDEX.md` to see what features have already been implemented.
2. Before implementing something similar to prior work, read the matching `plans/YYYY-MM-DD-feature-name.md` to:
   - Match prior conventions, patterns, and architectural choices.
   - Surface lessons learned, edge cases, and follow-up items recorded by previous agents.
   - Avoid duplicating work that has already been done.
3. Read individual dated docs on demand only. The INDEX is the directory; bodies are read when relevant. Do not exhaustively load every plan into context.
4. If a prior implementation conflicts with the current request, surface the conflict to the user rather than silently overriding it.
