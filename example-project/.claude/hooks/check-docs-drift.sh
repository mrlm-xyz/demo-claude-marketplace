#!/usr/bin/env bash
# PostToolUse hook (matcher: Edit|Write).
# docs-as-code enforcement: if the API contract changed but the architecture
# doc was not touched to match, surface a reminder. Exit 2 sends the message
# back to Claude as feedback so the drift cannot be quietly ignored.
#
# This is illustrative. A real check would diff semantic content, not mtimes.
set -euo pipefail

SPEC="api/openapi.yaml"
DOC="docs/architecture.md"

# The changed file path is passed by Claude Code as tool_input.file_path on stdin.
changed="$(cat - | python3 -c 'import sys,json; print(json.load(sys.stdin).get("tool_input",{}).get("file_path",""))' 2>/dev/null || true)"

case "$changed" in
  *"$SPEC")
    if [ -f "$DOC" ] && [ "$SPEC" -nt "$DOC" ]; then
      echo "docs-drift: $SPEC changed but $DOC is older. Update the architecture doc in the same change so the docs cannot rot." >&2
      exit 2
    fi
    ;;
esac
exit 0
