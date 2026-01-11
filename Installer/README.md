# WDOT Installer

This directory contains the WiX-based MSI installer for deploying the Windows Desktop Optimization Tool (WDOT) to Windows 365 Cloud PC and other Windows environments.

## Overview

The installer:
1. Deploys WDOT files to `C:\Program Files\WDOT`
2. Executes the optimization script automatically during installation
3. Supports silent installation for enterprise deployment

## Prerequisites

### Build Requirements

- **WiX Toolset v4** or later
- **.NET SDK** (for dotnet tool installation)

### Installation of WiX Toolset

```powershell
# Install WiX Toolset as a .NET global tool
dotnet tool install --global wix

# Verify installation
wix --version
```

Alternatively, download from [WiX Toolset website](https://wixtoolset.org/).

## Building the MSI

### Using PowerShell (Recommended)

```powershell
cd Installer
.\Build.ps1
```

### Using Command Prompt

```cmd
cd Installer
Build.cmd
```

### Output

The build creates: `WDOT-1.1-W365CloudPC.msi`

## Deployment

### Silent Installation

```cmd
msiexec /i WDOT-1.1-W365CloudPC.msi /qn
```

### Silent Installation with Logging

```cmd
msiexec /i WDOT-1.1-W365CloudPC.msi /qn /l*v C:\Logs\wdot-install.log
```

### Interactive Installation

```cmd
msiexec /i WDOT-1.1-W365CloudPC.msi
```

### Uninstallation

```cmd
msiexec /x WDOT-1.1-W365CloudPC.msi /qn
```

Or via **Programs and Features** in Control Panel.

## Configuration

The MSI is pre-configured with:

| Setting | Value |
|---------|-------|
| Install Path | `C:\Program Files\WDOT` |
| Configuration Profile | `W365-CloudPC` |
| Optimizations | `All` (Services, AppxPackages, ScheduledTasks, etc.) |
| Advanced Optimizations | `All` (Edge, RemoveOneDrive, RemoveLegacyIE) |

## What Gets Installed

```
C:\Program Files\WDOT\
├── Windows_Optimization.ps1       # Main optimization script
├── EULA.txt                       # License agreement
├── Functions\                     # PowerShell function modules (14 files)
│   ├── Disable-WDOTAutoLoggers.ps1
│   ├── Disable-WDOTScheduledTasks.ps1
│   ├── Disable-WDOTServices.ps1
│   ├── Get-WDOTOperatingSystemInfo.ps1
│   ├── New-WDOTCommentBox.ps1
│   ├── Optimize-WDOTDefaultUserSettings.ps1
│   ├── Optimize-WDOTDiskCleanup.ps1
│   ├── Optimize-WDOTEdgeSettings.ps1
│   ├── Optimize-WDOTLocalPolicySettings.ps1
│   ├── Optimize-WDOTNetworkOptimizations.ps1
│   ├── Remove-WDOTAppxPackages.ps1
│   ├── Remove-WDOTRemoveLegacyIE.ps1
│   ├── Remove-WDOTRemoveOneDrive.ps1
│   └── Remove-WDOTWindowsMediaPlayer.ps1
└── Configurations\
    └── W365-CloudPC\              # Cloud PC optimized configuration
        ├── AppxPackages.json
        ├── Autologgers.Json
        ├── DefaultAssociationsConfiguration.xml
        ├── DefaultUserSettings.json
        ├── EdgeSettings.json
        ├── PolicyRegSettings.json
        ├── ScheduledTasks.json
        └── Services.json
```

## Enterprise Deployment

### Microsoft Intune

1. Upload the MSI to Intune as a Line-of-Business app
2. Configure installation command: `msiexec /i WDOT-1.1-W365CloudPC.msi /qn`
3. Assign to device groups

### SCCM / Configuration Manager

1. Create an Application with MSI deployment type
2. Use silent installation command: `msiexec /i WDOT-1.1-W365CloudPC.msi /qn`
3. Detection method: File exists `C:\Program Files\WDOT\Windows_Optimization.ps1`

### Group Policy

1. Copy MSI to network share accessible by target computers
2. Create GPO with Computer Configuration > Policies > Software Settings > Software Installation
3. Assign MSI package

## Logging and Troubleshooting

### MSI Installation Log

```cmd
msiexec /i WDOT-1.1-W365CloudPC.msi /qn /l*v install.log
```

The log captures:
- File installation progress
- Custom action execution
- PowerShell script output
- Any errors encountered

### WDOT Event Log

The optimization script writes to Windows Event Log:
- **Log Name**: WDOT
- **Source**: Various (Services, AppxPackages, etc.)

View with:
```powershell
Get-WinEvent -LogName "WDOT" -MaxEvents 50
```

### Common Issues

| Issue | Cause | Solution |
|-------|-------|----------|
| Installation fails immediately | Insufficient privileges | Run as Administrator |
| Custom action timeout | Large number of apps to remove | Increase timeout or retry |
| Files installed but no optimization | Script error | Check MSI log for PowerShell errors |
| Antivirus blocks installation | Security software | Whitelist or temporarily disable |

## Customization

### Building with Different Profile

Edit `WDOT.wxs` to change the configuration profile:

1. Change `Source` paths in ConfigComponents to point to different profile
2. Update the `ExeCommand` in CustomAction to use different `-ConfigProfile` value
3. Rebuild the MSI

### Disabling Custom Action

To install files without running optimization (for testing):

Edit `WDOT.wxs` and comment out or remove:
```xml
<Custom Action="RunOptimization" After="InstallFiles">
    NOT REMOVE~="ALL"
</Custom>
```

## Technical Details

### MSI Properties

| Property | Value |
|----------|-------|
| ProductName | Windows Desktop Optimization Tool |
| Manufacturer | Microsoft |
| ProductVersion | 1.1.0.0 |
| UpgradeCode | 51115B56-21BF-4170-BB49-62864D60F0FB |
| InstallScope | perMachine |

### Custom Action Details

The optimization runs as a **deferred custom action**:
- Executes as `SYSTEM` account
- Runs after file installation completes
- Installation fails if script returns non-zero exit code
- Logs output to MSI verbose log

### WiX Source Structure

```
WDOT.wxs
├── Package (Product definition)
├── MajorUpgrade (Version upgrade handling)
├── StandardDirectory (ProgramFilesFolder)
│   └── INSTALLFOLDER (WDOT)
│       ├── FunctionsFolder
│       └── ConfigurationsFolder
│           └── W365CloudPCFolder
├── ComponentGroups
│   ├── MainComponents (2 files)
│   ├── FunctionComponents (14 files)
│   └── ConfigComponents (8 files)
├── Feature (Complete)
├── CustomAction (RunOptimization)
└── InstallExecuteSequence
```

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.1.0.0 | 2026-01 | Initial WiX installer for W365-CloudPC profile |

## Support

For issues with the installer:
1. Check the MSI log file
2. Review Windows Event Log (WDOT)
3. Report issues at: https://github.com/The-Virtual-Desktop-Team/Windows-Desktop-Optimization-Tool/issues
