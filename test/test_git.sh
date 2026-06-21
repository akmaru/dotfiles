#!/usr/bin/env bash
#
# test_git.sh - Test git configuration (identity, OS include, conditional
# include, credential helper).
#
# Two scopes:
#  - Part A uses the real $HOME to verify the install wired the symlinks and
#    that the effective config (credential helper, editor, etc.) resolves.
#  - Part B uses an isolated HOME so identity assertions are deterministic and
#    unaffected by an external ~/.work.gitconfig / ~/.gitconfig_dqrta.
#
set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

DOT_PATH=$(cd "$(dirname "$0")/.." && pwd)

EXPECTED_NAME="Akira Maruoka"
EXPECTED_EMAIL="akmaru0266@gmail.com"

case "$(uname)" in
    Darwin) OS_FILE="${DOT_PATH}/.gitconfig_mac" ;;
    Linux)  OS_FILE="${DOT_PATH}/.gitconfig_linux" ;;
    *)      OS_FILE="" ;;
esac

echo "=========================================="
echo "  Git Config Tests"
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

# Read effective config (with includes expanded) from a non-repo dir so no
# repo-level conditional include interferes. Note: do NOT use --global, which
# reads the literal global file without expanding includes.
NONREPO=$(mktemp -d)
gc() { (cd "$NONREPO" && git config "$@"); }

# ---------------------------------------------------------------------------
# Part A: install correctness against the real $HOME
# ---------------------------------------------------------------------------

# Test 1: ~/.gitconfig is symlinked into the repo
echo "Test 1: ~/.gitconfig symlink"
if [[ -L "${HOME}/.gitconfig" && "$(readlink "${HOME}/.gitconfig")" == "${DOT_PATH}/.gitconfig" ]]; then
    pass "~/.gitconfig -> ${DOT_PATH}/.gitconfig"
else
    fail "~/.gitconfig is not linked to ${DOT_PATH}/.gitconfig"
fi

# Test 2: core.editor
echo ""
echo "Test 2: core.editor"
editor=$(gc core.editor 2>/dev/null || true)
if [[ "$editor" == "nvim" ]]; then
    pass "core.editor is nvim"
else
    fail "core.editor expected 'nvim', got '$editor'"
fi

# Test 3: core.excludesfile resolves to an existing file
echo ""
echo "Test 3: core.excludesfile"
excludes=$(gc core.excludesfile 2>/dev/null || true)
excludes_expanded="${excludes/#\~/$HOME}"
if [[ -n "$excludes" && -e "$excludes_expanded" ]]; then
    pass "core.excludesfile resolves: $excludes"
else
    fail "core.excludesfile does not resolve: '$excludes'"
fi

# Test 4: LFS filter is configured
echo ""
echo "Test 4: filter.lfs.required"
if [[ "$(gc filter.lfs.required 2>/dev/null || true)" == "true" ]]; then
    pass "filter.lfs.required is true"
else
    fail "filter.lfs.required is not true"
fi

# Test 5: ~/.gitconfig_os symlink resolves to an existing file
echo ""
echo "Test 5: ~/.gitconfig_os resolves"
if [[ -e "${HOME}/.gitconfig_os" ]]; then
    pass "~/.gitconfig_os resolves to $(readlink "${HOME}/.gitconfig_os" 2>/dev/null || echo "${HOME}/.gitconfig_os")"
else
    fail "~/.gitconfig_os is missing or a dangling symlink"
fi

# Test 6: effective credential.helper matches the OS-specific config
echo ""
echo "Test 6: credential.helper matches OS config"
if [[ -z "$OS_FILE" ]]; then
    fail "unsupported OS: $(uname)"
else
    expected_helper=$(grep -E '^[[:space:]]*helper[[:space:]]*=' "$OS_FILE" | sed -E 's/^[^=]*=[[:space:]]*//' | head -1)
    actual_helper=$(gc credential.helper 2>/dev/null || true)
    if [[ "$actual_helper" == "$expected_helper" ]]; then
        pass "credential.helper is '$actual_helper'"
    else
        fail "credential.helper expected '$expected_helper', got '$actual_helper'"
    fi
