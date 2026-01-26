@echo off
setlocal EnableExtensions

echo === Language Indicator - Compile ===
echo.

:: Set paths
set "ScriptDir=%~dp0"
set "SourceFile=%ScriptDir%language-indicator.ahk"
set "OutputFile=%ScriptDir%language-indicator.exe"
set "Compiler=C:\Program Files\AutoHotkey\Compiler\Ahk2Exe.exe"
set "BaseFile=C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe"
set "IconFile=%ScriptDir%img\app-icon.ico"

:: Check if compiler exists
if not exist "%Compiler%" (
    echo [ERROR] Compiler not found: %Compiler%
    echo Please install AutoHotkey v2 with the compiler component.
    goto :end
)

:: Check if source file exists
if not exist "%SourceFile%" (
    echo [ERROR] Source file not found: %SourceFile%
    goto :end
)

echo Compiling...
echo   Source: %SourceFile%
echo   Output: %OutputFile%
echo.

:: Compile the script
"%Compiler%" /in "%SourceFile%" /out "%OutputFile%" /base "%BaseFile%" /icon "%IconFile%"

if exist "%OutputFile%" (
    echo [OK] Compilation successful.
    echo.
    for %%A in ("%OutputFile%") do echo   Size: %%~zA bytes
) else (
    echo [ERROR] Compilation failed.
)

:end
echo.
pause
endlocal
