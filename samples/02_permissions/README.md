# 02: 権限モードとツール制御（セクション9対応）

権限設定の動作を実際に確認するサンプルです。

> **準備: ターミナルを2つ開いてください**
>
> | ターミナル | 用途 | 表記 |
> |-----------|------|------|
> | **A** | Claude セッション（プロンプト・スラッシュコマンド） | `[A]` |
> | **B** | シェル操作（bash・git・スクリプト実行） | `[B]` |
>
> - **Claude に聞く:** `>` 引用部分をターミナル A で入力
> - **`/command`** — ターミナル A でスラッシュコマンドを実行

## 事前準備

**[B]** ダミーの `.env` ファイルを作成:
```bash
cd samples/02_permissions
cp .env.example .env
```

**[A]** Claude を起動:
```bash
cd samples/02_permissions
claude
```

## 演習

### 1. 権限モードの切り替え

**[A]** セッション内で `Shift+Tab` を押してモードを切り替えてみてください:
- **Default** → 各ツール初回使用時に確認
- **Accept Edits** → ファイル編集を自動承認
- **Plan** → 読み取り専用（コード分析向け）

### 2. deny ルールの体験

このディレクトリの `.claude/settings.json` には以下が設定されています:
- `.env` ファイルへの Read/Edit を deny
- `rm -rf` を deny
- `curl`, `wget` を deny

Claude に聞く:
> .env ファイルの中身を見せて

→ deny でブロックされる

Claude に聞く:
> rm -rf で不要ファイルを消して

→ deny でブロックされる

Claude に聞く:
> curl でAPIを叩いて

→ deny でブロックされる

Claude に聞く:
> app.js を読んで

→ 許可される（Read は allow）

### 3. CLI フラグでの権限制御

**[A]** `Ctrl+C` で抜けて、各フラグ付きで起動してみてください:

特定ツールを禁止して起動:
```bash
claude --disallowedTools "Bash(git push *)"
```

Plan モードで起動（読み取り専用）:
```bash
claude --permission-mode plan
```

dontAsk モードで起動（事前承認以外は自動拒否）:
```bash
claude --permission-mode dontAsk
```

### 4. 権限ルールの確認

適用されている設定・権限ルールを確認:
```
/config
```

---

## 実践編: 段階的セキュリティ強化

### 5. 権限設定の3段階比較

このディレクトリに3つの設定ファイルを用意しています。

| ファイル | レベル | 用途 |
|---------|--------|------|
| `settings-minimal.json` | 最小限 | 個人開発・PoC |
| `.claude/settings.json` | 標準 | チーム開発（現在適用中） |
| `settings-hardened.json` | 最大強化 | 本番環境・機密プロジェクト |

Claude に聞く:
> settings-minimal.json と settings-hardened.json を比較して、どのルールが追加されているか表にまとめて

**試してみよう — 段階的な強化体験:**

**[A]** `Ctrl+C` で抜けます。

**[B]** 最小設定をコピーして適用:
```bash
cp settings-minimal.json .claude/settings.json
```

**[A]** Claude を起動:
```bash
claude
```

Claude に聞く:
> .env の中身を見せて

→ ブロックされない！

**[A]** `Ctrl+C` で抜けます。

**[B]** 強化設定に切替:
```bash
cp settings-hardened.json .claude/settings.json
```

**[A]** Claude を起動:
```bash
claude
```

Claude に聞く:
> .env の中身を見せて

→ deny でブロック ✅

**[B]** 演習後は元の設定に戻してください:
```bash
git checkout .claude/settings.json
```

### 6. 権限コンフリクトのデバッグ

Claude に聞く:
> .claude/settings.json を読んで、allow と deny のルールが競合するケースがないか分析して

**よくあるコンフリクトパターン:**

| allow | deny | 結果 |
|-------|------|------|
| `Read` | `Read(.env*)` | .env 以外は読める、.env はブロック |
| `Bash(npm *)` | `Bash(sudo *)` | `npm` OK、`sudo npm` はブロック |
| `Bash(git *)` | `Bash(git push --force *)` | push OK、force push はブロック |

### 7. dontAsk モードの体験

**[A]** `Ctrl+C` で抜けて、dontAsk モードで起動:
```bash
claude --permission-mode dontAsk
```

Claude に聞く:
> app.js を読んで

→ Read は allow にあるので成功

Claude に聞く:
> app.js を編集して

→ Edit は allow にないので自動拒否（CI/CD 向けの厳格モード）

---

## ポイント

- 権限優先順位: **Deny > Ask > Allow**（最初にマッチしたルールが適用）
- 頻繁に使うコマンドは `allow` に追加して「権限疲れ」を防ぐ
- `.env`, `*.pem`, `*.key` は必ず deny に設定する
- **段階的に強化する: 最小 → 標準 → 強化の順で設定を育てる**
- **`dontAsk` モードは CI/CD パイプラインに必須（事前許可リスト以外は全拒否）**
