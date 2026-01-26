@echo off
setlocal EnableExtensions DisableDelayedExpansion

echo === Language Indicator - Uninstall ===
echo.

:: Get Windows Startup folder from registry
set "StartupDir="
for /F "skip=1 tokens=1,2*" %%I in ('%SystemRoot%\System32\reg.exe QUERY "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" /v Startup 2^>nul') do (
    if /I "%%I" == "Startup" if not "%%~K" == "" (
        if "%%J" == "REG_SZ" (set "StartupDir=%%~K") else if "%%J" == "REG_EXPAND_SZ" call set "StartupDir=%%~K"
    )
)
if not defined StartupDir set "StartupDir=%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup"

:: Remove shortcut from Startup folder
set "ShortcutName=language-indicator.lnk"
set "Shortcut=%StartupDir%\%ShortcutName%"

echo Removing startup shortcut...
echo   Shortcut: %Shortcut%
echo.

if exist "%Shortcut%" (
    del "%Shortcut%"
    if not exist "%Shortcut%" (
        echo [OK] Shortcut removed successfully.
        echo Language Indicator will no longer start automatically.
    ) else (
        echo [ERROR] Failed to remove shortcut.
    )
) else (
    echo [INFO] Shortcut not found. Nothing to remove.
)

echo.
set /P "OPEN=Open startup folder? [Y/N]: "
if /I "%OPEN%" == "Y" start "" shell:startup

endlocal
