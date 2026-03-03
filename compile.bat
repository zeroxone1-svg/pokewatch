@echo off
setlocal enabledelayedexpansion

echo Buscando Garmin SDK...

set "MONKEYC="

if exist "C:\Garmin\ConnectIQ_SDK\bin\monkeyc.exe" (
    set "MONKEYC=C:\Garmin\ConnectIQ_SDK\bin\monkeyc.exe"
) else if exist "C:\Garmin\ConnectIQ\bin\monkeyc.exe" (
    set "MONKEYC=C:\Garmin\ConnectIQ\bin\monkeyc.exe"
) else if exist "C:\Program Files\Garmin\ConnectIQ\bin\monkeyc.exe" (
    set "MONKEYC=C:\Program Files\Garmin\ConnectIQ\bin\monkeyc.exe"
) else if exist "C:\Program Files (x86)\Garmin\ConnectIQ\bin\monkeyc.exe" (
    set "MONKEYC=C:\Program Files (x86)\Garmin\ConnectIQ\bin\monkeyc.exe"
)

if "!MONKEYC!"=="" (
    echo.
    echo ERROR: No se encontro monkeyc
    echo Instala Garmin SDK desde: https://developer.garmin.com/connect-iq/download/
    pause
    exit /b 1
)

echo SDK encontrado: %MONKEYC%
echo.
echo Compilando PokeWatch...
"%MONKEYC%" -o bin/pokewatch.prg -m monkey.jungle -z resources -y developer_key

if %ERRORLEVEL% EQU 0 (
    echo.
    echo [OK] Compilacion exitosa!
    echo Archivo: bin/pokewatch.prg
) else (
    echo.
    echo [ERROR] Fallo en compilacion
)

pause
