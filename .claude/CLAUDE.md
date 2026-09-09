# Dotfiles

Windows / macOS / Ubuntu 対応の個人用 dotfiles リポジトリ。

## プロジェクト構成

```
.
├── install.sh                # フルインストール (install_minimum.sh + OS別)
├── install_minimum.sh        # 最小インストール (Docker/CLI向け)
├── install/                  # ツール別インストールスクリプト
│   ├── mac.sh / ubuntu.sh / ubuntu_minimum.sh
│   ├── sheldon.sh / mise.sh / rust.sh
│   └── windows.ps1
├── .zshrc / .p10k.zsh        # Zsh + Powerlevel10k
├── .tmux.conf                # tmux
├── .gitconfig                # Git (remote 別の conditional include あり)
├── .vimrc / .vim/            # Vim (dein プラグイン管理, userautoload/ でモジュール分割)
├── nvim/                     # Neovim (LazyVim, ~/.config/nvim へディレクトリごと symlink)
├── .emacs.d/                 # Emacs
├── .vscode/                  # VSCode (settings, keybindings, extensions)
├── .ssh/config               # SSH (個人用のみ, config.d/*.conf で会社用を Include)
├── sheldon/plugins.toml      # Zsh プラグイン管理
├── mise/config.toml          # ツールバージョン管理 (Python, Node, Go 等)
├── Brewfile                  # macOS Homebrew パッケージ
└── test/                     # テスト用 Docker 環境
    ├── docker-compose.yml
    ├── ubuntu.Dockerfile
    └── init_env.sh
```

## インストール

- フル: `./install.sh` (OS を自動検出し mac.sh / ubuntu.sh を実行)
- 最小: `./install_minimum.sh` (CLI ツールのみ、Docker コンテナ向け)

設定ファイルはコピーではなくシンボリックリンクで配置される。

## SSH Config の構成

- `.ssh/config` — 個人用ホストとグローバル設定のみ
- `.ssh/config.d/*.conf` — 個別環境用 config の配置先 (別リポジトリから Include)

個別環境用リポジトリのセットアップスクリプトで `~/.ssh/config.d/work.conf` にシンボリックリンクを作成する想定。

## Neovim (LazyVim)

`nvim/` を `~/.config/nvim` へ**ディレクトリごと** symlink する。LazyVim が書き出す
`lazyvim.json` (`:LazyExtras` の結果) と `lazy-lock.json` (プラグインのリビジョン) が
リポジトリ側に残り、構成をそのまま追跡できるようにするため。

- nvim 本体・`lazygit`・`tree-sitter` は mise 管理 (apt/brew の版は LazyVim の要件 >= 0.11.2 を満たさない)
- herdr の pane で動くエージェントへコード範囲を渡すため `herdr-nvim` を入れている
  (`ai.claudecode` extra はキーマップと役割が衝突するため使わない)
- 素の `vim` 用の `.vimrc` / `.vim/` (dein) は別系統としてそのまま残している

詳細は [doc/nvim.md](../doc/nvim.md) を参照。

## テスト

GitHub Actions で Ubuntu 24.04 / 26.04 の Docker イメージをビルドし、`install_minimum.sh` の動作を検証する。

- ワークフロー: `.github/workflows/test.yml`
- Docker 環境: `test/docker-compose.yml` + `test/ubuntu.Dockerfile`
- 環境変数: `test/init_env.sh` で HOST_UID/GID を `.env` に書き出し、`source .env` でエクスポートしてからビルドする
- 個別テスト: `test/test_nvim.sh` (LazyVim)

## コミットメッセージ規約

`[カテゴリ] 説明` の形式を使う。

例: `[SSH] Support include`, `[GitHub Actions] Fixed workflow permissions`

## 注意点

- `.gitconfig` は remote 別の conditional include を使用。HTTPS の資格情報は `gh` / `glab` の credential helper に委譲しており、OS 別の分岐やホスト名の記述は持たない
- Zsh プラグインは `zsh-defer` で遅延読み込みしてパフォーマンスを確保
- XDG Base Directory 仕様に準拠 (`~/.local/bin`, `~/.config`, `~/.local/share`)
