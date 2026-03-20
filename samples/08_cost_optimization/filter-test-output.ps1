# filter-test-output.ps1
# PreToolUse フック: テストコマンドの出力をフィルタリングしてトークンを節約する（Windows版）

$Input = $input | Out-String
$Cmd = ($Input | ConvertFrom-Json).tool_input.command

if ($Cmd -match '(npm test|npx jest|pytest|go test|cargo test)') {
    $FilteredCmd = "$Cmd 2>&1 | Select-String -Pattern 'FAIL|ERROR|FAILED|panic|assert' -Context 2,5 | Select-Object -First 100; Write-Host '--- [フック] テスト出力をフィルタリングしました ---'"

    @"
{"hookSpecificOutput":{"hookEventName":"PreToolUse","updatedInput":{"command":"powershell -Command `"$FilteredCmd`""}}}
"@
} else {
    Write-Output '{}'
}

exit 0
