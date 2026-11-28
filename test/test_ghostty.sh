#!/usr/bin/env bash
#
# test_ghostty.sh - Test the Ghostty config placement done by install/install_ghostty.sh
#
set -uo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

DOT_PATH=$(cd "$(dirname "${BASH_SOURCE[0]}")/../" && pwd)
XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-${HOME}/.config}"
GHOSTTY_CONFIG="${XDG_CONFIG_HOME}/ghostty"

echo "=========================================="
echo "  Ghostty Setup Tests"
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

# Test 1: The XDG path is read on both macOS and Linux, so one directory symlink
# covers every supported OS.
echo "Test 1: Check ${GHOSTTY_CONFIG} is a symlink to ${DOT_PATH}/ghostty"
if [[ ! -L "${GHOSTTY_CONFIG}" ]]; then
    fail "${GHOSTTY_CONFIG} is not a symlink"
elif [[ "$(readlink -f "${GHOSTTY_CONFIG}")" != "$(readlink -f "${DOT_PATH}/ghostty")" ]]; then
    fail "${GHOSTTY_CONFIG} points to $(readlink -f "${GHOSTTY_CONFIG}"), expected ${DOT_PATH}/ghostty"
else
    pass "${GHOSTTY_CONFIG} -> $(readlink "${GHOSTTY_CONFIG}")"
fi

# Test 2: config.ghostty is the file name Ghostty >= 1.2.3 looks for
echo ""
echo "Test 2: Check ${GHOSTTY_CONFIG}/config.ghostty exists"
if [[ -f "${GHOSTTY_CONFIG}/config.ghostty" ]]; then
    pass "config.ghostty found"
else
    fail "config.ghostty not found"
fi

# Test 3: Ghostty itself accepts the config. Skipped where Ghostty is not installed.
echo ""
echo "Test 3: Check Ghostty accepts the config"
ghostty_bin=$(command -v ghostty || true)
if [[ -z "${ghostty_bin}" && -x /Applications/Ghostty.app/Contents/MacOS/ghostty ]]; then
    ghostty_bin=/Applications/Ghostty.app/Contents/MacOS/ghostty
fi
if [[ -z "${ghostty_bin}" ]]; then
    echo "SKIP: ghostty is not installed"
elif "${ghostty_bin}" +validate-config --config-file="${GHOSTTY_CONFIG}/config.ghostty"; then
    pass "ghostty +validate-config succeeded"
else
    fail "ghostty +validate-config reported errors"
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
