# Technology Stack

- Stack facts (languages, frameworks, commands, deploy target) live in `BOOTSTRAPPER_SPEC.md`. Setup and operator steps live in `README.md`.
- Prefer the patterns and libraries already in the repo. Add a dependency only when it clearly beats what exists. When replacing one, trace every use of the old one.
- Before adding or upgrading a dependency, check its current documentation instead of relying on memory.
- Centralize API wrappers and shared transformations. Keep route handlers thin and integration points explicit.
- Background services, pollers, and helper daemons stay resource-conscious: minimal idle memory, polling no tighter than needed, cached or event-driven data over long-lived heavy processes, and no agent CLI left running when an on-demand read would do.
- Do not delete, move, or gitignore the governance files (`.cursor/`, `.claude/rules/`, `.codex/`, `rulesets/`, `plans/`, `scripts/`) on your own. Whether a repo tracks them or keeps them local is the owner's decision.
