# Ideas Inbox

- Use this file for future ideas, pasted research notes, and implementation seeds that are not active coding work yet.
- Keep it append-only. Mark items as `research-needed`, `promoted`, `shelved`, or `superseded` instead of deleting them.
- When an idea becomes active, create a dated implementation doc with `./scripts/create-implementation-doc.sh YYYY-MM-DD feature-name`, update the current monthly file, and keep the seed note linked here.

## Active Ideas
- Add new seed notes here as they appear.

## sync-agent-rules.sh chmods the whole tree (found 2026-09-14)

`scripts/sync-agent-rules.sh` sets mode 755 on ~67 unrelated files (plans, READMEs,
templates) on every run, with zero content change. Effects: documentation is marked
executable, and any real rule change arrives buried in a large mode-only diff.

Fix: preserve modes, or write only the files whose content actually changed. Wanted
as its own commit, separate from any rule change.
