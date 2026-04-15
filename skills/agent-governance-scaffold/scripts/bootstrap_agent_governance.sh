#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEMPLATE_DIR="$ROOT_DIR/assets/templates"
SCAFFOLD_VERSION="2026-04-15.1"
SOURCE_COMMIT=""

if git -C "$ROOT_DIR" rev-parse --short HEAD >/dev/null 2>&1; then
  SOURCE_COMMIT="$(git -C "$ROOT_DIR" rev-parse --short HEAD)"
fi

usage() {
  cat <<'EOF'
Usage:
  scripts/bootstrap_agent_governance.sh [repo_path]
  scripts/bootstrap_agent_governance.sh --update [repo_path]
  scripts/bootstrap_agent_governance.sh --check-updates [repo_path]
  scripts/bootstrap_agent_governance.sh --auto-update [repo_path]
  scripts/bootstrap_agent_governance.sh --force-spec [repo_path]

Behavior:
  - Works on existing non-empty folders.
  - Does not require the target folder to already be a git repository.
  - Preserves repo-owned docs unless --force-spec is used for BOOTSTRAPPER_SPEC.md.
EOF
}

MODE="install"
FORCE_SPEC=0
TARGET_DIR=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --update)
      MODE="update"
      shift
      ;;
    --check-updates)
      MODE="check"
      shift
      ;;
    --auto-update)
      MODE="auto-update"
      shift
      ;;
    --force-spec)
      FORCE_SPEC=1
      shift
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      if [[ -n "$TARGET_DIR" ]]; then
        usage >&2
        exit 2
      fi
      TARGET_DIR="$1"
      shift
      ;;
  esac
done

if [[ "$MODE" == "check" && "$FORCE_SPEC" -eq 1 ]]; then
  echo "--force-spec cannot be used with --check-updates" >&2
  exit 2
fi

TARGET_DIR="${TARGET_DIR:-$PWD}"
if [[ ! -d "$TARGET_DIR" ]]; then
  echo "Target directory does not exist: $TARGET_DIR" >&2
  exit 1
fi
TARGET_DIR="$(cd "$TARGET_DIR" && pwd)"

MANIFEST_PATH="$TARGET_DIR/.agent-governance-manifest.json"

manifest_field() {
  python3 - "$MANIFEST_PATH" "$@" <<'PY'
import json
import pathlib
import sys

path = pathlib.Path(sys.argv[1])
if not path.exists():
    print("")
    raise SystemExit(0)

try:
    data = json.loads(path.read_text(encoding="utf-8"))
except Exception:
    print("")
    raise SystemExit(0)

for key in sys.argv[2:]:
    value = data.get(key, "")
    if value not in ("", None):
        print(value)
        raise SystemExit(0)

print("")
PY
}

manifest_version() {
  manifest_field "scaffold_version" "version"
}

needs_update() {
  [[ "$(manifest_version)" != "$SCAFFOLD_VERSION" ]]
}

ensure_parent_dir() {
  mkdir -p "$(dirname "$1")"
}

copy_managed_file() {
  local src="$1"
  local dest="$2"
  ensure_parent_dir "$dest"
  install -m 0644 "$src" "$dest"
}

copy_managed_script() {
  local src="$1"
  local dest="$2"
  ensure_parent_dir "$dest"
  install -m 0755 "$src" "$dest"
}

copy_if_missing() {
  local src="$1"
  local dest="$2"
  if [[ -f "$dest" ]]; then
    return
  fi
  ensure_parent_dir "$dest"
  install -m 0644 "$src" "$dest"
}

ensure_gitignore_lines() {
  local target="$TARGET_DIR/.gitignore"
  local line
  if [[ ! -f "$target" ]]; then
    install -m 0644 "$TEMPLATE_DIR/.gitignore" "$target"
    return
  fi

  while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    if ! grep -qxF "$line" "$target"; then
      printf '%s\n' "$line" >> "$target"
    fi
  done < "$TEMPLATE_DIR/.gitignore"
}

