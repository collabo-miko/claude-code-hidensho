# 05: カスタムスキル（セクション15対応）

スキルの作成・呼び出し・動的コンテキスト注入を体験するサンプルです。

## ディレクトリ構成

```
05_skills/
├── .claude/
│   └── skills/
│       ├── review-code/
│       │   └── SKILL.md        # コードレビュースキル
│       ├── gen-test/
│       │   └── SKILL.md        # テスト生成スキル
│       ├── deploy-check/
│       │   └── SKILL.md        # デプロイ前チェックスキル（動的コンテキスト付き）
│       └── health-check/
│           └── SKILL.md        # ヘルスチェックスキル（!`command` による動的注入）
├── src/
│   └── calculator.js           # レビュー・テスト対象のコード
└── README.md
```

## 演習

### 1. スキル一覧の確認

```bash
cd samples/05_skills
claude
/skills    # 利用可能なスキル一覧を表示
```

### 2. コードレビュースキルの実行

```bash
# セッション内で:
/review-code
# → src/calculator.js のレビューが実行される
```

### 3. テスト生成スキルの実行

```bash
/gen-test
# → calculator.js のテストが自動生成される
```

### 4. 動的コンテキスト付きスキル

```bash
/deploy-check
# → `!git status` と `!git log` の出力がスキルに注入されてから実行
```

---

## 実践編: 動的コンテキスト注入スキルの構築

### 5. ヘルスチェックスキルの体験

`health-check` スキルは `!`command`` 構文を使い、実行時にリアルタイムのプロジェクト情報を動的に収集します。

```bash
# スキル一覧を確認
/skills
# → health-check が追加されている

# スキルを実行
/health-check
# → Git 状態、依存関係の更新状況、セキュリティ脆弱性、テスト結果が
#   自動収集されて診断レポートが生成される
```

**SKILL.md の中身を確認してみましょう:**

```bash
# 「.claude/skills/health-check/SKILL.md を読んで、
#   !`command` 構文がどう使われているか説明して」
```

**動的コンテキストの仕組み:**
- `!`git status --short`` → スキル実行時に `git status` を実行し、その出力がプロンプトに埋め込まれる
- `!`npm outdated`` → 依存関係の更新状況がリアルタイムで注入される
- 結果は毎回異なる（静的な CLAUDE.md とは対照的）

### 6. スキルを一から作る演習

自分でスキルを作成する体験です。以下のどれかを選んで作ってみましょう。

**演習 A: コードフォーマットスキル**
```bash
# 「以下の仕様でスキルを作って:
#   名前: format-code
#   場所: .claude/skills/format-code/SKILL.md
#   動作: src/ 配下の全 .js ファイルをフォーマットチェック
#   allowed-tools: Read, Bash(npx prettier *)
#   user-invocable: true」
```

**演習 B: 変更影響分析スキル**
```bash
# 「以下の仕様でスキルを作って:
#   名前: impact-analysis
#   場所: .claude/skills/impact-analysis/SKILL.md
#   動作: !`git diff --name-only` で変更ファイルを取得し、
#         各ファイルの依存関係（import 先）を分析して影響範囲を表示
#   context: fork（メインのコンテキストを汚さない）」
```

### 7. allowed-tools によるスキルのサンドボックス化

スキルの `allowed-tools` は、そのスキルの実行中に使えるツールを制限します。

```bash
# deploy-check スキルの allowed-tools を確認
# 「.claude/skills/deploy-check/SKILL.md の frontmatter を見せて」
# → allowed-tools: Read, Bash(git*), Bash(npm test*)
# → Edit や Write は使えない（デプロイチェックに書き込みは不要）

# 試してみよう: deploy-check 実行中に書き込みが拒否されるか確認
/deploy-check
```

**allowed-tools 設計のベストプラクティス:**

| スキルの目的 | 許可すべきツール | 禁止すべきツール |
|-------------|----------------|----------------|
| コードレビュー | Read, Grep, Glob | Edit, Write, Bash |
| テスト生成 | Read, Write, Bash(npx jest*) | Bash(rm*), Bash(git push*) |
| デプロイチェック | Read, Bash(git*), Bash(npm test*) | Edit, Write |
| ヘルスチェック | Read, Bash(git*), Bash(npm*) | Edit, Write |

---

## ポイント

- スキルは呼び出し時にのみロード（CLAUDE.md と違いコンテキスト節約に有効）
- `user-invocable: true` で `/` メニューに表示
- `disable-model-invocation: true` で手動呼び出し専用に
- `context: fork` でサブエージェントとして隔離実行
- `!`command`` 構文で実行前にシェル出力を注入
- **`allowed-tools` で最小権限の原則を適用（スキルごとにサンドボックス化）**
- **CLAUDE.md が肥大化したら、手順部分をスキルに切り出す**
