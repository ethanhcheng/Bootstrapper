# Scaffold Version Gate for Content Changes

**Date:** 2026-09-14
**Status:** implemented-verified

## Problem

`bootstrap --check-updates` reported "Scaffold is up to date" on a downstream
repo that was demonstrably missing the Version Control rules added the same day.

Cause: `needs_update()` compares only the manifest's recorded `scaffold_version`
against the script's `SCAFFOLD_VERSION` constant. It does not compare content.
The rule change in PR #2 edited shipped templates without bumping that constant,
so every downstream repo would report up to date while silently missing the new
rules -- the failure is silent in exactly the direction that matters, because a
project believes it is current when it is not.

## Change

1. Bumped `SCAFFOLD_VERSION` from `2026-05-19.1` to `2026-09-14.1`, so the
   Version Control rules actually propagate.
2. Documented the coupling directly above `needs_update()`: any change to
   shipped scaffold content must bump the version, because drift is detected by
   version and never by content.

## Verification

Against `/home/ethan/Projects/SJIS/InvoiceTracker-IS`, which had the old
manifest and none of the new rules:

- before the bump: `Scaffold is up to date` (wrong)
- after the bump: `Scaffold missing or behind current version` (correct)

`bash -n` clean.

## Follow-up worth considering

A version gate still depends on a human remembering to bump it. A content hash
over the shipped template set, recorded in the manifest, would make drift
detection self-maintaining. Logged as a possible improvement rather than done
here, since it changes the manifest format and deserves its own change.
