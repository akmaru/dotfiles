#!/bin/bash
# Install Claude Code

set -euo pipefail

DOT_PATH=$(cd $(dirname $0)/../; pwd)

# Install Claude Code CLI
curl -fsSL https://claude.ai/install.sh | bash

# Create ~/.claude directory if it doesn't exist
mkdir -p "${HOME}/.claude"

# Symlink only configuration files (not runtime data)
# This allows Claude Code to create cache, debug, etc. in ~/.claude
# while keeping only settings under version control
#
# Note: Using claude-user/ instead of .claude/ to avoid confusion with
# project-level .claude/ directory when working on the dotfiles repository

if [ -f "${DOT_PATH}/claude-user/settings.json" ]; then
  ln -sf "${DOT_PATH}/claude-user/settings.json" "${HOME}/.claude/settings.json"
  echo "Linked settings.json"
fi

if [ -f "${DOT_PATH}/claude-user/CLAUDE.md" ]; then
  ln -sf "${DOT_PATH}/claude-user/CLAUDE.md" "${HOME}/.claude/CLAUDE.md"
  echo "Linked CLAUDE.md"
fi

if [ -d "${DOT_PATH}/claude-user/agents" ]; then
  ln -sf "${DOT_PATH}/claude-user/agents" "${HOME}/.claude/agents"
  echo "Linked agents/"
fi

if [ -d "${DOT_PATH}/claude-user/rules" ]; then
  ln -sf "${DOT_PATH}/claude-user/rules" "${HOME}/.claude/rules"
  echo "Linked rules/"
fi

echo "Claude Code configuration linked successfully"
