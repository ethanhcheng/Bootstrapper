#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PLANS_DIR="$ROOT_DIR/plans"
CURRENT_MONTH="$(date +%Y-%m)"

required_files=(
  "$PLANS_DIR/README.md"
  "$PLANS_DIR/INDEX.md"
  "$PLANS_DIR/IMPLEMENTATION_TEMPLATE.md"
  "$PLANS_DIR/$CURRENT_MONTH.md"
)

for path in "${required_files[@]}"; do
  if [[ ! -f "$path" ]]; then
    echo "Missing plans workflow file: $path" >&2
    exit 1
  fi
done

python3 - <<'PY' "$PLANS_DIR" "$CURRENT_MONTH"
import re
import sys
from pathlib import Path

plans_dir = Path(sys.argv[1])
current_month = sys.argv[2]

index_text = (plans_dir / "INDEX.md").read_text(encoding="utf-8")
readme_text = (plans_dir / "README.md").read_text(encoding="utf-8")
monthly_text = (plans_dir / f"{current_month}.md").read_text(encoding="utf-8")
template_text = (plans_dir / "IMPLEMENTATION_TEMPLATE.md").read_text(encoding="utf-8")
ideas_exists = (plans_dir / "IDEAS.md").exists()

checks = [
    ("README planning cadence", "Update planning artifacts before implementation" in readme_text),
    ("README incomplete-task rule", "Treat missing `plans/` updates for changed functionality as an incomplete task." in readme_text),
    ("README audit trail rule", "append-only audit trail" in readme_text),
    ("Monthly current month index entry", f"- [{current_month}]({current_month}.md)" in index_text),
    ("Implementation docs section", "## Implementation Docs" in index_text),
    ("Monthly checklist heading", "## Monthly Feature Checklist" in monthly_text),
    ("Monthly implementation docs heading", "## Implementation Docs Created" in monthly_text),
    ("Implementation template monthly reference", "Monthly plan updated:" in template_text),
    ("Implementation template index reference", "`plans/INDEX.md` updated:" in template_text),
]

if ideas_exists:
    checks.extend(
        [
            ("README ideas guidance", "`plans/IDEAS.md`" in readme_text),
            ("Index seed-notes section", "## Seed Notes / Idea Backlog" in index_text),
            ("Index ideas entry", "- [IDEAS](IDEAS.md)" in index_text),
        ]
    )

exit_status = 0
for label, ok in checks:
    if not ok:
        print(f"Plans workflow verification failed: {label}", file=sys.stderr)
        exit_status = 1

# INDEX <-> disk drift: every dated implementation doc on disk must be linked
# from INDEX.md, and every INDEX.md link must resolve to a real file.
dated_re = re.compile(r"^\d{4}-\d{2}-\d{2}-[a-z0-9-]+\.md$")
link_re = re.compile(r"\(([0-9]{4}-[0-9]{2}-[0-9]{2}-[a-z0-9-]+\.md)\)")
on_disk = sorted({p.name for p in plans_dir.iterdir() if p.is_file() and dated_re.match(p.name)})
in_index = sorted(set(link_re.findall(index_text)))

missing_in_index = [d for d in on_disk if d not in in_index]
missing_on_disk = [d for d in in_index if d not in on_disk]

if missing_in_index:
    print(
        f"Plans workflow verification failed: {len(missing_in_index)} dated implementation docs on disk are not linked from INDEX.md:",
        file=sys.stderr,
    )
    for d in missing_in_index:
        print(f"  - plans/{d}", file=sys.stderr)
    exit_status = 1

if missing_on_disk:
    print(
        f"Plans workflow verification failed: {len(missing_on_disk)} INDEX.md links point to non-existent files:",
        file=sys.stderr,
    )
    for d in missing_on_disk:
        print(f"  - plans/{d}", file=sys.stderr)
    exit_status = 1

if exit_status:
    raise SystemExit(1)
PY

echo "Plans workflow scaffolding verified."
