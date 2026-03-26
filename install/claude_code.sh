#!/bin/bash
# Install Claude Code

set -euo pipefail

DOT_PATH=$(cd $(dirname $0)/../; pwd)

# Install Claude Code CLI
curl -fsSL https://claude.ai/install.sh | bash

# Create ~/.claude directory if it doesn't exist
mkdir -p "${HOME}/.claude"

# Create and merge settings.json if it doesn't exist, or merge with existing settings.
#
# Note: Not symlink settings.json directly to avoid confusing another settings on updates. Instead, we merge
# 
# Note: Using claude-user/ instead of .claude/ to avoid confusion with
# project-level .claude/ directory when working on the dotfiles repository
#
SETTINGS="${HOME}/.claude/settings.json"
if [ ! -f "${SETTINGS}" ]; then
  echo '{}' > "${SETTINGS}"
fi
jq -s '.[0] * .[1]' "${SETTINGS}" "${DOT_PATH}/claude-user/settings.json" > "${SETTINGS}.tmp" && mv "${SETTINGS}.tmp" "${SETTINGS}"
echo "Merged settings into ${SETTINGS}"

# Symlink only configuration files (not runtime data)
# This allows Claude Code to create cache, debug, etc. in ~/.claude
# while keeping only settings under version control
#
if [ -f "${DOT_PATH}/claude-user/settings.json" ]; then
  ln -sf "${DOT_PATH}/claude-user/settings.json" "${HOME}/.claude/settings.json"
  echo "Linked settings.json"
fi

if [ -f "${DOT_PATH}/claude-user/CLAUDE.md" ]; then
  ln -sf "${DOT_PATH}/claude-user/CLAUDE.md" "${HOME}/.claude/CLAUDE.md"
  echo "Linked CLAUDE.md"
fi

link_dir_files() {
  local src="$1"
  local dst="$2"
  mkdir -p "$dst"
  [ -d "$src" ] || return 0
  find "$src" -type f | while read -r file; do
    local rel="${file#${src}/}"
    local dst_file="${dst}/${rel}"
    mkdir -p "$(dirname "$dst_file")"
    ln -sf "$file" "$dst_file"
    echo "Linked ${rel}"
  done
}

link_dir_files "${DOT_PATH}/claude-user/agents" "${HOME}/.claude/agents"
link_dir_files "${DOT_PATH}/claude-user/rules" "${HOME}/.claude/rules"
link_dir_files "${DOT_PATH}/claude-user/skills" "${HOME}/.claude/skills"

echo "Claude Code configuration linked successfully"
