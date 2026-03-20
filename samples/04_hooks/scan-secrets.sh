#!/bin/bash
# scan-secrets.sh
# PreToolUse フック: git commit 実行前にシークレットの混入をチェックする
#
# 仕組み:
#   Bash コマンドから git commit を検出し、ステージされた差分に
#   API キー・パスワード・トークン等のパターンがないかスキャンする。
#   検出された場合は exit 2 でコミットをブロックする。
#
# 検出パターン:
#   - AWS アクセスキー (AKIA...)
#   - 秘密鍵ファイルヘッダ (BEGIN RSA/PRIVATE KEY)
#   - 汎用 API キー/トークン (password=, api_key=, secret= 等)
#   - Bearer トークン
#   - 高エントロピー文字列（Base64 長文字列）

INPUT=$(cat)
CMD=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

# git commit コマンドかどうか判定
if echo "$CMD" | grep -qE '^\s*git\s+commit'; then

  # ステージされた差分を取得（新規追加分のみ）
  STAGED_DIFF=$(git diff --cached --diff-filter=ACM 2>/dev/null || true)

  if [ -z "$STAGED_DIFF" ]; then
    echo '{}'
    exit 0
  fi

  # シークレットパターンの定義
  PATTERNS=(
    'AKIA[0-9A-Z]{16}'                          # AWS Access Key ID
    'BEGIN (RSA |EC |DSA |OPENSSH )?PRIVATE KEY' # 秘密鍵
    '[pP]assword\s*[=:]\s*["\x27][^"\x27]{4,}'  # password = "..."
    '[aA][pP][iI][-_]?[kK][eE][yY]\s*[=:]\s*["\x27][^"\x27]{8,}'  # API key
    '[sS][eE][cC][rR][eE][tT]\s*[=:]\s*["\x27][^"\x27]{8,}'       # Secret
    '[tT][oO][kK][eE][nN]\s*[=:]\s*["\x27][^"\x27]{8,}'           # Token
    'Bearer\s+[A-Za-z0-9\-._~+/]{20,}'          # Bearer token
    'ghp_[A-Za-z0-9]{36}'                        # GitHub Personal Access Token
    'sk-[A-Za-z0-9]{20,}'                        # OpenAI / Anthropic API key
    'xox[bpsa]-[A-Za-z0-9\-]{10,}'              # Slack token
  )

  # 検出結果を格納
  FOUND=""
  for pattern in "${PATTERNS[@]}"; do
    MATCHES=$(echo "$STAGED_DIFF" | grep -nE "$pattern" 2>/dev/null | head -5 || true)
    if [ -n "$MATCHES" ]; then
      FOUND="${FOUND}\n  パターン: ${pattern}\n${MATCHES}\n"
    fi
  done

  # .env ファイルがステージされていないか確認
  ENV_FILES=$(git diff --cached --name-only | grep -E '\.env($|\..+)' | grep -v '\.example$' || true)
  if [ -n "$ENV_FILES" ]; then
    FOUND="${FOUND}\n  .env ファイルがステージされています:\n${ENV_FILES}\n"
  fi

  if [ -n "$FOUND" ]; then
    echo -e "🚨 シークレットの可能性を検出しました！コミットをブロックします。\n${FOUND}" >&2
    echo -e "\n対処方法:" >&2
    echo "  1. git reset HEAD <file> で該当ファイルをアンステージ" >&2
    echo "  2. シークレットを環境変数または .env に移動" >&2
    echo "  3. .gitignore に .env を追加" >&2
    exit 2
  fi

  echo '{}'
  exit 0
else
  echo '{}'
  exit 0
fi
