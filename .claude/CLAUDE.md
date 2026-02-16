# Dotfiles

Windows / macOS / Ubuntu 対応の個人用 dotfiles リポジトリ。

## プロジェクト構成

```
.
├── install.sh                # フルインストール (install_minimum.sh + OS別)
├── install_minimum.sh        # 最小インストール (Docker/CLI向け)
├── install/                  # ツール別インストールスクリプト
│   ├── mac.sh / ubuntu.sh / ubuntu_minimum.sh
│   ├── sheldon.sh / mise.sh / rust.sh / claude_code.sh
│   └── windows.ps1
├── .zshrc / .p10k.zsh        # Zsh + Powerlevel10k
├── .tmux.conf                # tmux
├── .gitconfig                # Git (OS別・ディレクトリ別の conditional include あり)
├── .vimrc / .vim/            # Vim (dein プラグイン管理, userautoload/ でモジュール分割)
├── .emacs.d/                 # Emacs
├── .vscode/                  # VSCode (settings, keybindings, extensions)
├── .ssh/config               # SSH (個人用のみ, config.d/*.conf で会社用を Include)
├── sheldon/plugins.toml      # Zsh プラグイン管理
├── mise/config.toml          # ツールバージョン管理 (Python, Node, Go 等)
├── mcp/                      # MCP サーバー設定
│   ├── master-mcp.json       # MCP サーバーのマスター設定
│   ├── sync-mcp.sh           # 設定を Claude Code/Desktop, VS Code, GitLab Duo に同期
│   └── README.md             # MCP 設定の詳細
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

## MCP サーバー設定

MCP (Model Context Protocol) サーバーの設定を一元管理し、複数のツールに同期する仕組み。

- `mcp/master-mcp.json` — MCP サーバーのマスター設定（個人用）
- `~/.config/mcp/master-mcp.d/*.json` — 追加設定（会社用など、別リポジトリから Include）
- `mcp/sync-mcp.sh` — 設定を各ツールに同期するスクリプト

### 同期対象ツール

- Claude Code (`~/.claude.json`)
- Claude Desktop (`~/Library/Application Support/Claude/claude_desktop_config.json`, macOS のみ)
- VS Code / GitHub Copilot (`~/Library/Application Support/Code/User/mcp.json`)
- GitLab Duo (`~/.gitlab/duo/mcp.json`)

### 使い方

```bash
# 全ツールに同期
sync-mcp.sh all

# 個別に同期
sync-mcp.sh claude    # Claude Code
sync-mcp.sh desktop   # Claude Desktop (macOS)
sync-mcp.sh vscode    # VS Code
sync-mcp.sh gitlab    # GitLab Duo
```

詳細は [mcp/README.md](mcp/README.md) を参照。

## テスト

GitHub Actions で Ubuntu 22.04 / 24.04 の Docker イメージをビルドし、`install_minimum.sh` の動作を検証する。

- ワークフロー: `.github/workflows/test.yml`
- Docker 環境: `test/docker-compose.yml` + `test/ubuntu.Dockerfile`
- 環境変数: `test/init_env.sh` で HOST_UID/GID を `.env` に書き出し、`source .env` でエクスポートしてからビルドする

## コミットメッセージ規約

`[カテゴリ] 説明` の形式を使う。

例: `[SSH] Support include`, `[GitHub Actions] Fixed workflow permissions`

## 注意点

- `.gitconfig` は OS 別 (`.gitconfig_linux` / `.gitconfig_mac`) とディレクトリ別の conditional include を使用
- Zsh プラグインは `zsh-defer` で遅延読み込みしてパフォーマンスを確保
- XDG Base Directory 仕様に準拠 (`~/.local/bin`, `~/.config`, `~/.local/share`)
