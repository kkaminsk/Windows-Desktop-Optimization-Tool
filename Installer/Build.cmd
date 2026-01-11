@echo off
REM ============================================================================
REM WDOT Installer Build Script
REM
REM Builds the MSI installer for Windows Desktop Optimization Tool.
REM Requires: WiX Toolset v4+ (https://wixtoolset.org/)
REM
REM Usage: Build.cmd
REM ============================================================================

setlocal EnableDelayedExpansion

echo.
echo ============================================================
echo   Windows Desktop Optimization Tool - MSI Builder
echo ============================================================
echo.

REM Check if wix is available
where wix >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo ERROR: WiX Toolset not found in PATH.
    echo.
    echo Please install WiX Toolset v4 or later:
    echo   1. Install .NET SDK if not present
    echo   2. Run: dotnet tool install --global wix
    echo.
    echo Or download from: https://wixtoolset.org/
    echo.
    exit /b 1
)

REM Display WiX version
echo WiX version:
wix --version
echo.

REM Set output filename
set OUTPUT_MSI=WDOT-1.1-W365CloudPC.msi

REM Clean previous build
if exist "%OUTPUT_MSI%" (
    echo Removing previous build...
    del "%OUTPUT_MSI%"
)

REM Build the MSI
echo Building MSI...
echo.

wix build -o "%OUTPUT_MSI%" WDOT.wxs

if %ERRORLEVEL% neq 0 (
    echo.
    echo ============================================================
    echo   BUILD FAILED
    echo ============================================================
    echo.
    echo Check the error messages above for details.
    exit /b 1
)

REM Verify output exists
if not exist "%OUTPUT_MSI%" (
    echo.
    echo ERROR: MSI file was not created.
    exit /b 1
)

REM Display success
echo.
echo ============================================================
echo   BUILD SUCCESSFUL
echo ============================================================
echo.
echo Output: %CD%\%OUTPUT_MSI%
echo.

REM Display file size
for %%F in ("%OUTPUT_MSI%") do (
    echo Size: %%~zF bytes
)
echo.

echo Installation commands:
echo   Silent install:      msiexec /i %OUTPUT_MSI% /qn
echo   With logging:        msiexec /i %OUTPUT_MSI% /qn /l*v install.log
echo   Interactive install: msiexec /i %OUTPUT_MSI%
echo.

endlocal
