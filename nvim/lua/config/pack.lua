-- vim.pack の薄いラッパーと、インストール・更新後のビルドフック。
local M = {}

--- "owner/repo" を GitHub の URL に展開して vim.pack.add() に渡す。
--- table の spec はそのまま (src だけ展開する)。
---@param specs (string|vim.pack.Spec)[]
function M.add(specs)
  local resolved = vim.tbl_map(function(spec)
    if type(spec) == "string" then
      spec = { src = spec }
    end
    if not spec.src:find("://") then
      spec.src = "https://github.com/" .. spec.src
    end
    return spec
  end, specs)
  -- confirm を切るのは、ヘッドレス起動 (test/test_nvim.sh や新しいマシンの初回起動) が
  -- インストール確認のダイアログで止まらないようにするため。
  -- 何が入るかは nvim-pack-lock.json の git diff でレビューする。
  vim.pack.add(resolved, { confirm = false })
end

-- lock ファイルからの一括インストールは最初の vim.pack.add() で走るので、
-- それより前にフックを登録しておく必要がある (:help vim.pack-events)。
vim.api.nvim_create_autocmd("PackChanged", {
  group = vim.api.nvim_create_augroup("pack_hooks", { clear = true }),
  callback = function(ev)
    local name, kind = ev.data.spec.name, ev.data.kind
    if kind ~= "install" and kind ~= "update" then
      return
    end
    -- インストール直後はまだ読み込まれていないので、フックがプラグインのコードを使う前に読み込む
    local function ensure_loaded()
      if not ev.data.active then
        vim.cmd.packadd(name)
      end
    end

    if name == "nvim-treesitter" and kind == "update" then
      -- パーサをプラグインのリビジョンに合わせて作り直す。
      -- 初回インストール時のパーサは plugins/treesitter.lua の install() が入れる
      ensure_loaded()
      vim.cmd("TSUpdate")
    elseif name == "markdown-preview.nvim" then
      -- プレビュー用のビルド済みバイナリを取ってくる
      ensure_loaded()
      vim.fn["mkdp#util#install"]()
    end
  end,
})

return M
