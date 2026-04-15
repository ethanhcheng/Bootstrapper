#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
EMBEDDED_SKILL_DIR="$REPO_ROOT/skills/agent-governance-scaffold"
TEMPLATE_DIR="$EMBEDDED_SKILL_DIR/assets/templates"
LOCAL_SKILL_DIR="${CODEX_HOME:-$HOME/.codex}/skills/agent-governance-scaffold"
TARGET_DIR=""
STATUS=0

usage() {
  cat <<'EOF'
Usage:
  scripts/check-bootstrapper-alignment.sh [--target /path/to/repo]
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --target)
      TARGET_DIR="${2:-}"
      if [[ -z "$TARGET_DIR" ]]; then
        usage >&2
        exit 2
      fi
      shift 2
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      usage >&2
      exit 2
      ;;
  esac
done

if [[ ! -f "$EMBEDDED_SKILL_DIR/SKILL.md" ]]; then
  echo "Missing embedded skill: $EMBEDDED_SKILL_DIR" >&2
  exit 1
fi

report_ok() {
  printf 'OK: %s\n' "$1"
}

report_drift() {
  printf 'DRIFT: %s\n' "$1" >&2
  STATUS=1
}

compare_exact() {
  local label="$1"
  local src="$2"
  local dest="$3"

  if [[ ! -f "$src" ]]; then
    report_drift "$label missing source file $src"
    return
  fi

  if [[ ! -f "$dest" ]]; then
    report_drift "$label missing target file $dest"
    return
  fi

  if ! cmp -s "$src" "$dest"; then
    report_drift "$label differs: $dest"
  fi
}

check_gitignore_lines() {
  local label="$1"
  local src="$2"
  local dest="$3"
  local line

  if [[ ! -f "$dest" ]]; then
    report_drift "$label missing target file $dest"
    return
  fi

  while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    if ! grep -qxF "$line" "$dest"; then
      report_drift "$label missing .gitignore line '$line' in $dest"
    fi
  done < "$src"
}

run_check() {
  local label="$1"
  shift
  local output=""

  if ! output="$("$@" 2>&1)"; then
    report_drift "$label failed"
    if [[ -n "$output" ]]; then
      printf '%s\n' "$output" >&2
    fi
    return
  fi

  report_ok "$label"
}

check_shared_scaffold() {
  local label="$1"
  local base_dir="$2"
  local include_gitignore="$3"
  local include_ideas="$4"
  local src

  compare_exact "$label" "$TEMPLATE_DIR/AGENTS.md" "$base_dir/AGENTS.md"
  compare_exact "$label" "$TEMPLATE_DIR/CLAUDE.md" "$base_dir/CLAUDE.md"
  compare_exact "$label" "$TEMPLATE_DIR/.codex/PROJECT_RULES.md" "$base_dir/.codex/PROJECT_RULES.md"
  compare_exact "$label" "$TEMPLATE_DIR/plans/README.md" "$base_dir/plans/README.md"
  compare_exact "$label" "$TEMPLATE_DIR/plans/IMPLEMENTATION_TEMPLATE.md" "$base_dir/plans/IMPLEMENTATION_TEMPLATE.md"
  compare_exact "$label" "$TEMPLATE_DIR/plans/legacy-plans.md" "$base_dir/plans/legacy-plans.md"

  if [[ "$include_gitignore" == "1" ]]; then
    compare_exact "$label" "$TEMPLATE_DIR/.gitignore" "$base_dir/.gitignore"
  else
    check_gitignore_lines "$label" "$TEMPLATE_DIR/.gitignore" "$base_dir/.gitignore"
  fi

  if [[ "$include_ideas" == "1" ]]; then
    compare_exact "$label" "$TEMPLATE_DIR/plans/IDEAS.md" "$base_dir/plans/IDEAS.md"
  fi

  for src in "$TEMPLATE_DIR/.cursor/rules/"*; do
    compare_exact "$label" "$src" "$base_dir/.cursor/rules/$(basename "$src")"
  done

  for src in "$TEMPLATE_DIR/.claude/rules/"*; do
    compare_exact "$label" "$src" "$base_dir/.claude/rules/$(basename "$src")"
  done

  for src in "$TEMPLATE_DIR/scripts/"*; do
    compare_exact "$label" "$src" "$base_dir/scripts/$(basename "$src")"
  done

  run_check "$label sync-agent-rules" "$base_dir/scripts/sync-agent-rules.sh" --check
  run_check "$label verify-plans-workflow" "$base_dir/scripts/verify-plans-workflow.sh"
}

check_tree_alignment() {
  local label="$1"
  local left="$2"
  local right="$3"
  local diff_output=""

  if [[ ! -d "$right" ]]; then
    report_drift "$label missing directory $right"
    return
  fi

  if ! diff_output="$(diff -qr "$left" "$right" 2>&1)"; then
    report_drift "$label differs"
    printf '%s\n' "$diff_output" >&2
    return
  fi

  report_ok "$label"
}

printf 'Embedded skill: %s\n' "$EMBEDDED_SKILL_DIR"

check_shared_scaffold "repo-root" "$REPO_ROOT" "1" "1"
check_tree_alignment "local-codex-skill" "$EMBEDDED_SKILL_DIR" "$LOCAL_SKILL_DIR"

if [[ -n "$TARGET_DIR" ]]; then
  TARGET_DIR="$(cd "$TARGET_DIR" && pwd)"
  printf 'Target repo: %s\n' "$TARGET_DIR"
  if ! "$REPO_ROOT/scripts/bootstrap_agent_governance.sh" --check-updates "$TARGET_DIR" >/tmp/bootstrapper-target-check.$$ 2>&1; then
    report_drift "target scaffold version check failed for $TARGET_DIR"
    cat /tmp/bootstrapper-target-check.$$ >&2
  else
    report_ok "target scaffold version check"
  fi
  rm -f /tmp/bootstrapper-target-check.$$
  check_shared_scaffold "target-repo" "$TARGET_DIR" "0" "0"
fi

if [[ $STATUS -eq 0 ]]; then
  printf 'Alignment OK.\n'
else
  exit 1
fi
