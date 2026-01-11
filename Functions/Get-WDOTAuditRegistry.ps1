function Get-WDOTAuditRegistry
{
    <#
    .SYNOPSIS
        Audits registry settings against WDOT configuration.

    .DESCRIPTION
        Compares current registry values against PolicyRegSettings.json configuration.
        Returns compliance status for each setting configured with OptimizationState = "Apply".

    .PARAMETER ConfigPath
        Path to the PolicyRegSettings.json configuration file.

    .OUTPUTS
        Array of PSCustomObject with audit results.

    .EXAMPLE
        Get-WDOTAuditRegistry -ConfigPath ".\Configurations\W365-CloudPC\PolicyRegSettings.json"
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
            Write-Warning "PolicyRegSettings configuration file not found: $ConfigPath"
            return $Results
        }

        $RegistryConfig = Get-Content $ConfigPath | ConvertFrom-Json
        $SettingsToAudit = $RegistryConfig.Where({ $_.OptimizationState -eq 'Apply' })

        Write-Verbose "Found $($SettingsToAudit.Count) registry settings configured for optimization"

        foreach ($Item in $SettingsToAudit)
        {
            $RegPath = $Item.RegItemPath
            $ValueName = $Item.RegItemValueName
            $ExpectedValue = $Item.RegItemValue
            $ValueType = $Item.RegItemValueType

            $DisplayName = "$RegPath\$ValueName"

            try
            {
                if (Test-Path $RegPath)
                {
                    $RegKey = Get-ItemProperty -Path $RegPath -Name $ValueName -ErrorAction Stop
                    $ActualValue = $RegKey.$ValueName

                    # Compare values (convert to string for comparison)
                    $Compliant = ($ActualValue.ToString() -eq $ExpectedValue.ToString())

                    $Results += [PSCustomObject]@{
                        Category    = "Registry"
                        Name        = $ValueName
                        Description = $DisplayName
                        Expected    = "$ExpectedValue ($ValueType)"
                        Actual      = $ActualValue.ToString()
                        Compliant   = $Compliant
                        Details     = "Path: $RegPath"
                    }
                }
                else
                {
                    # Registry path doesn't exist
                    $Results += [PSCustomObject]@{
                        Category    = "Registry"
                        Name        = $ValueName
                        Description = $DisplayName
                        Expected    = "$ExpectedValue ($ValueType)"
                        Actual      = "Path Not Found"
                        Compliant   = $false
                        Details     = "Registry path does not exist: $RegPath"
                    }
                }
            }
            catch [System.Management.Automation.ItemNotFoundException]
            {
                # Value doesn't exist
                $Results += [PSCustomObject]@{
                    Category    = "Registry"
                    Name        = $ValueName
                    Description = $DisplayName
                    Expected    = "$ExpectedValue ($ValueType)"
                    Actual      = "Value Not Found"
                    Compliant   = $false
                    Details     = "Registry value does not exist"
                }
            }
            catch [System.Security.SecurityException]
            {
                $Results += [PSCustomObject]@{
                    Category    = "Registry"
                    Name        = $ValueName
                    Description = $DisplayName
                    Expected    = "$ExpectedValue ($ValueType)"
                    Actual      = "Access Denied"
                    Compliant   = $false
                    Details     = "Insufficient permissions to read registry"
                }
            }
            catch
            {
                $Results += [PSCustomObject]@{
                    Category    = "Registry"
                    Name        = $ValueName
                    Description = $DisplayName
                    Expected    = "$ExpectedValue ($ValueType)"
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
