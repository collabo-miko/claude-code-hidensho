#!/bin/bash
# setup-demo.sh
# deny ルールの効果を体験するためのデモファイルを生成する
#
# 生成されるディレクトリ:
#   node_modules/  - ダミーの依存パッケージ（大量ファイル）
#   dist/          - ミニファイ済みバンドル
#   build/         - ビルド成果物
#   coverage/      - テストカバレッジレポート
#
# これらは .gitignore で除外されるため Git には含まれません。
# 演習終了後は cleanup-demo.sh で削除できます。

set -e
cd "$(dirname "$0")"

echo "=== deny ルール体験用デモファイルを生成します ==="
echo ""

# --- node_modules/ ---
echo "[1/4] node_modules/ を生成中..."
mkdir -p node_modules/lodash
cat > node_modules/lodash/index.js << 'NODEOF'
// lodash v4.17.21 (dummy)
module.exports = {
  chunk: (arr, size) => { /* 1200行のユーティリティコード... */ },
  compact: (arr) => arr.filter(Boolean),
  concat: (...args) => [].concat(...args),
  difference: (arr, values) => arr.filter(v => !values.includes(v)),
  drop: (arr, n = 1) => arr.slice(n),
  // ... 省略: 実際の lodash は 17,000行以上
};
NODEOF

mkdir -p node_modules/express/lib
cat > node_modules/express/lib/application.js << 'NODEOF'
// express v4.18.2 application.js (dummy)
var proto = module.exports = {};
proto.init = function init() { /* 500行の初期化コード... */ };
proto.use = function use(fn) { /* 200行のミドルウェア登録... */ };
proto.route = function route(path) { /* 150行のルーティング... */ };
proto.listen = function listen() { /* 100行のサーバー起動... */ };
// ... 省略: 実際の express は数千行
NODEOF

mkdir -p node_modules/express/lib/router
cat > node_modules/express/lib/router/index.js << 'NODEOF'
// express router (dummy) - 600行のルーターロジック
var proto = module.exports = function(options) { /* ... */ };
proto.handle = function handle(req, res, out) { /* 200行... */ };
proto.process_params = function process_params(layer, called, req, res, done) { /* 100行... */ };
NODEOF

# --- dist/ ---
echo "[2/4] dist/ を生成中..."
mkdir -p dist
# 大きなミニファイ済みバンドルを生成（実際のプロジェクトでは数百KB〜数MB）
python3 -c "
content = 'var a=' + ','.join(['function(){return ' + str(i) + '}' for i in range(500)]) + ';'
print(content)
" > dist/bundle.min.js 2>/dev/null || {
  # python3 が無い場合のフォールバック
  echo 'var a=function(){return 0},b=function(){return 1};/* ... minified bundle 200KB ... */' > dist/bundle.min.js
  for i in $(seq 1 100); do
    echo "var _$i=function(){return $i};" >> dist/bundle.min.js
  done
}

cat > dist/bundle.min.js.map << 'MAPEOF'
{"version":3,"sources":["src/app.js","src/utils.js"],"names":["createUser","getUser","listUsers"],"mappings":"AAAA,SAASA,aAAa,SAAS,GAAG,OAAO,CAAC,MAAM,IAAI,QAAQ,GAAG,SAAS"}
MAPEOF

# --- build/ ---
echo "[3/4] build/ を生成中..."
mkdir -p build
cat > build/output.log << 'BUILDEOF'
[2026-03-20T10:00:00Z] Starting build...
[2026-03-20T10:00:01Z] Compiling src/app.js...
[2026-03-20T10:00:01Z] Compiling src/utils.js...
[2026-03-20T10:00:02Z] Bundling modules...
[2026-03-20T10:00:03Z] Minifying output...
[2026-03-20T10:00:03Z] Generating source maps...
[2026-03-20T10:00:04Z] Build completed successfully.
Output: dist/bundle.min.js (245KB)
Output: dist/bundle.min.js.map (89KB)
BUILDEOF

# --- coverage/ ---
echo "[4/4] coverage/ を生成中..."
mkdir -p coverage/lcov-report
cat > coverage/lcov-report/index.html << 'COVEOF'
<!DOCTYPE html>
<html><head><title>Coverage Report</title></head>
<body>
<h1>Code Coverage Report</h1>
<table>
<tr><th>File</th><th>Statements</th><th>Branches</th><th>Functions</th><th>Lines</th></tr>
<tr><td>src/app.js</td><td>85%</td><td>70%</td><td>100%</td><td>85%</td></tr>
<tr><td>src/utils.js</td><td>100%</td><td>90%</td><td>100%</td><td>100%</td></tr>
</table>
</body></html>
COVEOF

cat > coverage/lcov.info << 'LCOVEOF'
TN:
SF:src/app.js
FN:5,createUser
FN:14,getUser
FN:20,listUsers
FN:24,deleteUser
FNF:4
FNH:4
DA:5,3
DA:6,3
DA:14,2
DA:20,1
DA:24,1
LF:5
LH:5
end_of_record
LCOVEOF

echo ""
echo "=== 生成完了 ==="
echo ""
echo "生成されたディレクトリ:"
echo "  node_modules/  - ダミー依存パッケージ（lodash, express）"
echo "  dist/          - ミニファイ済みバンドル + ソースマップ"
echo "  build/         - ビルドログ"
echo "  coverage/      - テストカバレッジレポート"
echo ""
echo "これらは .gitignore で除外されるため Git には含まれません。"
echo "演習終了後: bash cleanup-demo.sh で削除できます。"
