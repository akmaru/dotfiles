# SSH

## SSH config の構成

```
~/.ssh/config           # 個人用 + グローバル設定
~/.ssh/config.d/*.conf  # 環境別設定（会社用など、別リポジトリから配置）
```

`~/.ssh/config` は `Include ~/.ssh/config.d/*.conf` で追加設定を読み込む。
会社用ホストの設定は別リポジトリのセットアップスクリプトで `config.d/work.conf` にシンボリックリンクを作成する。

## iTerm2 tmux 統合モード

iTerm2 の tmux integration を使うと、リモートの tmux セッションを iTerm2 のネイティブウィンドウ/タブとして操作できる。

### 接続コマンド

```sh
# セッションがなければ作成、あればアタッチ
ssh -t <host> 'tmux -CC new -A -s main'
```

| オプション       | 説明                                      |
| ---------------- | ----------------------------------------- |
| `-t`             | 疑似 TTY を割り当てる（必須）             |
| `tmux -CC`       | tmux をコントロールモードで起動           |
| `new -A -s main` | `main` セッションにアタッチ、なければ作成 |

### SSH config でのホスト設定例

接続時に自動で tmux 統合モードを起動する場合:

```
Host myserver
  HostName example.com
  User myusername
  RequestTTY yes
  RemoteCommand tmux -CC new -A -s main
```

`RequestTTY yes` + `RemoteCommand` で `ssh myserver` だけで統合モードが起動する。

## リモートで Claude Code を使う場合の通知設定

SSH 越しに Claude Code を動かしつつ、ローカルの macOS に通知を届ける仕組み。

### 仕組み

```
[リモート] claude-notify.sh
  → nc localhost 9999  (SSH リバーストンネル経由)
    → [ローカル] notify-server.sh
      → terminal-notifier (macOS 通知)
        → iterm-jump.sh (iTerm2 の該当タブへジャンプ)
```

### セットアップ手順

1. **ローカルで通知サーバーを起動**

```sh
notify-server.sh &
```

2. **SSH 接続時にリバーストンネルを張る**

```sh
ssh -R 9999:localhost:9999 <host>
```

SSH config に書いておくと便利:

```
Host myserver
  HostName example.com
  User myusername
  RequestTTY yes
  RemoteCommand tmux -CC new -A -s main
  RemoteForward 9999 localhost:9999
```

3. **リモート側にスクリプトを配置**

`install.sh` または `install_minimum.sh` を実行すると `bin/` 以下のスクリプトが `~/.local/bin/` にリンクされる。

4. **Claude Code の hooks 確認**

`~/.claude/settings.json` に以下が設定されていることを確認:

```json
"hooks": {
  "Notification": [{ "hooks": [{ "type": "command", "command": "claude-notify.sh 'Waiting for approval' 'Claude'" }] }],
  "Stop":         [{ "hooks": [{ "type": "command", "command": "claude-notify.sh 'Task completed' 'Claude'" }] }]
}
```
