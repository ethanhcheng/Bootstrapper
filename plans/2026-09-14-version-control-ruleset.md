# Version Control Ruleset

**Date:** 2026-09-14
**Status:** implemented-verified

## Motivation

Downstream agent work had no rule governing branches, commit granularity, or when
a pull request should exist. In practice that produced feature branches where a
whole multi-task plan landed before any PR was opened, so nothing was reviewable
mid-flight and CI only ran at the end. It also produced commits that bundled
several plan tasks, which destroys the ability to roll back one step without
unpicking unrelated work.

The repo owner asked for two rules specifically:

1. every task gets its own commit, so each step is a rollback point;
2. the pull request opens when the work *starts*, not when it finishes.

## Change

Added a `## Version Control` section to the `development-workflow` rule, placed
before `## Cross-Client Parity`.

Ten numbered rules covering: branch-per-feature, PR-at-start (draft while
incomplete), commit-per-task as the rollback unit, no bundling and no
tree-breaking splits, expected suite state per commit, commit messages that
record the why, push-per-task, no force-push under review, and no self-merge
without explicit delegation.

## Where the edit had to go

`rulesets/CONSOLIDATED_RULESET.md` is **generated** by `scripts/sync-agent-rules.sh`
and must never be hand-edited -- an edit there is silently overwritten on the next
sync. The actual sources are the four rule files, which the sync script asserts
are byte-identical via `cmp -s`:

- `.cursor/rules/development-workflow.mdc`
- `.claude/rules/development-workflow.md`
- `skills/agent-governance-scaffold/assets/templates/.cursor/rules/development-workflow.mdc`
- `skills/agent-governance-scaffold/assets/templates/.claude/rules/development-workflow.md`

The repo-root pair governs this repo; the templates pair is what downstream
projects receive. Both must be updated or the two diverge, and downstream
projects would never see the rule.

## Verification

- `scripts/sync-agent-rules.sh` regenerated the consolidated ruleset and the
  `.codex` mirrors; `scripts/sync-agent-rules.sh --check` reports in sync.
- 7 files changed, all expected: the 4 sources, the generated consolidated
  ruleset, and 2 generated `.codex` mirrors.

## Defect found: sync-agent-rules.sh chmods the entire tree

Running `scripts/sync-agent-rules.sh` changed the file mode of **67 unrelated
files** from `644` to `755` -- every plan, README, and template in the repo --
with zero content change. Left uncommitted, that would have buried a 7-file rule
change in a 74-file diff, and marked documentation executable.

The modes were restored by hand for this commit. The script itself is not fixed
here; that is logged in `plans/IDEAS.md` as follow-up, since fixing it is a
separate change from adding the rule and deserves its own commit under the very
rule being added.

## Downstream propagation

Downstream projects do **not** auto-update. Each holds a copy of the scaffold.
After this lands, each project needs:

```
bootstrap --check-updates   # report drift
bootstrap --auto-update     # take the newer scaffold
```

The installed Codex skill at `~/.codex/skills/agent-governance-scaffold` is
refreshed separately via `scripts/update-local-codex-skill.sh`.
