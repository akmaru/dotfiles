-- LSP は Neovim 本体の vim.lsp.config() / vim.lsp.enable() で動かす。
-- nvim-lspconfig はサーバーごとの既定設定 (lsp/*.lua) の配布元としてだけ使い、
-- mason はサーバー・フォーマッタ・リンタのインストールだけを担う。
require("config.pack").add({
  "neovim/nvim-lspconfig",
  "mason-org/mason.nvim",
  "mason-org/mason-lspconfig.nvim",
  "folke/lazydev.nvim", -- nvim の設定を書くときの lua_ls 用の型情報
  "b0o/SchemaStore.nvim", -- jsonls / yamlls 用の JSON Schema 集
})

-- 起動するサーバー。旧 vim 構成の coc-* と LazyVim の lang extras に対応する。
-- rust_analyzer は rustaceanvim が自分で起動するので入れない (plugins/lang.lua)
local servers = {
  "bashls", "cssls", "html", "jsonls", "lua_ls", "marksman", "taplo", "yamlls",
  "gopls", "pyright", "ruff", "vtsls",
  "clangd", "neocmake",
  "terraformls", "dockerls", "docker_compose_language_service", "ansiblels",
}

-- mason で入れるフォーマッタ・リンタなど (plugins/format.lua で使う)
local tools = {
  "stylua", "shfmt", "shellcheck", "prettier", "markdownlint-cli2", "markdown-toc",
  "goimports", "gofumpt", "golangci-lint", "rust-analyzer",
  "cmakelang", "cmakelint", "hadolint", "tflint", "sqlfluff", "ansible-lint",
}

require("mason").setup()
require("mason-lspconfig").setup({
  ensure_installed = servers,
  automatic_enable = false, -- 起動するサーバーは下の vim.lsp.enable() で明示する
})

-- mason には lspconfig 名以外のツールを自動で入れる機能がないので、足りないものだけ入れる
local registry = require("mason-registry")
registry.refresh(function()
  for _, name in ipairs(tools) do
    local ok, pkg = pcall(registry.get_package, name)
    if ok and not pkg:is_installed() and not pkg:is_installing() then
      pkg:install()
    end
  end
end)

require("lazydev").setup({
  library = { { path = "${3rd}/luv/library", words = { "vim%.uv" } } },
})

vim.lsp.config("*", {
  -- 補完で選んだ候補のスニペット展開や import の追加を、サーバーに伝える
  capabilities = vim.lsp.protocol.make_client_capabilities(),
})
vim.lsp.config("jsonls", {
  settings = { json = { schemas = require("schemastore").json.schemas(), validate = { enable = true } } },
})
vim.lsp.config("yamlls", {
  settings = {
    yaml = {
      -- SchemaStore.nvim から渡すので、yamlls 自身の取得は切る
      schemaStore = { enable = false, url = "" },
      schemas = require("schemastore").yaml.schemas(),
      keyOrdering = false,
    },
  },
})
vim.lsp.config("gopls", {
  settings = {
    gopls = {
      gofumpt = true,
      usePlaceholders = true,
      completeUnimported = true,
      staticcheck = true,
      semanticTokens = true,
      hints = {
        assignVariableTypes = true,
        compositeLiteralFields = true,
        constantValues = true,
        functionTypeParameters = true,
        parameterNames = true,
        rangeVariableTypes = true,
      },
    },
  },
})
vim.lsp.config("clangd", {
  cmd = {
    "clangd",
    "--background-index",
    "--clang-tidy",
    "--header-insertion=iwyu",
    "--completion-style=detailed",
    "--function-arg-placeholders",
    "--fallback-style=llvm",
  },
})
-- 型やフォーマットは pyright と ruff で分担する。hover は pyright のほうが詳しい
vim.lsp.config("ruff", {
  on_attach = function(client)
    client.server_capabilities.hoverProvider = false
  end,
})

vim.lsp.enable(servers)

vim.diagnostic.config({
  underline = true,
  update_in_insert = false,
  severity_sort = true,
  virtual_text = { spacing = 4, source = "if_many", prefix = "●" },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = " ",
      [vim.diagnostic.severity.WARN] = " ",
      [vim.diagnostic.severity.HINT] = " ",
      [vim.diagnostic.severity.INFO] = " ",
    },
  },
})

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("lsp_attach", { clear = true }),
  callback = function(ev)
    local client = assert(vim.lsp.get_client_by_id(ev.data.client_id))
    local buf = ev.buf

    -- 候補の表示は 'autocomplete' が行う (options.lua)。ここで有効にするのは、
    -- 確定 (<C-y>) したときのスニペット展開や import の追加といった副作用のほう
    if client:supports_method("textDocument/completion") then
      vim.lsp.completion.enable(true, client.id, buf, { autotrigger = false })
    end
    if client:supports_method("textDocument/inlayHint") then
      vim.lsp.inlay_hint.enable(true, { bufnr = buf })
    end

    -- LazyVim と同じキーマップ。Neovim 0.11 の既定 (grn / gra / grr / gri / K) もそのまま使える
    local function map(mode, lhs, rhs, desc, opts)
      vim.keymap.set(mode, lhs, rhs, vim.tbl_extend("force", { buffer = buf, desc = desc }, opts or {}))
    end
    map("n", "gd", function() Snacks.picker.lsp_definitions() end, "Goto Definition")
    map("n", "gr", function() Snacks.picker.lsp_references() end, "References", { nowait = true })
    map("n", "gI", function() Snacks.picker.lsp_implementations() end, "Goto Implementation")
    map("n", "gy", function() Snacks.picker.lsp_type_definitions() end, "Goto T[y]pe Definition")
    map("n", "gD", vim.lsp.buf.declaration, "Goto Declaration")
    map("n", "gK", vim.lsp.buf.signature_help, "Signature Help")
    map("i", "<c-k>", vim.lsp.buf.signature_help, "Signature Help")
    map({ "n", "x" }, "<leader>ca", vim.lsp.buf.code_action, "Code Action")
    map("n", "<leader>cr", vim.lsp.buf.rename, "Rename")
    map("n", "<leader>cR", function() Snacks.rename.rename_file() end, "Rename File")
    map("n", "<leader>cl", function() Snacks.picker.lsp_config() end, "Lsp Info")
    map("n", "<leader>ss", function() Snacks.picker.lsp_symbols() end, "LSP Symbols")
    map("n", "<leader>sS", function() Snacks.picker.lsp_workspace_symbols() end, "LSP Workspace Symbols")
    map("n", "]]", function() Snacks.words.jump(vim.v.count1) end, "Next Reference")
    map("n", "[[", function() Snacks.words.jump(-vim.v.count1) end, "Prev Reference")
  end,
})
