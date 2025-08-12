<#####################################################################################################################################

    This Sample Code is provided for the purpose of illustration only and is not intended to be used in a production environment.  
    THIS SAMPLE CODE AND ANY RELATED INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, 
    INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.  We grant 
    You a nonexclusive, royalty-free right to use and modify the Sample Code and to reproduce and distribute the object code form 
    of the Sample Code, provided that You agree: (i) to not use Our name, logo, or trademarks to market Your software product in 
    which the Sample Code is embedded; (ii) to include a valid copyright notice on Your software product in which the Sample Code 
    is embedded; and (iii) to indemnify, hold harmless, and defend Us and Our suppliers from and against any claims or lawsuits, 
    including attorneys’ fees, that arise or result from the use or distribution of the Sample Code.

    Microsoft provides programming examples for illustration only, without warranty either expressed or
    implied, including, but not limited to, the implied warranties of merchantability and/or fitness 
    for a particular purpose. 
 
    This sample assumes that you are familiar with the programming language being demonstrated and the 
    tools used to create and debug procedures. Microsoft support professionals can help explain the 
    functionality of a particular procedure, but they will not modify these examples to provide added 
    functionality or construct procedures to meet your specific needs. if you have limited programming 
    experience, you may want to contact a Microsoft Certified Partner or the Microsoft fee-based consulting 
    line at (800) 936-5200. 

    For more information about Microsoft Certified Partners, please visit the following Microsoft Web site:
    https://partner.microsoft.com/global/30000104 

######################################################################################################################################>

<#
- TITLE:          Microsoft Windows Virtual Desktop Optimization Script
- AUTHORED BY:    Robert M. Smith and Tim Muessig (Microsoft)
- AUTHORED DATE:  8/12/2025
- CONTRIBUTORS:   
- LAST UPDATED:   
- PURPOSE:        To automatically apply many optimization settings to and Windows device; VDI, AVD, standalone machine
                  
- Important:      Every setting in this script and input files are possible optimizations only,
                  and NOT recommendations or requirements. Please evaluate every setting for applicability
                  to your specific environment. These scripts have been tested on Hyper-V VMs, as well as Azure VMs...
                  including Windows 11 23H2.
                  Please test thoroughly in your environment before implementation

- DEPENDENCIES    1. On the target machine, run PowerShell elevated (as administrator)
                  2. Within PowerShell, set exectuion policy to enable the running of scripts.
                     Ex. Set-ExecutionPolicy -ExecutionPolicy RemoteSigned
                  5. This PowerShell script
                  6. The text input files containing all the apps, services, traces, etc. that you...
                     may be interested in disabling. Please review these input files to customize...
                     to your environment/requirements

- REFERENCES:
https://social.technet.microsoft.com/wiki/contents/articles/7703.powershell-running-executables.aspx
https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.management/remove-item?view=powershell-6
https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.management/set-service?view=powershell-6
https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.management/remove-item?view=powershell-6
https://msdn.microsoft.com/en-us/library/cc422938.aspx
#>

