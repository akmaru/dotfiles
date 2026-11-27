-- LazyVim の既定キーマップ (lazyvim/config/keymaps.lua と snacks_picker extra) のうち、
-- 使っていたものを引き継いでいる。LSP 関連は plugins/lsp.lua の LspAttach、
-- git の hunk 操作は plugins/ui.lua の gitsigns にある。
local map = vim.keymap.set

-- 折り返した行を見た目どおりに上下する
map({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { desc = "Down", expr = true, silent = true })
map({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { desc = "Up", expr = true, silent = true })

-- ウィンドウ
map("n", "<C-h>", "<C-w>h", { desc = "Go to Left Window", remap = true })
map("n", "<C-j>", "<C-w>j", { desc = "Go to Lower Window", remap = true })
map("n", "<C-k>", "<C-w>k", { desc = "Go to Upper Window", remap = true })
map("n", "<C-l>", "<C-w>l", { desc = "Go to Right Window", remap = true })
map("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "Increase Window Height" })
map("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "Decrease Window Height" })
map("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease Window Width" })
map("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase Window Width" })
map("n", "<leader>-", "<C-W>s", { desc = "Split Window Below", remap = true })
map("n", "<leader>|", "<C-W>v", { desc = "Split Window Right", remap = true })
map("n", "<leader>wd", "<C-W>c", { desc = "Delete Window", remap = true })

-- 行の移動
map("n", "<A-j>", "<cmd>execute 'move .+' . v:count1<cr>==", { desc = "Move Down" })
map("n", "<A-k>", "<cmd>execute 'move .-' . (v:count1 + 1)<cr>==", { desc = "Move Up" })
map("i", "<A-j>", "<esc><cmd>m .+1<cr>==gi", { desc = "Move Down" })
map("i", "<A-k>", "<esc><cmd>m .-2<cr>==gi", { desc = "Move Up" })
map("v", "<A-j>", ":<C-u>execute \"'<,'>move '>+\" . v:count1<cr>gv=gv", { desc = "Move Down" })
map("v", "<A-k>", ":<C-u>execute \"'<,'>move '<-\" . (v:count1 + 1)<cr>gv=gv", { desc = "Move Up" })

-- バッファ
map("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Prev Buffer" })
map("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Next Buffer" })
map("n", "[b", "<cmd>bprevious<cr>", { desc = "Prev Buffer" })
map("n", "]b", "<cmd>bnext<cr>", { desc = "Next Buffer" })
map("n", "<leader>bb", "<cmd>e #<cr>", { desc = "Switch to Other Buffer" })
map("n", "<leader>`", "<cmd>e #<cr>", { desc = "Switch to Other Buffer" })
map("n", "<leader>bd", function() Snacks.bufdelete() end, { desc = "Delete Buffer" })
map("n", "<leader>bo", function() Snacks.bufdelete.other() end, { desc = "Delete Other Buffers" })
map("n", "<leader>bD", "<cmd>:bd<cr>", { desc = "Delete Buffer and Window" })

-- 検索・編集
map({ "i", "n", "s" }, "<esc>", function()
  vim.cmd("noh")
  if vim.snippet.active() then
    vim.snippet.stop()
  end
  return "<esc>"
end, { expr = true, desc = "Escape and Clear hlsearch" })
map("n", "n", "'Nn'[v:searchforward].'zv'", { expr = true, desc = "Next Search Result" })
map("n", "N", "'nN'[v:searchforward].'zv'", { expr = true, desc = "Prev Search Result" })
map({ "x", "o" }, "n", "'Nn'[v:searchforward]", { expr = true, desc = "Next Search Result" })
map({ "x", "o" }, "N", "'nN'[v:searchforward]", { expr = true, desc = "Prev Search Result" })
map("i", ",", ",<c-g>u") -- 句読点ごとに undo の区切りを入れる
map("i", ".", ".<c-g>u")
map("i", ";", ";<c-g>u")
map({ "i", "x", "n", "s" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "Save File" })
map("x", "<", "<gv")
map("x", ">", ">gv")
map("n", "gco", "o<esc>Vcx<esc><cmd>normal gcc<cr>fxa<bs>", { desc = "Add Comment Below" })
map("n", "gcO", "O<esc>Vcx<esc><cmd>normal gcc<cr>fxa<bs>", { desc = "Add Comment Above" })
map("n", "<leader>fn", "<cmd>enew<cr>", { desc = "New File" })
map("n", "<leader>qq", "<cmd>qa<cr>", { desc = "Quit All" })
map({ "n", "x" }, "<leader>cf", function() require("conform").format({ force = true }) end, { desc = "Format" })

-- 補完メニューを <Tab> / <S-Tab> で選ぶ。<C-y> で確定、<C-e> で閉じる
map("i", "<Tab>", function() return vim.fn.pumvisible() == 1 and "<C-n>" or "<Tab>" end, { expr = true })
map("i", "<S-Tab>", function() return vim.fn.pumvisible() == 1 and "<C-p>" or "<S-Tab>" end, { expr = true })

