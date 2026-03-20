#!/bin/bash
# cleanup-demo.sh
# setup-demo.sh で生成したデモファイルを削除する

set -e
cd "$(dirname "$0")"

echo "=== デモファイルを削除します ==="

for dir in node_modules dist build coverage; do
  if [ -d "$dir" ]; then
    rm -rf "$dir"
    echo "  削除: $dir/"
  fi
done

echo ""
echo "=== クリーンアップ完了 ==="
