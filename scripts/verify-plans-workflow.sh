#!/usr/bin/env bash
# Verify the plans workflow: the scaffolding exists, and every plan doc dated
# on or after this repo's cutover carries a valid header.
#
# The cutover is `plan_doc_headers_since` in .agent-governance-manifest.json,
# recorded when the scaffold was installed or updated. Docs older than that
# predate the header convention and are left alone.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PLANS_DIR="$ROOT_DIR/plans"
MANIFEST_PATH="$ROOT_DIR/.agent-governance-manifest.json"

for path in "$PLANS_DIR/README.md" "$PLANS_DIR/IMPLEMENTATION_TEMPLATE.md"; do
  if [[ ! -f "$path" ]]; then
    echo "Missing plans workflow file: $path" >&2
    exit 1
  fi
done

python3 - "$PLANS_DIR" "$MANIFEST_PATH" <<'PY'
import json
import re
import sys
from pathlib import Path

plans_dir = Path(sys.argv[1])
manifest_path = Path(sys.argv[2])

STATUSES = {"planned", "in-progress", "partial", "implemented-verified", "not-implemented"}
SUMMARY_PLACEHOLDER = "One plain-language sentence"
SUMMARY_MAX_CHARS = 220
DATED_DOC = re.compile(r"^(\d{4}-\d{2}-\d{2})-(.+)\.md$")
KEBAB = re.compile(r"[a-z0-9]+(?:-[a-z0-9]+)*")


def header_block(text):
    """Everything above the first `## ` heading."""
    first_section = re.search(r"^##\s", text, re.MULTILINE)
    return text[: first_section.start()] if first_section else text


def header_field(block, name):
    match = re.search(
        rf"^\s*-?\s*(?:\*\*)?{re.escape(name)}:(?:\*\*)?[ \t]*(.*)$",
        block,
        re.MULTILINE | re.IGNORECASE,
    )
    return match.group(1).strip().strip("`").strip() if match else None


errors = []

template_header = header_block((plans_dir / "IMPLEMENTATION_TEMPLATE.md").read_text(encoding="utf-8"))
for name in ("Status", "Category", "Summary"):
    if header_field(template_header, name) is None:
        errors.append(f"IMPLEMENTATION_TEMPLATE.md header is missing `{name}:`")

since = ""
if manifest_path.exists():
    try:
        since = str(json.loads(manifest_path.read_text(encoding="utf-8")).get("plan_doc_headers_since") or "")
    except (OSError, ValueError):
        since = ""

checked = 0
for path in sorted(plans_dir.iterdir()):
    match = DATED_DOC.match(path.name)
    if not match or not path.is_file():
        continue
    doc_date, slug = match.groups()
    if not since or doc_date < since:
        continue
    checked += 1

    if not KEBAB.fullmatch(slug):
        errors.append(f"{path.name}: the name after the date must be lowercase kebab-case")

    block = header_block(path.read_text(encoding="utf-8"))

    status = header_field(block, "Status")
    status_word = re.match(r"[a-z-]+", (status or "").lower())
    if not status:
        errors.append(f"{path.name}: header is missing `Status:`")
    elif not status_word or status_word.group(0) not in STATUSES:
        errors.append(f"{path.name}: Status `{status}` is not one of {', '.join(sorted(STATUSES))}")

    summary = header_field(block, "Summary") or header_field(block, "User Update")
    if not summary:
        errors.append(f"{path.name}: header is missing a one-line `Summary:`")
    elif summary.startswith(SUMMARY_PLACEHOLDER):
        errors.append(f"{path.name}: Summary is still the template placeholder")
    elif len(summary) > SUMMARY_MAX_CHARS:
        errors.append(f"{path.name}: Summary is {len(summary)} characters; keep it under {SUMMARY_MAX_CHARS}")

if errors:
    for error in errors:
        print(f"Plans workflow verification failed: {error}", file=sys.stderr)
    raise SystemExit(1)

if since:
    print(f"Plans workflow verified: {checked} doc(s) dated on or after {since} have valid headers.")
else:
    print("Plans workflow scaffolding verified. No cutover date recorded, so doc headers were not checked.")
PY
