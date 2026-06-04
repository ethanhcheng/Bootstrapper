# 2026-05-19 - recursive-self-bootstrap-and-templates-sync

## Request Summary
- Make the agent-governance-scaffold skill dogfood itself: install the same
  governance scaffold (entry points, mirrored rules, plans workflow, helper
  scripts, manifest) inside the skill's own directory so changes to the skill
  are tracked under the workflow the skill ships.
- Add a sync helper that keeps `assets/templates/*` (the source-of-truth the
  bootstrap copies into target repos) byte-aligned with the skill's own
  root governance files, so edits made inside the skill repo cannot drift
  out of sync with what the skill ships.

## Full Agent Implementation Plan
1. Run `scripts/bootstrap_agent_governance.sh` against
   `/home/ethan/.codex/skills/agent-governance-scaffold` itself to install
   the scaffold recursively. The bootstrap is additive against pre-existing
   skill machinery (`SKILL.md`, `agents/`, `assets/`,
   `scripts/bootstrap_agent_governance.sh`).
2. Author `scripts/sync-templates-from-self.sh`:
   - Source-of-truth direction is ROOT → `assets/templates/`.
   - Mirrors AGENTS.md, CLAUDE.md, README.md, BOOTSTRAPPER_SPEC.md,
     .gitignore, .codex/PROJECT_RULES.md, every `.cursor/rules/*.mdc`,
     every `.claude/rules/*.md`, the three plans structural files
     (`README.md`, `IMPLEMENTATION_TEMPLATE.md`, `legacy-plans.md`), and
     the three helper scripts.
   - Excludes:
     - `projectbootstrapper.txt` — bootstrap writes this inline with
       install-time path substitutions; the template copy is decorative.
     - `plans/INDEX.md`, `plans/IDEAS.md`, monthly files, dated
       implementation docs — project-specific content; templates must keep
       their placeholder shape.
     - `.agent-governance-manifest.json` — regenerated per install.
     - `SKILL.md`, `agents/`, `assets/`, `scripts/bootstrap_agent_governance.sh`,
       and the sync script itself — skill-only machinery, never installed
       into target repos.
   - Supports `--check` for drift detection (intended for CI / pre-commit).
3. Mirror the codex skill folder (`~/.codex/skills/agent-governance-scaffold/`)
   to the Claude copy (`~/.claude/skills/agent-governance-scaffold/`) using
   `rsync -a --delete --exclude='.git/'` so both copies are byte-identical.
4. Record this work under the newly-installed `plans/` workflow:
   - This dated implementation document.
   - Monthly checklist entry in `plans/2026-05.md`.
   - Index entry in `plans/INDEX.md`.
5. Verify end-to-end:
   - `scripts/verify-plans-workflow.sh` exit 0.
   - `scripts/sync-agent-rules.sh --check` exit 0.
   - `scripts/sync-templates-from-self.sh --check` exit 0.
   - `bootstrap_agent_governance.sh --check-updates` against the skill
     folder exit 0.

## Execution Trace
- Affected files (codex copy):
  - New: `AGENTS.md`, `CLAUDE.md`, `BOOTSTRAPPER_SPEC.md`, `README.md`,
    `projectbootstrapper.txt`, `.gitignore`,
    `.agent-governance-manifest.json`.
  - New trees: `.cursor/rules/`, `.claude/rules/`, `.codex/`,
    `rulesets/`, `plans/`.
  - New scripts: `scripts/sync-agent-rules.sh`,
    `scripts/create-implementation-doc.sh`,
    `scripts/verify-plans-workflow.sh`,
    `scripts/sync-templates-from-self.sh` (this change).
  - Untouched: `SKILL.md`, `agents/openai.yaml`, `assets/templates/**`,
    `scripts/bootstrap_agent_governance.sh`.
  - New plan files: `plans/README.md`, `plans/INDEX.md`,
    `plans/IMPLEMENTATION_TEMPLATE.md`, `plans/IDEAS.md`,
    `plans/legacy-plans.md`, `plans/2026-05.md`,
    `plans/2026-05-19-recursive-self-bootstrap-and-templates-sync.md`.
