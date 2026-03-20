# 08: コスト管理・トークン節約（セクション24対応）

トークン消費の確認と節約テクニックを体験するサンプルです。

> **準備: ターミナルを2つ開いてください**
>
> | ターミナル | 用途 | 表記 |
> |-----------|------|------|
> | **A** | Claude セッション（プロンプト・スラッシュコマンド） | `[A]` |
> | **B** | シェル操作（bash・git・スクリプト実行） | `[B]` |
>
> - **Claude に聞く:** `>` 引用部分をターミナル A で入力
> - **`/command`** — ターミナル A でスラッシュコマンドを実行

> **注意:** `/cost` コマンドは API 直接利用（Max プラン等）の場合のみ使用可能です。
> Teams プランではコンテキスト消費の確認に `/context` を使用してください。

## 演習

**[A]** Claude を起動:
```bash
cd samples/08_cost_optimization
claude
```

### 1. コンテキストの確認

コンテキスト使用状況の内訳を表示（最適化提案付き）:
```
/context
```

### 2. モデル切り替えによるコスト削減

日常作業（推奨デフォルト）:
```
/model sonnet
```

単純タスク（大幅コスト削減）:
```
/model haiku
```

複雑な設計時のみ:
```
/model opus
```

Plan は Opus、実行は Sonnet で自動切替:
```
/model opusplan
```

### 3. エフォートレベルの調整

リネーム、ログ追加など単純タスク:
```
/effort low
```

通常のコーディング:
```
/effort medium
```

複雑な推論・設計判断:
```
/effort high
```

### 4. /compact と /clear の使い分け

同一タスク内でコンテキストが重い時:
```
/compact API変更に焦点を当てて
```

タスクが切り替わる時（公式推奨: 頻繁に）:
```
/rename "task-name"
/clear
```

### 5. 不要ファイル読み込みの制限（deny ルール体験）

ビルド成果物や依存パッケージの読み込みを `deny` ルールでブロックする効果を体験します。

**Step 1:** デモ用ビルド成果物を生成します。`Ctrl+C` で抜けます。

**[B]** デモファイルを生成:
```bash
bash setup-demo.sh
```

**[A]** Claude を再起動:
```bash
claude
```

生成されるダミーファイル:

| ディレクトリ | 内容 | 実プロジェクトでのサイズ目安 |
|-------------|------|--------------------------|
| `node_modules/` | lodash, express のダミー | 数百MB |
| `dist/` | ミニファイ済みバンドル + ソースマップ | 数MB |
| `build/` | ビルドログ | 数KB〜数MB |
| `coverage/` | テストカバレッジレポート | 数MB |

**Step 2:** deny ルールの効果を確認します。

Claude に聞く:
> このディレクトリの全ファイルを調べて、プロジェクトの構成を教えて

→ `src/app.js`, `src/utils.js` は読めるが、`node_modules/` 等は deny でブロックされる

**Step 3:** deny ルールを無効化して違いを体験します。

Claude に聞く:
> .claude/settings.json の deny ルールを全てコメントアウトして

Claude に聞く:
> もう一度、全ファイルを調べて

→ `node_modules/` 等も読み込まれ、コンテキストが膨張する

コンテキスト消費の差を確認:
```
/context
```

**Step 4:** 確認後、deny ルールを元に戻します。

Claude に聞く:
> .claude/settings.json の deny セクションを元に戻して

**Step 5:** `Ctrl+C` で抜けます。

**[B]** デモファイルのクリーンアップ:
```bash
bash cleanup-demo.sh
```

> **ポイント:** deny ルールはプロジェクトのビルド構成に合わせてカスタマイズしましょう。
> Python なら `Read(.venv/**)`, `Read(__pycache__/**)` なども有効です。

### 6. MCP ツールのコンテキスト消費確認

MCP サーバーごとのコンテキスト消費を確認:
```
/context
```

不要なサーバーを無効化:
```
/mcp
```

### 7. CLAUDE.md の軽量化チェック

Claude に聞く:
> CLAUDE.md は何行ある？200行以内か確認して

---

## Hooks によるコスト最適化（実践編）

Hooks を使うと、プロンプトに頼らず**確実に**トークン消費を抑制できます。
このサンプルには 3 つのフックスクリプトと PostCompact フックが設定済みです。

### 8. テスト出力フィルタリング（filter-test-output.sh）

テストコマンドの出力を「失敗箇所のみ」に自動フィルタリングします。

Claude に聞く:
> filter-test-output.sh を読んで仕組みを説明して

Claude に聞く:
> npx jest --verbose を実行して

→ フックが出力を FAIL/ERROR 行 + 前後の文脈のみに絞る

