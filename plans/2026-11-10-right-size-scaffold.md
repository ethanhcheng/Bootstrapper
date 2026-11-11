# 2026-11-10 - right-size-scaffold

- Date: 2026-11-10
- Status: implemented-verified
- Category: feature
- Summary: The shared agent rules are shorter and work for any language, small fixes no longer need the full feature process, and each change is recorded in one file so parallel branches stop conflicting.

## Request
- Measured on a downstream repo (InvoiceTracker-IS): the scaffold made work there far more expensive than in other projects, a PR was opened for every edit, and merging one PR caused conflicts in the others.
- Port every fix that is generic into the scaffold so new projects start with it, provided it actually helps the agent.
- No agent auto-merge of PRs. No agent signatures on commits and PRs.

## What Changed And Why

Evidence from the downstream repo, last 100 commits on its default branch: every one edited `plans/INDEX.md` and the monthly file, so any two open branches conflicted by construction. Its always-loaded rules were 25.3 KB, of which 54 of 84 non-blank `CLAUDE.md` lines were duplicated in `code-review.md`, and the standards file was Python-specific in a repo with no Python.

- **Plans: one self-describing doc per change.** A plan doc now carries `Status`, `Category`, and a one-line `Summary` in its header. Nothing appends to a shared index or monthly file any more, which removes the conflict source. Existing `plans/INDEX.md` and `plans/YYYY-MM.md` files are frozen history: never created, edited, or deleted by the scaffold.
- **Work tiers instead of one process for everything.** Ops/data work commits to the default branch with no PR; a small change gets one branch and one PR; feature work gets a draft PR and the full review. One PR per piece of work, not per edit. Merging stays with the human.
- **Full review scoped to feature work.** The eight-dimension review ran on any multi-file change and "every few sessions". It now runs for feature-tier work and on request; small changes get the same questions applied to the lines they touch.
- **Stack-neutral rules.** `python-standards` is replaced by `coding-standards`, and the review dimensions no longer name Python constructs. Language and project specifics go in the target's `BOOTSTRAPPER_SPEC.md`, whose template gained sections for the stack and for what each tier means in that project.
- **No duplication.** `CLAUDE.md` and `AGENTS.md` are now one short, identical entry file; the pre-change protocol, quality lists, and style addendum that were repeated across files exist once. Always-loaded text for Claude drops from 25.3 KB to 14.4 KB.
- **One rule source.** Rules are edited only in `.claude/rules/`; `sync-agent-rules.sh` generates the Cursor, Codex, and consolidated copies. Previously the Cursor and Claude copies were both hand-edited and the script failed if they diverged, and Codex received every rule twice (`name.md` and `claude-name.md`).
- **Plan docs are records, not transcripts.** "Copy the full agent plan into the doc" is replaced by a short template. On the downstream repo, plan writing was 16% of everything the agent wrote.
- **New rules:** no agent attribution anywhere; clean up merged worktrees and branches; one task per session, with plan docs and git as the memory; scope searches away from dependency, build, and worktree directories.
- **Verification by script rather than by prose.** `verify-plans-workflow.sh` checks the header of every doc dated on or after `plan_doc_headers_since`, a date the bootstrap records in the manifest once and then preserves, so older docs are never failed retroactively.

Rejected: letting the agent merge its own PRs once CI is green (the owner declined); a `merge=union` git attribute for the shared plans files (works for local rebases, not verified for the GitHub merge button, and leaves the shared files in place); mirroring every file found in `.claude/rules/` and deleting unmatched copies (would delete a project's own Cursor rules).

## Files And Integration Points
- Rule source and entry files: `CLAUDE.md`, `AGENTS.md`, `.claude/rules/*.md`, `.codex/PROJECT_RULES.md`. Generated: `.cursor/rules/`, `.codex/rules/`, `rulesets/`.
- Scripts shipped to targets: `scripts/sync-agent-rules.sh`, `scripts/create-implementation-doc.sh`, `scripts/verify-plans-workflow.sh`.
- `skills/agent-governance-scaffold/scripts/bootstrap_agent_governance.sh`: `SCAFFOLD_VERSION` 2026-11-10.1; no longer creates or repairs `plans/INDEX.md` or a monthly file; writes `plan_doc_headers_since`; `.cursor/rules` is generated rather than copied.
- `skills/agent-governance-scaffold/scripts/sync-templates-from-self.sh`: resolved the skill directory as the repo root, so every source was reported missing and the script could never run. Fixed. `README.md` and `BOOTSTRAPPER_SPEC.md` were removed from its list: had the script worked, it would have overwritten the generic templates with Bootstrapper's own project files.
- `scripts/check-bootstrapper-alignment.sh`: no longer compares `.cursor/rules` against templates (the sync check covers it).
- Templates: `plans/INDEX.md` and `.cursor/rules/` removed; `README.md`, `BOOTSTRAPPER_SPEC.md`, `plans/IDEAS.md`, `plans/legacy-plans.md` updated.
- Downstream: any repo on an older version reports "behind" until `bootstrap --update` is run.

## Edge Cases, Risks, Assumptions
- The scaffold never deletes a file in a target. Files a new version retires (`python-standards` and the duplicate `claude-*` Codex copies) are listed by `sync-agent-rules.sh` on every run for a person to delete. Until deleted, `.claude/rules/python-standards.md` keeps loading in that repo.
- A project that had customized a managed rule file loses the customization on update. That was already true; managed files have always been overwritten.
- A target with no manifest, or a manifest without `plan_doc_headers_since`, gets no header checks until the bootstrap is run once.
- Docs written before the cutover with a non-standard status are ignored by the verifier by design.
- A real Python project loses the Python-specific bullets. The generic standards cover the same ground; anything truly specific belongs in that project's spec.
- Ops/data work committed straight to the default branch skips CI. The tier is limited to changes that touch no application code, tests, CI, dependencies, or config for that reason.

## Verification
- Empty folder: `bootstrap_agent_governance.sh /tmp/bootstrapper-verify-empty` installed 32 files, `--check-updates` reported up to date, manifest recorded `plan_doc_headers_since: 2026-11-10`. A doc from `create-implementation-doc.sh` failed verification with the placeholder summary, passed once the summary was written, and failed again with `Status: done`.
- Old scaffold: `git archive origin/main` into a temp folder, then `--update`. `plans/INDEX.md`, all monthly files, and existing docs were byte-identical before and after (sha256); no `2026-11.md` was created; all eight retired files were listed; `sync-agent-rules.sh --check` passed. A manifest edited to `plan_doc_headers_since: 2026-10-01` kept that value across another `--update`.
- This repo: `bootstrap_agent_governance.sh --update .`, `sync-templates-from-self.sh --check`, `sync-agent-rules.sh --check`, `verify-plans-workflow.sh`, and `check-bootstrapper-alignment.sh` (results in the PR).
- Baseline on `main` before this change, for comparison: `sync-templates-from-self.sh --check` failed with every source missing, and `verify-plans-workflow.sh` failed for want of a `plans/2026-11.md`.
- Applied to InvoiceTracker-IS with `--update`; see that repo's PR.
- Not verified: macOS and Windows; Cursor and Codex actually loading the regenerated copies.

## Follow-Ups
- Run `scripts/update-local-codex-skill.sh` after merge to refresh the installed Codex and Claude copies of the skill.
- Run `bootstrap --update` in each other scaffolded repo, fill in its `BOOTSTRAPPER_SPEC.md`, and delete the retired files it lists.
- The retired-file notice prints twice during a bootstrap (once per sync pass).
