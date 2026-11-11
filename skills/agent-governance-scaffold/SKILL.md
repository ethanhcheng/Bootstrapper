---
name: agent-governance-scaffold
description: Use when the user wants to install, restore, or update the portable agent-governance scaffold for Codex, Cursor, and Claude; recover the missing bootstrap_agent_governance.sh workflow; or apply mirrored repo rules, plans scaffolding, and Codex project rules to a repository.
model: haiku
---

# Agent Governance Scaffold

Use this skill when a repo should carry the same governance files across Codex, Cursor, and Claude, or when the local Codex account is missing the scaffold skill itself.

## Quick Start

- Run `scripts/bootstrap_agent_governance.sh` (or `--init`) to scaffold the current directory.
- Run `scripts/bootstrap_agent_governance.sh /path/to/repo` to target another repo.
- Run `scripts/bootstrap_agent_governance.sh --update /path/to/repo` to update an already-scaffolded directory against this clone.
- Run `scripts/bootstrap_agent_governance.sh /path/to/folder` for an existing non-empty folder; a git repo is not required.
- Run `scripts/bootstrap_agent_governance.sh --force-spec /path/to/repo` when you intentionally want to replace an existing `BOOTSTRAPPER_SPEC.md`.
- Run `scripts/bootstrap_agent_governance.sh --check-updates /path/to/repo` to compare the repo manifest with the current skill version.
- Run `scripts/bootstrap_agent_governance.sh --auto-update /path/to/repo` to refresh only when the repo is missing or behind the current scaffold version.

If the operator installed the global `bootstrap` command (via the Bootstrapper repo's `scripts/install-bootstrap-command.sh`), `bootstrap` in any directory is equivalent to running this script against that directory.

## What The Script Installs

- Governance entry points:
  - `AGENTS.md`
  - `CLAUDE.md`
  - `.codex/PROJECT_RULES.md`
- Rule source (the only place rules are edited):
  - `.claude/rules/*.md`
- Generated copies:
  - `.cursor/rules/*.mdc`
  - `.codex/rules/*.md`
  - `rulesets/*.md`
- Planning workflow:
  - `plans/README.md`
  - `plans/IMPLEMENTATION_TEMPLATE.md`
  - `plans/legacy-plans.md` and `plans/IDEAS.md` if missing
- Helper scripts:
  - `scripts/sync-agent-rules.sh`
  - `scripts/create-implementation-doc.sh`
  - `scripts/verify-plans-workflow.sh`
- Repo docs created only when missing:
  - `README.md`
  - `BOOTSTRAPPER_SPEC.md`
  - `projectbootstrapper.txt`

## Safety Model

- Governance-managed rule files and helper scripts are refreshed from the skill templates.
- Plan docs are never touched. Each one describes itself in its header (`Status`, `Category`, `Summary`), so there is no index or monthly file to maintain; an existing `plans/INDEX.md` or `plans/YYYY-MM.md` is left as frozen history.
- Nothing is ever deleted. Files retired by a newer scaffold version are listed at the end of the run for a person to remove.
- `README.md`, `BOOTSTRAPPER_SPEC.md`, and `projectbootstrapper.txt` are treated as repo-owned content after creation, so they are only created when missing.
- The script writes `.agent-governance-manifest.json` with the scaffold version and source path so later checks can detect drift, and `plan_doc_headers_since`, the date from which `scripts/verify-plans-workflow.sh` requires plan-doc headers.

## After Bootstrap

When working inside a bootstrapped repo, read:

1. `AGENTS.md`
2. `.codex/PROJECT_RULES.md`
3. `BOOTSTRAPPER_SPEC.md`
4. `rulesets/CONSOLIDATED_RULESET.md`

Fill in `BOOTSTRAPPER_SPEC.md` first: the rules defer to it for the stack, the commands, and what each work tier means in that project.

If rule files change, edit `.claude/rules/` and re-run `scripts/sync-agent-rules.sh`.
