# 06: MCP サーバー連携（セクション13対応）

MCP サーバーの追加・管理・コンテキスト影響を体験するサンプルです。

## 演習

### 1. MCP サーバーの管理

```bash
cd samples/06_mcp

# ターミナルから（セッション外）:
claude mcp list              # 設定済みサーバー一覧

# セッション内で:
claude
/mcp                         # MCP サーバーの管理画面
```

### 2. GitHub MCP サーバーの追加（HTTP）

```bash
# GitHub MCP サーバーを追加（推奨方法）
claude mcp add --transport http github https://api.githubcopilot.com/mcp/

# プロジェクトスコープで追加（チーム共有）
claude mcp add --scope project --transport http github https://api.githubcopilot.com/mcp/
```

### 3. ローカル MCP サーバーの追加（stdio）

```bash
# Playwright MCP サーバー
claude mcp add -s project -- npx -y @playwright/mcp@latest

# JSON 形式で追加
claude mcp add-json my-server '{"command":"node","args":["server.js"]}'
```

### 4. .mcp.json によるチーム共有

このディレクトリの `.mcp.json` を確認してください。環境変数の展開（`${VAR}`）や
デフォルト値（`${VAR:-default}`）の書き方が含まれています。

> **注意:** `.mcp.json` 内の `example-local` サーバーは設定例です。
> `mcp-server.js` は存在しないため、このサーバーは起動に失敗します。
> `github` サーバー（HTTP）はそのまま動作します。

### 5. コンテキスト消費の確認

```bash
# セッション内で:
/context    # MCP サーバーごとのコンテキスト消費量を確認
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
外部依存なしで stdio トランスポートの仕組みを理解できます。

**提供するツール:**

| ツール | 機能 |
|--------|------|
| `project_stats` | ファイル統計（ファイル数、行数、言語別内訳） |
| `todo_list` | ソースコード内の TODO/FIXME/HACK を一覧 |

**Step 1: サーバーを登録**

```bash
# プロジェクトスコープで追加
claude mcp add demo-tools -s project -- node mcp-server-demo.js
```

**Step 2: 動作確認**

```bash
claude
# セッション内で:
# 「project_stats ツールでこのプロジェクトのファイル統計を教えて」
# 「todo_list ツールで TODO コメントを一覧して」
```

**Step 3: コンテキスト消費の計測**

```bash
# MCP 追加前後のコンテキスト消費を比較
/context
# → demo-tools のツール定義が消費するトークン数を確認
```

**Step 4: サーバーのコードを読む**

```bash
# 「mcp-server-demo.js を読んで、MCP プロトコルの仕組みを説明して」
#
# 学べること:
# - JSON-RPC over stdin/stdout の通信フォーマット
# - initialize → tools/list → tools/call のライフサイクル
# - ツール定義の inputSchema 設計
# - エラーハンドリング
```

**Step 5: ツールを追加してみる**

```bash
# 「mcp-server-demo.js に file_search ツールを追加して。
#   引数: query（検索キーワード）, extension（ファイル拡張子、オプション）
#   動作: grep でファイル内のキーワードを検索して結果を返す」
```

### 8. MCP サーバーの CLI 代替比較

MCP サーバーと CLI ツールの使い分けを実践的に比較します。

```bash
# GitHub MCP vs gh CLI の比較
# MCP 版:
claude mcp add --transport http github https://api.githubcopilot.com/mcp/
# → /context でコンテキスト消費を確認

# CLI 版（MCP なし）:
# 「gh pr list --limit 5 を実行して」
# → MCP のツール定義分のコンテキスト消費がない

# 判断基準:
# - ツール数が少ない（5個以下）→ MCP でも OK
# - ツール数が多い（10個以上）→ CLI 代替を検討
# - チームで共有したい設定がある → .mcp.json + MCP
# - 個人のワークフロー → CLI で十分
```

### 9. サーバー削除とクリーンアップ

```bash
# 演習で追加したサーバーを削除
claude mcp remove demo-tools

# 確認
claude mcp list
```

---

## ポイント

- チーム共有には `-s project` で `.mcp.json` に保存
- 未使用の MCP サーバーは無効化してコンテキスト節約
- 信頼できるサーバーのみ追加（セキュリティリスク）
- `ENABLE_TOOL_SEARCH` で自動遅延読み込みを活用
- **MCP サーバーは JSON-RPC over stdio — Node.js なら標準ライブラリのみで自作可能**
- **ツール数が多い場合は CLI 代替のほうがコンテキスト効率が良い**
