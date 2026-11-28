#!/usr/bin/env bash
#
# test_nvim.sh - Test the vim.pack-based nvim setup
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

# vim.pack (the built-in plugin manager) first shipped in Neovim 0.12
REQUIRED_NVIM_VERSION="0.12.0"

echo "=========================================="
echo "  nvim (vim.pack) Setup Tests"
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

# Plugin installs and parser builds print a lot. Keep it in a log and only
# surface it when something actually breaks.
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

version_ge() {
    # sort -V puts the lower version first, so the required version must come first
    [[ "$(printf '%s\n%s\n' "$1" "$2" | sort -V | head -1)" == "$1" ]]
}

# Test 1: Check nvim is available and new enough for vim.pack
echo "Test 1: Check nvim is available and >= ${REQUIRED_NVIM_VERSION}"
if ! command -v nvim &> /dev/null; then
    fail "nvim is not installed"
    exit 1
fi
nvim_version=$(nvim --version | head -1 | sed -E 's/^NVIM v?//')
if version_ge "${REQUIRED_NVIM_VERSION}" "${nvim_version}"; then
    pass "nvim ${nvim_version} satisfies >= ${REQUIRED_NVIM_VERSION} ($(command -v nvim))"
else
    fail "nvim ${nvim_version} is older than ${REQUIRED_NVIM_VERSION}"
    exit 1
fi

# Test 2: The whole config directory must be a symlink into the repository.
# Linking the directory (not individual files) is what lets vim.pack write
# nvim-pack-lock.json back into the repository.
echo ""
echo "Test 2: Check ${NVIM_CONFIG} is a symlink to ${DOT_PATH}/nvim"
if [[ ! -L "${NVIM_CONFIG}" ]]; then
    fail "${NVIM_CONFIG} is not a symlink (the lockfile would not land in the repository)"
elif [[ "$(readlink -f "${NVIM_CONFIG}")" != "$(readlink -f "${DOT_PATH}/nvim")" ]]; then
    fail "${NVIM_CONFIG} points to $(readlink -f "${NVIM_CONFIG}"), expected ${DOT_PATH}/nvim"
else
    pass "${NVIM_CONFIG} -> $(readlink "${NVIM_CONFIG}")"
fi

# Test 3: Check the entry points exist and no LazyVim state is left behind.
# A stale lazy-lock.json would suggest it is still the source of truth.
echo ""
echo "Test 3: Check config files exist and LazyVim files are gone"
missing=()
for f in init.lua nvim-pack-lock.json lua/config/options.lua lua/config/keymaps.lua lua/config/autocmds.lua; do
    [[ -f "${DOT_PATH}/nvim/${f}" ]] || missing+=("${f}")
done
leftover=()
for f in lazy-lock.json lazyvim.json lua/config/lazy.lua; do
    [[ -e "${DOT_PATH}/nvim/${f}" ]] && leftover+=("${f}")
