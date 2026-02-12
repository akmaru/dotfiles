#!/usr/bin/env bash
#
# sync-mcp.sh - Sync MCP configuration across all tools
#
# Usage:
#   1. Edit ~/.config/mcp/master-mcp.json (master config)
#   2. Run ./sync-mcp.sh
#   3. Restart each tool
#
# Supported tools:
#   - Claude Code (user scope: ~/.claude.json)
#   - VS Code / GitHub Copilot (user scope: mcp.json)
#   - GitLab Duo (user scope: ~/.gitlab/duo/mcp.json)
#
set -euo pipefail

# ============================================================
# Configuration
# ============================================================

MASTER_CONFIG="${HOME}/.config/mcp/master-mcp.json"

# Claude Code: mcpServers key in ~/.claude.json
CLAUDE_CODE_CONFIG="${HOME}/.claude.json"

# VS Code: user-level mcp.json
# macOS:  ~/Library/Application Support/Code/User/mcp.json
# Linux:  ~/.config/Code/User/mcp.json
# Windows (WSL): adjust accordingly
if [[ "$(uname)" == "Darwin" ]]; then
    VSCODE_MCP_CONFIG="${HOME}/Library/Application Support/Code/User/mcp.json"
else
    VSCODE_MCP_CONFIG="${HOME}/.config/Code/User/mcp.json"
fi

# GitLab Duo: ~/.gitlab/duo/mcp.json
GITLAB_DUO_CONFIG="${HOME}/.gitlab/duo/mcp.json"

