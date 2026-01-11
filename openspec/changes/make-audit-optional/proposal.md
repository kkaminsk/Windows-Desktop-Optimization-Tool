# Proposal: Make Audit Tool Installation Optional via AUDIT Property

## Summary
Make the audit script, its supporting functions, and Start Menu shortcut optional in the MSI installer, controlled by an `AUDIT=TRUE` property. By default, the audit tool will not be installed.

## Problem
The audit tool adds files that aren't needed for the core optimization functionality. For silent enterprise deployments where machines are optimized once and not audited, the extra files add unnecessary bloat and a Start Menu shortcut that users don't need.

## Solution
Create a separate optional Feature for audit components, controlled by the `AUDIT` property:
- `AUDIT=TRUE` - Install audit script, functions, and Start Menu shortcut
- Default (no property) - Only install core optimization files

## Components to Make Optional

| Component | Currently In | Move To |
|-----------|--------------|---------|
| `Get-WDOTAudit.ps1` | MainComponents | AuditComponents |
| `Get-WDOTAuditServices.ps1` | FunctionComponents | AuditFunctionComponents |
| `Get-WDOTAuditAppxPackages.ps1` | FunctionComponents | AuditFunctionComponents |
| `Get-WDOTAuditScheduledTasks.ps1` | FunctionComponents | AuditFunctionComponents |
| `Get-WDOTAuditRegistry.ps1` | FunctionComponents | AuditFunctionComponents |
| Start Menu shortcut | ShortcutComponents | AuditComponents |

## Usage

**Default install (no audit):**
```cmd
msiexec /i WDOT-1.1-W365CloudPC.msi /qn
```

**Install with audit tool:**
```cmd
msiexec /i WDOT-1.1-W365CloudPC.msi /qn AUDIT=TRUE
```

## WiX Implementation Approach
1. Create new `AuditComponents` and `AuditFunctionComponents` ComponentGroups
2. Create new `AuditFeature` Feature with `Level="0"` (disabled by default)
3. Add condition to set `Level="1"` when `AUDIT=TRUE`
4. Move audit-related components to the new groups
5. Reference new groups in `AuditFeature`

## Files to Modify
| File | Change |
|------|--------|
| `Installer/WDOT.wxs` | Restructure components and add AuditFeature |
| `Installer/README.md` | Document AUDIT property |
| `README.md` | Update MSI installation instructions |
