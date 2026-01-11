<#
.SYNOPSIS
    Audits Windows system configuration against WDOT optimization settings.

.DESCRIPTION
    This script performs a read-only audit of the current system state compared to
    WDOT configuration files. It reports which optimizations have been applied,
    which are pending, and identifies any configuration drift.

    Categories audited:
    - Services: Checks if services are disabled as configured
    - AppxPackages: Checks if apps are removed as configured
    - ScheduledTasks: Checks if tasks are disabled as configured
    - Registry: Checks if registry values match configuration

.PARAMETER ConfigProfile
    Name of the configuration profile folder (e.g., "W365-CloudPC").
    Must exist under the Configurations directory.

.PARAMETER Categories
    Which categories to audit. Default is "All".
    Valid values: All, Services, AppxPackages, ScheduledTasks, Registry

.PARAMETER OutputFormat
    Output format for the report. Default is "Console".
    Valid values: Console, JSON

.PARAMETER OutputPath
    File path for JSON output. Required when OutputFormat is JSON.

.EXAMPLE
    .\Get-WDOTAudit.ps1 -ConfigProfile W365-CloudPC
    Audits all categories and displays results in console.

.EXAMPLE
    .\Get-WDOTAudit.ps1 -ConfigProfile W365-CloudPC -Categories Services,AppxPackages
    Audits only Services and AppxPackages categories.

.EXAMPLE
    .\Get-WDOTAudit.ps1 -ConfigProfile W365-CloudPC -OutputFormat JSON -OutputPath C:\Temp\audit.json
    Exports audit results to JSON file.

.NOTES
    Author: WDOT Team
    This script is read-only and makes no system modifications.
#>

[CmdletBinding()]
Param
(
    [Parameter(Mandatory = $true, HelpMessage = "Configuration profile folder name")]
    [string]$ConfigProfile,

    [Parameter(Mandatory = $false)]
    [ValidateSet("All", "Services", "AppxPackages", "ScheduledTasks", "Registry")]
    [string[]]$Categories = @("All"),

    [Parameter(Mandatory = $false)]
    [ValidateSet("Console", "JSON")]
    [string]$OutputFormat = "Console",

    [Parameter(Mandatory = $false)]
    [string]$OutputPath
)

#region Initialization

$ScriptPath = Split-Path -Parent $MyInvocation.MyCommand.Definition
$ConfigPath = Join-Path $ScriptPath "Configurations\$ConfigProfile"
$FunctionsPath = Join-Path $ScriptPath "Functions"

# Validate configuration profile exists
if (-not (Test-Path $ConfigPath))
{
    Write-Error "Configuration profile not found: $ConfigPath"
    Write-Host "Available profiles:" -ForegroundColor Yellow
    Get-ChildItem (Join-Path $ScriptPath "Configurations") -Directory | ForEach-Object { Write-Host "  - $($_.Name)" }
    exit 1
}

# Validate OutputPath if JSON format selected
if ($OutputFormat -eq "JSON" -and -not $OutputPath)
{
    Write-Error "OutputPath is required when OutputFormat is JSON"
    exit 1
}

# Load audit functions
$AuditFunctions = @(
    "Get-WDOTAuditServices.ps1",
    "Get-WDOTAuditAppxPackages.ps1",
    "Get-WDOTAuditScheduledTasks.ps1",
    "Get-WDOTAuditRegistry.ps1"
)

foreach ($Function in $AuditFunctions)
{
    $FunctionPath = Join-Path $FunctionsPath $Function
    if (Test-Path $FunctionPath)
    {
        . $FunctionPath
        Write-Verbose "Loaded: $Function"
    }
    else
    {
        Write-Warning "Audit function not found: $FunctionPath"
    }
}

#endregion

#region Main Audit Logic

$AllResults = @()
$AuditDate = Get-Date

# Determine which categories to audit
$CategoriesToRun = if ($Categories -contains "All")
{
    @("Services", "AppxPackages", "ScheduledTasks", "Registry")
}
else
{
    $Categories
}

Write-Host ""
Write-Host "WDOT Configuration Audit" -ForegroundColor Cyan
Write-Host "========================" -ForegroundColor Cyan
Write-Host "Profile: $ConfigProfile" -ForegroundColor White
Write-Host "Date: $($AuditDate.ToString('yyyy-MM-dd HH:mm:ss'))" -ForegroundColor White
Write-Host ""

# Audit Services
if ($CategoriesToRun -contains "Services")
{
    Write-Host "Auditing Services..." -ForegroundColor Yellow
    $ServicesConfigPath = Join-Path $ConfigPath "Services.json"
    if (Test-Path $ServicesConfigPath)
    {
        $ServiceResults = Get-WDOTAuditServices -ConfigPath $ServicesConfigPath
        $AllResults += $ServiceResults
        Write-Verbose "Services audit complete: $($ServiceResults.Count) items"
    }
    else
    {
        Write-Warning "Services.json not found in profile"
    }
}

