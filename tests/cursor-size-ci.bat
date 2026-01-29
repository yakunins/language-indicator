@echo off
"C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe" /ErrorStdOut "%~dp0GetCursorSize.test.ahk" 2>&1
echo Exit code: %ERRORLEVEL%
