# Implementation Tasks

## 1. Create Audit Function Modules

- [x] 1.1 Create `Functions/Get-WDOTAuditServices.ps1`
  - Query service startup type with `Get-Service`
  - Compare against Services.json "Apply" entries
  - Return objects with Name, Expected, Actual, Compliant status

- [x] 1.2 Create `Functions/Get-WDOTAuditAppxPackages.ps1`
  - Query installed packages with `Get-AppxPackage -AllUsers` and `Get-AppxProvisionedPackage`
  - Compare against AppxPackages.json "Apply" entries (expected: not installed)
  - Return objects with PackageName, Expected, Actual, Compliant status

- [x] 1.3 Create `Functions/Get-WDOTAuditScheduledTasks.ps1`
  - Query task state with `Get-ScheduledTask`
  - Compare against ScheduledTasks.json "Apply" entries (expected: Disabled)
  - Return objects with TaskName, Expected, Actual, Compliant status

- [x] 1.4 Create `Functions/Get-WDOTAuditRegistry.ps1`
  - Query registry values from PolicyRegSettings.json paths
  - Compare actual vs configured values
  - Return objects with Path, ValueName, Expected, Actual, Compliant status

## 2. Create Main Audit Script

- [x] 2.1 Create `Get-WDOTAudit.ps1` with parameter block
  - `-ConfigProfile` (Required): Configuration folder name
  - `-OutputFormat`: Console (default), JSON
  - `-OutputPath`: File path for JSON export
  - `-Categories`: Which categories to audit (All, Services, AppxPackages, ScheduledTasks, Registry)

- [x] 2.2 Implement configuration file loading
  - Load JSON files from `Configurations/<Profile>/`
  - Handle missing files gracefully

- [x] 2.3 Implement audit orchestration
  - Call each audit function
  - Aggregate results
  - Calculate compliance percentages

- [x] 2.4 Implement output formatting
  - Console output with color coding (Green=compliant, Red=drift, Yellow=warning)
  - JSON export for automation/reporting
  - HTML report deferred to future enhancement

## 3. Documentation

- [x] 3.1 Add usage examples to script comment-based help
- [x] 3.2 Update README.md with audit script documentation

## 4. Testing

- [ ] 4.1 Test on clean Windows 11 VM (pre-optimization)
- [ ] 4.2 Test on optimized Cloud PC (post-optimization)
- [ ] 4.3 Test JSON export format
- [ ] 4.4 Verify no write operations occur (read-only)

## Dependencies

- **Task 2 depends on**: Task 1 (audit functions must exist) ✓
- **Task 3 depends on**: Task 2 (script must be complete for documentation) ✓
- **Task 4 depends on**: Task 2 (script must be complete for testing)

## Parallelizable Work

- Tasks 1.1, 1.2, 1.3, 1.4 can be done in parallel ✓
- Task 3 can start once Task 2.1 is complete (parameter documentation) ✓

---

## Implementation Summary

**Files Created:**
- `Get-WDOTAudit.ps1` - Main audit orchestrator script
- `Functions/Get-WDOTAuditServices.ps1` - Service compliance auditor
- `Functions/Get-WDOTAuditAppxPackages.ps1` - AppX package compliance auditor
- `Functions/Get-WDOTAuditScheduledTasks.ps1` - Scheduled task compliance auditor
- `Functions/Get-WDOTAuditRegistry.ps1` - Registry compliance auditor

**Files Modified:**
- `README.md` - Added Configuration Audit Tool section

**Usage:**
```powershell
# Full audit
.\Get-WDOTAudit.ps1 -ConfigProfile W365-CloudPC

# JSON export
.\Get-WDOTAudit.ps1 -ConfigProfile W365-CloudPC -OutputFormat JSON -OutputPath audit.json

# Specific categories
.\Get-WDOTAudit.ps1 -ConfigProfile W365-CloudPC -Categories Services,AppxPackages
```

**Pending (Manual Testing Required):**
- Tasks 4.1-4.4: Testing on Windows VMs
