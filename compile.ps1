#!/usr/bin/env pwsh

param(
    [switch]$Clean
)

Write-Host "╔═══════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║ PokeWatch Garmin Compilation Script      ║" -ForegroundColor Cyan
Write-Host "╚═══════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# Limpiar si se solicita
if ($Clean) {
    Write-Host "Limpiando builds anteriores..." -ForegroundColor Yellow
    if (Test-Path "bin/pokewatch.prg") { Remove-Item "bin/pokewatch.prg" -Force }
    if (Test-Path "bin/gen") { Remove-Item "bin/gen" -Recurse -Force }
}

# Buscar monkeyc
$monkeyc = $null
$searchPaths = @(
    "$env:APPDATA\Garmin\ConnectIQ\Sdks\connectiq-sdk-win-8.4.1-2026-02-03-e9f77eeaa\bin\monkeyc.bat",
    "C:\Garmin\ConnectIQ_SDK\bin\monkeyc.exe",
    "C:\Garmin\ConnectIQ\bin\monkeyc.exe",
    "C:\Program Files\Garmin\ConnectIQ\bin\monkeyc.exe",
    "C:\Program Files (x86)\Garmin\ConnectIQ\bin\monkeyc.exe"
)

Write-Host "Buscando Garmin SDK..." -ForegroundColor Yellow
foreach ($path in $searchPaths) {
    if (Test-Path $path) {
        $monkeyc = $path
        Write-Host "✓ SDK encontrado en: $([System.IO.Path]::GetDirectoryName($path))" -ForegroundColor Green
        break
    }
}

# Si no encontró monkeyc, intentar ejecutar directamente
if (-not $monkeyc) {
    Write-Host "Intentando compilar con monkeyc del PATH..." -ForegroundColor Yellow
    $monkeyc = "monkeyc"
}

Write-Host ""
Write-Host "Compilando PokeWatch para vivoactive6..." -ForegroundColor Cyan
Write-Host ""

try {
    & $monkeyc -o bin/pokewatch.prg -f monkey.jungle -y developer_key -d vivoactive6 -w 2>&1
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Host "✓ ¡Compilación exitosa!" -ForegroundColor Green
        Write-Host "📦 Archivo generado: bin/pokewatch.prg" -ForegroundColor Green
    } else {
        Write-Host ""
        Write-Host "✗ Error en compilación" -ForegroundColor Red
        exit 1
    }
}
catch {
    Write-Host ""
    Write-Host "✗ Error: No se pudo ejecutar monkeyc" -ForegroundColor Red
    Write-Host "Instala el Garmin Connect IQ SDK desde:" -ForegroundColor Yellow
    Write-Host "https://developer.garmin.com/en-US/connect-iq/download/" -ForegroundColor Yellow
    exit 1
}
