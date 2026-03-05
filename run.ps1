$sdk = "C:/Users/Alonso/AppData/Roaming/Garmin/ConnectIQ/Sdks/connectiq-sdk-win-8.4.1-2026-02-03-e9f77eeaa/bin"
$device = "vivoactive6"

# Build
Write-Host "=== Building ===" -ForegroundColor Cyan
& "$sdk/monkeyc.bat" -o bin/pokewatch.prg -f monkey.jungle -y developer_key -d $device -w
if ($LASTEXITCODE -ne 0) {
    Write-Host "BUILD FAILED" -ForegroundColor Red
    exit 1
}
Write-Host "BUILD OK" -ForegroundColor Green

# Kill existing simulator
$sim = Get-Process -Name "simulator" -ErrorAction SilentlyContinue
if ($sim) {
    Write-Host "Killing existing simulator..." -ForegroundColor Yellow
    Stop-Process -Name "simulator" -Force
    Start-Sleep -Seconds 2
}

# Start simulator
Write-Host "Starting simulator..." -ForegroundColor Cyan
Start-Process "$sdk/connectiq.bat"
Start-Sleep -Seconds 4

# Run app
Write-Host "Launching app..." -ForegroundColor Cyan
& "$sdk/monkeydo.bat" bin/pokewatch.prg $device
Write-Host "Done!" -ForegroundColor Green