# ============================================================
# Utilities
# ============================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info()  { echo -e "${BLUE}[INFO]${NC}  $1"; }
log_ok()    { echo -e "${GREEN}[OK]${NC}    $1"; }
log_warn()  { echo -e "${YELLOW}[WARN]${NC}  $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

check_jq() {
    if ! command -v jq &> /dev/null; then
        log_error "jq not found. Please install it:"
        echo "  macOS:  brew install jq"
        echo "  Ubuntu: sudo apt install jq"
        exit 1
    fi
}

backup_file() {
    local file="$1"
    if [[ -f "$file" ]]; then
        cp "$file" "${file}.bak.$(date +%Y%m%d_%H%M%S)"
        log_info "Backed up: ${file}.bak.*"
    fi
}

ensure_dir() {
    local dir
    dir=$(dirname "$1")
    mkdir -p "$dir"
}

# Extract server definitions from master config, stripping _comment fields
get_servers() {
    jq 'del(.["$schema"], ._comment) | .servers | to_entries | map(.value |= del(._comment)) | from_entries' "$MASTER_CONFIG"
}

# ============================================================
# Claude Code
# ============================================================

sync_claude_code() {
    log_info "Syncing to Claude Code..."

    local servers
    servers=$(get_servers)

    ensure_dir "$CLAUDE_CODE_CONFIG"

    if [[ -f "$CLAUDE_CODE_CONFIG" ]]; then
        backup_file "$CLAUDE_CODE_CONFIG"
        # Merge mcpServers into existing .claude.json (preserves other keys)
        local tmp
        tmp=$(mktemp)
        jq --argjson servers "$servers" '.mcpServers = $servers' "$CLAUDE_CODE_CONFIG" > "$tmp"
        mv "$tmp" "$CLAUDE_CODE_CONFIG"
    else
        # Create new file
        jq -n --argjson servers "$servers" '{"mcpServers": $servers}' > "$CLAUDE_CODE_CONFIG"
    fi

    log_ok "Claude Code: $CLAUDE_CODE_CONFIG"
}

# ============================================================
# VS Code / GitHub Copilot
# ============================================================

sync_vscode() {
    log_info "Syncing to VS Code (GitHub Copilot)..."

    local servers
    servers=$(get_servers)

    ensure_dir "$VSCODE_MCP_CONFIG"

    # VS Code uses the "servers" key (not "mcpServers")
    if [[ -f "$VSCODE_MCP_CONFIG" ]]; then
        backup_file "$VSCODE_MCP_CONFIG"
        local tmp
        tmp=$(mktemp)
        jq --argjson servers "$servers" '.servers = $servers' "$VSCODE_MCP_CONFIG" > "$tmp"
        mv "$tmp" "$VSCODE_MCP_CONFIG"
    else
        jq -n --argjson servers "$servers" '{"servers": $servers}' > "$VSCODE_MCP_CONFIG"
    fi

    log_ok "VS Code:     $VSCODE_MCP_CONFIG"
}

# ============================================================
# GitLab Duo
# ============================================================

sync_gitlab_duo() {
    log_info "Syncing to GitLab Duo..."

    local servers
    servers=$(get_servers)

    ensure_dir "$GITLAB_DUO_CONFIG"
    backup_file "$GITLAB_DUO_CONFIG"

    # GitLab Duo uses the "mcpServers" key
    jq -n --argjson servers "$servers" '{"mcpServers": $servers}' > "$GITLAB_DUO_CONFIG"

    log_ok "GitLab Duo:  $GITLAB_DUO_CONFIG"
}

# ============================================================
# Project-level sync (optional)
# ============================================================

sync_project() {
    local project_dir="$1"

    if [[ ! -d "$project_dir" ]]; then
        log_error "Directory does not exist: $project_dir"
        return 1
    fi

    log_info "Syncing project-level config: $project_dir"

    local servers
    servers=$(get_servers)

    # Claude Code: <project>/.mcp.json
    jq -n --argjson servers "$servers" '{"mcpServers": $servers}' \
        > "${project_dir}/.mcp.json"
    log_ok "  Claude Code:  ${project_dir}/.mcp.json"

    # VS Code: <project>/.vscode/mcp.json
    mkdir -p "${project_dir}/.vscode"
    jq -n --argjson servers "$servers" '{"servers": $servers}' \
        > "${project_dir}/.vscode/mcp.json"
    log_ok "  VS Code:      ${project_dir}/.vscode/mcp.json"

    # GitLab Duo: <project>/.gitlab/duo/mcp.json
    mkdir -p "${project_dir}/.gitlab/duo"
    jq -n --argjson servers "$servers" '{"mcpServers": $servers}' \
        > "${project_dir}/.gitlab/duo/mcp.json"
    log_ok "  GitLab Duo:   ${project_dir}/.gitlab/duo/mcp.json"
}

# ============================================================
# Main
# ============================================================

main() {
    echo ""
    echo "========================================"
    echo "  MCP Config Sync Tool"
    echo "========================================"
    echo ""

    check_jq

    # Check master config exists
    if [[ ! -f "$MASTER_CONFIG" ]]; then
        log_error "Master config not found: $MASTER_CONFIG"
        log_info "First run: creating master config template"
        ensure_dir "$MASTER_CONFIG"
        cat > "$MASTER_CONFIG" << 'TEMPLATE'
{
  "_comment": "MCP master configuration - edit this file and run sync-mcp.sh to propagate",
  "servers": {
    "GitLab": {
      "type": "http",
      "url": "https://gitlab.com/api/v4/mcp"
    },
    "memory": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-memory"]
    }
  }
}
TEMPLATE
        log_ok "Template created: $MASTER_CONFIG"
        log_info "Edit the config and run again"
        exit 0
    fi

    # Validate JSON
    if ! jq empty "$MASTER_CONFIG" 2>/dev/null; then
        log_error "Invalid JSON in master config: $MASTER_CONFIG"
        exit 1
    fi

    local server_count
    server_count=$(jq '.servers | length' "$MASTER_CONFIG")
    log_info "Master config: ${server_count} server(s) found"
    echo ""

    # User-level sync
    case "${1:-all}" in
        all)
            sync_claude_code
            sync_vscode
            sync_gitlab_duo
            ;;
        claude)
            sync_claude_code
            ;;
        vscode)
            sync_vscode
            ;;
        gitlab)
            sync_gitlab_duo
            ;;
        project)
            if [[ -z "${2:-}" ]]; then
                log_error "Please specify a project path: $0 project /path/to/project"
                exit 1
            fi
            sync_project "$2"
            ;;
        *)
            echo "Usage: $0 [all|claude|vscode|gitlab|project <path>]"
            exit 1
            ;;
    esac

    echo ""
    log_ok "Sync complete! Restart each tool to apply changes."
    echo ""
    echo "  Verify with:"
    echo "    Claude Code:  claude mcp list"
    echo "    VS Code:      Command Palette > MCP: List Servers"
    echo "    GitLab Duo:   Command Palette > GitLab: Show MCP Dashboard"
    echo ""
}

main "$@"
