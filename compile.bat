@echo off
setlocal enabledelayedexpansion

echo Buscando Garmin SDK...

set "MONKEYC="

if exist "C:\Users\Alonso\AppData\Roaming\Garmin\ConnectIQ\Sdks\connectiq-sdk-win-8.4.1-2026-02-03-e9f77eeaa\bin\monkeyc.bat" (
    set "MONKEYC=C:\Users\Alonso\AppData\Roaming\Garmin\ConnectIQ\Sdks\connectiq-sdk-win-8.4.1-2026-02-03-e9f77eeaa\bin\monkeyc.bat"
) else if exist "C:\Garmin\ConnectIQ_SDK\bin\monkeyc.exe" (
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
"%MONKEYC%" -o bin/pokewatch.prg -f monkey.jungle -y developer_key -d vivoactive6 -w

if %ERRORLEVEL% EQU 0 (
    echo.
    echo [OK] Compilacion exitosa!
    echo Archivo: bin/pokewatch.prg
) else (
    echo.
    echo [ERROR] Fallo en compilacion
)

pause
