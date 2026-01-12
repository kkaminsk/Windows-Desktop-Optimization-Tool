function Remove-WDOTRemoveLegacyIE
{
    [CmdletBinding()]

    Param
    (

    )

    Begin
    {
        Write-Verbose "Entering Function '$($MyInvocation.MyCommand.Name)'"
    }
    Process
    {
        Write-EventLog -EventId 80 -Message "Remove Legacy Internet Explorer" -LogName 'WDOT' -Source 'AdvancedOptimizations' -EntryType Information
        Write-Host "[Windows Advanced Optimize] Remove Legacy Internet Explorer" -ForegroundColor Cyan

        $IECapabilities = Get-WindowsCapability -Online -ErrorAction SilentlyContinue |
            Where-Object { $_.Name -Like "*Browser.Internet*" -and $_.State -eq 'Installed' }

        if ($IECapabilities) {
            $IECapabilities | ForEach-Object {
                Write-Host "`tRemoving $($_.Name)" -ForegroundColor Gray
                $_ | Remove-WindowsCapability -Online -ErrorAction SilentlyContinue | Out-Null
            }
        }
        else {
            Write-Host "`tLegacy Internet Explorer is not installed or already removed" -ForegroundColor Gray
        }
    }
    End
    {
        Write-Verbose "Exiting Function '$($MyInvocation.MyCommand.Name)'"
    }
}
