# Neovim

## 構成

nvim は Neovim 0.12 の組み込みプラグインマネージャ [`vim.pack`](https://neovim.io/doc/user/pack.html#vim.pack)
を使った、自前の Lua 設定で動かす。LazyVim (lazy.nvim) からの移行の経緯は
「[LazyVim をやめた理由](#lazyvim-をやめた理由)」を参照。

```
dotfiles/nvim/  →  ~/.config/nvim   (ディレクトリごと symlink)
```

```
nvim/
├── init.lua                   # 下の各ファイルを決まった順に require する
├── nvim-pack-lock.json        # プラグインのリビジョン固定 (vim.pack が自動生成)
├── lua/config/
│   ├── options.lua            # オプション (組み込み補完の設定を含む)
│   ├── pack.lua               # vim.pack.add() のラッパーと、ビルド用の PackChanged フック
│   ├── keymaps.lua            # キーマップ (LazyVim の既定を引き継いだもの)
│   └── autocmds.lua           # autocmd (treesitter の有効化を含む)
└── lua/plugins/
    ├── colorscheme.lua        # monokai-pro
    ├── ui.lua                 # snacks, lualine, bufferline, which-key, gitsigns, neo-tree, trouble など
    ├── editor.lua             # mini.ai, mini.pairs, flash, grug-far, persistence
    ├── treesitter.lua         # nvim-treesitter (main ブランチ) とパーサの一覧
    ├── lsp.lua                # vim.lsp.config / vim.lsp.enable、mason、診断表示、LSP のキーマップ
    ├── format.lua             # conform (保存時フォーマット), nvim-lint
    ├── lang.lua               # 言語別 (Rust, C/C++, Markdown, SQL, Ansible)
    └── herdr.lua              # herdr-nvim
```

各ファイルは先頭で `require("config.pack").add({...})` を呼んでプラグインを追加し、続けて `setup()` を呼ぶ。
`vim.pack.add()` は呼ばれた時点でプラグインを読み込むので、`init.lua` の `require` の順序がそのまま読み込み順になる。

### ファイル単位でなくディレクトリごとリンクする理由

`vim.pack` はプラグインのリビジョンを `nvim-pack-lock.json` として `stdpath("config")` = `~/.config/nvim`
直下へ書き出す。ディレクトリごと symlink しておけば、この書き込みがそのままリポジトリの作業ツリーに現れ、
更新した構成をコミットして他のマシンで再現できる。

### 遅延読み込みをしない理由

`vim.pack` には lazy.nvim の `event` / `cmd` / `keys` のような宣言的な遅延読み込みがない。
autocmd の中で `vim.pack.add()` を呼べば自前で遅延できるが、今は使っていない。

- 使うプラグインだけに絞ったので、全部を起動時に読み込んでも起動時間は許容できる範囲に収まる
- 遅延読み込みの条件を自分で書くと、そのぶん「なぜ今このプラグインが動かないのか」を追う手間が増える

起動が遅いと感じたら、`nvim --startuptime` で重いプラグインを特定し、そのプラグインだけ autocmd で遅延させる。

### 補完にプラグインを使わない理由

Neovim 0.12 の `'autocomplete'` オプションで、入力に合わせて補完メニューが自動で出る。
候補の取得元は `'complete'` で決まり、ここでは LSP (`omnifunc`) → 現在のバッファ → 他のウィンドウ → 他のバッファ の順にしている。
LSP の候補を確定 (`<C-y>`) したときのスニペット展開や import の追加は、`LspAttach` で呼ぶ
`vim.lsp.completion.enable()` が担う。これで blink.cmp / friendly-snippets が要らなくなった。

| キー | 動作 |
| --- | --- |
| `<Tab>` / `<S-Tab>` | 補完メニューの候補を選ぶ |
| `<C-y>` | 確定 |
| `<C-e>` | メニューを閉じる |

## 運用

```sh
:lua vim.pack.update()   # または <leader>pu。確認バッファが開き、:write で適用 → nvim-pack-lock.json が変わる
:checkhealth vim.pack    # 状態の確認
:Mason                   # LSP サーバー・フォーマッタのインストール状況

git -C ~/dotfiles status --short nvim/
```

別のマシンでは、最初の起動時に `nvim-pack-lock.json` に書かれたリビジョンで全プラグインが入る。
インストール確認のダイアログは出さない設定にしている (`lua/config/pack.lua`)。何が入るかは
`nvim-pack-lock.json` の git diff でレビューする。

更新を取り消すときは lock ファイルを戻してから lock の状態に揃える。

```sh
git -C ~/dotfiles checkout HEAD -- nvim/nvim-pack-lock.json
nvim +"lua vim.pack.update(nil, { target = 'lockfile' })"
```

プラグインを外すときは、`lua/plugins/*.lua` から消したうえで `:lua vim.pack.del({ "名前" })` を実行する
(設定から消しただけではディスクと lock ファイルに残る)。

### LSP サーバーの追加

`lua/plugins/lsp.lua` の `servers` に nvim-lspconfig の名前で足す。mason がインストールし、
`vim.lsp.enable()` が起動する。フォーマッタ・リンタは同じファイルの `tools` に mason のパッケージ名で足し、
`lua/plugins/format.lua` で filetype に割り当てる。

rust-analyzer は rustaceanvim が自分で起動するので `servers` には入れない (入れるとクライアントが 2 つ立つ)。

## 本体・依存ツールのインストール

`vim.pack` は Neovim 0.12 以降にしかない。apt (Ubuntu 24.04 で 0.9.5 系) や brew の版はこれを満たさない・
追随しないため、本体は mise で管理する。`mise/config.toml` の `# Editor` セクションを参照。

| ツール        | 用途                                    | 管理     |
| ------------- | --------------------------------------- | -------- |
| `neovim`      | 本体                                    | mise     |
| `lazygit`     | git UI (`<leader>gg`)                   | mise     |
| `tree-sitter` | nvim-treesitter のパーサ生成            | mise     |
| `fd` `ripgrep` `fzf` | ファイル検索・grep              | mise     |
| `git`         | vim.pack がプラグインの取得に使う       | apt/brew |
| `gcc`         | nvim-treesitter のパーサのコンパイル    | apt/brew |
| `unzip`       | mason が落とすアーカイブの展開          | apt/brew |
| Nerd Font     | アイコン表示 (mac は `font-hackgen-nerd`) | brew   |

## herdr との連携 (herdr-nvim)

[herdr](https://herdr.dev) の pane で動かしているエージェントに、nvim 上で指定した
コード範囲を渡すための構成。[herdr-nvim](https://github.com/ChmaraX/herdr-nvim) は
**2つの半分**からなり、両方入れないと機能しない。

| 半分 | 実体 | 設定場所 |
| --- | --- | --- |
| sidebar + ファイルピッカー | herdr プラグイン | `~/.config/herdr/config.toml` |
| コード注釈 (annotations) | nvim プラグイン | `nvim/lua/plugins/herdr.lua` |

```
herdr workspace
┌─────────────────────────┬──────────────────────────┐
│ pane: claude            │ sidebar: nvim            │
│   ← <leader>aS で       │   prefix+alt+e でトグル   │
│     コメントが届く        │   prefix+alt+o でファイル │
└─────────────────────────┴──────────────────────────┘
```

| 操作 | 内容 |
| --- | --- |
| `prefix+alt+e` | sidebar のトグル (tab ごとに永続。閉じてもバッファと未送信コメントが残る) |
| `prefix+alt+o` | エージェントが触ったファイルの fuzzy ピッカー |
| `<leader>ac` | 現在行 / 選択範囲にコメントを付ける |
| `<leader>al` | コメント一覧 |
| `<leader>as` / `<leader>aS` | 全コメントをエージェントの入力欄へ貼る / 貼って送信 |

送信されるプロンプトには file:line とリポジトリ・ブランチが付く。同じ tab の
隣の pane にエージェントが1つだけなら、宛先は自動で決まる。

`<leader>a` 以下は herdr-nvim が使うので、ほかの AI 連携プラグイン (claudecode.nvim など) は入れない。
claudecode.nvim は nvim 側で WebSocket サーバを立てて `~/.claude/ide/*.lock` 経由で接続する方式なので、
**herdr が pane で管理しているセッションとは別の Claude** になる。

### `~/.local/bin/nvim` を mise の shim に向ける理由

herdr はプラグイン pane やカスタムコマンドを **mise の shim を含まない PATH** で起動する
(プラグインの `run.sh` が張る `PATH=/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:...`)。
このため `install_minimum.sh` で `${XDG_BIN_HOME}/nvim` を shim へリンクしている。

`/usr/bin/nvim` は `/usr/local/bin` より後・`~/.local/bin` より**先**に評価されるので、
apt 版の neovim が残っていると sidebar がそちらを起動してしまう。apt 版は
`ubuntu_minimum.sh` のパッケージ一覧から外してあるが、**既存マシンでは手で消す必要がある**。

```sh
sudo apt-get remove -y neovim
```

`test/test_nvim.sh` の Test 10 がこの PATH 解決を検証する。

## LazyVim をやめた理由

LazyVim は多くの機能を最初から揃えてくれる一方で、何がどこで設定されているかを追いにくかった。
自分で書いた設定はオプション 1 つ・配色・LSP 3 つ・herdr-nvim だけで、残りは extras に任せていた。

Neovim 0.11〜0.12 で、LazyVim がプラグインで補っていた機能の多くが本体に入った。

| 機能 | LazyVim での実現 | 今の構成 |
| --- | --- | --- |
| プラグイン管理 | lazy.nvim | `vim.pack` |
| LSP の設定と起動 | nvim-lspconfig の setup + mason-lspconfig | `vim.lsp.config()` / `vim.lsp.enable()` (nvim-lspconfig は既定設定の配布元として使う) |
| 補完 | blink.cmp + friendly-snippets | `'autocomplete'` + `vim.lsp.completion` |
| コメントアウト | ts-comments.nvim | 組み込みの `gc` |

本体の機能に寄せれば、設定を全部自分で読める量に保てると判断した。
LazyVim の既定のうち使っていたもの (オプション・キーマップ・autocmd) は `lua/config/` に書き写してある。

移行時に外したもの: lazy.nvim, LazyVim, blink.cmp, friendly-snippets, ts-comments.nvim, noice.nvim,
venv-selector.nvim, catppuccin, tokyonight.nvim。mini.ai / mini.pairs / mini.icons は個別のリポジトリから
mini.nvim 1 つにまとめた。

## 素の vim との関係

`.vimrc` / `.vim/` (dein + coc) は素の `vim` 用にそのまま残している。
nvim が使えない環境でのフォールバックとして機能する。両者は設定を共有しない。

## テスト

```sh
./test/test_nvim.sh
```

nvim のバージョン (>= 0.12)、`~/.config/nvim` がリポジトリへの symlink になっていること、LazyVim のファイルが
残っていないこと、ヘッドレスの初回起動が確認ダイアログで止まらずにプラグインを入れられること、
入ったプラグインが `nvim-pack-lock.json` のリビジョンと一致すること、配色・LSP・組み込み補完が有効なこと、
削られた PATH でも新しい nvim が解決されること、herdr-nvim が読み込まれていることを検証する。
