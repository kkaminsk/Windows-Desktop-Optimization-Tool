function Get-WDOTAuditAppxPackages
{
    <#
    .SYNOPSIS
        Audits AppX packages against WDOT configuration.

    .DESCRIPTION
        Checks if AppX packages configured for removal are still installed.
        Queries both provisioned packages and per-user packages.

    .PARAMETER ConfigPath
        Path to the AppxPackages.json configuration file.

    .OUTPUTS
        Array of PSCustomObject with audit results.

    .EXAMPLE
        Get-WDOTAuditAppxPackages -ConfigPath ".\Configurations\W365-CloudPC\AppxPackages.json"
    #>
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory = $true)]
        [string]$ConfigPath
    )

    Begin
    {
        Write-Verbose "Entering Function '$($MyInvocation.MyCommand.Name)'"
        $Results = @()
    }

    Process
    {
        If (-not (Test-Path $ConfigPath))
        {
            Write-Warning "AppxPackages configuration file not found: $ConfigPath"
            return $Results
        }

        $AppxConfig = Get-Content $ConfigPath | ConvertFrom-Json
        $PackagesToAudit = $AppxConfig.Where({ $_.OptimizationState -eq 'Apply' })

        Write-Verbose "Found $($PackagesToAudit.Count) AppX packages configured for removal"

        # Get all installed packages once for performance
        Write-Verbose "Querying installed AppX packages..."
        $InstalledPackages = @()
        $ProvisionedPackages = @()

        try
        {
            $InstalledPackages = Get-AppxPackage -AllUsers -ErrorAction SilentlyContinue
        }
        catch
        {
            Write-Warning "Unable to query AppX packages for all users: $($_.Exception.Message)"
            $InstalledPackages = Get-AppxPackage -ErrorAction SilentlyContinue
        }

        try
        {
            $ProvisionedPackages = Get-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue
        }
        catch
        {
            Write-Warning "Unable to query provisioned packages: $($_.Exception.Message)"
        }

        foreach ($Item in $PackagesToAudit)
        {
            $PackageName = $Item.AppxPackage
            $Description = $Item.Description

            # Check if package is installed (either provisioned or per-user)
            $FoundInstalled = $InstalledPackages | Where-Object { $_.Name -like "*$PackageName*" }
            $FoundProvisioned = $ProvisionedPackages | Where-Object { $_.PackageName -like "*$PackageName*" }

            $IsInstalled = ($null -ne $FoundInstalled) -or ($null -ne $FoundProvisioned)

            # Expected state for "Apply" is Not Installed (removed)
            $ExpectedState = "Not Installed"
            $ActualState = if ($IsInstalled) { "Installed" } else { "Not Installed" }
            $Compliant = -not $IsInstalled

            $Details = ""
            if ($FoundInstalled)
            {
                $Details = "Found: $($FoundInstalled[0].Name)"
            }
            elseif ($FoundProvisioned)
            {
                $Details = "Provisioned: $($FoundProvisioned[0].DisplayName)"
            }
            else
            {
                $Details = "Package not found on system"
            }

            $Results += [PSCustomObject]@{
                Category    = "AppxPackages"
                Name        = $PackageName
                Description = $Description
                Expected    = $ExpectedState
                Actual      = $ActualState
                Compliant   = $Compliant
                Details     = $Details
            }
        }
    }

    End
    {
        Write-Verbose "Exiting Function '$($MyInvocation.MyCommand.Name)'"
        return $Results
    }
}
