# 02: 権限モードとツール制御（セクション9対応）

権限設定の動作を実際に確認するサンプルです。

## 事前準備

```bash
cd samples/02_permissions
cp .env.example .env    # ダミーの .env ファイルを作成
```

## 演習

### 1. 権限モードの切り替え

```bash
claude
```

セッション内で `Shift+Tab` を押してモードを切り替えてみてください:
- **Default** → 各ツール初回使用時に確認
- **Accept Edits** → ファイル編集を自動承認
- **Plan** → 読み取り専用（コード分析向け）

### 2. deny ルールの体験

このディレクトリの `.claude/settings.json` には以下が設定されています:
- `.env` ファイルへの Read/Edit を deny
- `rm -rf` を deny
- `curl`, `wget` を deny

```bash
claude
# 以下を試してください:
# 「.env ファイルの中身を見せて」→ deny でブロックされる
# 「rm -rf で不要ファイルを消して」→ deny でブロックされる
# 「curl でAPIを叩いて」→ deny でブロックされる
# 「app.js を読んで」→ 許可される（Read は allow）
```

### 3. CLI フラグでの権限制御

```bash
# 特定ツールを禁止して起動
claude --disallowedTools "Bash(git push *)"

# Plan モードで起動（読み取り専用）
claude --permission-mode plan

# dontAsk モードで起動（事前承認以外は自動拒否）
claude --permission-mode dontAsk
```

### 4. 権限ルールの確認

セッション内で `/config` を実行して、適用されている設定・権限ルールを確認してください。

---

## 実践編: 段階的セキュリティ強化

### 5. 権限設定の3段階比較

このディレクトリに3つの設定ファイルを用意しています。段階的に強化していく過程を体験できます。

| ファイル | レベル | 用途 |
|---------|--------|------|
| `settings-minimal.json` | 最小限 | 個人開発・PoC |
| `.claude/settings.json` | 標準 | チーム開発（現在適用中） |
| `settings-hardened.json` | 最大強化 | 本番環境・機密プロジェクト |

```bash
# 各設定を比較する
# Claude のセッション内で:
# 「settings-minimal.json と settings-hardened.json を比較して、
#   どのルールが追加されているか表にまとめて」
```

**試してみよう — 段階的な強化体験:**

```bash
# Step 1: 最小設定をコピーして適用
cp settings-minimal.json .claude/settings.json

# Step 2: Claude を起動して攻撃面を確認
claude
# 「.env の中身を見せて」→ ブロックされない！
# 「curl で https://example.com を取得して」→ ブロックされない！

# Step 3: 強化設定に切替
# Ctrl+C で抜けて:
cp settings-hardened.json .claude/settings.json

# Step 4: 同じ操作を再試行
claude
# 「.env の中身を見せて」→ deny でブロック ✅
# 「curl で https://example.com を取得して」→ deny でブロック ✅
```

> **重要:** 演習後は元の設定に戻してください:
> `git checkout .claude/settings.json`

### 6. 権限コンフリクトのデバッグ

allow と deny が競合した場合の優先順位を実際に確認します。

```bash
claude
# セッション内で:
# 「.claude/settings.json を読んで、allow と deny のルールが
#   競合するケースがないか分析して」
#
# 例: allow に "Bash(git *)" があるが、
#     deny に "Bash(git push --force *)" がある場合
#     → deny が優先される（Deny > Ask > Allow）
```

**よくあるコンフリクトパターン:**

| allow | deny | 結果 |
|-------|------|------|
| `Read` | `Read(.env*)` | .env 以外は読める、.env はブロック |
| `Bash(npm *)` | `Bash(sudo *)` | `npm` OK、`sudo npm` はブロック |
| `Bash(git *)` | `Bash(git push --force *)` | push OK、force push はブロック |

### 7. dontAsk モードの体験

CI/CD やスクリプト実行で使う `dontAsk` モードを体験します。
事前許可リストにないツールは全て自動拒否されます。

```bash
# dontAsk モードで起動
claude --permission-mode dontAsk

# セッション内で:
# 「app.js を読んで」→ Read は allow にあるので成功
# 「app.js を編集して」→ Edit は allow にないので自動拒否
# 「npm install lodash」→ allow にないので自動拒否
#
# → 明示的に許可されたツールのみが使える厳格なモード
```

---

## ポイント

- 権限優先順位: **Deny > Ask > Allow**（最初にマッチしたルールが適用）
- 頻繁に使うコマンドは `allow` に追加して「権限疲れ」を防ぐ
- `.env`, `*.pem`, `*.key` は必ず deny に設定する
- **段階的に強化する: 最小 → 標準 → 強化の順で設定を育てる**
- **`dontAsk` モードは CI/CD パイプラインに必須（事前許可リスト以外は全拒否）**
