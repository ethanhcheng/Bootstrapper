# 2026-06-04 - port-lost-governance-logic-from-jiggamumps

## Request Summary
- Diff this bootstrapper repo's governance against the legacy hand-tuned
  agent-governance files in `/home/ethan/Projects/Jiggamumps` (a repo that was
  scaffolded long ago and then hand-edited heavily).
- Recover governance *logic* that exists in the Jiggamumps legacy rules but was
  never absorbed back into the bootstrapper templates / self-rules / ruleset,
  generalize out the project-specific flavor, and port it in.

## Full Agent Implementation Plan
1. Locate the bootstrapper repo and map both sides:
   - Canonical source of truth in this repo = top-level `.claude/rules/*.md`
     and `.cursor/rules/*.mdc` (kept byte-identical via `cmp -s`).
   - `scripts/sync-agent-rules.sh` *generates* `.codex/rules/*` and
     `rulesets/CONSOLIDATED_RULESET.md` (concatenation of the rule files).
   - Repo templates at `skills/agent-governance-scaffold/assets/templates/`
     are verbatim mirrors of the repo-root canonical files (invariant
     confirmed against unchanged files `sandbox-permissions`, `tech-stack`).
2. Identify lost logic (verified absent from this repo's templates, self-rules,
   and CONSOLIDATED_RULESET via direct diff + grep):
   - Full Code Review Checklist — 8 detailed dimensions.
   - Abstraction Policy / Abstraction Review.
   - Extra edge-case bullets (concurrent + malformed input).
   - Cross-Client Parity (generalized from Jiggamumps's multi-GUI wording).
   - Concrete Python standards (asyncio/threading/freeze-prevention), replacing
     the 7-line stub.
3. Edit only the canonical rule files (`.claude/rules/*.md`), generalizing out
   Jiggamumps specifics (audio buffers, Tkinter, librosa, "Jiggumps is the
   orchestrator", desktop/mac GUI parity). Inline the detailed 8-dimension
   checklist into `code-review.md` so it propagates into the *generated*
   CONSOLIDATED_RULESET and the templates (templates ship no `rulesets/`).
4. Mirror `.claude/rules/*.md` → `.cursor/rules/*.mdc` byte-for-byte.
5. Run `scripts/sync-agent-rules.sh` to regenerate `.codex/*` + rulesets.
6. Copy the 3 edited files into `assets/templates/{.claude,.cursor}` (the
   embedded `sync-templates-from-self.sh` cannot run from the repo root because
   it resolves ROOT_DIR to the un-bootstrapped embedded skill dir; the repo
   maintains templates as verbatim mirrors, so `cp` reproduces the sync output).
7. Record plans artifacts and verify.

## Execution Trace
- Affected files:
  - `.claude/rules/code-review.md`, `.cursor/rules/code-review.mdc`
  - `.claude/rules/development-workflow.md`, `.cursor/rules/development-workflow.mdc`
  - `.claude/rules/python-standards.md`, `.cursor/rules/python-standards.mdc`
  - `AGENTS.md`, `CLAUDE.md` — added `### 6. Abstraction and Object-Oriented Design`
    protocol section + two "Always Do" abstraction bullets (monolith extraction,
    explicit abstraction state/lifecycle/contract ownership)
  - `.codex/PROJECT_RULES.md` — added three abstraction-seam bullets to Effective Policy
  - `code-review.md` Contract Consistency — added `.env.example` mirror/redaction nuance
    (Jiggamumps CONSOLIDATED_RULESET Core Requirement #9)
  - Generated: `.codex/rules/{code-review,development-workflow,python-standards}.md`,
    `.codex/rules/claude-*.md`, `rulesets/CONSOLIDATED_RULESET.md`,
    `rulesets/AGENT_BINDINGS.md` (via `sync-agent-rules.sh`)
  - Templates: `skills/agent-governance-scaffold/assets/templates/.claude/rules/*`
    and `.cursor/rules/*` for the 3 files
- Downstream dependents:
  - Future `bootstrap_agent_governance.sh` installs into target repos now carry
    the recovered logic.
  - Installed skill copies `~/.codex/skills/agent-governance-scaffold` and
    `~/.claude/skills/agent-governance-scaffold` are NOT updated by this change
    (deploy step — see Follow-up).
- Integration points: `sync-agent-rules.sh`, `verify-plans-workflow.sh`,
  template tree consumed by `bootstrap_agent_governance.sh`.
- Current monthly checklist entry: `plans/2026-06.md`.

## Edge Cases / Risks / Assumptions
- Edge cases:
  - `.claude` vs `.cursor` must stay byte-identical or `sync-agent-rules.sh`
    fails its `assert_rule_alignment` — verified via `--check`.
  - Templates ship no `rulesets/`, so the detailed checklist had to live inside
    `code-review.md` to reach scaffolded repos, not in a separate ruleset file.
- Risks:
  - Reverse drift: this repo's `development-workflow` already had newer logic
    ("Plans As Reference Library", "Repo-Specific Inputs") that Jiggamumps lacks.
    Those sections were preserved, not overwritten. Re-bootstrapping Jiggamumps
    would still overwrite its hand-tuned rules — porting first is the mitigation.
- Assumptions:
  - The bootstrapper is intended to be language-leaning-Python (rule file is
    named `python-standards`); promoting concrete Python guidance is in scope.
  - Cross-Client Parity is worth generalizing (user-confirmed).

## Verification
- Commands run:
  - `bash scripts/sync-agent-rules.sh` → "Agent rules synced into .codex/rules and rulesets/."
  - `bash scripts/sync-agent-rules.sh --check` → "Agent rules, codex mirrors, and rulesets are in sync."
  - `cmp -s` across all 5 rule names × {.claude/.cursor} × {root/template}
  - `grep` confirms "Full Code Review Dimensions / Abstraction Review /
    Cross-Client Parity / Abstraction Requirements" present in generated
    `rulesets/CONSOLIDATED_RULESET.md` and in the template `code-review.md`.
  - `bash scripts/verify-plans-workflow.sh`
- Results:
  - sync + alignment checks: PASS.
  - plans verifier: PASS after this doc + `plans/2026-06.md` + INDEX entry added.

## Full-Surface Audit (completeness pass)
Diffed every Jiggamumps governance surface against this repo to confirm no
remaining generic lost logic:
- `code-review`, `development-workflow`, `python-standards` — ported (above).
- `AGENTS.md`, `CLAUDE.md`, `.codex/PROJECT_RULES.md` — abstraction logic ported.
- `tech-stack` — the two general stack rules ("prefer existing patterns / trace
  replacements", "centralize API wrappers") were ALREADY present in the template;
  remainder is project-specific (faster-whisper/Piper/Ollama). No gap.
- `sandbox-permissions` — generic intent already covered by the template stub;
  Jiggamumps content is environment-specific (allowed commands, docker, path
  exclusions). No generic gap.
- `CONSOLIDATED_RULESET` Core Requirements — only `.env.example` redaction (#9)
  was generic-and-missing; ported. Items like "Jiggumps is the orchestrator"
  and native-shell parity are project-specific and intentionally not ported.
- Project-specific content deliberately NOT ported: project structure, critical
  integration tables, native-shell/companion-client policy, audio/Tkinter/librosa
  specifics, concrete stack choices.

## Outcome
- Status: implemented-verified.
- Follow-up items:
  - Deploy to installed skill copies via `scripts/update-local-codex-skill.sh`
    (and rsync codex→claude) when ready; this change is repo-only.
  - Optionally re-bootstrap Jiggamumps with `--update` AFTER confirming all its
    remaining hand-tuned logic is ported, since `--update` would overwrite it.
  - Consider whether `sandbox-permissions` / `tech-stack` stubs should also gain
    generalized structure (left as intentional project fill-ins this pass).
- Monthly plan updated: yes (`plans/2026-06.md`).
- `plans/INDEX.md` updated: yes.
