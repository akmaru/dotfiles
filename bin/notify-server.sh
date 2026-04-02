#!/bin/bash
# ~/bin/notify-server.sh

PORT=9999

while true; do
  DATA=$(nc -l $PORT 2>/dev/null)
  [ -z "$DATA" ] && continue

  MESSAGE=$(echo "$DATA" | cut -d'|' -f1)
  TITLE=$(echo "$DATA"   | cut -d'|' -f2)
  TAB_INDEX=$(echo "$DATA" | cut -d'|' -f3)

  if [ -n "$TAB_INDEX" ]; then
    EXECUTE_CMD="$HOME/bin/iterm-jump.sh $TAB_INDEX"
  else
    EXECUTE_CMD="osascript -e 'tell application \"iTerm2\" to activate'"
  fi

  terminal-notifier \
    -title "${TITLE:-Claude}" \
    -message "${MESSAGE:-通知}" \
    -sound default \
    -execute "$EXECUTE_CMD"
done
