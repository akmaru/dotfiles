#!/usr/bin/env bash
#
# test_aws.sh - Test aws.sh installs session-manager-plugin and it runs
#
set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

# XDG / PATH setup (independent CI step does not inherit install_minimum.sh exports)
export XDG_BIN_HOME="${XDG_BIN_HOME:-$HOME/.local/bin}"
export PATH="$XDG_BIN_HOME:$PATH"

DOT_PATH=$(cd "$(dirname "$0")/.." && pwd)
SMP="${XDG_BIN_HOME}/session-manager-plugin"

echo "=========================================="
echo "  AWS Tests"
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

# Test 1: aws.sh runs and installs session-manager-plugin (downloads from S3)
echo "Test 1: Run install/aws.sh"
if SMP_INSTALL_DIR="${XDG_BIN_HOME}" "${DOT_PATH}/install/aws.sh"; then
    pass "install/aws.sh completed"
else
    fail "install/aws.sh failed"
    exit 1
fi

# Test 2: session-manager-plugin binary exists
echo ""
echo "Test 2: Check session-manager-plugin binary"
if [[ -x "$SMP" ]]; then
    pass "session-manager-plugin installed at $SMP"
else
    fail "session-manager-plugin not found at $SMP"
    exit 1
fi

# Test 3: session-manager-plugin --version runs
echo ""
echo "Test 3: Check session-manager-plugin --version"
if version=$("$SMP" --version 2>/dev/null); then
    pass "session-manager-plugin runs (version: $version)"
else
    fail "session-manager-plugin --version failed"
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