**仕組み:**
- `PreToolUse`（Bash マッチャー）でテストコマンドを検出
- `hookSpecificOutput` の `updatedInput` でコマンドを書き換え
- `grep -E -A 5 -B 2 'FAIL|ERROR'` で失敗箇所のみ抽出
- `head -100` で最大行数を制限

**比較してみよう:**

Claude に聞く:
> .claude/settings.json の filter-test-output.sh フックを一時的にコメントアウトして

Claude に聞く:
> npx jest --verbose を再実行して

コンテキスト消費の差を確認:
```
/context
```

### 9. コマンド出力のトランケート（truncate-output.sh）

`find` や `ls -R` など大量出力が予想されるコマンドを自動で 200 行に制限します。

Claude に聞く:
> find . -name "*.js" を実行して

→ フックが出力を 200行に制限

Claude に聞く:
> find . -name "*.js" | head -5 を実行して

→ `head` が既にパイプされているのでフックは介入しない

### 10. コンパクション通知（PostCompact フック）

自動コンパクション発生時に通知を出し、`/context` 確認を促します。

このサンプルでは `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE=75` で通常より早くコンパクションが発生します。
長めの会話をして自動コンパクションを体験してみましょう。

### 11. ビルド出力フィルタリング（filter-build-output.sh）

ビルドコマンドの大量ログを WARNING/ERROR のみに自動圧縮します。

Claude に聞く:
> filter-build-output.sh を読んで仕組みを説明して

Claude に聞く:
> npm run build を実行して

→ 成功時: 最後の3行（サマリー）のみ / 失敗時: ERROR 行に集中 / 全出力は `/tmp/_build_full.log` に保存

### 12. サブエージェントに冗長な作業を委譲

**出力が多い作業**をサブエージェントに委譲すると、メインのコンテキストには要約のみが返ります。

**Step 1:** サブエージェントなしでテスト実行。

Claude に聞く:
> src/ 配下のコードを読んで、テストを書いて実行して

コンテキスト消費を確認（メインにテストコード + 全出力が入っている）:
```
/context
```

**Step 2:** サブエージェントに委譲。

Claude に聞く:
> src/ 配下のコードのテストを書いて実行して。テストの作成と実行はサブエージェントに任せて、結果の要約だけ教えて

コンテキスト消費を比較（メインには要約のみ）:
```
/context
```

**効果の目安:**

| 方式 | コンテキスト消費 |
|------|----------------|
| メインで直接テスト実行 | テストコード + 全出力（数千〜数万トークン） |
| サブエージェントに委譲 | 要約のみ（500〜1,000トークン） |
| haiku サブエージェントに委譲 | 要約のみ + haiku 単価（最低コスト） |

### 13. 応用: 自分だけのコスト最適化フックを作る

| フックアイデア | イベント | 効果 |
|--------------|---------|------|
| Docker ログ制限 | PreToolUse (Bash) | `docker logs` の出力を末尾 100 行に制限 |
| SQL 結果制限 | PreToolUse (Bash) | SELECT クエリに `LIMIT 50` を自動付与 |
| コスト超過警告 | Stop | セッションコストが閾値を超えたら警告表示 |
| diff 出力制限 | PreToolUse (Bash) | `git diff` の出力をファイル単位の stat + 変更上位のみに |

Claude に聞く:
> docker logs の出力を末尾100行に制限するフックスクリプトを作って

---

## この設定に含まれるコスト最適化

| 設定 | 効果 |
|------|------|
| deny: Read(node_modules/**) 等 | 不要ファイル読み込み防止 |
| CLAUDE_AUTOCOMPACT_PCT_OVERRIDE: 75 | 早めの自動コンパクション |
| MAX_THINKING_TOKENS: 8000 | Extended Thinking の予算制限 |
| ENABLE_TOOL_SEARCH: auto:5 | MCP ツール遅延読み込み |
| **filter-test-output.sh** | **テスト出力を失敗箇所のみに圧縮** |
| **filter-build-output.sh** | **ビルド出力を WARNING/ERROR のみに圧縮** |
| **truncate-output.sh** | **大量出力コマンドを200行に制限** |
| **PostCompact フック** | **コンパクション発生を通知** |

## ポイント

- `/context` を定期的に確認する習慣をつける
- 単純な作業に `opus` + `high` を使わない
- 曖昧なプロンプトは20以上のファイルを読み込むが、具体的なプロンプトは2〜3ファイルで済む
- CLAUDE.md の詳細な手順はスキルに分離してオンデマンドロード
- **Hooks はプロンプトと違い「必ず毎回」実行される — コスト最適化の確実な防衛線になる**
- **フックの効果は `/context` でビフォー・アフターを比較して定量的に検証する**
