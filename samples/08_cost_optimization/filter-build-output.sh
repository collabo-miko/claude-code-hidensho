#!/bin/bash
# filter-build-output.sh
# PreToolUse フック: ビルドコマンドの出力を WARNING/ERROR のみにフィルタリングする
#
# 対象コマンド:
#   npm run build, npx tsc, cargo build, go build, gradle build, mvn compile
#
# 効果:
#   ビルドの大量ログから WARNING/ERROR 行のみ抽出
#   → 成功時はサマリーのみ、失敗時はエラー箇所に集中できる

INPUT=$(cat)
CMD=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

# ビルドコマンドかどうか判定
if echo "$CMD" | grep -qE '(npm run build|npx tsc|cargo build|go build|gradle build|mvn compile|make\b)'; then
  # ビルドコマンドに出力フィルタを追加
  # 成功時: 最後の5行（サマリー）のみ
  # 失敗時: WARNING/ERROR 行 + 前後の文脈を抽出
  FILTERED_CMD="set -o pipefail; $CMD 2>&1 | tee /tmp/_build_full.log | grep -E -A 3 -B 1 '(WARNING|WARN|ERROR|error\\[|failed)' | head -80; BUILD_EXIT=\${PIPESTATUS[0]}; if [ \$BUILD_EXIT -eq 0 ]; then echo ''; echo '--- ビルド成功 ---'; tail -3 /tmp/_build_full.log; else echo ''; echo \"--- ビルド失敗 (exit \$BUILD_EXIT) ---\"; fi; echo '--- [フック] ビルド出力をフィルタリングしました。全出力: /tmp/_build_full.log ---'; exit \$BUILD_EXIT"

  cat <<HOOK_JSON
{"hookSpecificOutput":{"hookEventName":"PreToolUse","updatedInput":{"command":"$FILTERED_CMD"}}}
HOOK_JSON
else
  echo '{}'
fi

exit 0
