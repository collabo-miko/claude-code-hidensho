#!/bin/bash
# ci-review.sh
# CI/CD パイプラインで Claude Code を非対話モードで活用するサンプルスクリプト
#
# 使い方:
#   bash ci-review.sh                    # デフォルト: main ブランチとの差分をレビュー
#   bash ci-review.sh origin/develop     # 指定ブランチとの差分をレビュー
#   REVIEW_MODEL=haiku bash ci-review.sh # haiku でコスト削減レビュー
#
# CI での実行例（GitHub Actions）:
#   - name: AI Code Review
#     run: bash ci-review.sh origin/${{ github.base_ref }}
#     env:
#       ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}

set -euo pipefail

BASE_BRANCH="${1:-origin/main}"
MODEL="${REVIEW_MODEL:-sonnet}"
MAX_TOKENS="${REVIEW_MAX_TOKENS:-4096}"
OUTPUT_DIR="${REVIEW_OUTPUT_DIR:-.}"

echo "=== Claude Code CI Review ==="
echo "Base branch: $BASE_BRANCH"
echo "Model: $MODEL"
echo ""

# --- Step 1: 差分の取得 ---
DIFF=$(git diff "$BASE_BRANCH"...HEAD -- '*.js' '*.ts' '*.py' '*.go' '*.java' '*.rb')

if [ -z "$DIFF" ]; then
  echo "レビュー対象の変更がありません。"
  exit 0
fi

CHANGED_FILES=$(git diff --name-only "$BASE_BRANCH"...HEAD -- '*.js' '*.ts' '*.py' '*.go' '*.java' '*.rb')
FILE_COUNT=$(echo "$CHANGED_FILES" | wc -l | tr -d ' ')

echo "変更ファイル数: $FILE_COUNT"
echo "$CHANGED_FILES"
echo ""

# --- Step 2: セキュリティレビュー（JSON出力） ---
echo "--- セキュリティレビュー ---"
SECURITY_RESULT=$(echo "$DIFF" | claude -p \
  --model "$MODEL" \
  --max-turns 1 \
  --output-format json \
  "以下の diff にセキュリティ上の問題がないかレビューしてください。
問題がある場合は severity (critical/warning/info) と該当行を示してください。
問題がなければ「セキュリティ問題なし」と回答してください。" 2>/dev/null || echo '{"result":"error","message":"Claude API call failed"}')

echo "$SECURITY_RESULT" | jq -r '.result // .message // "No result"' 2>/dev/null || echo "$SECURITY_RESULT"
echo ""

# --- Step 3: コード品質レビュー（テキスト出力） ---
echo "--- コード品質レビュー ---"
echo "$DIFF" | claude -p \
  --model "$MODEL" \
  --max-turns 1 \
  "以下の diff をレビューしてください。以下の観点で簡潔にコメントしてください:
1. バグの可能性
2. エラーハンドリングの不足
3. パフォーマンスへの影響
各項目は1-2行で。問題なければ「問題なし」と書いてください。" 2>/dev/null || echo "Claude API call failed"

echo ""

# --- Step 4: 結果をファイルに保存（オプション） ---
if [ "$OUTPUT_DIR" != "." ]; then
  mkdir -p "$OUTPUT_DIR"
  echo "$SECURITY_RESULT" > "$OUTPUT_DIR/security-review.json"
  echo "レビュー結果を $OUTPUT_DIR/ に保存しました"
fi

echo ""
echo "=== レビュー完了 ==="