- Downstream dependents:
  - Claude mirror at `~/.claude/skills/agent-governance-scaffold/` — kept
    byte-identical via rsync after every change to the codex copy.
  - Future host repos scaffolded via `bootstrap_agent_governance.sh` —
    unaffected; they still receive the unchanged `assets/templates/*`
    content.
- Integration points:
  - `assets/templates/*` is the input the bootstrap copies into target
    repos. The new sync helper guarantees those templates equal the
    skill's own root files for the synced set, so what the skill enforces
    on itself equals what it ships to consumers.
- Current monthly checklist entry:
  `plans/2026-05.md` → `- [ ] 2026-05-19 - recursive-self-bootstrap-and-templates-sync`.

## Edge Cases / Risks / Assumptions
- Edge cases:
  - `projectbootstrapper.txt` is generated inline by the bootstrap, not
    copied from a template — including it in the sync list would replace
    the template's `/path/to/...` placeholders with whatever absolute
    paths the last install happened to use. Excluded.
  - `plans/INDEX.md` and `plans/IDEAS.md` in the skill repo now contain
    skill-specific content; the corresponding templates must keep their
    placeholder shape so newly scaffolded repos start clean. Excluded.
  - Monthly files (`plans/YYYY-MM.md`) and dated docs are project-specific
    by definition. Excluded.
- Risks:
  - Edits made directly to `assets/templates/*` without running
    `sync-templates-from-self.sh` (or its inverse) will silently drift
    from what the skill enforces on itself. Mitigation: `--check` mode
    is intended to be wired into CI / a pre-commit hook in a follow-up.
  - Two locations now hold (effectively) the same governance content
    inside the skill folder. Manual edits should land in root rule
    sources first, then `scripts/sync-agent-rules.sh` and
    `scripts/sync-templates-from-self.sh` propagate them.
- Assumptions:
  - The codex copy at `~/.codex/skills/agent-governance-scaffold/` is the
    canonical development location; the Claude copy is a passive mirror.
  - All managed rule names remain semantically aligned between
    `.cursor/rules/*.mdc` and `.claude/rules/*.md` (already enforced by
    `sync-agent-rules.sh` via `cmp -s`).

## Verification
- Commands run:
  - `scripts/bootstrap_agent_governance.sh /home/ethan/.codex/skills/agent-governance-scaffold`
  - `scripts/sync-templates-from-self.sh --check`
  - `scripts/sync-agent-rules.sh --check`
  - `scripts/verify-plans-workflow.sh`
  - `scripts/bootstrap_agent_governance.sh --check-updates /home/ethan/.codex/skills/agent-governance-scaffold`
  - `rsync -a --delete --exclude='.git/' codex/ claude/ && diff -rq codex claude`
- Results:
  - Bootstrap: scaffold installed; rules/codex mirrors/rulesets synced;
    plans workflow verified.
  - `sync-templates-from-self.sh --check`: "Templates match root governance files."
  - `sync-agent-rules.sh --check`: "Agent rules, codex mirrors, and rulesets are in sync."
  - `verify-plans-workflow.sh`: "Plans workflow scaffolding verified."
  - `--check-updates`: "Scaffold is up to date."
  - `diff -rq` between codex and claude copies: clean (exit 0).

## Outcome
- Status: implemented-verified.
- Follow-up items:
  - Wire `scripts/sync-templates-from-self.sh --check` and
    `scripts/sync-agent-rules.sh --check` into a pre-commit / CI hook
    so template drift fails fast.
  - Strengthen `scripts/verify-plans-workflow.sh` to cross-check
    `plans/INDEX.md` against on-disk dated docs (currently only checks
    scaffolding presence and required headings; misses INDEX↔disk drift
    in consumer repos).
  - Decide whether the skill folder should be `git init`'d so the
    recursive plans audit trail is durably versioned.
- Monthly plan updated: yes (`plans/2026-05.md`).
- `plans/INDEX.md` updated: yes.
