#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

usage() {
  cat <<'EOF'
Usage:
  scripts/apply-bootstrapper-to-target.sh [--force-spec] [TARGET_DIR]

Compatibility wrapper around `scripts/bootstrap_agent_governance.sh`.

Behavior:
  - Applies this repo's governance scaffold into an existing folder.
  - TARGET_DIR may already contain files and does not need to be a git repository.
  - Existing repo-owned docs are preserved unless --force-spec is used.
EOF
}

for arg in "$@"; do
  case "$arg" in
    --help|-h)
      usage
      exit 0
      ;;
  esac
done

exec "$REPO_ROOT/scripts/bootstrap_agent_governance.sh" "$@"
