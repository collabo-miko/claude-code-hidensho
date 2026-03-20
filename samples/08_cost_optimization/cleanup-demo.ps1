# cleanup-demo.ps1
# setup-demo.ps1 で生成したデモファイルを削除する（Windows版）

Push-Location $PSScriptRoot

Write-Host "=== デモファイルを削除します ===" -ForegroundColor Cyan

foreach ($dir in @("node_modules", "dist", "build", "coverage")) {
    if (Test-Path $dir) {
        Remove-Item -Recurse -Force $dir
        Write-Host "  削除: $dir/"
    }
}

Write-Host ""
Write-Host "=== クリーンアップ完了 ===" -ForegroundColor Green

Pop-Location