# Audit AppX Packages
if ($CategoriesToRun -contains "AppxPackages")
{
    Write-Host "Auditing AppX Packages..." -ForegroundColor Yellow
    $AppxConfigPath = Join-Path $ConfigPath "AppxPackages.json"
    if (Test-Path $AppxConfigPath)
    {
        $AppxResults = Get-WDOTAuditAppxPackages -ConfigPath $AppxConfigPath
        $AllResults += $AppxResults
        Write-Verbose "AppX Packages audit complete: $($AppxResults.Count) items"
    }
    else
    {
        Write-Warning "AppxPackages.json not found in profile"
    }
}

# Audit Scheduled Tasks
if ($CategoriesToRun -contains "ScheduledTasks")
{
    Write-Host "Auditing Scheduled Tasks..." -ForegroundColor Yellow
    $TasksConfigPath = Join-Path $ConfigPath "ScheduledTasks.json"
    if (Test-Path $TasksConfigPath)
    {
        $TaskResults = Get-WDOTAuditScheduledTasks -ConfigPath $TasksConfigPath
        $AllResults += $TaskResults
        Write-Verbose "Scheduled Tasks audit complete: $($TaskResults.Count) items"
    }
    else
    {
        Write-Warning "ScheduledTasks.json not found in profile"
    }
}

# Audit Registry
if ($CategoriesToRun -contains "Registry")
{
    Write-Host "Auditing Registry Settings..." -ForegroundColor Yellow
    $RegistryConfigPath = Join-Path $ConfigPath "PolicyRegSettings.json"
    if (Test-Path $RegistryConfigPath)
    {
        $RegistryResults = Get-WDOTAuditRegistry -ConfigPath $RegistryConfigPath
        $AllResults += $RegistryResults
        Write-Verbose "Registry audit complete: $($RegistryResults.Count) items"
    }
    else
    {
        Write-Warning "PolicyRegSettings.json not found in profile"
    }
}

#endregion

#region Output Results

# Calculate summary statistics
$TotalChecks = $AllResults.Count
$CompliantCount = ($AllResults | Where-Object { $_.Compliant -eq $true }).Count
$DriftCount = $TotalChecks - $CompliantCount
$CompliancePercent = if ($TotalChecks -gt 0) { [math]::Round(($CompliantCount / $TotalChecks) * 100, 1) } else { 0 }

if ($OutputFormat -eq "Console")
{
    Write-Host ""

    # Group and display results by category
    $GroupedResults = $AllResults | Group-Object -Property Category

    foreach ($Group in $GroupedResults)
    {
        Write-Host ""
        Write-Host "$($Group.Name) ($($Group.Count) items)" -ForegroundColor Cyan
        Write-Host ("-" * 50) -ForegroundColor Gray

        foreach ($Item in $Group.Group)
        {
            if ($Item.Compliant)
            {
                Write-Host "[COMPLIANT] " -ForegroundColor Green -NoNewline
            }
            else
            {
                Write-Host "[DRIFT]     " -ForegroundColor Red -NoNewline
            }
            Write-Host "$($Item.Name): " -NoNewline
            Write-Host "$($Item.Actual)" -ForegroundColor $(if ($Item.Compliant) { "Gray" } else { "Yellow" }) -NoNewline
            Write-Host " (expected: $($Item.Expected))" -ForegroundColor Gray
        }
    }

    # Summary
    Write-Host ""
    Write-Host "Summary" -ForegroundColor Cyan
    Write-Host ("-" * 50) -ForegroundColor Gray
    Write-Host "Total Checks: $TotalChecks"
    Write-Host "Compliant:    $CompliantCount " -NoNewline
    Write-Host "($CompliancePercent%)" -ForegroundColor $(if ($CompliancePercent -ge 90) { "Green" } elseif ($CompliancePercent -ge 70) { "Yellow" } else { "Red" })
    Write-Host "Drift:        $DriftCount"
    Write-Host ""
}
elseif ($OutputFormat -eq "JSON")
{
    $JsonOutput = [PSCustomObject]@{
        AuditDate     = $AuditDate.ToString("o")
        ConfigProfile = $ConfigProfile
        Summary       = [PSCustomObject]@{
            TotalChecks       = $TotalChecks
            Compliant         = $CompliantCount
            Drift             = $DriftCount
            CompliancePercent = $CompliancePercent
        }
        Results       = $AllResults
    }

    $JsonOutput | ConvertTo-Json -Depth 10 | Out-File -FilePath $OutputPath -Encoding UTF8
    Write-Host "Audit results exported to: $OutputPath" -ForegroundColor Green
    Write-Host "Total Checks: $TotalChecks | Compliant: $CompliantCount ($CompliancePercent%) | Drift: $DriftCount"
}

#endregion

# Return results for pipeline use
return $AllResults
