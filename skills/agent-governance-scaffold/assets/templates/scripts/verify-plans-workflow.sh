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

failed = [label for label, ok in checks if not ok]
if failed:
    for label in failed:
        print(f"Plans workflow verification failed: {label}", file=sys.stderr)
    raise SystemExit(1)
PY

echo "Plans workflow scaffolding verified."
