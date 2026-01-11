function Get-WDOTAuditServices
{
    <#
    .SYNOPSIS
        Audits Windows services against WDOT configuration.

    .DESCRIPTION
        Compares current service startup types against Services.json configuration.
        Returns compliance status for each service configured with OptimizationState = "Apply".

    .PARAMETER ConfigPath
        Path to the Services.json configuration file.

    .OUTPUTS
        Array of PSCustomObject with audit results.

    .EXAMPLE
        Get-WDOTAuditServices -ConfigPath ".\Configurations\W365-CloudPC\Services.json"
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
            Write-Warning "Services configuration file not found: $ConfigPath"
            return $Results
        }

        $ServicesConfig = Get-Content $ConfigPath | ConvertFrom-Json
        $ServicesToAudit = $ServicesConfig.Where({ $_.OptimizationState -eq 'Apply' })

        Write-Verbose "Found $($ServicesToAudit.Count) services configured for optimization"

        foreach ($Item in $ServicesToAudit)
        {
            $ServiceName = $Item.Name
            $Description = $Item.Description

            try
            {
                $Service = Get-Service -Name $ServiceName -ErrorAction Stop
                $StartupType = (Get-CimInstance -ClassName Win32_Service -Filter "Name='$ServiceName'" -ErrorAction Stop).StartMode

                # Expected state for "Apply" is Disabled
                $ExpectedState = "Disabled"
                $ActualState = $StartupType
                $Compliant = ($StartupType -eq "Disabled")

                $Results += [PSCustomObject]@{
                    Category    = "Services"
                    Name        = $ServiceName
                    Description = $Description
                    Expected    = $ExpectedState
                    Actual      = $ActualState
                    Compliant   = $Compliant
                    Details     = "Status: $($Service.Status)"
                }
            }
            catch [Microsoft.PowerShell.Commands.ServiceCommandException]
            {
                # Service not found - could be removed or renamed
                $Results += [PSCustomObject]@{
                    Category    = "Services"
                    Name        = $ServiceName
                    Description = $Description
                    Expected    = "Disabled"
                    Actual      = "Not Found"
                    Compliant   = $true  # Not found = effectively disabled
                    Details     = "Service does not exist on this system"
                }
            }
            catch
            {
                $Results += [PSCustomObject]@{
                    Category    = "Services"
                    Name        = $ServiceName
                    Description = $Description
                    Expected    = "Disabled"
                    Actual      = "Error"
                    Compliant   = $false
                    Details     = $_.Exception.Message
                }
            }
        }
    }

    End
    {
        Write-Verbose "Exiting Function '$($MyInvocation.MyCommand.Name)'"
        return $Results
    }
}
