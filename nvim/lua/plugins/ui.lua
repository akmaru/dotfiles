-- 画面まわり: snacks (ピッカー・通知・lazygit など)、ステータスライン、バッファ一覧、
-- キーマップのガイド、ファイラ、git の差分表示、一覧パネル。
require("config.pack").add({
  "folke/snacks.nvim",
  "nvim-mini/mini.nvim", -- mini.icons / mini.ai / mini.pairs をこの 1 リポジトリでまかなう
  "nvim-lualine/lualine.nvim",
  "akinsho/bufferline.nvim",
  "folke/which-key.nvim",
  "lewis6991/gitsigns.nvim",
  "folke/trouble.nvim",
  "folke/todo-comments.nvim",
  -- neo-tree とその依存
  "nvim-lua/plenary.nvim",
  "MunifTanjim/nui.nvim",
  "nvim-neo-tree/neo-tree.nvim",
})

-- アイコン。nvim-web-devicons を前提にするプラグイン (neo-tree, bufferline など) にも
-- mini.icons を使わせる
require("mini.icons").setup()
MiniIcons.mock_nvim_web_devicons()

-- draw.io の SVG はラベルを foreignObject (HTML) で描き、ImageMagick では変換に失敗する。
-- そこで drawio CLI で PNG に書き出したものを snacks に渡す。書き出しに 2 秒ほどかかるので、
-- 元ファイルのパスと更新時刻をキーにキャッシュし、図を更新したときだけ書き出し直す。
local function resolve_drawio_svg(file, src)
  if not src:match("%.drawio%.svg$") or src:match("^%a+://") then
    return nil
  end
  local path = vim.fs.normalize(vim.fs.joinpath(vim.fs.dirname(file), src))
  local stat = vim.uv.fs_stat(path)
  if not stat or vim.fn.executable("drawio") == 0 then
    return nil
  end
  local dir = vim.fn.stdpath("cache") .. "/drawio-png"
  local png = ("%s/%s.png"):format(dir, vim.fn.sha256(path .. ":" .. stat.mtime.sec))
  if not vim.uv.fs_stat(png) then
    vim.fn.mkdir(dir, "p")
    -- headless のまま書き出すため、X なしで動く ozone と、SUID サンドボックスを使わない指定が要る
    vim
      .system({ "drawio", "--no-sandbox", "--ozone-platform=headless", "-x", "-f", "png", "-s", "2", "-o", png, path })
      :wait()
  end
  return vim.uv.fs_stat(png) and png or nil
end

require("snacks").setup({
  bigfile = { enabled = true },
  quickfile = { enabled = true },
  indent = { enabled = true },
  input = { enabled = true },
  notifier = { enabled = true },
  picker = { enabled = true },
  scope = { enabled = true },
  scroll = { enabled = true },
  words = { enabled = true },
  dashboard = {
    enabled = true,
    -- 既定の "startup" セクションは lazy.nvim の起動統計 (lazy.stats) を読むので外す
    sections = {
      { section = "header" },
      { section = "keys", gap = 1, padding = 1 },
    },
  },
  statuscolumn = { enabled = true },
  -- render-markdown.nvim は画像を描かないので、Markdown 内の画像は snacks が Kitty graphics で描く
  image = { enabled = true, resolve = resolve_drawio_svg },
})

require("lualine").setup({
  options = {
    theme = "auto",
    globalstatus = true,
    disabled_filetypes = { statusline = { "snacks_dashboard" } },
  },
  sections = {
    lualine_c = { { "diagnostics" }, { "filetype", icon_only = true, separator = "" }, { "filename", path = 1 } },
    lualine_x = { "diff" },
    lualine_y = { "progress", "location" },
    lualine_z = {},
  },
  extensions = { "neo-tree", "trouble" },
})

require("bufferline").setup({
  options = {
    close_command = function(n)
      Snacks.bufdelete(n)
    end,
    diagnostics = "nvim_lsp",
    always_show_bufferline = false,
    offsets = { { filetype = "neo-tree", text = "Neo-tree", highlight = "Directory", text_align = "left" } },
  },
})

require("which-key").setup({
  preset = "helix",
  spec = {
    { "<leader>b", group = "buffer" },
    { "<leader>c", group = "code" },
    { "<leader>f", group = "file/find" },
    { "<leader>g", group = "git" },
    { "<leader>gh", group = "hunks" },
    { "<leader>q", group = "quit/session" },
    { "<leader>s", group = "search" },
    { "<leader>u", group = "ui" },
    { "<leader>w", group = "windows", proxy = "<c-w>" },
    { "<leader>x", group = "diagnostics/quickfix" },
    { "<leader><tab>", group = "tabs" },
    { "[", group = "prev" },
    { "]", group = "next" },
    { "g", group = "goto" },
    { "gs", group = "surround" },
    { "z", group = "fold" },
  },
})

require("gitsigns").setup({
  on_attach = function(buf)
    local gs = package.loaded.gitsigns
    local function map(mode, l, r, desc)
      vim.keymap.set(mode, l, r, { buffer = buf, desc = desc })
    end
    map("n", "]h", function()
      if vim.wo.diff then
        vim.cmd.normal({ "]c", bang = true })
      else
        gs.nav_hunk("next")
      end
    end, "Next Hunk")
    map("n", "[h", function()
      if vim.wo.diff then
        vim.cmd.normal({ "[c", bang = true })
      else
        gs.nav_hunk("prev")
      end
    end, "Prev Hunk")
    map({ "n", "x" }, "<leader>ghs", ":Gitsigns stage_hunk<CR>", "Stage Hunk")
    map({ "n", "x" }, "<leader>ghr", ":Gitsigns reset_hunk<CR>", "Reset Hunk")
    map("n", "<leader>ghS", gs.stage_buffer, "Stage Buffer")
    map("n", "<leader>ghR", gs.reset_buffer, "Reset Buffer")
    map("n", "<leader>ghp", gs.preview_hunk_inline, "Preview Hunk Inline")
    map("n", "<leader>ghb", function()
      gs.blame_line({ full = true })
    end, "Blame Line")
    map("n", "<leader>ghd", gs.diffthis, "Diff This")
    map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "GitSigns Select Hunk")
  end,
})

require("trouble").setup({})
require("todo-comments").setup({})

require("neo-tree").setup({
  sources = { "filesystem", "buffers", "git_status" },
  open_files_do_not_replace_types = { "terminal", "Trouble", "trouble", "qf" },
  filesystem = {
    bind_to_cwd = false,
    follow_current_file = { enabled = true },
    use_libuv_file_watcher = true,
  },
  window = {
    mappings = {
      ["l"] = "open",
      ["h"] = "close_node",
      ["<space>"] = "none",
      ["P"] = { "toggle_preview", config = { use_float = false } },
    },
  },
})
