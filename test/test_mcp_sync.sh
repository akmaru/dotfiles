#!/usr/bin/env bash
#
# test_mcp_sync.sh - Test MCP configuration sync script
#
set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "=========================================="
echo "  MCP Sync Script Tests"
echo "=========================================="
echo ""

# Create isolated test environment
TEST_HOME=$(mktemp -d)
export HOME="${TEST_HOME}"
export XDG_CONFIG_HOME="${TEST_HOME}/.config"
MASTER_CONFIG="${XDG_CONFIG_HOME}/mcp/master-mcp.json"
MASTER_CONFIG_DIR="${XDG_CONFIG_HOME}/mcp/master-mcp.d"

echo "Test environment: ${TEST_HOME}"
echo ""

cleanup() {
    if [[ -n "${TEST_HOME:-}" ]] && [[ -d "${TEST_HOME}" ]]; then
        rm -rf "${TEST_HOME}"
        echo ""
        echo "Test environment cleaned up"
    fi
}

# Cleanup on exit
trap cleanup EXIT

test_result=0

fail() {
    echo -e "${RED}✗ FAIL:${NC} $1"
    test_result=1
}

pass() {
    echo -e "${GREEN}✓ PASS:${NC} $1"
}

# Test 1: Check jq is installed
echo "Test 1: Check jq is available"
if command -v jq &> /dev/null; then
    pass "jq is installed"
else
    fail "jq is not installed"
    exit 1
fi

# Test 2: Check sync-mcp.sh exists
echo ""
echo "Test 2: Check sync-mcp.sh exists"
if [[ -x "./mcp/sync-mcp.sh" ]]; then
    pass "sync-mcp.sh exists and is executable"
else
    fail "sync-mcp.sh not found or not executable"
    exit 1
fi

# Test 3: Create test master config
echo ""
echo "Test 3: Create test master config"
mkdir -p "${XDG_CONFIG_HOME}/mcp"
cat > "${MASTER_CONFIG}" <<'EOF'
{
  "servers": {
    "memory": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-memory"],
      "env": {
        "MEMORY_FILE": "${HOME}/.config/mcp/shared-memory.json"
      }
    },
    "test-server": {
      "command": "echo",
      "args": ["test"]
    }
  }
}
EOF

if [[ -f "${MASTER_CONFIG}" ]]; then
    pass "Test master config created"
else
    fail "Failed to create test master config"
    exit 1
fi

# Test 4: Test basic sync
echo ""
echo "Test 4: Test basic sync to Claude Code"
./mcp/sync-mcp.sh claude 2>/dev/null

if [[ -f "${HOME}/.claude.json" ]]; then
    pass "Claude Code config created"
else
    fail "Claude Code config not created"
    exit 1
fi

# Test 5: Verify command path resolution
echo ""
echo "Test 5: Verify command path resolution"
resolved_cmd=$(jq -r '.mcpServers."test-server".command' "${HOME}/.claude.json")
if [[ "$resolved_cmd" == "/bin/echo" || "$resolved_cmd" == "/usr/bin/echo" ]]; then
    pass "Command path resolved correctly: $resolved_cmd"
else
    fail "Command path not resolved: $resolved_cmd"
fi

# Test 6: Verify PATH injection
echo ""
echo "Test 6: Verify PATH injection"
if jq -e '.mcpServers."test-server".env.PATH' "${HOME}/.claude.json" > /dev/null 2>&1; then
    pass "PATH injected into server config"
else
    fail "PATH not injected"
fi

# Test 7: Test include pattern (master-mcp.d/*.json)
echo ""
echo "Test 7: Test include pattern (master-mcp.d/*.json)"
mkdir -p "${MASTER_CONFIG_DIR}"
cat > "${MASTER_CONFIG_DIR}/override.json" <<'EOF'
{
  "servers": {
    "test-server": {
      "command": "ls",
      "args": ["-la"]
    }
  }
}
EOF

