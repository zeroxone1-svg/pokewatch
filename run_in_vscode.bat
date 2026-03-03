@echo off
setlocal enabledelayedexpansion

echo ======================================
echo   PokeWatch - Build + Simulator
echo ======================================
echo.

set "SDK_BIN="
set "SDK_ROOT=%APPDATA%\Garmin\ConnectIQ\Sdks"

if exist "%SDK_ROOT%" (
	for /f "delims=" %%D in ('dir /b /ad /o-n "%SDK_ROOT%"') do (
		if exist "%SDK_ROOT%\%%D\bin\monkeyc.bat" (
			set "SDK_BIN=%SDK_ROOT%\%%D\bin"
			goto :sdk_found
		)
	)
)

if exist "C:\Garmin\ConnectIQ_SDK\bin\monkeyc.exe" set "SDK_BIN=C:\Garmin\ConnectIQ_SDK\bin"
if not "%SDK_BIN%"=="" goto :sdk_found

echo ERROR: No se encontro Garmin Connect IQ SDK.
echo Instala el SDK desde: https://developer.garmin.com/connect-iq/download/
exit /b 1

:sdk_found
echo SDK: %SDK_BIN%
echo.

where code >nul 2>nul
if %ERRORLEVEL% EQU 0 (
	start "" code .
)

echo Compilando app...
call "%SDK_BIN%\monkeyc.bat" -o bin/pokewatch.prg -f monkey.jungle -y developer_key -d vivoactive6
if %ERRORLEVEL% NEQ 0 (
	echo ERROR: Fallo la compilacion.
	exit /b 1
)

echo Iniciando simulador...
start "" "%SDK_BIN%\simulator.exe"
timeout /t 2 /nobreak >nul

echo Cargando app en simulador...
call "%SDK_BIN%\monkeydo.bat" bin/pokewatch.prg vivoactive6
if %ERRORLEVEL% NEQ 0 (
	echo WARNING: No se pudo cargar automaticamente en el simulador.
	echo Abre el simulador y vuelve a ejecutar este script.
	exit /b 1
)

echo OK: App compilada y cargada en vivoactive6.
exit /b 0
