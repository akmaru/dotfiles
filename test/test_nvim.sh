#!/usr/bin/env bash
#
# test_nvim.sh - Test the LazyVim-based nvim setup
#
set -uo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

# nvim is managed by mise, whose shims are not on PATH in a fresh shell
export PATH="${HOME}/.local/share/mise/shims:${HOME}/.local/bin:${PATH}"

DOT_PATH=$(cd "$(dirname "${BASH_SOURCE[0]}")/../" && pwd)
XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-${HOME}/.config}"
NVIM_CONFIG="${XDG_CONFIG_HOME}/nvim"

# LazyVim requires Neovim >= 0.11.2
REQUIRED_NVIM_VERSION="0.11.2"

echo "=========================================="
echo "  nvim (LazyVim) Setup Tests"
echo "=========================================="
echo ""
echo "Repository:  ${DOT_PATH}"
echo "nvim config: ${NVIM_CONFIG}"
echo ""

test_result=0

fail() {
    echo -e "${RED}✗ FAIL:${NC} $1"
    test_result=1
}

pass() {
    echo -e "${GREEN}✓ PASS:${NC} $1"
}

# lazy.nvim logs one line per plugin per task, which drowns the test output.
# Keep it in a log and only surface it when something actually breaks.
NVIM_LOG=$(mktemp)
trap 'rm -f "${NVIM_LOG}"' EXIT

run_nvim() {
    if nvim --headless "$@" > "${NVIM_LOG}" 2>&1; then
        return 0
    fi
    echo "--- nvim output ---"
    cat "${NVIM_LOG}"
    echo "-------------------"
    return 1
}

# A lua error raised from `-c` does NOT make nvim exit non-zero, so an assertion
# has to terminate the process itself for the shell to notice the failure.
run_nvim_lua() {
    run_nvim -c "lua local ok, err = pcall(function() $1 end); if not ok then io.stderr:write(tostring(err) .. '\n'); os.exit(1) end; os.exit(0)"
}

# Test 1: Check nvim is available and new enough for LazyVim
echo "Test 1: Check nvim is available and >= ${REQUIRED_NVIM_VERSION}"
if ! command -v nvim &> /dev/null; then
    fail "nvim is not installed"
    exit 1
fi
nvim_version=$(nvim --version | head -1 | sed -E 's/^NVIM v?//')
# sort -V puts the lower version first, so the required version must come first
if [[ "$(printf '%s\n%s\n' "${REQUIRED_NVIM_VERSION}" "${nvim_version}" | sort -V | head -1)" == "${REQUIRED_NVIM_VERSION}" ]]; then
    pass "nvim ${nvim_version} satisfies >= ${REQUIRED_NVIM_VERSION} ($(command -v nvim))"
else
    fail "nvim ${nvim_version} is older than ${REQUIRED_NVIM_VERSION}"
    exit 1
fi

# Test 2: The whole config directory must be a symlink into the repository.
# Linking the directory (not individual files) is what lets LazyVim write
# lazyvim.json / lazy-lock.json back into the repository.
echo ""
echo "Test 2: Check ${NVIM_CONFIG} is a symlink to ${DOT_PATH}/nvim"
if [[ ! -L "${NVIM_CONFIG}" ]]; then
    fail "${NVIM_CONFIG} is not a symlink (LazyVim state would not land in the repository)"
elif [[ "$(readlink -f "${NVIM_CONFIG}")" != "$(readlink -f "${DOT_PATH}/nvim")" ]]; then
    fail "${NVIM_CONFIG} points to $(readlink -f "${NVIM_CONFIG}"), expected ${DOT_PATH}/nvim"
else
    pass "${NVIM_CONFIG} -> $(readlink "${NVIM_CONFIG}")"
fi

# Test 3: Check the LazyVim entry points exist
echo ""
echo "Test 3: Check LazyVim config files exist"
missing=()
for f in init.lua lua/config/lazy.lua lua/config/options.lua lua/config/keymaps.lua lua/config/autocmds.lua; do
    [[ -f "${DOT_PATH}/nvim/${f}" ]] || missing+=("${f}")