./mcp/sync-mcp.sh claude 2>/dev/null

overridden_cmd=$(jq -r '.mcpServers."test-server".command' "${HOME}/.claude.json")
if [[ "$overridden_cmd" == *"ls"* ]]; then
    pass "Include pattern works, command overridden"
else
    fail "Include pattern failed: $overridden_cmd"
fi

# Test 8: Verify complete replacement (not shallow merge)
echo ""
echo "Test 8: Verify complete replacement"
overridden_args=$(jq -r '.mcpServers."test-server".args[0]' "${HOME}/.claude.json")
if [[ "$overridden_args" == "-la" ]]; then
    pass "Complete replacement works (args replaced)"
else
    fail "Shallow merge occurred: $overridden_args"
fi

# Test 9: Verify env.MEMORY_FILE is preserved
echo ""
echo "Test 9: Verify original env fields are preserved"
memory_file=$(jq -r '.mcpServers.memory.env.MEMORY_FILE' "${HOME}/.claude.json")
if [[ "$memory_file" == '${HOME}/.config/mcp/shared-memory.json' ]]; then
    pass "Original env fields preserved"
else
    fail "Original env fields lost: $memory_file"
fi

# Test 10: Sync to VS Code
echo ""
echo "Test 10: Test sync to VS Code"
# Set VS Code path based on OS
if [[ "$(uname)" == "Darwin" ]]; then
    VSCODE_CONFIG="${HOME}/Library/Application Support/Code/User/mcp.json"
else
    VSCODE_CONFIG="${XDG_CONFIG_HOME}/Code/User/mcp.json"
fi

./mcp/sync-mcp.sh vscode 2>/dev/null

if [[ -f "$VSCODE_CONFIG" ]]; then
    pass "VS Code config created"
else
    fail "VS Code config not created"
fi

# Test 11: Verify VS Code uses "servers" key (not "mcpServers")
echo ""
echo "Test 11: Verify VS Code config format"
if jq -e '.servers."test-server"' "$VSCODE_CONFIG" > /dev/null 2>&1; then
    pass "VS Code uses 'servers' key"
else
    fail "VS Code config format incorrect"
fi

# Test 12: Sync to GitLab Duo
echo ""
echo "Test 12: Test sync to GitLab Duo"
GITLAB_CONFIG="${HOME}/.gitlab/duo/mcp.json"

./mcp/sync-mcp.sh gitlab 2>/dev/null

if [[ -f "$GITLAB_CONFIG" ]]; then
    pass "GitLab Duo config created"
else
    fail "GitLab Duo config not created"
fi

# Test 13: Verify GitLab Duo uses "mcpServers" key
echo ""
echo "Test 13: Verify GitLab Duo config format"
if jq -e '.mcpServers."test-server"' "$GITLAB_CONFIG" > /dev/null 2>&1; then
    pass "GitLab Duo uses 'mcpServers' key"
else
    fail "GitLab Duo config format incorrect"
fi

# Test 14: Sync all tools at once
echo ""
echo "Test 14: Test sync to all tools"
# Clean up previous configs
rm -f "${HOME}/.claude.json" "$VSCODE_CONFIG" "$GITLAB_CONFIG"

./mcp/sync-mcp.sh all 2>/dev/null

all_created=true
if [[ ! -f "${HOME}/.claude.json" ]]; then
    all_created=false
fi
if [[ ! -f "$VSCODE_CONFIG" ]]; then
    all_created=false
fi
if [[ ! -f "$GITLAB_CONFIG" ]]; then
    all_created=false
fi

if $all_created; then
    pass "All tool configs created successfully"
else
    fail "Some tool configs not created"
fi

echo ""
echo "=========================================="
if [[ $test_result -eq 0 ]]; then
    echo -e "${GREEN}All tests passed!${NC}"
else
    echo -e "${RED}Some tests failed!${NC}"
fi
echo "=========================================="

exit $test_result
