# MCP Config Sync Tool

Centrally manage MCP server configuration across Claude Code, VS Code (GitHub Copilot), and GitLab Duo.

## How It Works

```
~/.config/mcp/master-mcp.json   ← ★ Single source of truth
         │
         ├──→ ~/.claude.json                     (Claude Code user config)
         ├──→ ~/Library/.../Code/User/mcp.json   (VS Code user config)
         └──→ ~/.gitlab/duo/mcp.json             (GitLab Duo user config)
```

Each tool uses a slightly different JSON format. The script handles the conversion automatically:

| Tool              | Root Key     | Config File Location                       |
| ----------------- | ------------ | ------------------------------------------ |
| Claude Code       | `mcpServers` | `~/.claude.json`                           |
| VS Code / Copilot | `servers`    | `~/Library/.../Code/User/mcp.json` (macOS) |
| GitLab Duo        | `mcpServers` | `~/.gitlab/duo/mcp.json`                   |

## Setup

### 1. Prerequisites

```bash
# jq is required
brew install jq        # macOS
# sudo apt install jq  # Ubuntu
```

### 2. Install

```bash
# Place the script
mkdir -p ~/.config/mcp
cp sync-mcp.sh ~/.config/mcp/
chmod +x ~/.config/mcp/sync-mcp.sh

# Optional: add an alias
echo 'alias mcp-sync="~/.config/mcp/sync-mcp.sh"' >> ~/.bashrc
# or ~/.zshrc
```

### 3. Edit the Master Config

```bash
# First run creates a template automatically
~/.config/mcp/sync-mcp.sh

# Edit the master config
$EDITOR ~/.config/mcp/master-mcp.json
```

### 4. Sync

```bash
# Sync to all tools
mcp-sync all

# Sync individually
mcp-sync claude    # Claude Code only
mcp-sync vscode    # VS Code only
mcp-sync gitlab    # GitLab Duo only

# Sync to a specific project (generates project-level configs)
mcp-sync project ~/projects/my-app
```

## Master Config Format

```json
{
  "servers": {
    "GitLab": {
      "type": "http",
      "url": "https://gitlab.com/api/v4/mcp",
      "_comment": "Comments are stripped during sync"
    },
    "memory": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-memory"],
      "env": {
        "MEMORY_FILE": "/Users/you/.config/mcp/shared-memory.json"
      }
    },
    "github": {
      "type": "http",
      "url": "https://api.githubcopilot.com/mcp",
      "headers": {
        "Authorization": "Bearer YOUR_GITHUB_PAT"
      }
    },
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "/Users/you/projects"]
    }
  }
}
```

### Server Definition Formats

**HTTP transport (remote servers):**
```json
{
  "type": "http",
  "url": "https://example.com/mcp",
  "headers": { "Authorization": "Bearer TOKEN" }
}
```

**stdio transport (local servers):**
```json
{
  "command": "npx",
  "args": ["-y", "package-name"],
  "env": { "API_KEY": "value" }
}
```

## Notes

- **Backups**: Existing config files are automatically backed up before overwriting (`.bak.TIMESTAMP`)
- **Merge behavior**: For Claude Code's `~/.claude.json`, only the `mcpServers` key is overwritten; other keys (theme, etc.) are preserved
- **Authentication**: GitLab MCP Server triggers OAuth in the browser on first connection. This is required once per tool.
- **Restart required**: Restart each tool after syncing for changes to take effect
- **VS Code paths**: Paths differ between Linux/macOS/Windows. The script auto-detects macOS and Linux. For WSL, adjust `VSCODE_MCP_CONFIG` in the script.

## Project-Level Sync and .gitignore

When syncing to a project, be careful not to commit configs containing secrets:

```gitignore
# MCP configs (may contain secrets)
.mcp.json
.vscode/mcp.json
.gitlab/duo/mcp.json
```

To share configs with your team without exposing secrets, use environment variables:

```json
{
  "servers": {
    "github": {
      "type": "http",
      "url": "https://api.githubcopilot.com/mcp",
      "headers": {
        "Authorization": "Bearer ${GITHUB_TOKEN}"
      }
    }
  }
}
```

> **Note**: Environment variable expansion (`${VAR}`) is supported by Claude Code and VS Code.
> Support in GitLab Duo may vary — check the latest docs.
