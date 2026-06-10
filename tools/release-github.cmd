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

:: Clean up the release staging folder
if exist "release\" (
    echo Cleaning release\ ...
    rmdir /s /q "release"
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

:: Stage release files into release\ (validates includes, applies ! exclusions)
echo Staging files into release\ ...
powershell -NoProfile -ExecutionPolicy Bypass -File "tools\stage-release-files.ps1" -ListFile "tools\release-files.txt" -OutDir "release"
if errorlevel 1 (
    echo ERROR: Failed to stage release files
    exit /b 1
)

:: Show what was staged and confirm before publishing
echo.
echo Files staged in release\:
dir /s /b "release"
echo.
set /p "CONFIRM=Confirm releasing files from /release/ to github repo? (y/n): "
if /i not "%CONFIRM%"=="y" (
    echo Aborted.
    exit /b 1
)

:: Zip the staged release folder
if exist "%ZIP%" del "%ZIP%"
echo Creating %ZIP%...
powershell -NoProfile -ExecutionPolicy Bypass -Command "Compress-Archive -Path 'release\*' -DestinationPath '%ZIP%'"
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