-- 診断
local function diagnostic_goto(next, severity)
  return function()
    vim.diagnostic.jump({
      count = (next and 1 or -1) * vim.v.count1,
      severity = severity and vim.diagnostic.severity[severity] or nil,
      float = true,
    })
  end
end
map("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Line Diagnostics" })
map("n", "]d", diagnostic_goto(true), { desc = "Next Diagnostic" })
map("n", "[d", diagnostic_goto(false), { desc = "Prev Diagnostic" })
map("n", "]e", diagnostic_goto(true, "ERROR"), { desc = "Next Error" })
map("n", "[e", diagnostic_goto(false, "ERROR"), { desc = "Prev Error" })
map("n", "]w", diagnostic_goto(true, "WARN"), { desc = "Next Warning" })
map("n", "[w", diagnostic_goto(false, "WARN"), { desc = "Prev Warning" })
map("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", { desc = "Diagnostics (Trouble)" })
map("n", "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", { desc = "Buffer Diagnostics (Trouble)" })
map("n", "<leader>xL", "<cmd>Trouble loclist toggle<cr>", { desc = "Location List (Trouble)" })
map("n", "<leader>xQ", "<cmd>Trouble qflist toggle<cr>", { desc = "Quickfix List (Trouble)" })
map("n", "<leader>xt", "<cmd>Trouble todo toggle<cr>", { desc = "Todo (Trouble)" })
map("n", "[q", vim.cmd.cprev, { desc = "Previous Quickfix" })
map("n", "]q", vim.cmd.cnext, { desc = "Next Quickfix" })
map("n", "]t", function() require("todo-comments").jump_next() end, { desc = "Next Todo Comment" })
map("n", "[t", function() require("todo-comments").jump_prev() end, { desc = "Previous Todo Comment" })

-- ピッカー (snacks)
local P = function(name, opts)
  return function() Snacks.picker[name](opts) end
end
map("n", "<leader><space>", P("files"), { desc = "Find Files" })
map("n", "<leader>/", P("grep"), { desc = "Grep" })
map("n", "<leader>,", P("buffers"), { desc = "Buffers" })
map("n", "<leader>:", P("command_history"), { desc = "Command History" })
map("n", "<leader>n", P("notifications"), { desc = "Notification History" })
map("n", "<leader>fb", P("buffers"), { desc = "Buffers" })
map("n", "<leader>fc", P("files", { cwd = vim.fn.stdpath("config") }), { desc = "Find Config File" })
map("n", "<leader>ff", P("files"), { desc = "Find Files" })
map("n", "<leader>fg", P("git_files"), { desc = "Find Files (git-files)" })
map("n", "<leader>fr", P("recent"), { desc = "Recent" })
map("n", "<leader>fR", P("recent", { filter = { cwd = true } }), { desc = "Recent (cwd)" })
map("n", "<leader>gd", P("git_diff"), { desc = "Git Diff (hunks)" })
map("n", "<leader>gs", P("git_status"), { desc = "Git Status" })
map("n", "<leader>gS", P("git_stash"), { desc = "Git Stash" })
map("n", "<leader>gl", P("git_log"), { desc = "Git Log" })
map("n", "<leader>gb", P("git_log_line"), { desc = "Git Blame Line" })
map("n", "<leader>gf", P("git_log_file"), { desc = "Git Current File History" })
map("n", "<leader>gi", P("gh_issue"), { desc = "GitHub Issues (open)" })
map("n", "<leader>gp", P("gh_pr"), { desc = "GitHub Pull Requests (open)" })
map({ "n", "x" }, "<leader>sw", P("grep_word"), { desc = "Visual selection or word" })
map("n", "<leader>sb", P("lines"), { desc = "Buffer Lines" })
map("n", "<leader>sB", P("grep_buffers"), { desc = "Grep Open Buffers" })
map("n", "<leader>sg", P("grep"), { desc = "Grep" })
map("n", "<leader>sa", P("autocmds"), { desc = "Autocmds" })
map("n", "<leader>sc", P("command_history"), { desc = "Command History" })
map("n", "<leader>sC", P("commands"), { desc = "Commands" })
map("n", "<leader>sd", P("diagnostics"), { desc = "Diagnostics" })
map("n", "<leader>sD", P("diagnostics_buffer"), { desc = "Buffer Diagnostics" })
map("n", "<leader>sh", P("help"), { desc = "Help Pages" })
map("n", "<leader>sH", P("highlights"), { desc = "Highlights" })
map("n", "<leader>si", P("icons"), { desc = "Icons" })
map("n", "<leader>sj", P("jumps"), { desc = "Jumps" })
map("n", "<leader>sk", P("keymaps"), { desc = "Keymaps" })
map("n", "<leader>sl", P("loclist"), { desc = "Location List" })
map("n", "<leader>sM", P("man"), { desc = "Man Pages" })
map("n", "<leader>sm", P("marks"), { desc = "Marks" })
map("n", "<leader>sR", P("resume"), { desc = "Resume" })
map("n", "<leader>sq", P("qflist"), { desc = "Quickfix List" })
map("n", "<leader>su", P("undo"), { desc = "Undotree" })
map("n", "<leader>st", function() Snacks.picker.todo_comments() end, { desc = "Todo" })
map("n", "<leader>uC", P("colorschemes"), { desc = "Colorschemes" })
map({ "n", "x" }, "<leader>sr", function()
  require("grug-far").open({ transient = true })
end, { desc = "Search and Replace" })

