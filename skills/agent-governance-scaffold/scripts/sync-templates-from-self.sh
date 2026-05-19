#!/usr/bin/env bash
# Sync root governance files into assets/templates/ so the scaffold
# templates always match what the skill installs into target repos.
#
# Usage:
#   scripts/sync-templates-from-self.sh           # write templates
#   scripts/sync-templates-from-self.sh --check   # fail on drift
#
# Deliberately excluded:
#   - plans/INDEX.md, plans/IDEAS.md, plans/YYYY-MM.md, plans/YYYY-MM-DD-*.md
#     (project-specific content; template versions must keep their
#     placeholder shape so newly scaffolded repos get a clean slate)
#   - .agent-governance-manifest.json (regenerated per install)
#   - projectbootstrapper.txt (generated inline by bootstrap with
#     install-time path substitutions; the template copy is decorative
#     and never consulted during install)
#   - SKILL.md, agents/, assets/, scripts/bootstrap_agent_governance.sh,
#     scripts/sync-templates-from-self.sh (skill-only machinery)

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEMPLATES_DIR="$ROOT_DIR/assets/templates"
CHECK_ONLY=0

if [[ "${1:-}" == "--check" ]]; then
  CHECK_ONLY=1
elif [[ "${1:-}" != "" ]]; then
  echo "Usage: scripts/sync-templates-from-self.sh [--check]" >&2
  exit 2
fi

# Paths whose root copy is the source-of-truth for the template copy.
# Each path is relative to ROOT_DIR; template lives at $TEMPLATES_DIR/<same path>.
SYNCED_PATHS=(
  "AGENTS.md"
  "CLAUDE.md"
  "README.md"
  "BOOTSTRAPPER_SPEC.md"
  ".gitignore"
  ".codex/PROJECT_RULES.md"
  ".cursor/rules/code-review.mdc"
  ".cursor/rules/development-workflow.mdc"
  ".cursor/rules/python-standards.mdc"
  ".cursor/rules/sandbox-permissions.mdc"
  ".cursor/rules/tech-stack.mdc"
  ".claude/rules/code-review.md"
  ".claude/rules/development-workflow.md"
  ".claude/rules/python-standards.md"
  ".claude/rules/sandbox-permissions.md"
  ".claude/rules/tech-stack.md"
  "plans/README.md"
  "plans/IMPLEMENTATION_TEMPLATE.md"
  "plans/legacy-plans.md"
  "scripts/sync-agent-rules.sh"
  "scripts/create-implementation-doc.sh"
  "scripts/verify-plans-workflow.sh"
)

status=0
for rel in "${SYNCED_PATHS[@]}"; do
  src="$ROOT_DIR/$rel"
  dst="$TEMPLATES_DIR/$rel"
  if [[ ! -f "$src" ]]; then
    echo "Missing source: $rel" >&2
    status=1
    continue
  fi
  if [[ $CHECK_ONLY -eq 1 ]]; then
    if [[ ! -f "$dst" ]]; then
      echo "Drift: template missing $rel" >&2
      status=1
    elif ! cmp -s "$src" "$dst"; then
      echo "Drift: template differs from root: $rel" >&2
      status=1
    fi
  else
    mkdir -p "$(dirname "$dst")"
    cp -p "$src" "$dst"
  fi
done

if [[ $status -ne 0 ]]; then
  exit 1
fi

if [[ $CHECK_ONLY -eq 1 ]]; then
  echo "Templates match root governance files."
else
  echo "Templates synced from root governance files."
fi
