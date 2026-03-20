# setup-demo.ps1
# deny ルールの効果を体験するためのデモファイルを生成する（Windows版）
#
# 生成されるディレクトリ:
#   node_modules/  - ダミーの依存パッケージ（大量ファイル）
#   dist/          - ミニファイ済みバンドル
#   build/         - ビルド成果物
#   coverage/      - テストカバレッジレポート

$ErrorActionPreference = "Stop"
Push-Location $PSScriptRoot

Write-Host "=== deny ルール体験用デモファイルを生成します ===" -ForegroundColor Cyan
Write-Host ""

# --- node_modules/ ---
Write-Host "[1/4] node_modules/ を生成中..."
New-Item -ItemType Directory -Force -Path "node_modules/lodash" | Out-Null
@'
// lodash v4.17.21 (dummy)
module.exports = {
  chunk: (arr, size) => { /* 1200行のユーティリティコード... */ },
  compact: (arr) => arr.filter(Boolean),
  concat: (...args) => [].concat(...args),
  // ... 省略: 実際の lodash は 17,000行以上
};
'@ | Set-Content "node_modules/lodash/index.js"

New-Item -ItemType Directory -Force -Path "node_modules/express/lib/router" | Out-Null
@'
// express v4.18.2 application.js (dummy)
var proto = module.exports = {};
proto.init = function init() { /* 500行の初期化コード... */ };
proto.use = function use(fn) { /* 200行のミドルウェア登録... */ };
proto.listen = function listen() { /* 100行のサーバー起動... */ };
'@ | Set-Content "node_modules/express/lib/application.js"

@'
// express router (dummy)
var proto = module.exports = function(options) { /* ... */ };
proto.handle = function handle(req, res, out) { /* 200行... */ };
'@ | Set-Content "node_modules/express/lib/router/index.js"

# --- dist/ ---
Write-Host "[2/4] dist/ を生成中..."
New-Item -ItemType Directory -Force -Path "dist" | Out-Null
$bundleContent = "var a=" + ((0..99 | ForEach-Object { "function(){return $_}" }) -join ',') + ";"
$bundleContent | Set-Content "dist/bundle.min.js"

@'
{"version":3,"sources":["src/app.js","src/utils.js"],"names":["createUser","getUser","listUsers"],"mappings":"AAAA"}
'@ | Set-Content "dist/bundle.min.js.map"

# --- build/ ---
Write-Host "[3/4] build/ を生成中..."
New-Item -ItemType Directory -Force -Path "build" | Out-Null
@"
[2026-03-20T10:00:00Z] Starting build...
[2026-03-20T10:00:01Z] Compiling src/app.js...
[2026-03-20T10:00:02Z] Bundling modules...
[2026-03-20T10:00:03Z] Build completed successfully.
Output: dist/bundle.min.js (245KB)
"@ | Set-Content "build/output.log"

# --- coverage/ ---
Write-Host "[4/4] coverage/ を生成中..."
New-Item -ItemType Directory -Force -Path "coverage/lcov-report" | Out-Null
@'
<!DOCTYPE html>
<html><head><title>Coverage Report</title></head>
<body>
<h1>Code Coverage Report</h1>
<table>
<tr><th>File</th><th>Statements</th><th>Lines</th></tr>
<tr><td>src/app.js</td><td>85%</td><td>85%</td></tr>
<tr><td>src/utils.js</td><td>100%</td><td>100%</td></tr>
</table>
</body></html>
'@ | Set-Content "coverage/lcov-report/index.html"

Write-Host ""
Write-Host "=== 生成完了 ===" -ForegroundColor Green
Write-Host ""
Write-Host "生成されたディレクトリ:"
Write-Host "  node_modules/  - ダミー依存パッケージ（lodash, express）"
Write-Host "  dist/          - ミニファイ済みバンドル + ソースマップ"
Write-Host "  build/         - ビルドログ"
Write-Host "  coverage/      - テストカバレッジレポート"
Write-Host ""
Write-Host "演習終了後: .\cleanup-demo.ps1 で削除できます。"

Pop-Location
