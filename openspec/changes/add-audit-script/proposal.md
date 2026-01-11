# Proposal: Add Configuration Audit Script

## Summary
Create a standalone PowerShell script (`Get-WDOTAudit.ps1`) that audits the current system state against WDOT configuration files, reporting which optimizations have been applied, which are pending, and any drift from expected state.

## Problem
System administrators need visibility into:
1. Whether WDOT optimizations were applied to a machine
2. Which specific optimizations are in effect
3. Whether system state has drifted from the configured optimizations
4. Quick verification after MSI deployment without re-running the optimization

Currently, the only way to verify is to manually check services, apps, tasks, and registry settings one by one, or parse the WDOT event log.

## Solution
Create `Get-WDOTAudit.ps1` - a read-only audit script that:
- Reads WDOT configuration JSON files from a specified profile
- Queries current system state (services, AppX packages, scheduled tasks, registry)
- Compares actual vs expected state
- Outputs a compliance report in console and optionally JSON/HTML

## Scope
- **In scope**: Services, AppX packages, Scheduled Tasks, Registry settings (PolicyRegSettings, DefaultUserSettings)
- **Out of scope**: Autologgers, Edge settings, Network optimizations (complex to audit)

## Output Format
```
WDOT Configuration Audit Report
================================
Profile: W365-CloudPC
Date: 2026-01-11 15:30:00

Services (2 configured)
-----------------------
[COMPLIANT] LanmanServer: Disabled (expected: Disabled)
[COMPLIANT] LanmanWorkstation: Disabled (expected: Disabled)

AppX Packages (49 configured for removal)
-----------------------------------------
[COMPLIANT] Microsoft.BingNews: Not installed
[DRIFT] Microsoft.GamingApp: Still installed
...

Scheduled Tasks (0 configured)
------------------------------
No scheduled tasks configured for optimization.

Summary
-------
Total Checks: 51
Compliant: 48 (94%)
Drift: 3 (6%)
```

## Non-Goals
- Remediation (script is read-only)
- Real-time monitoring
- Integration with the MSI installer

## Files to Create
| File | Purpose |
|------|---------|
| `Get-WDOTAudit.ps1` | Main audit script (root directory) |
| `Functions/Get-WDOTAuditServices.ps1` | Service compliance check |
| `Functions/Get-WDOTAuditAppxPackages.ps1` | AppX compliance check |
| `Functions/Get-WDOTAuditScheduledTasks.ps1` | Scheduled task compliance check |
| `Functions/Get-WDOTAuditRegistry.ps1` | Registry compliance check |

## Usage
```powershell
# Basic audit with console output
.\Get-WDOTAudit.ps1 -ConfigProfile W365-CloudPC

# Export to JSON for automation
.\Get-WDOTAudit.ps1 -ConfigProfile W365-CloudPC -OutputFormat JSON -OutputPath C:\Temp\audit.json

# Verbose output for troubleshooting
.\Get-WDOTAudit.ps1 -ConfigProfile W365-CloudPC -Verbose
```

## Alternatives Considered
1. **Add to existing Windows_Optimization.ps1**: Rejected - keeps audit separate from remediation
2. **Pester tests**: Rejected - requires Pester module, not admin-friendly
3. **Event log parsing only**: Rejected - doesn't catch drift after initial optimization
