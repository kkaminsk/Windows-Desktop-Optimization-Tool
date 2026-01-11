# Implementation Tasks

## 1. Restructure WiX Components

- [x] 1.1 Move AuditScript component from MainComponents to new AuditComponents group
- [x] 1.2 Move audit function components (4 files) from FunctionComponents to AuditFunctionComponents
- [x] 1.3 Rename ShortcutComponents to AuditShortcutComponents (already audit-only)

## 2. Create Conditional Feature

- [x] 2.1 Create AuditFeature with Level="1000" (disabled by default)
- [x] 2.2 Add AUDIT property and EnableAuditFeature custom action
- [x] 2.3 Reference AuditComponents, AuditFunctionComponents, and AuditShortcutComponents

## 3. Rebuild and Test

- [x] 3.1 Rebuild MSI
- [ ] 3.2 Test default install (no AUDIT) - verify audit files NOT installed
- [ ] 3.3 Test with AUDIT=TRUE - verify audit files ARE installed
- [ ] 3.4 Verify Start Menu shortcut behavior matches

## 4. Update Documentation

- [x] 4.1 Update Installer/README.md with AUDIT property
- [x] 4.2 Update main README.md MSI section

## Dependencies

- Task 2 depends on Task 1 ✓
- Task 3 depends on Tasks 1 and 2 ✓
- Task 4 can run in parallel with Task 3 ✓

## Parallelizable Work

- Tasks 1.1, 1.2, 1.3 can be done together ✓
- Tasks 4.1, 4.2 can be done in parallel ✓

---

## Implementation Summary

**Files Modified:**
- `Installer/WDOT.wxs` - Restructured components into optional AuditFeature
- `Installer/README.md` - Documented AUDIT property
- `README.md` - Updated MSI installation instructions

**New Component Structure:**
```
Features:
├── Complete (Level=1, always installed)
│   ├── MainComponents (Windows_Optimization.ps1, EULA.txt)
│   ├── FunctionComponents (14 optimization functions)
│   └── ConfigComponents (8 config files)
│
└── AuditFeature (Level=1000, requires AUDIT=TRUE)
    ├── AuditComponents (Get-WDOTAudit.ps1)
    ├── AuditFunctionComponents (4 audit functions)
    └── AuditShortcutComponents (Start Menu shortcut)
```

**Usage:**
```cmd
# Default install - NO audit tool
msiexec /i WDOT-1.1-W365CloudPC.msi /qn

# Install WITH audit tool
msiexec /i WDOT-1.1-W365CloudPC.msi /qn AUDIT=TRUE
```

**Pending (Manual Testing Required):**
- Tasks 3.2-3.4: Test on Windows VM
