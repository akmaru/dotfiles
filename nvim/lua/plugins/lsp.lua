-- LazyVim の extras が用意していない LSP サーバーを補う。
-- 旧 vim 構成の coc-css / coc-html / coc-sh に相当する。
-- ここに書いたサーバーは mason が自動でインストールする (:Mason で確認)。
return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        cssls = {},
        html = {},
        bashls = {},
      },
    },
  },
}
