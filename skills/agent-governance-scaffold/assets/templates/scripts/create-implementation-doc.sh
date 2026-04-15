#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PLANS_DIR="$ROOT_DIR/plans"

usage() {
  cat <<'EOF'
Usage:
  scripts/create-implementation-doc.sh YYYY-MM-DD feature-name

Creates:
  plans/YYYY-MM-DD-feature-name.md

Also updates:
  plans/INDEX.md
  plans/YYYY-MM.md
EOF
}

if [[ $# -ne 2 ]]; then
  usage >&2
  exit 2
fi

DOC_DATE="$1"
FEATURE_SLUG="$2"

if [[ ! "$DOC_DATE" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
  echo "Date must be YYYY-MM-DD" >&2
  exit 1
fi

if [[ ! "$FEATURE_SLUG" =~ ^[a-z0-9-]+$ ]]; then
  echo "feature-name must be lowercase kebab-case" >&2
  exit 1
fi

mkdir -p "$PLANS_DIR"

DOC_PATH="$PLANS_DIR/$DOC_DATE-$FEATURE_SLUG.md"
INDEX_PATH="$PLANS_DIR/INDEX.md"
MONTH_KEY="${DOC_DATE:0:7}"
MONTH_PATH="$PLANS_DIR/$MONTH_KEY.md"
CHECKLIST_ENTRY="- [ ] $DOC_DATE - $FEATURE_SLUG - implementation summary (\`planned\`)"
DOC_REFERENCE="  - Doc: \`plans/$DOC_DATE-$FEATURE_SLUG.md\`"
TRACE_REFERENCE="  - Trace: pre-change review recorded, downstream dependents identified, edge cases enumerated"
REVIEW_REFERENCE="  - Review: post-change continuity review pending"

if [[ -f "$DOC_PATH" ]]; then
  echo "Implementation doc already exists: $DOC_PATH" >&2
  exit 1
fi

if [[ ! -f "$MONTH_PATH" ]]; then
  cat > "$MONTH_PATH" <<EOF
# $MONTH_KEY Plans

## Monthly Feature Checklist
- Update this file before implementation, during meaningful scope changes, and after verification.
- Missing monthly checklist updates mean the task is not complete.

## Implementation Docs Created
- Record whether each item is \`implemented-verified\`, \`partial\`, or \`not-implemented\`.
EOF
fi

sed "s/YYYY-MM-DD/$DOC_DATE/g; s/feature-name/$FEATURE_SLUG/g" \
  "$PLANS_DIR/IMPLEMENTATION_TEMPLATE.md" > "$DOC_PATH"

python3 - <<'PY' "$MONTH_PATH" "$CHECKLIST_ENTRY" "$DOC_REFERENCE" "$TRACE_REFERENCE" "$REVIEW_REFERENCE"
import sys
from pathlib import Path

month_path = Path(sys.argv[1])
checklist_entry = sys.argv[2]
doc_reference = sys.argv[3]
trace_reference = sys.argv[4]
review_reference = sys.argv[5]
doc_filename = doc_reference.split("`")[1].split("/")[-1]
lines = month_path.read_text(encoding="utf-8").splitlines()

def ensure_heading(title: str) -> None:
    heading = f"## {title}"
    if heading not in lines:
        if lines and lines[-1] != "":
            lines.append("")
        lines.append(heading)

def section_insert_index(heading: str) -> int:
    insert_at = lines.index(heading) + 1
    while insert_at < len(lines) and not lines[insert_at].startswith("## "):
        insert_at += 1
    while insert_at > 0 and lines[insert_at - 1] == "":
        insert_at -= 1
    return insert_at

ensure_heading("Monthly Feature Checklist")
ensure_heading("Implementation Docs Created")

if checklist_entry not in lines:
    insert_at = section_insert_index("## Monthly Feature Checklist")
    lines.insert(insert_at, checklist_entry)
    lines.insert(insert_at + 1, doc_reference)
    lines.insert(insert_at + 2, trace_reference)
    lines.insert(insert_at + 3, review_reference)

doc_created = f"- [ ] `plans/{doc_filename}` - full implementation plan/output copied from the agent response"
if doc_created not in lines:
    lines.insert(section_insert_index("## Implementation Docs Created"), doc_created)

collapsed = []
for line in lines:
    if line == "" and collapsed and collapsed[-1] == "":
        continue
    collapsed.append(line)

month_path.write_text("\n".join(collapsed).rstrip() + "\n", encoding="utf-8")
PY

python3 - <<'PY' "$INDEX_PATH" "$MONTH_KEY" "$DOC_DATE" "$FEATURE_SLUG"
import sys
from pathlib import Path

index_path = Path(sys.argv[1])
month_key = sys.argv[2]
doc_date = sys.argv[3]
feature_slug = sys.argv[4]
month_entry = f"- [{month_key}]({month_key}.md)"
doc_entry = f"- [{doc_date}-{feature_slug}]({doc_date}-{feature_slug}.md)"

content = index_path.read_text(encoding="utf-8") if index_path.exists() else "# Plan Index\n\n## Active\n\n## Implementation Docs\n\n## Legacy Archive\n- [legacy-plans](legacy-plans.md)\n"
lines = content.splitlines()

def ensure_heading(title: str) -> None:
    heading = f"## {title}"
    if heading not in lines:
        if lines and lines[-1] != "":
            lines.append("")
        lines.append(heading)

def section_insert_index(heading: str) -> int:
    insert_at = lines.index(heading) + 1
    while insert_at < len(lines) and not lines[insert_at].startswith("## "):
        insert_at += 1
    while insert_at > 0 and lines[insert_at - 1] == "":
        insert_at -= 1
    return insert_at

ensure_heading("Active")
ensure_heading("Implementation Docs")
ensure_heading("Legacy Archive")

lines = [
    line for line in lines
    if line != "- Add `YYYY-MM-DD-feature-name.md` links here as they are created."
]

if month_entry not in lines:
    lines.insert(section_insert_index("## Active"), month_entry)

if doc_entry not in lines:
    lines.insert(section_insert_index("## Implementation Docs"), doc_entry)

collapsed = []
for line in lines:
    if line == "" and collapsed and collapsed[-1] == "":
        continue
    collapsed.append(line)

index_path.write_text("\n".join(collapsed).rstrip() + "\n", encoding="utf-8")
PY

echo "Created implementation doc: $DOC_PATH"
