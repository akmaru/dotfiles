#!/bin/bash
# ~/bin/iterm-jump.sh

TAB_INDEX="${1:-1}"

osascript <<EOF
tell application "iTerm2"
  activate
  tell window 1
    select tab $TAB_INDEX
  end tell
end tell
EOF