ensure_plan_index() {
  local current_month="$1"
  local index_path="$TARGET_DIR/plans/INDEX.md"
  local template_index="$TEMPLATE_DIR/plans/INDEX.md"
  local ideas_exists="0"

  if [[ -f "$TARGET_DIR/plans/IDEAS.md" ]]; then
    ideas_exists="1"
  fi

  python3 - "$index_path" "$current_month" "$template_index" "$ideas_exists" <<'PY'
import sys
from pathlib import Path

index_path = Path(sys.argv[1])
current_month = sys.argv[2]
template_index = Path(sys.argv[3])
ideas_exists = sys.argv[4] == "1"
month_entry = f"- [{current_month}]({current_month}.md)"
ideas_entry = "- [IDEAS](IDEAS.md)"
active_placeholder = "- Add monthly files like `[YYYY-MM](YYYY-MM.md)` here as they are created."

if index_path.exists():
    content = index_path.read_text(encoding="utf-8")
else:
    content = template_index.read_text(encoding="utf-8")

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
ensure_heading("Seed Notes / Idea Backlog")
ensure_heading("Implementation Docs")
ensure_heading("Legacy Archive")

if "- [legacy-plans](legacy-plans.md)" not in lines:
    lines.insert(section_insert_index("## Legacy Archive"), "- [legacy-plans](legacy-plans.md)")

if month_entry not in lines:
    lines = [line for line in lines if line != active_placeholder]
    lines.insert(section_insert_index("## Active"), month_entry)

if ideas_exists and ideas_entry not in lines:
    lines.insert(section_insert_index("## Seed Notes / Idea Backlog"), ideas_entry)

collapsed = []
for line in lines:
    if line == "" and collapsed and collapsed[-1] == "":
        continue
    collapsed.append(line)

index_path.parent.mkdir(parents=True, exist_ok=True)
index_path.write_text("\n".join(collapsed).rstrip() + "\n", encoding="utf-8")
PY
}

