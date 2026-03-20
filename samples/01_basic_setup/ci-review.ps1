# ci-review.ps1
# CI/CD パイプラインで Claude Code を非対話モードで活用するサンプルスクリプト
#
# 使い方:
#   .\ci-review.ps1                              # デフォルト: main ブランチとの差分をレビュー
#   .\ci-review.ps1 -BaseBranch origin/develop   # 指定ブランチとの差分をレビュー
#   $env:REVIEW_MODEL="haiku"; .\ci-review.ps1   # haiku でコスト削減レビュー

param(
    [string]$BaseBranch = "origin/main"
)

$ErrorActionPreference = "Stop"

$Model = if ($env:REVIEW_MODEL) { $env:REVIEW_MODEL } else { "sonnet" }
$MaxTokens = if ($env:REVIEW_MAX_TOKENS) { $env:REVIEW_MAX_TOKENS } else { "4096" }

Write-Host "=== Claude Code CI Review ===" -ForegroundColor Cyan
Write-Host "Base branch: $BaseBranch"
Write-Host "Model: $Model"
Write-Host ""

# --- Step 1: 差分の取得 ---
$Diff = git diff "$BaseBranch...HEAD" -- '*.js' '*.ts' '*.py' '*.go' '*.java' '*.rb' 2>$null

if (-not $Diff) {
    Write-Host "レビュー対象の変更がありません。"
    exit 0
}

$ChangedFiles = git diff --name-only "$BaseBranch...HEAD" -- '*.js' '*.ts' '*.py' '*.go' '*.java' '*.rb'
$FileCount = ($ChangedFiles | Measure-Object -Line).Lines

Write-Host "変更ファイル数: $FileCount"
Write-Host $ChangedFiles
Write-Host ""

# --- Step 2: セキュリティレビュー（JSON出力） ---
Write-Host "--- セキュリティレビュー ---" -ForegroundColor Yellow
try {
    $SecurityResult = $Diff | claude -p --model $Model --max-turns 1 --output-format json "以下の diff にセキュリティ上の問題がないかレビューしてください。問題がある場合は severity (critical/warning/info) と該当行を示してください。問題がなければ「セキュリティ問題なし」と回答してください。" 2>$null
    Write-Host $SecurityResult
} catch {
    Write-Host "Claude API call failed" -ForegroundColor Red
}
Write-Host ""

# --- Step 3: コード品質レビュー ---
Write-Host "--- コード品質レビュー ---" -ForegroundColor Yellow
try {
    $Diff | claude -p --model $Model --max-turns 1 "以下の diff をレビューしてください。以下の観点で簡潔にコメントしてください: 1. バグの可能性 2. エラーハンドリングの不足 3. パフォーマンスへの影響 各項目は1-2行で。問題なければ「問題なし」と書いてください。" 2>$null
} catch {
    Write-Host "Claude API call failed" -ForegroundColor Red
}

Write-Host ""
Write-Host "=== レビュー完了 ===" -ForegroundColor Cyan
