#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEMPLATE_DIR="$ROOT_DIR/assets/templates"
SCAFFOLD_VERSION="2026-11-10.1"
SOURCE_COMMIT=""

if git -C "$ROOT_DIR" rev-parse --short HEAD >/dev/null 2>&1; then
  SOURCE_COMMIT="$(git -C "$ROOT_DIR" rev-parse --short HEAD)"
fi

usage() {
  cat <<'EOF'
Usage:
  scripts/bootstrap_agent_governance.sh [repo_path]
  scripts/bootstrap_agent_governance.sh --init [repo_path]
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
    --init)
      MODE="install"
      shift
      ;;
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

# Drift is detected by VERSION, not by content: a downstream repo is considered
# up to date whenever its manifest records the current SCAFFOLD_VERSION.
#
# Therefore any change to the scaffold's shipped content -- rules, templates,
# plans scaffolding -- MUST bump SCAFFOLD_VERSION above. Without a bump,
# --check-updates reports "up to date" on every downstream repo while they
# silently miss the change, which is exactly what happened to the Version
# Control rules added on 2026-09-14.
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

write_manifest() {
  python3 - "$MANIFEST_PATH" "$SCAFFOLD_VERSION" "$ROOT_DIR" "$SOURCE_COMMIT" <<'PY'
import datetime
import json
import sys
from pathlib import Path

path = Path(sys.argv[1])
version = sys.argv[2]
source_path = sys.argv[3]
source_commit = sys.argv[4]

previous = {}
if path.exists():
    try:
        previous = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, ValueError):
        previous = {}

# The date from which plan docs must carry a Status/Category/Summary header.
# Set once, the first time a scaffold version with that convention lands, and
# kept on every later update so older docs are never retroactively failed.
headers_since = previous.get("plan_doc_headers_since") or datetime.date.today().isoformat()

path.write_text(
    json.dumps(
        {
            "version": version,
            "scaffold_version": version,
            "updated_at_utc": datetime.datetime.now(datetime.timezone.utc).isoformat(),
            "source_kind": "agent-governance-scaffold",
            "source_path": source_path,
            "source_repo_commit": source_commit or None,
            "plan_doc_headers_since": headers_since,
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
  ensure_gitignore_lines

  copy_managed_file "$TEMPLATE_DIR/AGENTS.md" "$TARGET_DIR/AGENTS.md"
  copy_managed_file "$TEMPLATE_DIR/CLAUDE.md" "$TARGET_DIR/CLAUDE.md"
  copy_managed_file "$TEMPLATE_DIR/.codex/PROJECT_RULES.md" "$TARGET_DIR/.codex/PROJECT_RULES.md"

  # .cursor/rules, .codex/rules, and rulesets/ are generated from
  # .claude/rules by sync-agent-rules.sh below.
  local src
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
  copy_if_missing "$TEMPLATE_DIR/plans/legacy-plans.md" "$TARGET_DIR/plans/legacy-plans.md"
  copy_if_missing "$TEMPLATE_DIR/plans/IDEAS.md" "$TARGET_DIR/plans/IDEAS.md"

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
