# Project Spec

This file is the project-specific source of truth for what this repository should build, configure, automate, or preserve. The governance files define process and quality gates; this file defines project behavior.

## Current Goal

- Describe the main capability, system, or workflow this repository owns.

## Agent Instructions

- Read this file before changing project behavior or repo automation.
- Use `README.md` for repo layout and workflow notes.
- Treat `projectbootstrapper.txt` as legacy reference material unless its contents are copied here.
- Record significant changes in `plans/` and keep the implementation trail append-only.

## Purpose

- What problem does this project solve?
- Who operates or consumes it?

## Supported Environments

- Linux:
- macOS:
- Windows:

## Project Outputs

- Files, services, scripts, or automation this repo is expected to produce or manage.

## Commands

```bash
# Primary project commands go here
```

## Inputs

- Required environment variables:
- Optional flags:
- Secrets handling rules:

## Stack And Conventions

- Language(s), runtime, and frameworks:
- Test command, and what CI runs:
- Language-specific conventions the shared rules do not cover:
- Dependency constraints:
- Portability or path expectations:
- Idempotency, logging, and error-handling expectations:

## Work Tiers In This Project

The shared rules define three tiers (ops/data, small change, feature). Say what each means here.

- Ops/data work (committed straight to the default branch, no PR): which scripts or directories qualify, and any safety steps such as a dry run or a confirmation before touching production data.
- Changes that always count as feature tier here:
- Plan-doc `Category` values this project uses, and anything that reads the docs' `Summary` line:

## Verification

- Commands that prove the bootstrap worked:
- Expected output or state after success:

## Non-Goals

- What this repository should not attempt to do:

## Open Questions

- Unknowns that should be resolved before automation expands:
