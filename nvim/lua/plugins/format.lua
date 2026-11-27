-- 保存時のフォーマット (conform) とリンタ (nvim-lint)。
-- ここに書いたツールは plugins/lsp.lua の tools で mason がインストールする。
require("config.pack").add({
  "stevearc/conform.nvim",
  "mfussenegger/nvim-lint",
})

-- <leader>uf で切り替える。LazyVim の vim.g.autoformat と同じ役割
vim.g.autoformat = true

require("conform").setup({
  formatters_by_ft = {
    lua = { "stylua" },
    sh = { "shfmt" },
    bash = { "shfmt" },
    go = { "goimports", "gofumpt" },
    python = { "ruff_organize_imports", "ruff_format" },
    markdown = { "prettier", "markdownlint-cli2", "markdown-toc" },
    ["markdown.mdx"] = { "prettier", "markdownlint-cli2", "markdown-toc" },
    cmake = { "cmake_format" },
    terraform = { "terraform_fmt" },
    tf = { "terraform_fmt" },
    ["terraform-vars"] = { "terraform_fmt" },
    sql = { "sqlfluff" },
    javascript = { "prettier" },
    typescript = { "prettier" },
    javascriptreact = { "prettier" },
    typescriptreact = { "prettier" },
    json = { "prettier" },
    jsonc = { "prettier" },
    yaml = { "prettier" },
    css = { "prettier" },
    html = { "prettier" },
  },
  -- フォーマッタが無い言語 (Rust, C/C++ など) は LSP に任せる
  default_format_opts = { lsp_format = "fallback" },
  formatters = {
    sqlfluff = { args = { "format", "--dialect=ansi", "-" } },
  },
  format_on_save = function(buf)
    if vim.g.autoformat == false or vim.b[buf].autoformat == false then
      return nil
    end
    return { timeout_ms = 3000 }
  end,
})
vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"

local lint = require("lint")
lint.linters_by_ft = {
  sh = { "shellcheck" },
  bash = { "shellcheck" },
  dockerfile = { "hadolint" },
  markdown = { "markdownlint-cli2" },
  cmake = { "cmakelint" },
  terraform = { "terraform_validate" },
  tf = { "terraform_validate" },
  sql = { "sqlfluff" },
  go = { "golangcilint" },
}
vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
  group = vim.api.nvim_create_augroup("lint", { clear = true }),
  callback = function()
    -- 実行ファイルが無いリンタ (mason のインストール待ちなど) はエラーにせず飛ばす
    lint.try_lint(nil, { ignore_errors = true })
  end,
})
