# Neovim

## 構成

nvim は [LazyVim](https://www.lazyvim.org/) ベースの Lua 設定を使う。

```
dotfiles/nvim/  →  ~/.config/nvim   (ディレクトリごと symlink)
```

```
nvim/
├── init.lua                 # require("config.lazy")
├── lua/config/lazy.lua      # lazy.nvim の bootstrap と LazyVim の spec
├── lua/config/options.lua   # オプションの上書き
├── lua/config/keymaps.lua   # キーマップの追加
├── lua/config/autocmds.lua  # autocmd の追加
├── lua/plugins/             # プラグインの追加・上書き (*.lua を自動で読み込む)
├── lazyvim.json             # :LazyExtras で有効化した extras (自動生成)
└── lazy-lock.json           # プラグインのバージョン固定 (自動生成)
```

### ファイル単位でなくディレクトリごとリンクする理由

LazyVim は `:LazyExtras` の結果を `lazyvim.json` に、lazy.nvim はプラグインのリビジョンを
`lazy-lock.json` に、いずれも `stdpath("config")` = `~/.config/nvim` 直下へ書き出す。
ディレクトリごと symlink しておけば、これらの書き込みがそのままリポジトリの作業ツリーに現れ、
GUI で操作した構成変更をコミットして他のマシンで再現できる。

## 運用

エディタ上で構成を変えたら、リポジトリ側に出た差分をコミットする。

```sh
:LazyExtras   # 言語サポートなどの extras を有効化 → nvim/lazyvim.json が変わる
:Lazy update  # プラグインを更新           → nvim/lazy-lock.json が変わる
:LazyHealth   # 依存関係の確認

git -C ~/dotfiles status --short nvim/
```

別のマシンでは `nvim/lazy-lock.json` の内容がそのまま復元される。
明示的にロックファイルの状態へ戻す場合は `:Lazy restore`。

## 本体・依存ツールのインストール

LazyVim は Neovim >= 0.11.2 を要求するが、apt (Ubuntu 22.04 で 0.6 系 / 24.04 で 0.9.5 系) や
brew の版はこれを満たさない・追随しないため、本体は mise で管理する。
`mise/config.toml` の `# Editor` セクションを参照。

| ツール        | 用途                                    | 管理     |
| ------------- | --------------------------------------- | -------- |
| `neovim`      | 本体                                    | mise     |
| `lazygit`     | LazyVim の git UI (`<leader>gg`)        | mise     |
| `tree-sitter` | nvim-treesitter のパーサ生成            | mise     |
| `fd` `ripgrep` `fzf` | ファイル検索・grep              | mise     |
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
│ pane: claude            │ sidebar: nvim (LazyVim)  │
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

### `ai.claudecode` extra を有効化しない理由

LazyVim には Claude Code 連携の `ai.claudecode` extra があるが、herdr 上では使わない。

- キーマップが衝突する (どちらも `<leader>ac` / `<leader>as` を使う)
- `ai.claudecode` は nvim 側で WebSocket サーバを立てて `~/.claude/ide/*.lock` 経由で
  接続する方式なので、**herdr が pane で管理しているセッションとは別の Claude** になる

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

`test/test_nvim.sh` の Test 9 がこの PATH 解決を検証する。

## 素の vim との関係

`.vimrc` / `.vim/` (dein + coc) は素の `vim` 用にそのまま残している。
nvim が使えない環境でのフォールバックとして機能する。両者は設定を共有しない。

## テスト

```sh
./test/test_nvim.sh
```

nvim のバージョン、`~/.config/nvim` がリポジトリへの symlink になっていること、
`lazy-lock.json` からプラグインを復元できること、LazyVim が読み込めること、
削られた PATH でも新しい nvim が解決されること、herdr-nvim が登録されていることを検証する。
