@echo off
REM Main test runner with verbose output
echo Running Language Indicator Tests...
echo.
"C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe" /ErrorStdOut "%~dp0RunTestsConsole.ahk"
set EXIT_CODE=%ERRORLEVEL%
echo.
type "%~dp0test-results.txt"
echo.
if %EXIT_CODE%==0 (
    echo [SUCCESS] All tests passed!
) else (
    echo [FAILURE] Some tests failed!
)
exit /b %EXIT_CODE%
