#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
EMBEDDED_SCRIPT="$REPO_ROOT/skills/agent-governance-scaffold/scripts/bootstrap_agent_governance.sh"

if [[ ! -x "$EMBEDDED_SCRIPT" ]]; then
  echo "Missing embedded bootstrap script: $EMBEDDED_SCRIPT" >&2
  exit 1
fi

exec "$EMBEDDED_SCRIPT" "$@"
