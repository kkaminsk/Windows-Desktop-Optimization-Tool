# Proposal: Add Interactive Mode to Audit Script with Start Menu Shortcut

## Summary
Add an `-Interactive` switch to `Get-WDOTAudit.ps1` that opens a new PowerShell window displaying audit results, and create a Start Menu shortcut via the MSI installer for easy access.

## Problem
Currently, the audit script runs in the existing console and exits immediately when run from shortcuts or double-clicked. System administrators need:
1. A way to run the audit that keeps the window open to view results
2. Easy access without opening PowerShell and navigating to the install directory

## Solution

### 1. Add `-Interactive` Switch to Get-WDOTAudit.ps1
When `-Interactive` is specified:
- Launch a new PowerShell window
- Run the audit with default W365-CloudPC profile
- Display results with colored output
- Pause at the end ("Press any key to exit...")
- Keep window open for review

### 2. Create Start Menu Shortcut via MSI
Add a shortcut in the Start Menu:
- **Name**: "WDOT Configuration Audit"
- **Location**: Start Menu > Programs > WDOT
- **Target**: `powershell.exe -ExecutionPolicy Bypass -File "C:\Program Files\WDOT\Get-WDOTAudit.ps1" -ConfigProfile W365-CloudPC -Interactive`
- **Run As**: Administrator (elevation prompt)
- **Icon**: PowerShell default or custom WDOT icon

## Scope
- **In scope**: `-Interactive` switch, Start Menu shortcut, "Press any key" pause
- **Out of scope**: GUI window (too complex), taskbar pin, desktop shortcut

## Files to Modify
| File | Change |
|------|--------|
| `Get-WDOTAudit.ps1` | Add `-Interactive` parameter and logic |
| `Installer/WDOT.wxs` | Add shortcut component |

## Usage

**From Start Menu:**
1. Click Start
2. Search "WDOT" or navigate to WDOT folder
3. Click "WDOT Configuration Audit"
4. Approve UAC prompt
5. View audit results
6. Press any key to close

**From Command Line:**
```powershell
# Interactive mode - opens new window
.\Get-WDOTAudit.ps1 -ConfigProfile W365-CloudPC -Interactive

# Normal mode - outputs to current console
.\Get-WDOTAudit.ps1 -ConfigProfile W365-CloudPC
```

## Alternatives Considered
1. **WPF GUI**: Rejected - too complex for simple audit display
2. **Out-GridView**: Rejected - loses color coding and formatting
3. **HTML report auto-open**: Rejected - requires browser, less immediate
