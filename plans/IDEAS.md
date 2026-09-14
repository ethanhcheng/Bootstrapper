# Ideas Inbox

- Use this file for future ideas, pasted research notes, and implementation seeds that are not active coding work yet.
- Keep it append-only. Mark items as `research-needed`, `promoted`, `shelved`, or `superseded` instead of deleting them.
- When an idea becomes active, create a dated implementation doc with `./scripts/create-implementation-doc.sh YYYY-MM-DD feature-name`, update the current monthly file, and keep the seed note linked here.

## Active Ideas
- Add new seed notes here as they appear.

## RETRACTED: "sync-agent-rules.sh chmods the whole tree" (filed 2026-09-14, retracted same day)

This entry claimed `scripts/sync-agent-rules.sh` sets mode 755 on ~67 unrelated
files on every run. **That is false.** The script does not modify file modes.

Disproved by direct test: `chmod 644` on `plans/IDEAS.md`, `README.md` and
`projectbootstrapper.txt`, then running the script, leaves all three at 644 and
produces no git diff at all. The 67 files also include plans, READMEs and
templates that the script never writes -- only `.codex/rules/*` and `rulesets/*`
are written.

What actually happened: the working tree already carried those mode changes
before the rule work began. `git status` was not checked first, the drift
surfaced in the same `git status` as the sync run, and it was attributed to the
script on no evidence.

The original cause is unknown and predates 2026-09-14. If the drift reappears,
suspect whatever last wrote the tree wholesale -- `apply-bootstrapper-to-target.sh`
or `update-local-codex-skill.sh` are the candidates worth instrumenting -- and
check `git status` BEFORE running anything, so the baseline is known.

Lesson worth keeping: check `git status` before starting work in a repo, so
pre-existing drift is never mistaken for damage done by the current change.