-- ファイラ (neo-tree)
map("n", "<leader>e", "<cmd>Neotree toggle reveal_force_cwd<cr>", { desc = "Explorer NeoTree" })
map("n", "<leader>fe", "<cmd>Neotree toggle reveal_force_cwd<cr>", { desc = "Explorer NeoTree" })
map("n", "<leader>ge", "<cmd>Neotree float git_status<cr>", { desc = "Git Explorer" })
map("n", "<leader>be", "<cmd>Neotree float buffers<cr>", { desc = "Buffer Explorer" })

-- git (snacks)
if vim.fn.executable("lazygit") == 1 then
  map("n", "<leader>gg", function() Snacks.lazygit() end, { desc = "Lazygit" })
end
map({ "n", "x" }, "<leader>gB", function() Snacks.gitbrowse() end, { desc = "Git Browse (open)" })

-- ジャンプ (flash)
map({ "n", "x", "o" }, "s", function() require("flash").jump() end, { desc = "Flash" })
map({ "n", "x", "o" }, "S", function() require("flash").treesitter() end, { desc = "Flash Treesitter" })
map("o", "r", function() require("flash").remote() end, { desc = "Remote Flash" })

-- セッション (persistence)
map("n", "<leader>qs", function() require("persistence").load() end, { desc = "Restore Session" })
map("n", "<leader>ql", function() require("persistence").load({ last = true }) end, { desc = "Restore Last Session" })
map("n", "<leader>qd", function() require("persistence").stop() end, { desc = "Don't Save Current Session" })

-- ターミナル
map({ "n", "t" }, "<c-/>", function() Snacks.terminal.focus() end, { desc = "Terminal" })
map({ "n", "t" }, "<c-_>", function() Snacks.terminal.focus() end, { desc = "which_key_ignore" })

-- 表示の切り替え (snacks.toggle)
Snacks.toggle({
  name = "Auto Format",
  get = function() return vim.g.autoformat ~= false end,
  set = function(state) vim.g.autoformat = state end,
}):map("<leader>uf")
Snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>us")
Snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>uw")
Snacks.toggle.option("relativenumber", { name = "Relative Number" }):map("<leader>uL")
Snacks.toggle.diagnostics():map("<leader>ud")
Snacks.toggle.line_number():map("<leader>ul")
Snacks.toggle.treesitter():map("<leader>uT")
Snacks.toggle.inlay_hints():map("<leader>uh")
Snacks.toggle.indent():map("<leader>ug")
Snacks.toggle.zoom():map("<leader>wm")
Snacks.toggle.zen():map("<leader>uz")
map("n", "<leader>un", function() Snacks.notifier.hide() end, { desc = "Dismiss All Notifications" })

-- タブ
map("n", "<leader><tab><tab>", "<cmd>tabnew<cr>", { desc = "New Tab" })
map("n", "<leader><tab>]", "<cmd>tabnext<cr>", { desc = "Next Tab" })
map("n", "<leader><tab>[", "<cmd>tabprevious<cr>", { desc = "Previous Tab" })
map("n", "<leader><tab>d", "<cmd>tabclose<cr>", { desc = "Close Tab" })
map("n", "<leader><tab>o", "<cmd>tabonly<cr>", { desc = "Close Other Tabs" })

-- 画像 (snacks.image)
-- インライン表示は max_width / max_height に縮められるので、大きく見たいときはタブ全体に開く。
-- src は resolve 後のパスなので、drawio.svg は書き出し済みの PNG が開く。
-- Snacks.image.doc.at_cursor() は行範囲を絞って構文木を解析し、markdown_inline の注入が
-- 未解析だと画像を見落とすので、バッファ全体を find() してカーソル位置と自分で照合する
map("n", "<leader>io", function()
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  Snacks.image.doc.find(vim.api.nvim_get_current_buf(), function(imgs)
    for _, img in ipairs(imgs) do
      local r = img.range
      if r and row >= r[1] and row <= r[3] and (r[1] ~= r[3] or (col >= r[2] and col <= r[4])) then
        return vim.schedule(function() vim.cmd.tabedit(vim.fn.fnameescape(img.src)) end)
      end
    end
    Snacks.notify.warn("No image under cursor")
  end)
end, { desc = "Open Image in Tab" })

-- プラグインの更新 (確認バッファで :write すると適用される)
map("n", "<leader>pu", function() vim.pack.update() end, { desc = "Update Plugins" })
