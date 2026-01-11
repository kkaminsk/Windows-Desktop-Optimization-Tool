# Implementation Tasks

## 1. Update Get-WDOTAudit.ps1

- [x] 1.1 Add `-Interactive` switch parameter to script
- [x] 1.2 Add logic to detect if already in interactive mode (prevent recursion)
- [x] 1.3 When `-Interactive` specified, launch new elevated PowerShell window
- [x] 1.4 Add "Press any key to exit..." pause at end of console output
- [x] 1.5 Update script help documentation with new parameter

## 2. Update WiX Installer

- [x] 2.1 Add `ProgramMenuFolder` directory reference
- [x] 2.2 Create WDOT subfolder in Start Menu
- [x] 2.3 Add Shortcut component for audit script
- [x] 2.4 Configure shortcut to run with -Interactive flag

## 3. Rebuild and Test

- [x] 3.1 Rebuild MSI with new shortcut
- [ ] 3.2 Test shortcut appears in Start Menu after install
- [ ] 3.3 Test shortcut launches elevated PowerShell with audit
- [ ] 3.4 Test "Press any key" pause works correctly

## 4. Documentation

- [x] 4.1 Update README.md with interactive mode usage

## Dependencies

- **Task 2 depends on**: Task 1 (script must support -Interactive first) ✓
- **Task 3 depends on**: Tasks 1 and 2 complete ✓
- **Task 4 depends on**: Task 3 verification

## Parallelizable Work

- Tasks 1.1-1.5 can be done together ✓
- Tasks 2.1-2.4 can be done together after Task 1 ✓

---

## Implementation Summary

**Files Modified:**
- `Get-WDOTAudit.ps1` - Added `-Interactive` and `-InInteractiveSession` switches
- `Installer/WDOT.wxs` - Added Start Menu shortcut component
- `README.md` - Added interactive mode and Start Menu usage documentation

**New Features:**
- `-Interactive` switch launches new elevated PowerShell window
- "Press any key to exit..." pause in interactive mode
- Start Menu shortcut: Start > WDOT > WDOT Configuration Audit

**Shortcut Details:**
- Location: `%ProgramData%\Microsoft\Windows\Start Menu\Programs\WDOT`
- Name: "WDOT Configuration Audit"
- Target: `powershell.exe -ExecutionPolicy Bypass -File "[INSTALLFOLDER]Get-WDOTAudit.ps1" -Interactive`

**Pending (Manual Testing Required):**
- Tasks 3.2-3.4: Test on Windows VM after MSI installation
