# scan-secrets.ps1
# PreToolUse フック: git commit 実行前にシークレットの混入をチェックする（Windows版）
#
# 検出パターン:
#   - AWS アクセスキー (AKIA...)
#   - 秘密鍵ファイルヘッダ (BEGIN RSA/PRIVATE KEY)
#   - 汎用 API キー/トークン (password=, api_key=, secret= 等)
#   - .env ファイルのステージ

$Input = $input | Out-String
$Cmd = ($Input | ConvertFrom-Json).tool_input.command

if ($Cmd -notmatch '^\s*git\s+commit') {
    Write-Output '{}'
    exit 0
}

# ステージされた差分を取得
$StagedDiff = git diff --cached --diff-filter=ACM 2>$null

if (-not $StagedDiff) {
    Write-Output '{}'
    exit 0
}

$Patterns = @(
    'AKIA[0-9A-Z]{16}',
    'BEGIN (RSA |EC |DSA |OPENSSH )?PRIVATE KEY',
    '[pP]assword\s*[=:]\s*[''"][^''"]{4,}',
    '[aA][pP][iI][-_]?[kK][eE][yY]\s*[=:]\s*[''"][^''"]{8,}',
    '[sS][eE][cC][rR][eE][tT]\s*[=:]\s*[''"][^''"]{8,}',
    '[tT][oO][kK][eE][nN]\s*[=:]\s*[''"][^''"]{8,}',
    'ghp_[A-Za-z0-9]{36}',
    'sk-[A-Za-z0-9]{20,}',
    'xox[bpsa]-[A-Za-z0-9\-]{10,}'
)

$Found = @()
$DiffText = $StagedDiff -join "`n"

foreach ($pattern in $Patterns) {
    $matches = [regex]::Matches($DiffText, $pattern)
    if ($matches.Count -gt 0) {
        $Found += "  パターン: $pattern ($($matches.Count) 件検出)"
    }
}

# .env ファイルのチェック
$EnvFiles = git diff --cached --name-only | Where-Object { $_ -match '\.env($|\..+)' -and $_ -notmatch '\.example$' }
if ($EnvFiles) {
    $Found += "  .env ファイルがステージされています: $($EnvFiles -join ', ')"
}

if ($Found.Count -gt 0) {
    $msg = "シークレットの可能性を検出しました！コミットをブロックします。`n" + ($Found -join "`n")
    Write-Error $msg
    exit 2
}

Write-Output '{}'
exit 0
