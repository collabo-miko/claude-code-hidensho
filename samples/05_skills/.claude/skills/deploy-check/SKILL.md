---
name: deploy-check
description: デプロイ前のチェックリストを実行する（動的コンテキスト注入のデモ）
allowed-tools: Read, Bash(git *), Bash(npm test *)
---

# 現在の Git 状態
!`git status --short 2>/dev/null || echo "(git リポジトリではありません)"`

# 最新コミット
!`git log --oneline -5 2>/dev/null || echo "(コミット履歴なし)"`

# デプロイ前チェックリスト

上記の Git 状態を確認し、以下のチェックを行ってください:

1. **未コミットの変更がないか** — `git status` の結果を確認
2. **テストが通るか** — `npm test` を実行（利用可能な場合）
3. **機密情報の漏洩がないか** — `.env` ファイルがコミットに含まれていないか確認
4. **ブランチが正しいか** — main/master ブランチからのデプロイか確認

結果をチェックリスト形式でまとめてください。
