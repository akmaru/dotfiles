#!/usr/bin/env bash
#
# test_sheldon.sh - Test sheldon installation and plugin loading
#
set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

# XDG / PATH setup (independent CI step does not inherit install_minimum.sh exports)
export XDG_BIN_HOME="${XDG_BIN_HOME:-$HOME/.local/bin}"
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export PATH="$XDG_BIN_HOME:$PATH"

DOT_PATH=$(cd "$(dirname "$0")/.." && pwd)
PLUGINS_TOML="${DOT_PATH}/sheldon/plugins.toml"

echo "=========================================="
echo "  Sheldon Tests"
echo "=========================================="
echo ""

test_result=0

fail() {
    echo -e "${RED}✗ FAIL:${NC} $1"
    test_result=1
}

pass() {
    echo -e "${GREEN}✓ PASS:${NC} $1"
}

# Test 1: sheldon is installed
echo "Test 1: Check sheldon is available"
if command -v sheldon &> /dev/null; then
    pass "sheldon is installed ($(sheldon --version))"
else
    fail "sheldon is not installed"
    exit 1
fi

# Test 2: plugins.toml is linked into the config dir
echo ""
echo "Test 2: Check plugins.toml is linked"
if [[ -f "${XDG_CONFIG_HOME}/sheldon/plugins.toml" ]]; then
    pass "plugins.toml present at ${XDG_CONFIG_HOME}/sheldon/plugins.toml"
else
    fail "plugins.toml not found at ${XDG_CONFIG_HOME}/sheldon/plugins.toml"
    exit 1
fi

# Test 3: sheldon source evaluates and clones missing plugins
echo ""
echo "Test 3: Check 'sheldon source' succeeds"
if SRC=$(sheldon source 2>/dev/null) && [[ -n "$SRC" ]]; then
    pass "'sheldon source' produced output"
else
    fail "'sheldon source' failed or produced no output"
    exit 1
fi

# Test 4: every github plugin from plugins.toml is wired into the source output
echo ""
echo "Test 4: Check each github plugin is loaded"
# Anchor at line start so commented-out examples (# github = "...") are excluded
plugins=$(grep -oE '^github = "[^"]+"' "${PLUGINS_TOML}" | sed -E 's/.*"(.*)"/\1/')
if [[ -z "$plugins" ]]; then
    fail "no github plugins found in ${PLUGINS_TOML}"
fi
while IFS= read -r repo; do
    [[ -z "$repo" ]] && continue
    if echo "$SRC" | grep -q "$repo"; then
        pass "plugin loaded: $repo"
    else
        fail "plugin not loaded: $repo"
    fi
done <<< "$plugins"

# Test 5: full load smoke test under zsh
echo ""
echo "Test 5: Check plugins eval cleanly under zsh"
if command -v zsh &> /dev/null; then
    if zsh -c 'eval "$(sheldon source)"' 2>/dev/null; then
        pass "plugins eval without error under zsh"
    else
        fail "plugins eval failed under zsh"
    fi
else
    fail "zsh is not installed"
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
