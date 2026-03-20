# filter-build-output.ps1
# PreToolUse フック: ビルドコマンドの出力を WARNING/ERROR のみにフィルタリングする（Windows版）

$Input = $input | Out-String
$Cmd = ($Input | ConvertFrom-Json).tool_input.command

if ($Cmd -match '(npm run build|npx tsc|cargo build|go build|gradle build|mvn compile)') {
    $FilteredCmd = "$Cmd 2>&1 | Tee-Object -FilePath `$env:TEMP\_build_full.log | Select-String -Pattern 'WARNING|WARN|ERROR|error\[|failed' -Context 1,3 | Select-Object -First 80; Write-Host '--- [フック] ビルド出力をフィルタリングしました。全出力: `$env:TEMP\_build_full.log ---'"

    @"
{"hookSpecificOutput":{"hookEventName":"PreToolUse","updatedInput":{"command":"powershell -Command `"$FilteredCmd`""}}}
"@
} else {
    Write-Output '{}'
}

exit 0
