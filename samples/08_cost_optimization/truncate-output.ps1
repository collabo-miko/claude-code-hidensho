# truncate-output.ps1
# PreToolUse フック: 大量出力が予想されるコマンドの出力行数を制限する（Windows版）

$MaxLines = 200

$Input = $input | Out-String
$Cmd = ($Input | ConvertFrom-Json).tool_input.command

if ($Cmd -match '(Get-ChildItem\s+-Recurse|dir\s+/s|find\s|ls\s+-[a-zA-Z]*R)') {
    # 既に Select-Object でパイプされている場合はスキップ
    if ($Cmd -match 'Select-Object|head|tail') {
        Write-Output '{}'
    } else {
        $TruncatedCmd = "$Cmd | Select-Object -First $MaxLines; Write-Host '--- [フック] 出力を${MaxLines}行に制限しました ---'"
        @"
{"hookSpecificOutput":{"hookEventName":"PreToolUse","updatedInput":{"command":"powershell -Command `"$TruncatedCmd`""}}}
"@
    }
} else {
    Write-Output '{}'
}

exit 0
