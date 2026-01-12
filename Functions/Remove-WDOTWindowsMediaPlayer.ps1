Function Remove-WDOTWindowsMediaPlayer
{
    [CmdletBinding()]
    Param ()

    Begin
    {
        Write-Verbose "Entering Function '$($MyInvocation.MyCommand.Name)'"
    }

    Process
    {
        try
        {
            Write-EventLog -EventId 10 -Message "[Windows Optimize] Disable / Remove Windows Media Player" -LogName 'WDOT' -Source 'WindowsMediaPlayer' -EntryType Information
            Write-Host "[Windows Optimize] Disable / Remove Windows Media Player" -ForegroundColor Cyan

            # Check if Windows Media Player feature is enabled before attempting to disable
            $WMPFeature = Get-WindowsOptionalFeature -Online -FeatureName WindowsMediaPlayer -ErrorAction SilentlyContinue
            if ($WMPFeature -and $WMPFeature.State -eq 'Enabled') {
                Disable-WindowsOptionalFeature -Online -FeatureName WindowsMediaPlayer -NoRestart -ErrorAction SilentlyContinue | Out-Null
            }
            else {
                Write-Host "`tWindows Media Player feature is not enabled or already disabled" -ForegroundColor Gray
            }

            Get-WindowsPackage -Online -PackageName "*Windows-mediaplayer*" -ErrorAction SilentlyContinue | ForEach-Object {
                Write-EventLog -EventId 10 -Message "Removing $($_.PackageName)" -LogName 'WDOT' -Source 'WindowsMediaPlayer' -EntryType Information
                Remove-WindowsPackage -PackageName $_.PackageName -Online -ErrorAction SilentlyContinue -NoRestart | Out-Null
            }
        }
        catch
        {
            Write-EventLog -EventId 110 -Message "Disabling / Removing Windows Media Player - $($_.Exception.Message)" -LogName 'WDOT' -Source 'WindowsMediaPlayer' -EntryType Error
        }
    }

    End
    {
        Write-Verbose "Exiting Function '$($MyInvocation.MyCommand.Name)'"
    }
}