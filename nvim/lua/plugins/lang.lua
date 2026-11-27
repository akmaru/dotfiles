-- 言語ごとの追加プラグイン。LSP サーバー自体は plugins/lsp.lua で起動する。
require("config.pack").add({
  -- Rust: rust-analyzer の起動と拡張機能 (Cargo.toml の依存補完は crates)
  "mrcjkb/rustaceanvim",
  "Saecki/crates.nvim",
  -- C / C++ / CMake
  "p00f/clangd_extensions.nvim",
  "Civitasv/cmake-tools.nvim",
  -- Markdown: バッファ内の整形表示と、ブラウザでのプレビュー
  "MeanderingProgrammer/render-markdown.nvim",
  "iamcco/markdown-preview.nvim", -- ビルドは config/pack.lua の PackChanged フック
  -- SQL: DB への接続とクエリ実行の UI。補完は omnifunc 経由で組み込み補完に出る
  "tpope/vim-dadbod",
  "kristijanhusak/vim-dadbod-ui",
  "kristijanhusak/vim-dadbod-completion",
  -- Ansible: playbook の filetype 判定 (yaml.ansible) と ansiblels 向けの設定
  "mfussenegger/nvim-ansible",
})

-- rustaceanvim は setup() を持たず、この変数を読む
vim.g.rustaceanvim = {
  server = {
    default_settings = {
      ["rust-analyzer"] = {
        cargo = { allFeatures = true, loadOutDirsFromCheck = true, buildScripts = { enable = true } },
        checkOnSave = true,
        procMacro = { enable = true },
      },
    },
  },
}
require("crates").setup({ completion = { crates = { enabled = true } }, lsp = { enabled = true, actions = true, completion = true, hover = true } })

require("clangd_extensions").setup({})
require("cmake-tools").setup({})

require("render-markdown").setup({
  code = { sign = false, width = "block", right_pad = 1 },
  heading = { sign = false, icons = {} },
  checkbox = { enabled = false },
})
vim.g.mkdp_filetypes = { "markdown" }

vim.g.db_ui_use_nerd_fonts = 1
vim.g.db_ui_save_location = vim.fn.stdpath("data") .. "/dadbod_ui"
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("dadbod_completion", { clear = true }),
  pattern = { "sql", "mysql", "plsql" },
  callback = function()
    vim.bo.omnifunc = "vim_dadbod_completion#omni"
  end,
})
