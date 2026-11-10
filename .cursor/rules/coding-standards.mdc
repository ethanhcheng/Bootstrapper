# Coding Standards

Write in the language, style, and idioms the repository already uses. Language-specific conventions belong in `BOOTSTRAPPER_SPEC.md`; the rules below apply in any language.

- Clear names, explicit error handling, minimal side effects.
- Validate input at system boundaries: user input, external APIs, files. Trust internal code and framework guarantees.
- No dead code, and no unused imports or dependencies.
- Read and write text files with an explicit encoding: UTF-8 unless the format says otherwise.
- Release files, connections, and other handles on every path, using the language's scoped-cleanup construct.
- Give every network request, subprocess, and blocking wait a timeout.
- Never run blocking work on a UI thread or an event loop.
- Loops that wait or retry have an exit condition and an attempt limit.
- Synchronize shared mutable state. Make check-then-act atomic. Hold no lock across a blocking call.
- Background work has a top-level error handler that logs, and can be stopped cleanly.
- Never swallow an error silently. Log what was attempted, on which resource, with what input.
- Copy nested data before mutating it when the caller must not see the change. No shared mutable default arguments.
- Comments explain why, not what.
