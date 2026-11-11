#!/usr/bin/env bash
# Create plans/YYYY-MM-DD-short-name.md from the template. Nothing else is
# edited: the doc's own header is its index entry.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PLANS_DIR="$ROOT_DIR/plans"
TEMPLATE_PATH="$PLANS_DIR/IMPLEMENTATION_TEMPLATE.md"

usage() {
  cat <<'USAGE'
Usage:
  scripts/create-implementation-doc.sh [YYYY-MM-DD] short-name

Creates plans/YYYY-MM-DD-short-name.md from plans/IMPLEMENTATION_TEMPLATE.md.
The date defaults to today.
USAGE
}

case $# in
  1)
    DOC_DATE="$(date +%Y-%m-%d)"
    DOC_SLUG="$1"
    ;;
  2)
    DOC_DATE="$1"
    DOC_SLUG="$2"
    ;;
  *)
    usage >&2
    exit 2
    ;;
esac

if [[ ! "$DOC_DATE" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
  echo "Date must be YYYY-MM-DD: $DOC_DATE" >&2
  exit 1
fi

if [[ ! "$DOC_SLUG" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]]; then
  echo "short-name must be lowercase kebab-case: $DOC_SLUG" >&2
  exit 1
fi

if [[ ! -f "$TEMPLATE_PATH" ]]; then
  echo "Missing template: $TEMPLATE_PATH" >&2
  exit 1
fi

DOC_PATH="$PLANS_DIR/$DOC_DATE-$DOC_SLUG.md"
if [[ -e "$DOC_PATH" ]]; then
  echo "Plan doc already exists: $DOC_PATH" >&2
  exit 1
fi

sed "s/YYYY-MM-DD/$DOC_DATE/g; s/feature-name/$DOC_SLUG/g" "$TEMPLATE_PATH" > "$DOC_PATH"

echo "Created $DOC_PATH"
echo "Write its Summary line now; scripts/verify-plans-workflow.sh rejects the placeholder."
