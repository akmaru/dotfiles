#!/bin/bash
# ~/bin/claude-notify.sh

MESSAGE="${1:-通知}"
TITLE="${2:-Claude}"

# tmux内かどうか判定してタブインデックスを取得
if [ -n "$TMUX" ]; then
  TAB_INDEX=$(tmux display-message -p '#I')
else
  TAB_INDEX=""
fi

# ローカル/リモートの判定
if [ -z "$SSH_CLIENT" ] && [ -z "$SSH_TTY" ]; then
  # ローカル
  if [ -n "$TAB_INDEX" ]; then
    EXECUTE_CMD="$HOME/.local/bin/iterm-jump.sh $TAB_INDEX"
  else
    EXECUTE_CMD="osascript -e 'tell application \"iTerm2\" to activate'"
  fi
  terminal-notifier \
    -title "$TITLE" \
    -message "$MESSAGE" \
    -sound default \
    -execute "$EXECUTE_CMD"
else
  # リモート → トンネル経由
  echo "${MESSAGE}|${TITLE}|${TAB_INDEX}" | nc -q1 localhost 9999 2>/dev/null || true
fi
