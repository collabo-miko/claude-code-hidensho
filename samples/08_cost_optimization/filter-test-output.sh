#!/bin/bash
# filter-test-output.sh
# PreToolUse フック: テストコマンドの出力をフィルタリングしてトークンを節約する
#
# 仕組み:
#   テストコマンド（npm test, jest, pytest, go test）を検出し、
#   出力を「失敗箇所 + サマリー」のみに絞る hookSpecificOutput を返す。
#   テスト以外のコマンドはそのまま通過させる。
#
# 効果:
#   1000行のテスト出力 → 失敗箇所のみ50〜100行に圧縮
#   → コンテキストトークンを大幅に節約

INPUT=$(cat)
CMD=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

# テストコマンドかどうか判定
if echo "$CMD" | grep -qE '(npm test|npx jest|pytest|go test|cargo test|mvn test|gradle test)'; then
  # テストコマンドに出力フィルタを追加
  # FAIL/ERROR/FAILED 行とその前後5行を抽出し、100行に制限
  FILTERED_CMD="$CMD 2>&1 | grep -E -A 5 -B 2 '(FAIL|ERROR|FAILED|panic|assert)' | head -100; echo '--- [フック] テスト出力をフィルタリングしました。全出力が必要な場合は filter-test-output.sh を一時的に無効化してください ---'"

  # hookSpecificOutput で書き換えたコマンドを返す
  cat <<HOOK_JSON
{"hookSpecificOutput":{"hookEventName":"PreToolUse","updatedInput":{"command":"$FILTERED_CMD"}}}
HOOK_JSON
else
  # テスト以外のコマンドはそのまま通す
  echo '{}'
fi

exit 0
