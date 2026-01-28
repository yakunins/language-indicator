@echo off
REM Minimal output for CI/automation
"C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe" /ErrorStdOut "%~dp0RunTestsConsole.ahk" 2>&1
echo Exit code: %ERRORLEVEL%
