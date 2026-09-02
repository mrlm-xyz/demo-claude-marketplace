#!/usr/bin/env bash
# PreToolUse hook (matcher: Bash).
# Belt-and-suspenders on top of the settings.json deny-list: block a couple of
# irreversible commands outright and log every shell command for the audit trail.
# Exit 2 blocks the tool call and returns the reason to Claude.
set -euo pipefail

cmd="$(cat - | python3 -c 'import sys,json; print(json.load(sys.stdin).get("tool_input",{}).get("command",""))' 2>/dev/null || true)"

log="${CLAUDE_PROJECT_DIR:-.}/.claude/command-audit.log"
printf '%s\n' "$cmd" >> "$log" 2>/dev/null || true

case "$cmd" in
  *"git push"*"--force"*|*"terraform destroy"*|*"rm -rf /"*)
    echo "guard: refused irreversible command. If you truly mean it, a human runs it outside the agent." >&2
    exit 2
    ;;
esac
exit 0
