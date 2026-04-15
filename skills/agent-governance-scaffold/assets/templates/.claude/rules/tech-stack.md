# Technology Stack Guidance

- This repository is documentation-first and governance-first; keep project requirements in `BOOTSTRAPPER_SPEC.md`.
- Keep machine setup and GitHub workflow steps in `README.md`.
- Preserve `.cursor/`, `.claude/`, `.codex/`, `rulesets/`, `plans/`, and `scripts/` in version control so cloned copies behave consistently across machines.
- Prefer existing stack patterns before adding dependencies. Unless a new dependency offers optimizations. If implementing a new dependency to replace an old one, make sure the old code that uses it traces with the new dependency/library.
- Centralize API wrappers and shared transformations.
- Keep route handlers thin and integration points explicit.
- Background services, popup daemons, polling scripts, and agent-facing helpers must be resource-conscious: minimize idle RAM, keep polling intervals no tighter than needed, prefer cached or event-driven data over heavyweight long-lived processes, and never keep agent CLIs running in the background when on-demand reads are sufficient.
