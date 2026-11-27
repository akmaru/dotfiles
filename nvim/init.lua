-- vim.pack は vim.pack.add() が呼ばれた順にプラグインを読み込むので、
-- ここでの require の順序がそのまま読み込み順になる。
-- 遅延読み込みはしない (docs/nvim.md の「遅延読み込みをしない理由」)。

-- <leader> を使うキーマップより先に決めておく必要がある
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

require("config.options")
require("config.pack") -- 最初の vim.pack.add() より前に PackChanged フックを登録する

require("plugins.colorscheme") -- 他の UI プラグインが配色を参照するので先頭
require("plugins.ui")
require("plugins.editor")
require("plugins.treesitter")
require("plugins.lsp")
require("plugins.format")
require("plugins.lang")
require("plugins.herdr")

require("config.keymaps")
require("config.autocmds")
