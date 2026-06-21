#!/usr/bin/env bash
#
# test_mise.sh - Test mise installation and that each configured tool is installed
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
export PATH="${XDG_DATA_HOME}/mise/shims:${XDG_BIN_HOME}:$PATH"

DOT_PATH=$(cd "$(dirname "$0")/.." && pwd)
CONFIG_TOML="${DOT_PATH}/mise/config.toml"

echo "=========================================="
echo "  mise Tests"
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

# Test 1: mise is installed
echo "Test 1: Check mise is available"
if command -v mise &> /dev/null; then
    pass "mise is installed ($(mise --version))"
else
    fail "mise is not installed"
    exit 1
fi

# Test 2: config.toml is linked into the config dir
echo ""
echo "Test 2: Check config.toml is linked"
if [[ -f "${XDG_CONFIG_HOME}/mise/config.toml" ]]; then
    pass "config.toml present at ${XDG_CONFIG_HOME}/mise/config.toml"
else
    fail "config.toml not found at ${XDG_CONFIG_HOME}/mise/config.toml"
    exit 1
fi

# Test 3: every tool in the [tools] section is installed
echo ""
echo "Test 3: Check each configured tool is installed"
tools=$(awk '/^\[tools\]/{f=1;next} /^\[/{f=0} f && /^[A-Za-z]/{split($0,a,"=");gsub(/[ \t]/,"",a[1]);print a[1]}' "${CONFIG_TOML}")
if [[ -z "$tools" ]]; then
    fail "no tools found in [tools] section of ${CONFIG_TOML}"
fi
while IFS= read -r tool; do
    [[ -z "$tool" ]] && continue
    if [[ -n "$(mise ls --installed "$tool" 2>/dev/null)" ]]; then
        pass "tool installed: $tool"
    else
        fail "tool not installed: $tool"
    fi
done <<< "$tools"

echo ""
echo "=========================================="
if [[ $test_result -eq 0 ]]; then
    echo -e "${GREEN}All tests passed!${NC}"
else
    echo -e "${RED}Some tests failed!${NC}"
fi
echo "=========================================="

exit $test_result
