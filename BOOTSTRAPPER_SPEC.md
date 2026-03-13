# Bootstrapper Spec

This file is the project-specific source of truth for what the Bootstrapper repo should build, generate, or automate. The governance files in this repository define process and quality gates; this file defines product behavior.

## Current Goal

- Keep a GitHub-cloneable bootstrapper repository whose rules and working conventions travel cleanly across machines.

## Agent Instructions

- Read this file before changing bootstrapper behavior.
- Use `README.md` for clone, setup, and GitHub workflow steps.
- Treat `projectbootstrapper.txt` as legacy reference material unless its contents are copied here.
- Record significant changes in `plans/` and keep the implementation trail append-only.

## Fill In Before Major Implementation

### Purpose

- What problem does this bootstrapper solve?
- Who will run it?

### Supported Environments

- macOS:
- Linux:
- Windows:

### Bootstrap Outputs

- Files or folders created:
- Tools installed:
- Config generated:

### Commands

```bash
# Primary bootstrap command(s) go here
```

### Inputs

- Required environment variables:
- Optional flags:
- Secrets handling rules:

### Implementation Rules

- Preferred language(s):
- Dependency constraints:
- Idempotency expectations:
- Logging and error handling expectations:

### Verification

- Commands that prove the bootstrap worked:
- Expected output or state after success:

### Non-Goals

- What this repository should not attempt to do:

### Open Questions

- Unknowns that should be resolved before automation expands:
