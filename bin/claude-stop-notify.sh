#!/bin/bash
# Stop hook: extract last assistant text from transcript and notify

INPUT=$(cat)
TP=$(echo "$INPUT" | jq -r '.transcript_path // empty')
MSG="Task completed"

if [ -n "$TP" ] && [ -f "$TP" ]; then
  LAST=$(jq -r 'select(.message.role == "assistant") | .message.content[]? | select(.type == "text") | .text' "$TP" 2>/dev/null | tail -1 | head -c 100)
  [ -n "$LAST" ] && MSG="$LAST"
fi

claude-notify.sh "$MSG" 'Claude'
