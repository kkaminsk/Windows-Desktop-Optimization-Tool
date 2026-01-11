function Get-WDOTAuditScheduledTasks
{
    <#
    .SYNOPSIS
        Audits scheduled tasks against WDOT configuration.

    .DESCRIPTION
        Compares current scheduled task states against ScheduledTasks.json configuration.
        Returns compliance status for each task configured with OptimizationState = "Apply".

    .PARAMETER ConfigPath
        Path to the ScheduledTasks.json configuration file.

    .OUTPUTS
        Array of PSCustomObject with audit results.

    .EXAMPLE
        Get-WDOTAuditScheduledTasks -ConfigPath ".\Configurations\W365-CloudPC\ScheduledTasks.json"
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
            Write-Warning "ScheduledTasks configuration file not found: $ConfigPath"
            return $Results
        }

        $TasksConfig = Get-Content $ConfigPath | ConvertFrom-Json
        $TasksToAudit = $TasksConfig.Where({ $_.OptimizationState -eq 'Apply' })

        Write-Verbose "Found $($TasksToAudit.Count) scheduled tasks configured for optimization"

        foreach ($Item in $TasksToAudit)
        {
            $TaskName = $Item.ScheduledTask
            $Description = $Item.Description

            try
            {
                # Handle wildcard patterns in task names
                $TaskObject = Get-ScheduledTask -TaskName $TaskName -ErrorAction Stop

                if ($TaskObject -is [array])
                {
                    # Multiple tasks matched (wildcard)
                    foreach ($Task in $TaskObject)
                    {
                        $ExpectedState = "Disabled"
                        $ActualState = $Task.State.ToString()
                        $Compliant = ($Task.State -eq 'Disabled')

                        $Results += [PSCustomObject]@{
                            Category    = "ScheduledTasks"
                            Name        = $Task.TaskName
                            Description = $Description
                            Expected    = $ExpectedState
                            Actual      = $ActualState
                            Compliant   = $Compliant
                            Details     = "Path: $($Task.TaskPath)"
                        }
                    }
                }
                else
                {
                    $ExpectedState = "Disabled"
                    $ActualState = $TaskObject.State.ToString()
                    $Compliant = ($TaskObject.State -eq 'Disabled')

                    $Results += [PSCustomObject]@{
                        Category    = "ScheduledTasks"
                        Name        = $TaskName
                        Description = $Description
                        Expected    = $ExpectedState
                        Actual      = $ActualState
                        Compliant   = $Compliant
                        Details     = "Path: $($TaskObject.TaskPath)"
                    }
                }
            }
            catch
            {
                # Task not found
                $Results += [PSCustomObject]@{
                    Category    = "ScheduledTasks"
                    Name        = $TaskName
                    Description = $Description
                    Expected    = "Disabled"
                    Actual      = "Not Found"
                    Compliant   = $true  # Not found = effectively disabled
                    Details     = "Task does not exist on this system"
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
