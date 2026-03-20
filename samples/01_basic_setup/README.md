# 01: 基本操作（セクション3対応）

Claude Code の基本的な操作を体験するサンプルです。

> **凡例（全サンプル共通）:**
> - **ターミナル:** Claude の外（通常のシェル）で実行
> - **Claude に聞く:** `>` 引用部分を Claude セッション内で入力
> - **`! command`** — セッション内から Bash を直接実行
> - **`/command`** — セッション内のスラッシュコマンド

## 演習

### 1. 対話セッションの開始

ターミナル:
```bash
cd samples/01_basic_setup
claude
```

Claude に聞く:
> このプロジェクトの構成を説明して

`!` プレフィックスで、セッション内から Bash を直接実行できます:

```
! ls -la
```

接続・モデル状態の確認:

```
/status
```

コンテキスト使用状況の視覚化:

```
/context
```

### 2. 名前付きセッションの管理

名前付きセッションで開始します。ターミナル:
```bash
claude -n "basic-demo"
```

Claude に聞く:
> app.js を読んで改善点を3つ挙げて

セッション名を変更:
```
/rename "basic-demo-v2"
```

`Ctrl+C` でセッションを抜けた後、名前で再開できます。ターミナル:
```bash
claude -r "basic-demo-v2"
```

直前のセッションを再開する場合:
```bash
claude -c
```

セッション一覧を表示する場合:
```bash
claude -l
```

### 3. コンテキスト管理の実践

Claude に聞く:
> app.js を読んで改善点を3つ挙げて

回答を受け取った後、会話を要約して圧縮（同じタスクを続ける場合）:
```
/compact
```

別のタスクに切り替える場合はコンテキストをリセット:
```
/clear
```

Claude に聞く（別の話題で）:
> README.md を読んで

やっぱり戻したい場合は巻き戻し（`Esc` × 2 でも可）:
```
/rewind
```

---

## 実践編: CI/CD での非対話モード活用

### 4. 非対話モード（ヘッドレス）

`claude -p` はセッションを起動せず、1回の質問→回答で終了します。
CI/CD やシェルスクリプトから使う場合の基本形です。

質問して即終了。ターミナル:
```bash
claude -p "app.js のコードを説明して"
```

パイプ入力:
```bash
cat app.js | claude -p "このコードのバグを見つけて"
```

JSON 出力（スクリプト連携向け）:
```bash
claude -p "app.js の関数一覧を返して" --output-format json
```

### 5. CI パイプラインでのコードレビュー自動化

`ci-review.sh` は `claude -p` を使い、Git の差分をレビューするスクリプトです。
対話セッション内からブランチ作成→レビュー実行まで一気に試せます。

ターミナル:
```bash
claude
```

Claude に聞く:
> ci-review.sh を読んで仕組みを説明して

Claude に聞く:
> app.js の calculateDiscount 関数のバグを修正して

修正されたら、ブランチを作ってコミット:
```
! git checkout -b demo/ci-review
! git add app.js && git commit -m "fix: calculateDiscount のバグ修正"
```

CI レビュースクリプトを実行:
```
! bash ci-review.sh origin/main
```

レビュー結果が表示されます。クリーンアップ:
```
! git checkout main && git branch -D demo/ci-review
```

**GitHub Actions での使い方:**
```yaml
- name: AI Code Review
  run: bash ci-review.sh origin/${{ github.base_ref }}
  env:
    ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
```

### 6. セッション管理のワークフロー

Claude に聞く:
> session-workflow.sh を読んで、各ワークフローを説明して

**4つのワークフロー:**

| パターン | 使い所 |
|---------|--------|
| 機能開発セッション | 1つの機能を名前付きセッションで追跡 |
| マルチタスク切替 | 複数タスクをセッション切替で管理 |
| 非対話 → 対話の連携 | `claude -p` で生成 → `claude -c` で対話に切替 |
| JSON出力でスクリプト連携 | 他ツールとの自動化パイプライン |

---

## ポイント

- タスクが変わるたびに `/clear` するのが公式推奨
- `/compact` は同一タスク内でコンテキストが重くなった時に使う
- `/rewind` はコードも含めて巻き戻す（Git の reset に近い）
- **CI/CD では `claude -p` + `--output-format json` + `--max-turns 1` の3点セットが基本**
- **名前付きセッションは長期タスクの追跡に有効（`-n` で開始、`-r` で再開）**
