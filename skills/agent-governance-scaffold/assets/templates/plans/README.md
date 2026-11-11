# Plans Directory

`plans/` is the only planning workspace and the durable record of what changed and why. The development-workflow rule file has the full rules; this is the short version.

- One file per change: `plans/YYYY-MM-DD-short-name.md`, created with `scripts/create-implementation-doc.sh YYYY-MM-DD short-name`.
- Each doc describes itself in its header: `Status`, `Category`, and a one-line plain-language `Summary`. Nothing else needs editing, so parallel branches never touch the same file.
- Status values: `planned`, `in-progress`, `partial`, `implemented-verified`, `not-implemented`.
- To find prior work, search filenames and contents: `ls plans | grep -i <keyword>` or `grep -l -i <keyword> plans/*.md`.
- Docs for finished work are history. Append corrections; never rewrite or delete.
- `plans/IDEAS.md` is the inbox for ideas and reference material that are not active work yet.
- `plans/INDEX.md`, `plans/YYYY-MM.md`, and `plans/legacy-plans.md`, where they exist, are frozen history from earlier workflows. Do not add to them.
- `scripts/verify-plans-workflow.sh` checks that every doc written under this workflow has a valid header.