done
if [[ ${#missing[@]} -ne 0 ]]; then
    fail "Missing config files: ${missing[*]}"
elif [[ ${#leftover[@]} -ne 0 ]]; then
    fail "LazyVim files are left behind: ${leftover[*]}"
else
    pass "All config files present, no LazyVim leftovers"
fi

# The remaining tests need a working config directory
if [[ $test_result -ne 0 ]]; then
    echo ""
    echo -e "${RED}Config is not in place; skipping plugin tests.${NC}"
    echo "=========================================="
    exit $test_result
fi

# Test 4: Starting nvim installs every plugin from the lockfile without
# prompting. A headless start must not block on the install confirmation.
echo ""
echo "Test 4: Install plugins on first start (nvim --headless +qa)"
if timeout 600 nvim --headless +qa > "${NVIM_LOG}" 2>&1; then
    pass "Startup (with plugin install) completed"
else
    echo "--- nvim output ---"; cat "${NVIM_LOG}"; echo "-------------------"
    fail "Startup failed or timed out (blocked on a confirmation prompt?)"
fi

# Test 5: The lockfile reproduces the plugin set.
# This is the IaC guarantee: nvim-pack-lock.json in the repository is enough to
# rebuild the exact same plugin revisions on another machine.
echo ""
echo "Test 5: Check every plugin matches the revision in nvim-pack-lock.json"
lock_assert='
  local lock = vim.json.decode(table.concat(vim.fn.readfile(vim.fn.stdpath("config") .. "/nvim-pack-lock.json"), "\n"))
  local bad = {}
  for _, p in ipairs(vim.pack.get()) do
    local want = lock.plugins[p.spec.name]
    if not want then
      table.insert(bad, p.spec.name .. " (not in lockfile)")
    elseif want.rev ~= p.rev then
      table.insert(bad, p.spec.name .. " (" .. tostring(p.rev) .. " ~= " .. want.rev .. ")")
    end
  end
  local installed = {}
  for _, p in ipairs(vim.pack.get()) do installed[p.spec.name] = true end
  for name in pairs(lock.plugins) do
    if not installed[name] then table.insert(bad, name .. " (in lockfile but not installed)") end
  end
  assert(#bad == 0, table.concat(bad, ", "))'
if run_nvim_lua "${lock_assert}"; then
    pass "Installed plugins match nvim-pack-lock.json"
else
    fail "Installed plugins diverge from nvim-pack-lock.json"
fi

# Test 6: lazy.nvim / LazyVim are really gone, not just unused
echo ""
echo "Test 6: Check lazy.nvim and LazyVim are not loaded"
if run_nvim_lua 'assert(not package.loaded["lazy"], "lazy.nvim is loaded"); assert(not pcall(require, "lazyvim.config"), "LazyVim is on the runtimepath")'; then
    pass "Neither lazy.nvim nor LazyVim is loaded"
else
    fail "lazy.nvim or LazyVim is still loaded"
fi

# Test 7: The colorscheme actually applies.
# `:colorscheme` failing would leave the builtin default, so asserting the
# resulting colors_name is what catches a broken colorscheme setup.
echo ""
echo "Test 7: Check the configured colorscheme is applied"
if run_nvim_lua 'assert(vim.g.colors_name == "monokai-pro", "colors_name = " .. tostring(vim.g.colors_name))'; then
    pass "colorscheme monokai-pro applied"
else
    fail "colorscheme was not applied"
fi

# Test 8: LSP servers are enabled through the builtin vim.lsp.enable().
# cssls / html / bashls replace the coc-css / coc-html / coc-sh of the old vim
# setup; the others replace the LazyVim language extras.
echo ""
echo "Test 8: Check LSP servers are enabled"
lsp_assert='
  for _, name in ipairs({ "cssls", "html", "bashls", "lua_ls", "gopls", "pyright", "vtsls", "clangd", "yamlls" }) do
    assert(vim.lsp.is_enabled(name), name .. " is not enabled")
  end
  -- rustaceanvim starts rust-analyzer itself; a second client would duplicate diagnostics
  assert(not vim.lsp.is_enabled("rust_analyzer"), "rust_analyzer must be left to rustaceanvim")'
if run_nvim_lua "${lsp_assert}"; then
    pass "LSP servers are enabled (rust_analyzer left to rustaceanvim)"
else
    fail "LSP server registration is wrong"
fi

# Test 9: Completion uses the builtin autocompletion instead of a plugin
echo ""
echo "Test 9: Check builtin autocompletion is on"
if run_nvim_lua 'assert(vim.o.autocomplete, "autocomplete is off"); for _, p in ipairs(vim.pack.get()) do assert(p.spec.name ~= "blink.cmp", "blink.cmp is installed") end'; then
    pass "'autocomplete' is on and no completion plugin is installed"
else
    fail "builtin autocompletion is not configured"
fi

# Test 10: herdr launches plugin panes and custom commands with a stripped PATH
# that has no mise shim directory, so they resolve nvim from /usr/bin or
# ~/.local/bin. A stale system nvim there shadows the mise-managed one and the
# herdr-nvim sidebar silently starts an ancient nvim that has no vim.pack.
echo ""
echo "Test 10: Check nvim on a stripped PATH is >= ${REQUIRED_NVIM_VERSION}"
stripped_path="/usr/local/bin:/usr/bin:/bin:${HOME}/.local/bin"
stripped_nvim=$(env -i HOME="${HOME}" PATH="${stripped_path}" sh -c 'command -v nvim' || true)
if [[ -z "${stripped_nvim}" ]]; then
    fail "no nvim on ${stripped_path}; tools launched by herdr would not find it"
else
    stripped_version=$(env -i HOME="${HOME}" PATH="${stripped_path}" "${stripped_nvim}" --version | head -1 | sed -E 's/^NVIM v?//')
    if version_ge "${REQUIRED_NVIM_VERSION}" "${stripped_version}"; then
        pass "stripped PATH resolves nvim ${stripped_version} (${stripped_nvim})"
    else
        fail "stripped PATH resolves nvim ${stripped_version} (${stripped_nvim}), older than ${REQUIRED_NVIM_VERSION}"
    fi
fi

# Test 11: The nvim half of the herdr-nvim integration. The herdr half (sidebar
# and file picker) is installed as a herdr plugin; this plugin is what provides
# the annotation commands that send file:line context to the agent in the next pane.
echo ""
echo "Test 11: Check herdr-nvim is active"
if run_nvim_lua 'local active = false; for _, p in ipairs(vim.pack.get()) do if p.spec.name == "herdr-nvim" then active = p.active end end; assert(active, "herdr-nvim is not active")'; then
    pass "herdr-nvim is added to the session"
else
    fail "herdr-nvim is not active (nvim/lua/plugins/herdr.lua missing?)"
fi

# Test 12: The start screen renders without lazy.nvim. snacks' default dashboard
# has a "startup" section that requires lazy.stats; it only runs on UIEnter, so
# the headless tests above never open it unless asked to.
echo ""
echo "Test 12: Check the snacks dashboard opens without lazy.nvim"
if run_nvim_lua 'Snacks.dashboard.open()'; then
    pass "Snacks.dashboard.open() succeeded"
else
    fail "the dashboard fails to render (a section still depends on lazy.nvim?)"
fi

# Test 13: Spell checking in prose buffers skips Japanese. With only "en" in
# 'spelllang', every run of Japanese between spaces is flagged as one bad word,
# which buries the real English typos under squiggles.
echo ""
echo "Test 13: Check spell checking skips CJK but still flags English typos"
spell_assert='
  vim.cmd("enew | setfiletype markdown")
  assert(vim.wo.spell, "spell is off in markdown buffers")
  local bad = vim.spell.check("Neovimの組み込みプラグインマネージャ")
  assert(#bad == 1 and bad[1][1] == "Neovim", "Japanese is spell checked: " .. vim.inspect(bad))
  assert(#vim.spell.check("speling") == 1, "English typos are no longer flagged")'
if run_nvim_lua "${spell_assert}"; then
    pass "Japanese is excluded from spell checking, English typos are flagged"
else
    fail "'spelllang' does not exclude CJK characters"
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
