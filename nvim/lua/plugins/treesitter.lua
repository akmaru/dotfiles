-- nvim-treesitter (main ブランチ) はパーサとクエリの配布だけを担い、
-- ハイライト・折りたたみは Neovim 本体の機能を FileType で有効にする (autocmds.lua)。
-- パーサのビルドには tree-sitter CLI と C コンパイラが要る (docs/nvim.md)。
require("config.pack").add({
  "nvim-treesitter/nvim-treesitter",
  "nvim-treesitter/nvim-treesitter-textobjects",
  "windwp/nvim-ts-autotag",
})

local parsers = {
  -- 基本
  "bash", "c", "diff", "html", "css", "javascript", "jsdoc", "json", "json5", "lua", "luadoc",
  "luap", "markdown", "markdown_inline", "printf", "query", "regex", "toml", "vim", "vimdoc", "xml", "yaml",
  -- git
  "git_config", "gitcommit", "git_rebase", "gitignore", "gitattributes",
  -- Go / Rust / Python / TypeScript
  "go", "gomod", "gowork", "gosum", "rust", "ron", "python", "ninja", "rst", "typescript", "tsx",
  -- C / C++ / CMake
  "cpp", "cmake",
  -- Terraform / Docker / SQL
  "terraform", "hcl", "dockerfile", "sql",
}
-- 非同期で走り、入っているものは何もしない。新しいマシンでは初回起動の裏でビルドが進む
require("nvim-treesitter").install(parsers)

require("nvim-treesitter-textobjects").setup({
  move = { set_jumps = true },
})
-- ]f / [f で関数、]c / [c でクラス、]a / [a で引数の間を移動する
local move = require("nvim-treesitter-textobjects.move")
for key, query in pairs({ f = "@function.outer", c = "@class.outer", a = "@parameter.inner" }) do
  vim.keymap.set({ "n", "x", "o" }, "]" .. key, function()
    move.goto_next_start(query, "textobjects")
  end, { desc = "Next " .. query })
  vim.keymap.set({ "n", "x", "o" }, "[" .. key, function()
    move.goto_previous_start(query, "textobjects")
  end, { desc = "Prev " .. query })
end

require("nvim-ts-autotag").setup({})
