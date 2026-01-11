<#
.SYNOPSIS
    Builds the WDOT MSI installer.

.DESCRIPTION
    This script builds the Windows Desktop Optimization Tool MSI installer
    using WiX Toolset v4. The resulting MSI can be deployed via SCCM, Intune,
    or Group Policy.

.PARAMETER OutputPath
    Path for the output MSI file. Defaults to current directory.

.PARAMETER Clean
    Remove previous build artifacts before building.

.EXAMPLE
    .\Build.ps1
    Builds the MSI in the current directory.

.EXAMPLE
    .\Build.ps1 -OutputPath "C:\Builds" -Clean
    Builds the MSI to C:\Builds after cleaning previous artifacts.

.NOTES
    Requires WiX Toolset v4 or later.
    Install with: dotnet tool install --global wix
#>

[CmdletBinding()]
param(
    [Parameter()]
    [string]$OutputPath = $PSScriptRoot,

    [Parameter()]
    [switch]$Clean
)

$ErrorActionPreference = 'Stop'

# Configuration
$MsiName = "WDOT-1.1-W365CloudPC.msi"
$WxsFile = Join-Path $PSScriptRoot "WDOT.wxs"
$OutputMsi = Join-Path $OutputPath $MsiName

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  Windows Desktop Optimization Tool - MSI Builder" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

# Check for WiX Toolset
$wixPath = Get-Command "wix" -ErrorAction SilentlyContinue
if (-not $wixPath) {
    Write-Host "ERROR: WiX Toolset not found in PATH." -ForegroundColor Red
    Write-Host ""
    Write-Host "Please install WiX Toolset v4 or later:" -ForegroundColor Yellow
    Write-Host "  1. Install .NET SDK if not present"
    Write-Host "  2. Run: dotnet tool install --global wix"
    Write-Host ""
    Write-Host "Or download from: https://wixtoolset.org/"
    exit 1
}

# Display WiX version
Write-Host "WiX version:" -ForegroundColor Gray
& wix --version
Write-Host ""

# Verify source file exists
if (-not (Test-Path $WxsFile)) {
    Write-Host "ERROR: WiX source file not found: $WxsFile" -ForegroundColor Red
    exit 1
}

# Clean previous build
if ($Clean -or (Test-Path $OutputMsi)) {
    if (Test-Path $OutputMsi) {
        Write-Host "Removing previous build..." -ForegroundColor Yellow
        Remove-Item $OutputMsi -Force
    }
}

# Build the MSI
Write-Host "Building MSI..." -ForegroundColor Cyan
Write-Host "  Source: $WxsFile" -ForegroundColor Gray
Write-Host "  Output: $OutputMsi" -ForegroundColor Gray
Write-Host ""

Push-Location $PSScriptRoot
try {
    & wix build -o $OutputMsi $WxsFile

    if ($LASTEXITCODE -ne 0) {
        Write-Host ""
        Write-Host "============================================================" -ForegroundColor Red
        Write-Host "  BUILD FAILED" -ForegroundColor Red
        Write-Host "============================================================" -ForegroundColor Red
        Write-Host ""
        Write-Host "Check the error messages above for details." -ForegroundColor Yellow
        exit 1
    }
}
finally {
    Pop-Location
}

# Verify output exists
if (-not (Test-Path $OutputMsi)) {
    Write-Host ""
    Write-Host "ERROR: MSI file was not created." -ForegroundColor Red
    exit 1
}

# Display success
$msiInfo = Get-Item $OutputMsi
$sizeMB = [math]::Round($msiInfo.Length / 1MB, 2)

Write-Host ""
Write-Host "============================================================" -ForegroundColor Green
Write-Host "  BUILD SUCCESSFUL" -ForegroundColor Green
Write-Host "============================================================" -ForegroundColor Green
Write-Host ""
Write-Host "Output: $OutputMsi" -ForegroundColor White
Write-Host "Size:   $sizeMB MB ($($msiInfo.Length) bytes)" -ForegroundColor Gray
Write-Host ""
Write-Host "Installation commands:" -ForegroundColor Cyan
Write-Host "  Silent install:      " -NoNewline; Write-Host "msiexec /i $MsiName /qn" -ForegroundColor Yellow
Write-Host "  With logging:        " -NoNewline; Write-Host "msiexec /i $MsiName /qn /l*v install.log" -ForegroundColor Yellow
Write-Host "  Interactive install: " -NoNewline; Write-Host "msiexec /i $MsiName" -ForegroundColor Yellow
Write-Host ""

# Return the path for scripting
return $OutputMsi
