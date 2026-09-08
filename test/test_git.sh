#!/usr/bin/env bash
#
# test_git.sh - Test git configuration (identity, conditional include,
# credential helper).
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

# XDG / PATH setup (independent CI step does not inherit install_minimum.sh exports)
# The credential helpers shell out to gh/glab, which mise installs as shims.
export XDG_BIN_HOME="${XDG_BIN_HOME:-$HOME/.local/bin}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export PATH="${XDG_DATA_HOME}/mise/shims:${XDG_BIN_HOME}:$PATH"

DOT_PATH=$(cd "$(dirname "$0")/.." && pwd)

EXPECTED_NAME="Akira Maruoka"
EXPECTED_EMAIL="akmaru0266@gmail.com"

# Credential helpers, in the order .gitconfig declares them. Both CLIs read the
# host from git's stdin and decline hosts they do not own, so one identical list
# works on every OS -- no per-OS include and no hostname in this repo.
EXPECTED_HELPERS=(
    '!gh auth git-credential'
    '!glab auth git-credential'
)

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

# Test 5: the per-OS credential include is gone
#
# Credential handling is delegated to gh/glab, which need no OS-specific
# backend, so ~/.gitconfig_os and the .gitconfig_{linux,mac,windows} files it
# pointed at must not come back. Guard against a partial revert leaving the
# include in place with no file behind it.
echo ""
echo "Test 5: no per-OS credential include"
os_include_refs=""
while IFS= read -r f; do
    [[ -f "$f" ]] || continue
    # Strip comments first: .gitconfig explains in prose why these files are
    # gone, and that rationale must not read as a live reference. Every file
    # type checked here (gitconfig, sh, ps1) comments with # (git also uses ;).
    if sed -E 's/[[:space:]]*[#;].*$//' "$f" \
        | grep -qE '\.gitconfig_(os|linux|mac|windows)'; then
        os_include_refs+="$f "
    fi
done < <(printf '%s\n' "${DOT_PATH}/.gitconfig" "${DOT_PATH}"/install_minimum.* \
    && find "${DOT_PATH}/install" -type f 2>/dev/null)
leftover_os_files=$(ls "${DOT_PATH}"/.gitconfig_{linux,mac,windows} 2>/dev/null || true)
if [[ -n "$os_include_refs" ]]; then
    fail "per-OS gitconfig still referenced by: $(echo "$os_include_refs" | tr '\n' ' ')"
elif [[ -n "$leftover_os_files" ]]; then
    fail "per-OS gitconfig files still present: $(echo "$leftover_os_files" | tr '\n' ' ')"
else
    pass "no .gitconfig_os indirection remains"
fi

# Test 6: effective credential.helper is the gh + glab list, in order
#
# Order matters only for which CLI is spawned first; both decline foreign hosts
# silently (exit 1, no output), so git falls through to the next one.
echo ""
echo "Test 6: credential.helper is gh + glab"
mapfile -t actual_helpers < <(gc --get-all credential.helper 2>/dev/null || true)
if [[ "${actual_helpers[*]}" == "${EXPECTED_HELPERS[*]}" ]]; then
    pass "credential.helper is ${#actual_helpers[@]} entries: ${actual_helpers[*]}"
else
    fail "credential.helper expected '${EXPECTED_HELPERS[*]}', got '${actual_helpers[*]:-<none>}'"
fi

# Test 7: every configured helper resolves to an executable
#
# The helpers are '!<cmd> ...' shell forms, so check the command word rather
# than looking for a git-credential-* binary.
echo ""
echo "Test 7: credential helpers are resolvable"
if [[ ${#actual_helpers[@]} -eq 0 ]]; then
    fail "no credential helper configured"
else
    for helper in "${actual_helpers[@]}"; do
        # '!gh auth git-credential' -> 'gh'
        cmd=$(echo "${helper#!}" | awk '{print $1}')
        if command -v "$cmd" &> /dev/null; then
            pass "$cmd is resolvable ($helper)"
        else
            fail "$cmd not found (from helper '$helper')"
        fi
    done
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
    pass "git config --list succeeds with absent ~/.work.gitconfig"
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
