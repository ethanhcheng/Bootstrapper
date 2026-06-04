#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOURCE_DIR="$REPO_ROOT/skills/agent-governance-scaffold"
DEST_BASE="${CODEX_HOME:-$HOME/.codex}/skills"
DEST_DIR="$DEST_BASE/agent-governance-scaffold"

if [[ ! -f "$SOURCE_DIR/SKILL.md" ]]; then
  echo "Missing embedded skill source: $SOURCE_DIR" >&2
  exit 1
fi

mkdir -p "$DEST_DIR"
rsync -a --delete --exclude '__pycache__/' "$SOURCE_DIR/" "$DEST_DIR/"

if ! diff -qr "$SOURCE_DIR" "$DEST_DIR" >/tmp/bootstrapper-local-skill-diff.$$ 2>&1; then
  cat /tmp/bootstrapper-local-skill-diff.$$ >&2
  rm -f /tmp/bootstrapper-local-skill-diff.$$
  echo "Local Codex skill update did not converge." >&2
  exit 1
fi

rm -f /tmp/bootstrapper-local-skill-diff.$$
echo "Updated local Codex skill: $DEST_DIR"

# Sync into Claude Code's user skills directory (subdirectory format required for slash commands)
CLAUDE_SKILLS_DIR="${CLAUDE_HOME:-$HOME/.claude}/skills/agent-governance-scaffold"
mkdir -p "$CLAUDE_SKILLS_DIR"
cp "$SOURCE_DIR/SKILL.md" "$CLAUDE_SKILLS_DIR/SKILL.md"
# Remove legacy flat-file install if present
rm -f "${CLAUDE_HOME:-$HOME/.claude}/skills/agent-governance-scaffold.md"
echo "Updated local Claude skill: $CLAUDE_SKILLS_DIR/SKILL.md"