fi

# Test 7: credential helper is resolvable (binary/command exists)
echo ""
echo "Test 7: credential helper is resolvable"
helper="${expected_helper:-}"
if [[ -z "$helper" ]]; then
    fail "no credential helper configured for this OS"
elif [[ "$helper" == /* ]]; then
    # Absolute path helper
    if [[ -x "$helper" ]]; then
        pass "helper binary exists: $helper"
    else
        fail "helper binary missing or not executable: $helper"
    fi
else
    # Bare name -> git looks for git-credential-<name>
    if command -v "git-credential-${helper}" &> /dev/null \
        || [[ -x "$(git --exec-path)/git-credential-${helper}" ]]; then
        pass "git-credential-${helper} is resolvable"
    else
        fail "git-credential-${helper} not found"
    fi
fi

# ---------------------------------------------------------------------------
# Part B: identity logic in an isolated HOME (deterministic)
# ---------------------------------------------------------------------------
TEST_HOME=$(mktemp -d)
cp "${DOT_PATH}/.gitconfig" "${TEST_HOME}/.gitconfig"
printf '[user]\n\tname = DQRTA Test\n\temail = dqrta@example.com\n' > "${TEST_HOME}/.gitconfig_dqrta"

# helper: identity for a repo whose origin is $1
identity_for_remote() {
    local url="$1" key="$2" repo
    repo=$(mktemp -d)
    git -C "$repo" init -q
    git -C "$repo" remote add origin "$url"
    HOME="$TEST_HOME" git -C "$repo" config "$key" 2>/dev/null || true
    rm -rf "$repo"
}

# Test 8: base identity (non-Maru0137 remote keeps repo defaults)
echo ""
echo "Test 8: base identity"
base_name=$(identity_for_remote "git@github.com:akmaru/dotfiles.git" user.name)
base_email=$(identity_for_remote "git@github.com:akmaru/dotfiles.git" user.email)
if [[ "$base_name" == "$EXPECTED_NAME" && "$base_email" == "$EXPECTED_EMAIL" ]]; then
    pass "base identity: $base_name <$base_email>"
else
    fail "base identity expected '$EXPECTED_NAME <$EXPECTED_EMAIL>', got '$base_name <$base_email>'"
fi

# Test 9: Maru0137 repos use the .gitconfig_dqrta identity (needs git >= 2.36)
echo ""
echo "Test 9: Maru0137 conditional include"
dqrta_name=$(identity_for_remote "git@github.com:Maru0137/somerepo.git" user.name)
dqrta_email=$(identity_for_remote "git@github.com:Maru0137/somerepo.git" user.email)
if [[ "$dqrta_name" == "DQRTA Test" && "$dqrta_email" == "dqrta@example.com" ]]; then
    pass "Maru0137 remote uses .gitconfig_dqrta identity (git $(git version | awk '{print $3}'))"
else
    fail "Maru0137 identity expected 'DQRTA Test <dqrta@example.com>', got '$dqrta_name <$dqrta_email>' (git $(git version | awk '{print $3}'); hasconfig:remote needs >= 2.36)"
fi

# Test 10: missing optional includes do not break config loading
echo ""
echo "Test 10: missing optional includes tolerated"
if HOME="$TEST_HOME" git -C "$NONREPO" config --list &> /dev/null; then
    pass "git config --list succeeds with absent ~/.gitconfig_os/.work.gitconfig"
else
    fail "git config --list failed with absent optional includes"
fi

rm -rf "$NONREPO" "$TEST_HOME"

echo ""
echo "=========================================="
if [[ $test_result -eq 0 ]]; then
    echo -e "${GREEN}All tests passed!${NC}"
else
    echo -e "${RED}Some tests failed!${NC}"
fi
echo "=========================================="

exit $test_result
