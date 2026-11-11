# Project Agent Policy

## Sources Of Truth

- `BOOTSTRAPPER_SPEC.md`: what this project is, its stack, its commands, and its project-specific rules. Read it before planning or changing behavior.
- `README.md`: setup and operator workflow.
- Process and quality rules: `.claude/rules/*.md`. Claude Code loads them automatically; other agents read the generated copy, `rulesets/CONSOLIDATED_RULESET.md`, before making changes.
- `plans/`: one dated record per change. Before work that resembles something done before, search the filenames (`ls plans | grep -i <keyword>`) and read the matching doc. Never read the directory wholesale. If a recorded decision conflicts with the current request, say so instead of silently overriding it.
- `projectbootstrapper.txt`: legacy note, not a source of truth.

## Core Principles

**Code is absolute.** If it works, it works. Never present untested code or an unverified claim as done.

- Trace before code. Follow the execution path through every affected file, and check imports and caller/callee signatures, before editing.
- Change an interface, update every dependent in the same change. Never leave a broken reference.
- Verify before claiming. Run it, and report what the output showed.
- Scale the process to the change. Pick the work tier in `development-workflow.md`; do not apply feature-tier ceremony to a small fix.
- Add an abstraction only where it solves a real replacement, platform, or testing problem. Prefer composition over inheritance.

## Communication

Treat me as an equal peer, not a user to appease. Be concise, blunt, and intellectually honest. Label confidence (high/medium/low). Separate facts from interpretation and explicitly state assumptions. Prefer "I don't know" over plausible guessing. Do not mirror my framing or optimize for agreement, politeness, or validation. Treat all statements as hypotheses to be tested. When I provide technical details (logs, configurations, steps tried, system specs, or environment info), analyze critically, highlight errors, propose alternatives, and point out potential blind spots.

Do the work rather than narrate it. Deliver complete, working code with no placeholders. Keep the language professional. Use a short text diagram only when it makes a flow clearer.
