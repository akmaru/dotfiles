# Global Claude Code Instructions

リポジトリ横断で適用される共通の指示です。

## Communication Style

- **簡潔に**: 必要な情報のみを伝える。無駄な説明や絵文字は使わない
- **技術的正確さを優先**: ユーザーの考えを無条件に肯定せず、客観的な技術情報を提供
- **明示的に依頼された場合のみ絵文字を使用**: デフォルトでは使用しない

## Coding Philosophy

### Core Principles

- **シンプル第一**: 過度な抽象化を避け、必要最小限の実装を優先
- **YAGNI (You Aren't Gonna Need It)**: 現時点で必要な機能のみを実装
- **既存コードを尊重**: ファイルを読まずに変更提案しない
- **最小限の変更**: 要求された範囲のみを変更し、余計なリファクタリングや機能追加はしない

### What NOT to Do

- 依頼されていない機能追加やリファクタリング
- 変更していないコードへのコメントや型注釈の追加
- 発生し得ないシナリオへのエラーハンドリング
- 一度しか使わない処理のためのヘルパー関数やユーティリティの作成
- 仮想的な将来の要件のための抽象化
- 未使用の変数の `_` リネームなどの後方互換性ハック（不要なものは完全に削除）

### Error Handling

- **システム境界でのみ検証**: ユーザー入力、外部 API など
- **内部コードやフレームワークの保証を信頼**: 内部関数間では過剰な検証は不要
- **発生し得ないシナリオへのエラーハンドリングは追加しない**

## Language-Specific Guidelines

### Python
- フォーマット: Black, Ruff などのフォーマッタに従う
- 型ヒント: プロジェクトの既存方針に合わせる

### TypeScript/JavaScript
- フォーマット: Prettier, ESLint などの設定に従う
- 型定義: プロジェクトの既存方針に合わせる

### Go
- フォーマット: `gofmt`, `goimports` に従う
- エラーハンドリング: Go の慣用句に従う

### Rust
- フォーマット: `rustfmt` に従う
- エラーハンドリング: `Result`, `Option` を適切に使用

### C/C++
- フォーマット: プロジェクトの `.clang-format` 設定に従う
- メモリ管理: RAII、スマートポインタを優先

## Security

- 基本的なセキュリティ対策を実施
- OWASP Top 10 の脆弱性（SQLインジェクション、XSS、コマンドインジェクションなど）に注意
- 不安全なコードを書いてしまった場合は即座に修正
- `.env`, `credentials.json` などの機密ファイルのコミットを警告

## Git and Commits

### Commit Message Format

```
[Category] Description
```

例:
- `[Feature] Add user authentication`
- `[Fix] Resolve memory leak in parser`
- `[Refactor] Simplify error handling logic`
- `[Docs] Update API documentation`
- `[Test] Add integration tests for API`

### Commit Guidelines

- コミットメッセージは簡潔に（1-2文）
- "why"（なぜ変更したか）を重視、"what"（何を変更したか）は diff で分かる
- プロジェクト固有のコミット規約がある場合はそちらを優先
- 既存のコミット履歴を確認し、そのスタイルに合わせる

## Testing

- **プロジェクトの方針に合わせる**: 既存のテストパターンを確認
- 新規テストは明示的に依頼された場合のみ作成
- 既存テストが通ることを確認

## Documentation

- **必要最小限**: 自明なコードを目指し、コメントは最小限に
- コメントは「なぜ」を説明（「何を」はコードが説明する）
- README やドキュメントファイルは明示的に依頼された場合のみ作成
- 変更していないコードにドキュメントを追加しない

## File Operations

- **既存ファイルの編集を優先**: 新規ファイル作成は必要最小限
- シンボリックリンクを尊重: リンク先ではなくリンク自体を操作
- プロジェクト固有の `.md` ファイルは明示的に依頼された場合のみ作成

## Tool Usage

- 専用ツールを優先: `cat` より `Read`、`sed` より `Edit`、`find` より `Glob`
- 複数の独立したツール呼び出しは並列実行
- 依存関係がある場合は順次実行


## Work-Specific Instructions

所属会社用の `CLAUDE.work.md` がある場合、下記の指示も参照してください。

@~/.claude/CLAUDE.work.md

## Project-Specific Instructions

プロジェクト固有の `CLAUDE.md` がある場合、そちらの指示を優先してください。このグローバル設定は、プロジェクト固有の指示がない場合のデフォルトとして機能します。
