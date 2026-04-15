---
name: agent-governance-scaffold
description: Use when the user wants to install, restore, or update the portable agent-governance scaffold for Codex, Cursor, and Claude; recover the missing bootstrap_agent_governance.sh workflow; or apply mirrored repo rules, plans scaffolding, and Codex project rules to a repository.
---

# Agent Governance Scaffold

Use this skill when a repo should carry the same governance files across Codex, Cursor, and Claude, or when the local Codex account is missing the scaffold skill itself.

## Quick Start

- Run `scripts/bootstrap_agent_governance.sh` to scaffold the current directory.
- Run `scripts/bootstrap_agent_governance.sh /path/to/repo` to target another repo.
- Run `scripts/bootstrap_agent_governance.sh --check-updates /path/to/repo` to compare the repo manifest with the current skill version.
- Run `scripts/bootstrap_agent_governance.sh --auto-update /path/to/repo` to refresh only when the repo is missing or behind the current scaffold version.

## What The Script Installs

- Governance entry points:
  - `AGENTS.md`
  - `CLAUDE.md`
  - `.codex/PROJECT_RULES.md`
- Editable rule sources:
  - `.cursor/rules/*.mdc`
  - `.claude/rules/*.md`
- Generated mirrors:
  - `.codex/rules/*.md`
  - `rulesets/*.md`
- Planning workflow:
  - `plans/README.md`
  - `plans/IMPLEMENTATION_TEMPLATE.md`
  - `plans/INDEX.md`
  - `plans/legacy-plans.md`
  - current-month `plans/YYYY-MM.md` if missing
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
- Existing monthly plan files are never overwritten.
- `README.md`, `BOOTSTRAPPER_SPEC.md`, and `projectbootstrapper.txt` are treated as repo-owned content after creation, so they are only created when missing.
- The script writes `.agent-governance-manifest.json` with the installed skill path so later checks can detect drift.

## After Bootstrap

When working inside a bootstrapped repo, read:

1. `AGENTS.md`
2. `.codex/PROJECT_RULES.md`
3. `BOOTSTRAPPER_SPEC.md`
4. `rulesets/CONSOLIDATED_RULESET.md`

If rule files change, re-run `scripts/sync-agent-rules.sh`.
