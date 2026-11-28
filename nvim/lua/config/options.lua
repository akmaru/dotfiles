-- LazyVim の既定 (lazyvim/config/options.lua) のうち、使っていたものを引き継いでいる
local opt = vim.opt

opt.number = true
opt.relativenumber = false -- 絶対行番号にする
opt.cursorline = true
opt.signcolumn = "yes" -- 診断や git の記号でテキストが左右にずれないようにする
opt.termguicolors = true
opt.laststatus = 3 -- ウィンドウを分けてもステータスラインは 1 本
opt.showmode = false -- モードは lualine に出す
opt.ruler = false
opt.list = true
opt.wrap = false
opt.linebreak = true
opt.scrolloff = 4
opt.sidescrolloff = 8
opt.smoothscroll = true
opt.splitbelow = true
opt.splitright = true
opt.splitkeep = "screen"
opt.winminwidth = 5
opt.pumheight = 10
opt.fillchars = { foldopen = "", foldclose = "", fold = " ", foldsep = " ", diff = "╱", eob = " " }

opt.mouse = "a"
opt.clipboard = vim.env.SSH_CONNECTION and "" or "unnamedplus" -- SSH 越しでは OSC 52 の往復を避ける
opt.confirm = true
opt.autowrite = true
opt.undofile = true
opt.undolevels = 10000
opt.updatetime = 200
opt.timeoutlen = 300 -- which-key がすぐ出るように
opt.virtualedit = "block"
opt.jumpoptions = "view"

opt.expandtab = true
opt.shiftwidth = 2
opt.tabstop = 2
opt.shiftround = true
opt.smartindent = true
opt.formatoptions = "jcroqlnt"

opt.ignorecase = true
opt.smartcase = true
opt.inccommand = "nosplit"
opt.grepprg = "rg --vimgrep"
opt.grepformat = "%f:%l:%c:%m"

opt.foldlevel = 99
opt.foldmethod = "indent" -- treesitter が使えるバッファでは autocmds.lua で expr に切り替える
opt.foldtext = ""

opt.sessionoptions = { "buffers", "curdir", "tabpages", "winsize", "help", "globals", "skiprtp", "folds" }
opt.shortmess:append({ W = true, I = true, c = true, C = true })
opt.spelllang = { "en", "cjk" } -- cjk: 日本語はスペルチェックの対象から外す (:h spell-cjk)
opt.wildmode = "longest:full,full"

-- 組み込みの自動補完 (Neovim 0.12)。blink.cmp の代わり。
-- 候補は LSP (omnifunc) → 現在のバッファ → 他のウィンドウ → 他のバッファ の順。
-- LSP 側の設定 (スニペット展開など) は plugins/lsp.lua の LspAttach にある
opt.autocomplete = true
opt.complete = { "o", ".^5", "w^5", "b^5" }
opt.completeopt = { "menuone", "noselect", "popup", "fuzzy" }

vim.g.markdown_recommended_style = 0
