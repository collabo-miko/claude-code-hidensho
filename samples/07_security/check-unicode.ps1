# check-unicode.ps1
# Unicode 制御文字検出スクリプト（Windows版）
# Rules File Backdoor 攻撃で使用される不可視文字を検出します
#
# 使い方:
#   .\check-unicode.ps1 CLAUDE.md
#   .\check-unicode.ps1 .claude\rules\security.md

param(
    [Parameter(Mandatory=$true)]
    [string]$FilePath
)

if (-not (Test-Path $FilePath)) {
    Write-Error "ファイルが見つかりません: $FilePath"
    exit 1
}

Write-Host "=== Unicode 制御文字チェック: $FilePath ===" -ForegroundColor Cyan

$content = [System.IO.File]::ReadAllText($FilePath)
$found = $false

# 検出パターン
$checks = @(
    @{ Name = "双方向テキスト制御文字 (Bidi)"; Pattern = '[\u200E\u200F\u202A-\u202E\u2066-\u2069]' },
    @{ Name = "ゼロ幅文字"; Pattern = '[\u200B-\u200D\uFEFF]' },
    @{ Name = "不可視制御文字 (C0/C1)"; Pattern = '[\x00-\x08\x0B\x0C\x0E-\x1F\x7F-\x9F]' }
)

foreach ($check in $checks) {
    $matches = [regex]::Matches($content, $check.Pattern)
    if ($matches.Count -gt 0) {
        $found = $true
        Write-Host "  検出: $($check.Name) ($($matches.Count) 件)" -ForegroundColor Red
        foreach ($m in $matches) {
            $pos = $m.Index
            $line = ($content.Substring(0, $pos) -split "`n").Count
            $hex = [System.String]::Format("U+{0:X4}", [int]$m.Value[0])
            Write-Host "    行 $line : $hex" -ForegroundColor Yellow
        }
    }
}

if (-not $found) {
    Write-Host "  問題なし: 不審な Unicode 制御文字は検出されませんでした" -ForegroundColor Green
}

Write-Host "=== チェック完了 ===" -ForegroundColor Cyan
