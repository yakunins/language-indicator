@echo off
setlocal enabledelayedexpansion

:: Work from project root
cd /d "%~dp0.."

:: Confirm exe is compiled
set /p "COMPILED=Have you compiled .exe? (y/n): "
if /i not "%COMPILED%"=="y" (
    echo Aborted.
    exit /b 1
)

:: Check for uncommitted changes
git diff --quiet 2>nul
if errorlevel 1 (
    echo ERROR: You have uncommitted changes. Commit or stash them first.
    exit /b 1
)
git diff --cached --quiet 2>nul
if errorlevel 1 (
    echo ERROR: You have staged uncommitted changes. Commit or stash them first.
    exit /b 1
)

:: Read version from language-indicator.ahk (matches: static Version := "0.7")
set "VERSION="
for /f "tokens=2 delims==" %%a in ('findstr /c:"static Version :=" language-indicator.ahk') do (
    set "VERSION=%%~a"
)
:: Clean up: remove quotes, spaces
set "VERSION=%VERSION: =%"
set "VERSION=%VERSION:"=%"

if "%VERSION%"=="" (
    echo ERROR: Could not read version from language-indicator.ahk
    exit /b 1
)

set "TAG=v%VERSION%"
set "ZIP=language-indicator-%TAG%.zip"

echo Version: %VERSION%
echo Tag:     %TAG%
echo Zip:     %ZIP%

:: Check if tag already exists
git tag -l "%TAG%" | findstr /c:"%TAG%" >nul 2>nul
if not errorlevel 1 (
    echo ERROR: Tag %TAG% already exists. Bump the version first.
    exit /b 1
)

:: Verify all release files exist
for /f "usebackq delims=" %%f in ("tools\release-files.txt") do (
    if not exist "%%f" (
        echo ERROR: Missing file: %%f
        exit /b 1
    )
)

:: Create zip from release-files.txt
if exist "%ZIP%" del "%ZIP%"
echo Creating %ZIP%...
powershell -NoProfile -Command "Compress-Archive -Path (Get-Content 'tools\release-files.txt' | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne '' }) -DestinationPath '%ZIP%'"
if errorlevel 1 (
    echo ERROR: Failed to create zip
    exit /b 1
)

:: Create GitHub release with auto-generated notes
echo Creating GitHub release %TAG%...
gh release create "%TAG%" "%ZIP%" --title "%TAG%" --generate-notes
if errorlevel 1 (
    echo ERROR: Failed to create GitHub release
    del "%ZIP%"
    exit /b 1
)

:: Clean up zip
del "%ZIP%"
echo Release %TAG% created successfully.
