-- 編集まわり: テキストオブジェクト、括弧の自動補完、ジャンプ、検索置換、セッション。
-- mini.nvim は plugins/ui.lua で追加済み。
require("config.pack").add({
  "folke/flash.nvim",
  "MagicDuck/grug-far.nvim",
  "folke/persistence.nvim",
})

-- af/if (関数)、ac/ic (クラス)、ao/io (ブロック) などを treesitter で拡張する
local ai = require("mini.ai")
ai.setup({
  n_lines = 500,
  custom_textobjects = {
    o = ai.gen_spec.treesitter({
      a = { "@block.outer", "@conditional.outer", "@loop.outer" },
      i = { "@block.inner", "@conditional.inner", "@loop.inner" },
    }),
    f = ai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }),
    c = ai.gen_spec.treesitter({ a = "@class.outer", i = "@class.inner" }),
    t = { "<([%p%w]-)%f[^<%w][^<>]->.-</%1>", "^<.->().*()</[^/]->$" },
    d = { "%f[%d]%d+" },
    u = ai.gen_spec.function_call(),
    U = ai.gen_spec.function_call({ name_pattern = "[%w_]" }),
  },
})

require("mini.pairs").setup({
  modes = { insert = true, command = true, terminal = false },
})

require("flash").setup({})
require("grug-far").setup({ headerMaxWidth = 80 })
require("persistence").setup({})
