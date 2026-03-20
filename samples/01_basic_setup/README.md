# 01: 基本操作（セクション3対応）

Claude Code の基本的な操作を体験するサンプルです。

## 演習

### 1. 対話セッションの開始

```bash
cd samples/01_basic_setup
claude
```

セッション内で以下を試してください:
- `このプロジェクトの構成を説明して` — ファイル読み取りの確認
- `! ls -la` — Bash 直接実行（`!` プレフィックス）
- `/status` — 接続・モデル状態の確認
- `/context` — コンテキスト使用状況の視覚化（最適化提案付き）

### 2. 名前付きセッションの管理

```bash
claude -n "basic-demo"        # 名前付きセッションで開始
# ... 作業 ...
/rename "basic-demo-v2"       # セッション名を変更
/exit                         # 終了

claude -r "basic-demo-v2"     # 名前で再開
claude -c                     # 直前のセッションを再開
```

### 3. 非対話モード

```bash
# 質問して即終了
claude -p "app.js のコードを説明して"

# パイプ入力
cat app.js | claude -p "このコードのバグを見つけて"

# JSON 出力
claude -p "app.js の関数一覧を返して" --output-format json
```

### 4. コンテキスト管理の実践

```bash
claude
# セッション内で:
# 1. 「app.js を読んで改善点を3つ挙げて」
# 2. /compact — 会話を圧縮
# 3. /clear — コンテキストをリセット（別タスクへ）
# 4. /rewind — 直前の操作を巻き戻し（Esc × 2 でも可）
```

---

## 実践編: CI/CD での非対話モード活用

### 5. CI パイプラインでのコードレビュー自動化

`ci-review.sh` は `claude -p` を使い、Git の差分に対してセキュリティ + 品質レビューを自動実行するスクリプトです。

```bash
# まずスクリプトの中身を確認
# 「ci-review.sh を読んで仕組みを説明して」

# ローカルで試す（main ブランチとの差分をレビュー）
bash ci-review.sh

# 別ブランチとの差分
bash ci-review.sh origin/develop

# haiku でコスト削減レビュー
REVIEW_MODEL=haiku bash ci-review.sh
```

**学べること:**
- `claude -p` の非対話モードでのパイプ入力
- `--output-format json` で構造化データを取得
- `--max-turns 1` でターン数を制限（コスト管理）
- `--model` でタスクに応じたモデル選択

**GitHub Actions での使い方:**
```yaml
- name: AI Code Review
  run: bash ci-review.sh origin/${{ github.base_ref }}
  env:
    ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
```

### 6. セッション管理のワークフロー

`session-workflow.sh` は実行用ではなく、セッション管理のパターン集です。

```bash
# セッション管理パターンを確認
# 「session-workflow.sh を読んで、各ワークフローを説明して」
```

**4つのワークフロー:**

| パターン | 使い所 |
|---------|--------|
| 機能開発セッション | 1つの機能を名前付きセッションで追跡 |
| マルチタスク切替 | 複数タスクをセッション切替で管理 |
| 非対話 → 対話の連携 | スクリプトで生成 → 対話で深掘り |
| JSON出力でスクリプト連携 | 他ツールとの自動化パイプライン |

**試してみよう:**
```bash
# ワークフロー 1: 名前付きセッション
claude -n "fix-app-bug"
# 「app.js の calculateDiscount のバグを修正して」
# Ctrl+C で抜ける

# ワークフロー 2: セッション一覧 → 再開
claude -l                    # 一覧
claude -r "fix-app-bug"      # 再開（コンテキスト維持）
```

---

## ポイント

- タスクが変わるたびに `/clear` するのが公式推奨
- `/compact` は同一タスク内でコンテキストが重くなった時に使う
- `/rewind` はコードも含めて巻き戻す（Git の reset に近い）
- **CI/CD では `claude -p` + `--output-format json` + `--max-turns 1` の3点セットが基本**
- **名前付きセッションは長期タスクの追跡に有効（`-n` で開始、`-r` で再開）**
