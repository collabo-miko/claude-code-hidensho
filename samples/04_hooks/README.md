# 04: Hooks（セクション14対応）

フックの設定と動作を実際に確認するサンプルです。

> **準備: ターミナルを2つ開いてください**
>
> | ターミナル | 用途 | 表記 |
> |-----------|------|------|
> | **A** | Claude セッション（プロンプト・スラッシュコマンド） | `[A]` |
> | **B** | シェル操作（bash・git・スクリプト実行） | `[B]` |
>
> - **Claude に聞く:** `>` 引用部分をターミナル A で入力
> - **`/command`** — ターミナル A でスラッシュコマンドを実行

## このサンプルに含まれるフック

| フック | イベント | 動作 |
|--------|---------|------|
| 機密ファイル保護 | PreToolUse | `.env`, `.pem`, `.key` への編集をブロック（exit 2） |
| 危険コマンドブロック | PreToolUse | `rm -rf`, `sudo` 等をブロック（exit 2） |
| 自動フォーマット | PostToolUse | ファイル編集後に prettier を実行 |
| デスクトップ通知 | Notification | Claude が入力を待つ時に通知（macOS） |

## 事前準備

**[B]**
```bash
cd samples/04_hooks
cp secrets.env.example secrets.env
```

**[A]** Claude を起動:
```bash
cd samples/04_hooks
claude
```

## 演習

### 1. フック設定の確認

設定されたフック一覧を表示:
```
/hooks
```

### 2. ブロックフックの体験

Claude に聞く:
> secrets.env を編集して内容を変更して

→ Edit フックでブロックされる

Claude に聞く:
> rm -rf で tmp/ を削除して

→ Bash フックでブロックされる

> **注意:** Read（読み取り）はフックでブロックされません。
> 読み取りも禁止するには permissions の deny ルールを使います。

### 3. exit code の確認

フックの exit code で動作が変わります:
- **exit 0** = 成功（処理続行）
- **exit 1** = 非ブロックエラー（verbose モードでのみ stderr 表示、処理は続行）
- **exit 2** = ブロック（操作を拒否）

`Ctrl+O` で verbose モードにすると、exit 1 のフック出力も確認できます。

### 4. フックのデバッグ

**[A]** `Ctrl+C` で抜けて、デバッグモードで起動:
```bash
claude --debug hooks
```

## カスタムフックの追加方法

Claude に聞く:
> .claude/settings.json を読んでフックの設定構造を説明して

インラインフックの例（コミット前にシークレットをスキャン）:

```json
{
  "hooks": {
    "PreToolUse": [{
      "matcher": "Bash",
      "hooks": [{
        "type": "command",
        "command": "CMD=$(jq -r '.tool_input.command // empty'); if echo \"$CMD\" | grep -q 'git commit'; then git diff --cached | grep -iE '(password|api_key|secret)' && exit 2; fi; exit 0"
      }]
    }]
  }
}
```

---

## 実践編: シークレットスキャンフック

### 5. git commit 前のシークレット検出（scan-secrets.sh）

`scan-secrets.sh` は git commit コマンドを検出し、ステージされた差分にシークレットが含まれていないかスキャンするフックです。

Claude に聞く:
> scan-secrets.sh を読んで、検出パターンと仕組みを説明して

**検出パターン:**

| パターン | 例 |
|---------|-----|
| AWS Access Key | `AKIA1234567890ABCDEF` |
| 秘密鍵ヘッダ | `BEGIN RSA PRIVATE KEY` |
| パスワード代入 | `password = "secret123"` |
| API キー | `api_key = "sk-..."` |
| GitHub PAT | `ghp_xxxxxxxxxxxx` |
| Slack トークン | `xoxb-xxxxxxxxxxxx` |
| .env ファイルのステージ | `.env` がコミット対象に含まれる |

**体験手順:**

Claude に聞く:
> .claude/settings.json の PreToolUse フックに scan-secrets.sh を追加して

**[B]** わざとシークレットを含むファイルをステージ:
```bash
echo 'const API_KEY = "sk-test-1234567890abcdef";' > test-secret.js
git add test-secret.js
```

Claude に聞く:
> git commit -m 'test' を実行して

→ scan-secrets.sh がシークレットを検出してブロック！

**[B]** クリーンアップ:
```bash
git reset HEAD test-secret.js
rm test-secret.js
```

### 6. フックの組み合わせパターン

Claude に聞く:
> .claude/settings.json のフック設定を読んで、各フックがどのイベント・マッチャーで動作するか表にまとめて

**推奨する組み合わせ:**

| レイヤー | フック | 目的 |
|---------|--------|------|
| 入力防御 | PreToolUse (Edit/Write) | 機密ファイルへの書き込みブロック |
| コマンド防御 | PreToolUse (Bash) | 危険コマンドのブロック |
| コミット防御 | PreToolUse (Bash) | シークレット混入防止 |
| 品質保証 | PostToolUse (Edit/Write) | 自動フォーマット |
| 通知 | Notification | 長時間タスクの完了通知 |
| 検証 | Stop | タスク完了時の品質チェック |

---

## ポイント

- フックは CLAUDE.md と違い **決定的** に実行される（100%動作保証）
- 絶対に守らせたいルールはフックで強制する
- macOS の通知フックは長時間タスクで特に有用
- **シークレットスキャンは `.gitignore` と併用する（二重防御）**
- **フックは単体ではなく組み合わせて多層防御を構築する**
- **前提条件:** フック内で `jq` を使用しています。未インストールの場合はフックが無効化されます（`brew install jq`）
