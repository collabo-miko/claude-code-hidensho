#!/bin/bash
# CLAUDE.md / ルールファイルの不正な Unicode 制御文字を検出するスクリプト
# macOS (BSD) / Linux 両対応、日本語テキストへの誤検出なし
# Usage: bash check-unicode.sh <file>

FILE="${1:?使用方法: bash check-unicode.sh <file>}"

if [ ! -f "$FILE" ]; then
  echo "エラー: ファイルが見つかりません: $FILE"
  exit 1
fi

echo "=== $FILE の Unicode 制御文字チェック ==="

# 不可視制御文字の検出（NULL, SOH, STX 等）
# -CSD フラグで Unicode 対応: UTF-8 マルチバイト文字を誤検出しない
if perl -CSD -ne 'print if /[\x{0000}-\x{0008}\x{000B}\x{000C}\x{000E}-\x{001F}\x{007F}-\x{009F}]/' "$FILE" | head -5 | grep -q .; then
  echo "[!] 警告: 不可視の制御文字が検出されました"
  perl -CSD -ne 'if (/[\x{0000}-\x{0008}\x{000B}\x{000C}\x{000E}-\x{001F}\x{007F}-\x{009F}]/) { print "  行 $.: $_" }' "$FILE" | head -10
  FOUND=1
else
  echo "[OK] 制御文字: なし"
fi

# 双方向テキストオーバーライド文字・ゼロ幅文字の検出
if perl -CSD -ne 'print if /[\x{202E}\x{202D}\x{200E}\x{200F}\x{061C}\x{200D}\x{200C}\x{FEFF}]/' "$FILE" | head -5 | grep -q .; then
  echo "[!] 警告: 双方向/ゼロ幅文字が検出されました"
  perl -CSD -ne 'if (/[\x{202E}\x{202D}\x{200E}\x{200F}\x{061C}\x{200D}\x{200C}\x{FEFF}]/) { print "  行 $.: $_" }' "$FILE" | head -10
  FOUND=1
else
  echo "[OK] 双方向/ゼロ幅文字: なし"
fi

if [ "${FOUND:-0}" = "1" ]; then
  echo ""
  echo "=== 詳細確認 ==="
  echo "以下のコマンドで内容をバイナリ表示できます:"
  echo "  od -c $FILE | head -50"
  echo "  xxd $FILE | head -50"
  exit 1
else
  echo ""
  echo "結果: 問題なし"
  exit 0
fi
