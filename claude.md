<!-- OPENSPEC:START -->
# OpenSpec Instructions

These instructions are for AI assistants working in this project.

Always open `@/openspec/AGENTS.md` when the request:
- Mentions planning or proposals (words like proposal, spec, change, plan)
- Introduces new capabilities, breaking changes, architecture shifts, or big performance/security work
- Sounds ambiguous and you need the authoritative spec before coding

Use `@/openspec/AGENTS.md` to learn:
- How to create and apply change proposals
- Spec format and conventions
- Project structure and guidelines

Keep this managed block so 'openspec update' can refresh the instructions.

<!-- OPENSPEC:END -->

# Windows Desktop Optimization Tool (WDOT)

## Project Overview

A PowerShell-based automation solution for optimizing Windows devices for VDI (Virtual Desktop Infrastructure), Azure Virtual Desktop (AVD), and standalone machines. Authored by Robert M. Smith and Tim Muessig (Microsoft).

## Project Structure

```
Windows-Desktop-Optimization-Tool/
├── Windows_Optimization.ps1          # Main optimization engine (entry point)
├── New-WVDConfigurationFiles.ps1     # Creates new configuration profiles
├── Set-WVDConfigurations.ps1         # Interactive configuration editor
├── EULA.txt                          # License terms
├── README.md                         # Main documentation
├── Configuration Files User Guide.md # Detailed configuration guide
├── Configurations/
│   ├── Templates/                    # Master template files (JSON/XML)
│   └── [Custom Profiles]/            # User-created configurations
├── Functions/                        # Modular optimization functions (14 files)
└── Images/                           # Project branding
```

## Key Files

### Entry Points
- `Windows_Optimization.ps1` - Main script, requires Administrator privileges and PowerShell 5.1+
- `New-WVDConfigurationFiles.ps1` - Creates configuration profiles from templates
- `Set-WVDConfigurations.ps1` - Interactive JSON configuration editor

### Function Modules (in `/Functions/`)
- `Disable-WDOTServices.ps1` - Disables Windows services
- `Disable-WDOTScheduledTasks.ps1` - Disables scheduled tasks
- `Disable-WDOTAutoLoggers.ps1` - Disables ETW autologgers
- `Remove-WDOTAppxPackages.ps1` - Removes Microsoft Store apps
- `Remove-WDOTRemoveOneDrive.ps1` - Removes OneDrive
- `Remove-WDOTRemoveLegacyIE.ps1` - Removes Internet Explorer
- `Remove-WDOTWindowsMediaPlayer.ps1` - Removes Windows Media Player
- `Optimize-WDOTDefaultUserSettings.ps1` - Modifies default user registry
- `Optimize-WDOTLocalPolicySettings.ps1` - Applies group policy settings
- `Optimize-WDOTEdgeSettings.ps1` - Configures Microsoft Edge
- `Optimize-WDOTNetworkOptimizations.ps1` - SMB/network tuning
- `Optimize-WDOTDiskCleanup.ps1` - Removes temporary files
- `Get-WDOTOperatingSystemInfo.ps1` - Retrieves OS version info
- `New-WDOTCommentBox.ps1` - Utility for formatted output

### Configuration Files (in `/Configurations/Templates/`)
- `Services.json` - Windows services (22 items)
- `AppxPackages.json` - Store apps to remove (54 items)
- `ScheduledTasks.json` - Scheduled tasks (30 items)
- `DefaultUserSettings.json` - User profile registry (58 items)
- `PolicyRegSettings.json` - Group policy settings (103 items)
- `EdgeSettings.json` - Microsoft Edge policies (9 items)
- `LanManWorkstation.json` - SMB client settings (5 items)
- `Autologgers.json` - ETW autologgers (7 items)
- `DefaultAssociationsConfiguration.xml` - File associations

## Coding Conventions

### Function Pattern
```powershell
Function Verb-WDOTNoun {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $true)]
        [Type]$ParameterName
    )

    Begin { Write-Verbose "Entering..." }
    Process { /* main logic */ }
    End { Write-Verbose "Exiting..." }
}
```

### Naming
- Functions: `Verb-WDOTNoun` pattern (e.g., `Disable-WDOTServices`)
- File names match function names
- Configuration folders: alphanumeric with hyphens/underscores

### Output
- `Write-Verbose` - Diagnostic messages
- `Write-Host` with colors - User-facing (Cyan=headers, Green=success, Red=errors, Yellow=warnings)
- `Write-EventLog` - Audit trail to Windows Event Log (Log: "WDOT")

### Configuration JSON Structure
```json
{
    "Name": "ServiceName",
    "OptimizationState": "Skip",  // "Apply" or "Skip"
    "Description": "What this does",
    "URL": "https://docs.microsoft.com/..."
}
```

### Event IDs
- 20: AppxPackages
- 50: ScheduledTasks
- 60: Services
- 70: NetworkOptimizations
- 90: DiskCleanup
- 100+: Other operations

## Usage

```powershell
# Create new configuration profile
.\New-WVDConfigurationFiles.ps1 -FolderName "Production-VDI"

# Customize settings interactively
.\Set-WVDConfigurations.ps1 -ConfigurationFile "Services" -ConfigFolderName "Production-VDI"

# Run optimization
.\Windows_Optimization.ps1 -ConfigProfile "Production-VDI" -Optimizations All -AcceptEULA
```

## Parameters for Windows_Optimization.ps1

- `-ConfigProfile` (Required): Name of configuration folder
- `-Optimizations`: Categories to apply (All, Services, AppxPackages, ScheduledTasks, DefaultUserSettings, LocalPolicy, Autologgers, NetworkOptimizations, DiskCleanup, WindowsMediaPlayer)
- `-AdvancedOptimizations`: Aggressive options (All, Edge, RemoveLegacyIE, RemoveOneDrive)
- `-AcceptEULA`: Skip EULA prompt
- `-Restart`: Auto-restart after completion

## Registry Tracking

Execution recorded in: `HKLM:\SOFTWARE\WDOT`
- `Version` - Tool version
- `LastRunTime` - Last execution timestamp

## Requirements

- Windows 10/11 or Windows Server 2019/2022/2025
- PowerShell 5.1+
- Administrator privileges
- Execution policy: `RemoteSigned` or `Bypass`

## License

Microsoft Sample Code License (AS IS without warranty)