ensure_current_month_plan() {
  local current_month="$1"
  local current_date
  current_date="$(date +%Y-%m-%d)"
  local month_path="$TARGET_DIR/plans/$current_month.md"

  if [[ ! -f "$month_path" ]]; then
    cat > "$month_path" <<EOF
# $current_month Plans

## Monthly Feature Checklist
- Add one checklist entry per significant feature implementation.
- Each entry should include:
  - the implementation date
  - a short summary
  - status such as \`planned\`, \`in-progress\`, or \`implemented-verified\`
  - a \`Doc:\` line pointing to \`plans/YYYY-MM-DD-feature-name.md\`
- Update this file before implementation, during meaningful scope changes, and after verification.
- Missing monthly checklist updates mean the task is not complete.

## $current_date - Governance Bootstrap

### Pre-Change Trace (Gate A)
- [ ] Identify affected files and dependents.
- [ ] Enumerate edge cases.
- [ ] Record integration points and downstream consumers.

### Plan
- [ ] Implement requested changes.
- [ ] Validate integrations.
- [ ] Record verification outcomes.

### Optimization / Improvement Additions
- [ ] Add future improvements discovered during implementation review.

### Post-Change Continuity Review (Gate B)
- [ ] Re-trace modified paths.
- [ ] Verify signatures/imports/dependents.
- [ ] Record verification commands and outcomes.

## Implementation Docs Created
- Add one entry for each dated implementation document created this month.
- Record whether each item is \`implemented-verified\`, \`partial\`, or \`not-implemented\`.
EOF
    return
  fi

  python3 - "$month_path" <<'PY'
import sys
from pathlib import Path

month_path = Path(sys.argv[1])
lines = month_path.read_text(encoding="utf-8").splitlines()

def ensure_heading(title: str, content_lines: list[str]) -> None:
    heading = f"## {title}"
    if heading in lines:
        return
    if lines and lines[-1] != "":
        lines.append("")
    lines.append(heading)
    lines.extend(content_lines)

ensure_heading(
    "Monthly Feature Checklist",
    [
        "- Add one checklist entry per significant feature implementation.",
        "- Each entry should include:",
        "  - the implementation date",
        "  - a short summary",
        "  - status such as `planned`, `in-progress`, or `implemented-verified`",
        "  - a `Doc:` line pointing to `plans/YYYY-MM-DD-feature-name.md`",
        "- Update this file before implementation, during meaningful scope changes, and after verification.",
        "- Missing monthly checklist updates mean the task is not complete.",
    ],
)

ensure_heading(
    "Implementation Docs Created",
    [
        "- Add one entry for each dated implementation document created this month.",
        "- Record whether each item is `implemented-verified`, `partial`, or `not-implemented`.",
    ],
)

collapsed = []
for line in lines:
    if line == "" and collapsed and collapsed[-1] == "":
        continue
    collapsed.append(line)

month_path.write_text("\n".join(collapsed).rstrip() + "\n", encoding="utf-8")
PY
}

write_manifest() {
  python3 - "$MANIFEST_PATH" "$SCAFFOLD_VERSION" "$ROOT_DIR" "$SOURCE_COMMIT" <<'PY'
import json
import sys
from pathlib import Path

path = Path(sys.argv[1])
version = sys.argv[2]
source_path = sys.argv[3]
source_commit = sys.argv[4]

path.write_text(
    json.dumps(
        {
            "version": version,
            "scaffold_version": version,
            "updated_at_utc": __import__("datetime").datetime.now(__import__("datetime").timezone.utc).isoformat(),
            "source_kind": "agent-governance-scaffold",
            "source_path": source_path,
            "source_repo_commit": source_commit or None,
        },
        indent=2,
    )
    + "\n",
    encoding="utf-8",
)
PY
}

write_legacy_note_if_missing() {
  local legacy_path="$TARGET_DIR/projectbootstrapper.txt"
  [[ -f "$legacy_path" ]] && return

  cat > "$legacy_path" <<EOF
LEGACY NOTE

This file is retained for reference only.

Canonical repo documents:
- \`README.md\`
- \`BOOTSTRAPPER_SPEC.md\`
- \`AGENTS.md\`

Do not treat the remaining contents of this file as the authoritative project specification.

Use the scaffold source that installed this repo to inspect or refresh it:
- \`$ROOT_DIR/scripts/bootstrap_agent_governance.sh --check-updates $TARGET_DIR\`
- \`$ROOT_DIR/scripts/bootstrap_agent_governance.sh --auto-update $TARGET_DIR\`

Project-specific behavior belongs in \`BOOTSTRAPPER_SPEC.md\`.
EOF
}

install_scaffold() {
  local current_month
  current_month="$(date +%Y-%m)"

  ensure_gitignore_lines

  copy_managed_file "$TEMPLATE_DIR/AGENTS.md" "$TARGET_DIR/AGENTS.md"
  copy_managed_file "$TEMPLATE_DIR/CLAUDE.md" "$TARGET_DIR/CLAUDE.md"
  copy_managed_file "$TEMPLATE_DIR/.codex/PROJECT_RULES.md" "$TARGET_DIR/.codex/PROJECT_RULES.md"

  local src
  for src in "$TEMPLATE_DIR/.cursor/rules/"*; do
    copy_managed_file "$src" "$TARGET_DIR/.cursor/rules/$(basename "$src")"
  done

  for src in "$TEMPLATE_DIR/.claude/rules/"*; do
    copy_managed_file "$src" "$TARGET_DIR/.claude/rules/$(basename "$src")"
  done

  for src in "$TEMPLATE_DIR/scripts/"*; do
    copy_managed_script "$src" "$TARGET_DIR/scripts/$(basename "$src")"
  done

  copy_if_missing "$TEMPLATE_DIR/README.md" "$TARGET_DIR/README.md"
  if [[ "$FORCE_SPEC" -eq 1 ]]; then
    copy_managed_file "$TEMPLATE_DIR/BOOTSTRAPPER_SPEC.md" "$TARGET_DIR/BOOTSTRAPPER_SPEC.md"
  else
    copy_if_missing "$TEMPLATE_DIR/BOOTSTRAPPER_SPEC.md" "$TARGET_DIR/BOOTSTRAPPER_SPEC.md"
  fi
  copy_managed_file "$TEMPLATE_DIR/plans/README.md" "$TARGET_DIR/plans/README.md"
  copy_managed_file "$TEMPLATE_DIR/plans/IMPLEMENTATION_TEMPLATE.md" "$TARGET_DIR/plans/IMPLEMENTATION_TEMPLATE.md"
  copy_managed_file "$TEMPLATE_DIR/plans/legacy-plans.md" "$TARGET_DIR/plans/legacy-plans.md"
  copy_if_missing "$TEMPLATE_DIR/plans/IDEAS.md" "$TARGET_DIR/plans/IDEAS.md"

  ensure_plan_index "$current_month"
  ensure_current_month_plan "$current_month"
  write_legacy_note_if_missing
  write_manifest

  "$TARGET_DIR/scripts/sync-agent-rules.sh"
  "$TARGET_DIR/scripts/sync-agent-rules.sh" --check
  "$TARGET_DIR/scripts/verify-plans-workflow.sh"
}

case "$MODE" in
  check)
    if needs_update; then
      echo "Scaffold missing or behind current version: $TARGET_DIR"
      exit 1
    fi
    echo "Scaffold is up to date: $TARGET_DIR"
    ;;
  auto-update)
    if needs_update; then
      install_scaffold
      echo "Scaffold installed or updated: $TARGET_DIR"
      if [[ ! -d "$TARGET_DIR/.git" ]]; then
        echo "Note: target directory is not a git repository yet. Run 'git init -b main' when you want to version it."
      fi
    else
      echo "Scaffold already up to date: $TARGET_DIR"
    fi
    ;;
  install|update)
    install_scaffold
    echo "Scaffold installed or updated: $TARGET_DIR"
    if [[ ! -d "$TARGET_DIR/.git" ]]; then
      echo "Note: target directory is not a git repository yet. Run 'git init -b main' when you want to version it."
    fi
    ;;
  *)
    echo "Unknown mode: $MODE" >&2
    exit 2
    ;;
esac