done
if [[ ${#missing[@]} -eq 0 ]]; then
    pass "All LazyVim config files present"
else
    fail "Missing config files: ${missing[*]}"
fi

# The remaining tests need a working config directory
if [[ $test_result -ne 0 ]]; then
    echo ""
    echo -e "${RED}Config is not in place; skipping plugin tests.${NC}"
    echo "=========================================="
    exit $test_result
fi

# Test 4: Plugins install headlessly
echo ""
echo "Test 4: Install plugins (nvim --headless +Lazy! install)"
if run_nvim "+Lazy! install" +qa; then
    pass "Plugin install completed"
else
    fail "Plugin install failed"
fi

# Test 5: The lockfile can reproduce the plugin set.
# This is the IaC guarantee: lazy-lock.json in the repository is enough to
# rebuild the exact same plugin versions on another machine.
echo ""
echo "Test 5: Restore plugins from lazy-lock.json (nvim --headless +Lazy! restore)"
if [[ ! -f "${DOT_PATH}/nvim/lazy-lock.json" ]]; then
    fail "nvim/lazy-lock.json was not written into the repository"
elif run_nvim "+Lazy! restore" +qa; then
    pass "Plugins restored from lazy-lock.json"
else
    fail "Restoring from lazy-lock.json failed"
fi

# Test 6: LazyVim itself is loadable
echo ""
echo "Test 6: Check LazyVim is on the runtimepath"
if run_nvim_lua 'assert(require("lazyvim.config"))'; then
    pass "require(\"lazyvim.config\") succeeded"
else
    fail "LazyVim could not be loaded"
fi

# Test 7: The colorscheme actually applies.
# LazyVim silently falls back to habamax when loading fails, so asserting the
# resulting colors_name is what catches a broken colorscheme spec.
echo ""
echo "Test 7: Check the configured colorscheme is applied"
if run_nvim_lua 'assert(vim.g.colors_name == "monokai-pro", "colors_name = " .. tostring(vim.g.colors_name))'; then
    pass "colorscheme monokai-pro applied"
else
    fail "colorscheme was not applied (LazyVim fell back to habamax?)"
fi

# Test 8: LSP servers that no LazyVim extra provides are configured by hand.
# cssls / html / bashls replace the coc-css / coc-html / coc-sh of the old setup.
echo ""
echo "Test 8: Check hand-configured LSP servers are registered"
lsp_assert='
  local servers = LazyVim.opts("nvim-lspconfig").servers or {}
  for _, name in ipairs({ "cssls", "html", "bashls" }) do
    assert(servers[name], name .. " is not configured")
  end'
if run_nvim_lua "${lsp_assert}"; then
    pass "cssls, html and bashls are configured"
else
    fail "some hand-configured LSP servers are missing"
fi

# Test 9: herdr launches plugin panes and custom commands with a stripped PATH
# that has no mise shim directory, so they resolve nvim from /usr/bin or
# ~/.local/bin. A stale system nvim there shadows the mise-managed one and the
# herdr-nvim sidebar silently starts an ancient nvim that LazyVim cannot run on.
echo ""
echo "Test 9: Check nvim on a stripped PATH is >= ${REQUIRED_NVIM_VERSION}"
stripped_path="/usr/local/bin:/usr/bin:/bin:${HOME}/.local/bin"
stripped_nvim=$(env -i HOME="${HOME}" PATH="${stripped_path}" sh -c 'command -v nvim' || true)
if [[ -z "${stripped_nvim}" ]]; then
    fail "no nvim on ${stripped_path}; tools launched by herdr would not find it"
else
    stripped_version=$(env -i HOME="${HOME}" PATH="${stripped_path}" "${stripped_nvim}" --version | head -1 | sed -E 's/^NVIM v?//')
    if [[ "$(printf '%s\n%s\n' "${REQUIRED_NVIM_VERSION}" "${stripped_version}" | sort -V | head -1)" == "${REQUIRED_NVIM_VERSION}" ]]; then
        pass "stripped PATH resolves nvim ${stripped_version} (${stripped_nvim})"
    else
        fail "stripped PATH resolves nvim ${stripped_version} (${stripped_nvim}), older than ${REQUIRED_NVIM_VERSION}"
    fi
fi

# Test 10: The nvim half of the herdr-nvim integration. The herdr half (sidebar
# and file picker) is installed as a herdr plugin; this spec is what provides the
# annotation commands that send file:line context to the agent in the next pane.
echo ""
echo "Test 10: Check the herdr-nvim plugin spec is registered"
if run_nvim_lua 'assert(require("lazy.core.config").plugins["herdr-nvim"], "herdr-nvim is not in the lazy spec")'; then
    pass "herdr-nvim is registered with lazy.nvim"
else
    fail "herdr-nvim is not registered (nvim/lua/plugins/herdr.lua missing?)"
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
