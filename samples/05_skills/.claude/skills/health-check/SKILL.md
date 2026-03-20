---
name: health-check
description: プロジェクトの健全性を動的に診断する（Git状態、依存関係、テスト結果を自動収集）
allowed-tools:
  - Read
  - Bash(git *)
  - Bash(npm test *)
  - Bash(npm outdated *)
  - Bash(npm audit *)
  - Bash(wc *)
---

# Health Check スキル

プロジェクトの現在の状態を動的に収集・診断するスキルです。
`!`command`` 構文でリアルタイム情報をコンテキストに注入します。

## 動的コンテキスト

### Git 状態
```
!`git status --short`
```

### 直近のコミット
```
!`git log --oneline -5`
```

### 未コミットの変更量
```
!`git diff --stat`
```

### 依存関係の更新状況
```
!`npm outdated 2>/dev/null || echo "npm outdated: 実行不可"`
```

### セキュリティ脆弱性
```
!`npm audit --json 2>/dev/null | jq '{total: .metadata.totalDependencies, vulnerabilities: .metadata.vulnerabilities}' 2>/dev/null || echo "npm audit: 実行不可"`
```

### テスト結果
```
!`npm test 2>&1 | tail -20 || echo "テスト実行: 失敗または未設定"`
```

## 診断ルール

上記の動的コンテキストを基に、以下の項目を診断してレポートしてください:

| 項目 | 正常 | 警告 | 危険 |
|------|------|------|------|
| 未コミット変更 | なし | 10ファイル以下 | 10ファイル超 |
| 依存関係の更新 | 全て最新 | minor 更新あり | major 更新あり |
| セキュリティ脆弱性 | なし | low/moderate | high/critical |
| テスト | 全て合格 | 一部スキップ | 失敗あり |

## 出力形式

```
## 🏥 プロジェクト健全性レポート

| 項目 | 状態 | 詳細 |
|------|------|------|
| Git 状態 | ✅/⚠️/🚨 | ... |
| 依存関係 | ✅/⚠️/🚨 | ... |
| セキュリティ | ✅/⚠️/🚨 | ... |
| テスト | ✅/⚠️/🚨 | ... |

### 推奨アクション
1. ...
2. ...
```
