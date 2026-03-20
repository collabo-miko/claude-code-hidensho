# 06: MCP サーバー連携（セクション13対応）

MCP サーバーの追加・管理・コンテキスト影響を体験するサンプルです。

> **凡例（全サンプル共通）:**
> - **ターミナル:** Claude の外（通常のシェル）で実行
> - **Claude に聞く:** `>` 引用部分を Claude セッション内で入力
> - **`! command`** — セッション内から Bash を直接実行
> - **`/command`** — セッション内のスラッシュコマンド

## 演習

### 1. MCP サーバーの管理

ターミナル:
```bash
cd samples/06_mcp
claude mcp list              # 設定済みサーバー一覧
claude
```

MCP サーバーの管理画面を開く:
```
/mcp
```

### 2. GitHub MCP サーバーの追加（HTTP）

`Ctrl+C` で抜けて、ターミナル:
```bash
# GitHub MCP サーバーを追加（推奨方法）
claude mcp add --transport http github https://api.githubcopilot.com/mcp/

# プロジェクトスコープで追加（チーム共有）
claude mcp add --scope project --transport http github https://api.githubcopilot.com/mcp/
```

### 3. ローカル MCP サーバーの追加（stdio）

ターミナル:
```bash
# Playwright MCP サーバー
claude mcp add -s project -- npx -y @playwright/mcp@latest

# JSON 形式で追加
claude mcp add-json my-server '{"command":"node","args":["server.js"]}'
```

### 4. .mcp.json によるチーム共有

ターミナル:
```bash
claude
```

Claude に聞く:
> .mcp.json を読んで、環境変数の展開やデフォルト値の書き方を説明して

> **注意:** `.mcp.json` 内の `example-local` サーバーは設定例です。
> `mcp-server.js` は存在しないため起動に失敗します。
> `github` サーバー（HTTP）はそのまま動作します。

### 5. コンテキスト消費の確認

MCP サーバーごとのコンテキスト消費量を確認:
```
/context
```

MCP ツール定義がコンテキストの10%を超える場合は見直しましょう。
CLI 代替（`gh`, `aws`, `gcloud`）はツール定義のコンテキスト消費がありません。

### 6. MCP Elicitation（v2.1.76〜）

MCP サーバーがタスク実行中にユーザーに構造化入力（フォーム等）を要求できます。
`Elicitation` / `ElicitationResult` フックイベントで制御可能。

---

## 実践編: MCP サーバーを自作する

### 7. デモ MCP サーバーの構築体験

`mcp-server-demo.js` は Node.js 標準ライブラリのみで動作する最小限の MCP サーバーです。

**提供するツール:**

| ツール | 機能 |
|--------|------|
| `project_stats` | ファイル統計（ファイル数、行数、言語別内訳） |
| `todo_list` | ソースコード内の TODO/FIXME/HACK を一覧 |

`Ctrl+C` で抜けて、ターミナル:
```bash
claude mcp add demo-tools -s project -- node mcp-server-demo.js
claude
```

Claude に聞く:
> project_stats ツールでこのプロジェクトのファイル統計を教えて

Claude に聞く:
> todo_list ツールで TODO コメントを一覧して

demo-tools のツール定義が消費するトークン数を確認:
```
/context
```

Claude に聞く:
> mcp-server-demo.js を読んで、MCP プロトコルの仕組みを説明して

→ 学べること: JSON-RPC over stdin/stdout、initialize → tools/list → tools/call のライフサイクル

Claude に聞く:
> mcp-server-demo.js に file_search ツールを追加して。引数は query（検索キーワード）と extension（ファイル拡張子、オプション）で、grep でファイル内のキーワードを検索して結果を返す

### 8. MCP サーバーの CLI 代替比較

Claude に聞く:
> gh pr list --limit 5 を実行して

→ MCP のツール定義分のコンテキスト消費がない（CLI 代替のメリット）

**判断基準:**
- ツール数が少ない（5個以下）→ MCP でも OK
- ツール数が多い（10個以上）→ CLI 代替を検討
- チームで共有したい設定がある → .mcp.json + MCP
- 個人のワークフロー → CLI で十分

### 9. サーバー削除とクリーンアップ

`Ctrl+C` で抜けて、ターミナル:
```bash
claude mcp remove demo-tools
claude mcp list               # 削除を確認
```

---

## ポイント

- チーム共有には `-s project` で `.mcp.json` に保存
- 未使用の MCP サーバーは無効化してコンテキスト節約
- 信頼できるサーバーのみ追加（セキュリティリスク）
- `ENABLE_TOOL_SEARCH` で自動遅延読み込みを活用
- **MCP サーバーは JSON-RPC over stdio — Node.js なら標準ライブラリのみで自作可能**
- **ツール数が多い場合は CLI 代替のほうがコンテキスト効率が良い**
