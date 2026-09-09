-- 旧 vim 構成の molokai を引き継ぐ配色。
-- tomasr/molokai は Vim script 時代のもので treesitter / LSP semantic token の
-- ハイライトグループを持たないため、それらに対応した monokai-pro.nvim を使う。
return {
  {
    "loctvl842/monokai-pro.nvim",
    lazy = false,
    priority = 1000, -- 他のプラグインより先に読み込む
    opts = {
      -- molokai の元になったオリジナルの Monokai 配色。
      -- pro / machine / octagon / ristretto / spectrum に変えると印象が変わる
      filter = "classic",
    },
  },

  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "monokai-pro",
    },
  },
}
