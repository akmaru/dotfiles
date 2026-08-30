#!/usr/bin/env bash
#
# test_brewfile.sh - Validate Brewfile / Brewfile_minimum entries without installing them
#
# CI runners have none of these packages installed, so `brew bundle check` would
# always fail. Instead verify that every entry still refers to something that
# exists: formulae and casks against the Homebrew API, mas apps against the
# App Store lookup API (this is what catches a stale app id or a renamed cask).
set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

DOT_PATH=$(cd "$(dirname "$0")/.." && pwd)
BREWFILE="${DOT_PATH}/Brewfile"
BREWFILE_MINIMUM="${DOT_PATH}/Brewfile_minimum"

# App Store listings are per-storefront; use the storefront these apps were
# installed from. Override when a Brewfile targets a different region.
MAS_COUNTRY="${MAS_COUNTRY:-jp}"

echo "=========================================="
echo "  Brewfile Tests"
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

# Test 1: Both Brewfiles are syntactically valid
echo "Test 1: Parse Brewfiles"
for file in "$BREWFILE" "$BREWFILE_MINIMUM"; do
    if brew bundle list --file="$file" >/dev/null 2>&1; then
        pass "$(basename "$file") parses"
    else
        fail "$(basename "$file") failed to parse"
    fi
done

# Test 2: Every formula exists in homebrew-core
echo ""
echo "Test 2: Check formulae exist"
while IFS= read -r name; do
    if brew info --formula "$name" >/dev/null 2>&1; then
        pass "formula: $name"
    else
        fail "formula not found: $name"
    fi
done < <(grep -h '^brew "' "$BREWFILE" "$BREWFILE_MINIMUM" | sed 's/^brew "\([^"]*\)".*/\1/')

# Test 3: Every cask exists in homebrew-cask
echo ""
echo "Test 3: Check casks exist"
while IFS= read -r name; do
    if brew info --cask "$name" >/dev/null 2>&1; then
        pass "cask: $name"
    else
        fail "cask not found: $name"
    fi
done < <(grep -h '^cask "' "$BREWFILE" "$BREWFILE_MINIMUM" | sed 's/^cask "\([^"]*\)".*/\1/')

# Test 4: Every mas app id still resolves on the App Store
#
# The name in a mas entry is a comment as far as brew bundle is concerned (it
# installs by id), and the installed bundle name often differs from the store
# listing, so only the id is asserted. The store name is printed so a rename
# like "Microsoft Remote Desktop" -> "Windows App" is visible in the log.
echo ""
echo "Test 4: Check mas app ids resolve (storefront: ${MAS_COUNTRY})"
while IFS='|' read -r name id; do
    store_name=$(curl -sf "https://itunes.apple.com/lookup?id=${id}&country=${MAS_COUNTRY}" \
        | python3 -c 'import sys, json; d = json.load(sys.stdin); print(d["results"][0]["trackName"] if d["resultCount"] else "")' 2>/dev/null || true)
    if [[ -n "$store_name" ]]; then
        pass "mas: $name (id: $id) -> \"$store_name\""
    else
        fail "mas app id not found: $name (id: $id)"
    fi
done < <(grep -h '^mas "' "$BREWFILE" "$BREWFILE_MINIMUM" | sed 's/^mas "\([^"]*\)", id: \([0-9]*\).*/\1|\2/')

echo ""
echo "=========================================="
if [[ $test_result -eq 0 ]]; then
    echo -e "${GREEN}All tests passed!${NC}"
else
    echo -e "${RED}Some tests failed!${NC}"
fi
echo "=========================================="

exit $test_result