[Cmdletbinding(DefaultParameterSetName = "Default")]
Param (
    # Parameter help description
    [ArgumentCompleter( { Get-ChildItem $PSScriptRoot\Configurations -Directory | Select-Object -ExpandProperty Name } )]
    [System.String]$WindowsVersion = (Get-ItemProperty "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\").ReleaseId,

    [ValidateSet('All', 'WindowsMediaPlayer', 'AppxPackages', 'ScheduledTasks', 'DefaultUserSettings', 'LocalPolicy', 'Autologgers', 'Services', 'NetworkOptimizations', 'DiskCleanup')] 
    [String[]]
    $Optimizations,

    [Parameter()]
    [ValidateSet('All', 'Edge', 'RemoveLegacyIE', 'RemoveOneDrive')]
    [String[]]
    $AdvancedOptimizations,

    [Switch]$Restart,
    [Switch]$AcceptEULA
)

#Requires -RunAsAdministrator
#Requires -PSEdition Desktop

BEGIN 
{
    # Load all functions for later use
    $WDOTFunctions = Get-ChildItem "$PSScriptRoot\Functions\*-WDOT.ps1" | Select-Object -ExpandProperty FullName
    $WDOTFunctions | ForEach-Object {
        Write-Verbose "Loading function $_"
        . $_
    }

    [Version]$WDOTVersion = "1.0.0.0" 
    # Create Key
    $KeyPath = 'HKLM:\SOFTWARE\WDOT'
    If (-Not(Test-Path $KeyPath))
    {
        New-Item -Path $KeyPath | Out-Null
    }

    # Add WDOT Version Key
    $Version = "Version"
    $VersionValue = $WDOTVersion
    If (Get-ItemProperty $KeyPath -Name Version -ErrorAction SilentlyContinue)
    {
        Set-ItemProperty -Path $KeyPath -Name $Version -Value $VersionValue
    }
    Else
    {
        New-ItemProperty -Path $KeyPath -Name $Version -Value $VersionValue | Out-Null
    }

    # Add WDOT Last Run
    $LastRun = "LastRunTime"
    $LastRunValue = Get-Date
    If (Get-ItemProperty $KeyPath -Name LastRunTime -ErrorAction SilentlyContinue)
    {
        Set-ItemProperty -Path $KeyPath -Name $LastRun -Value $LastRunValue
    }
    Else
    {
        New-ItemProperty -Path $KeyPath -Name $LastRun -Value $LastRunValue | Out-Null
    }
    
    $EventSources = @('WDOT', 'WindowsMediaPlayer', 'AppxPackages', 'ScheduledTasks', 'DefaultUserSettings', 'Autologgers', 'Services', 'LocalPolicy', 'NetworkOptimizations', 'AdvancedOptimizations', 'DiskCleanup')
    If (-not([System.Diagnostics.EventLog]::SourceExists("WDOT")))
    {
        # All WDOT main function Event ID's [1-9]
        New-EventLog -Source $EventSources -LogName 'WDOT'
        Limit-EventLog -OverflowAction OverWriteAsNeeded -MaximumSize 64KB -LogName 'WDOT'
        Write-EventLog -LogName 'WDOT' -Source 'WDOT' -EntryType Information -EventId 1 -Message "Log Created"
    }
    Else 
    {
        New-EventLog -Source $EventSources -LogName 'WDOT' -ErrorAction SilentlyContinue
    }
    Write-EventLog -LogName 'WDOT' -Source 'WDOT' -EntryType Information -EventId 1 -Message "Starting WDOT by user '$env:USERNAME', for WDOT build '$WindowsVersion', with the following options:`n$($PSBoundParameters | Out-String)" 

    $StartTime = Get-Date
    $CurrentLocation = Get-Location
    $WorkingLocation = (Join-Path $PSScriptRoot "Configurations\$WindowsVersion")

    try
    {
        Push-Location $WorkingLocation -ErrorAction Stop
    }
    catch
    {
        $Message = "Invalid Path $WorkingLocation - Exiting Script!"
        Write-EventLog -Message $Message -Source 'WDOT' -EventID 100 -EntryType Error -LogName 'WDOT'
        Write-Warning $Message
        Return
    }
} # End Begin

PROCESS {
    if (-not ($PSBoundParameters.Keys -match 'Optimizations') )
    {
        Write-EventLog -Message "No Optimizations (Optimizations or AdvancedOptimizations) passed, exiting script!" -Source 'WDOT' -EventID 100 -EntryType Error -LogName 'WDOT'
        $Message = "`nThe Optimizations parameter no longer defaults to 'All', you must explicitly pass in this parameter.`nThis is to allow for running 'AdvancedOptimizations' separately " 
        Write-Host " * " -ForegroundColor black -BackgroundColor yellow -NoNewline
        Write-Host " Important " -ForegroundColor Yellow -BackgroundColor Red -NoNewline
        Write-Host " * " -ForegroundColor black -BackgroundColor yellow -NoNewline
        Write-Host $Message -ForegroundColor yellow -BackgroundColor black
        Return
    }
    $EULA = Get-Content (Join-Path $PSScriptRoot "EULA.txt")
    if (-not $AcceptEULA) {
        $Title = "Accept EULA"
        $Options = @(
            New-Object System.Management.Automation.Host.ChoiceDescription "&Yes"
            New-Object System.Management.Automation.Host.ChoiceDescription "&No"
        )
        $Response = $host.UI.PromptForChoice($Title, $EULA, $Options, 0)
        if ($Response -eq 0) {
            Write-EventLog -LogName 'WDOT' -Source 'WDOT' -EntryType Information -EventId 1 -Message "EULA Accepted"
        } else {
            Write-EventLog -LogName 'WDOT' -Source 'WDOT' -EntryType Warning -EventId 1 -Message "EULA Declined, exiting!"
            Set-Location $CurrentLocation
            $ScriptRunTime = (New-TimeSpan -Start $StartTime -End (Get-Date))
            Write-EventLog -LogName 'WDOT' -Source 'WDOT' -EntryType Information -EventId 1 -Message "WDOT Total Run Time: $($ScriptRunTime.Hours) Hours $($ScriptRunTime.Minutes) Minutes $($ScriptRunTime.Seconds) Seconds"
            Write-Host "`n`nThank you from the Windows Desktop Optimization Team" -ForegroundColor Cyan
            continue
        }
    } else {
        Write-EventLog -LogName 'WDOT' -Source 'WDOT' -EntryType Information -EventId 1 -Message "EULA Accepted by Parameter"
    }

    #region Disable, then remove, Windows Media Player including payload
    If ($Optimizations -contains "WindowsMediaPlayer" -or $Optimizations -contains "All")
    {
        Remove-WDOTWindowsMediaPlayer
    }
    #endregion

} # End process