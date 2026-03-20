#!/bin/bash
# truncate-output.sh
# PreToolUse フック: 大量出力が予想されるコマンドの出力行数を制限する
#
# 仕組み:
#   find, ls -R, cat（巨大ファイル読み込み時）などの出力を
#   最大 MAX_LINES 行に制限する。コンテキストの肥大化を防ぐ。
#
# 効果:
#   無制限のコマンド出力 → 最大200行に制限
#   → 予期しないコンテキスト消費を防止

MAX_LINES=200

INPUT=$(cat)
CMD=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

# 大量出力が予想されるコマンドパターン
if echo "$CMD" | grep -qE '(find\s|ls\s+-[a-zA-Z]*R|log\s+--all|git\s+log\s*$)'; then
  # 既に head/tail でパイプされている場合はスキップ
  if echo "$CMD" | grep -qE '\|\s*(head|tail)'; then
    echo '{}'
  else
    TRUNCATED_CMD="$CMD | head -n $MAX_LINES; echo '--- [フック] 出力を${MAX_LINES}行に制限しました ---'"
    cat <<HOOK_JSON
{"hookSpecificOutput":{"hookEventName":"PreToolUse","updatedInput":{"command":"$TRUNCATED_CMD"}}}
HOOK_JSON
  fi
else
  echo '{}'
fi

exit 0
