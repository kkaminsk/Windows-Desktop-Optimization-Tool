# Implementation Tasks

## 1. Create Windows 365 Cloud PC Configuration Profile

- [x] 1.1 Create `Configurations/W365-CloudPC/` directory
- [x] 1.2 Copy all JSON files from `Configurations/Templates/` to `W365-CloudPC/`
- [x] 1.3 Copy `DefaultAssociationsConfiguration.xml` to `W365-CloudPC/`

## 2. Modify Services.json for Cloud PC

- [x] 2.1 Open `W365-CloudPC/Services.json`
- [x] 2.2 Change `LanmanServer` OptimizationState from "Skip" to "Apply"
- [x] 2.3 Change `LanmanWorkstation` OptimizationState from "Skip" to "Apply"
- [x] 2.4 Verify all telemetry services remain "Skip": DiagTrack, DPS, WdiSystemHost, WerSvc, DiagSvc, InstallService, VSS

## 3. Remove LanManWorkstation.json from Cloud PC Profile

- [x] 3.1 Delete `W365-CloudPC/LanManWorkstation.json` (not needed, SMB is disabled via Services.json)
  - Note: File was never copied since it doesn't exist in Templates

## 4. Verify ScheduledTasks.json

- [x] 4.1 Confirm `*Compatibility*` is "Skip"
- [x] 4.2 Confirm `Microsoft-Windows-DiskDiagnosticDataCollector` is "Skip"
- [x] 4.3 Confirm `Consolidator` is "Skip"
- [x] 4.4 Confirm `Sqm-Tasks` is "Skip"
- [x] 4.5 Confirm `StartComponentCleanup` is "Skip"
- [x] 4.6 Confirm `Restore` is "Skip"

## 5. Verify AppxPackages.json

- [x] 5.1 Confirm `Microsoft.Copilot` is "Skip"
- [x] 5.2 Confirm `Microsoft.MicrosoftStickyNotes` is "Skip"
- [x] 5.3 Confirm `Microsoft.Todos` is "Skip"
- [x] 5.4 Confirm `Microsoft.WindowsNotepad` is "Skip"
- [x] 5.5 Confirm `Microsoft.WindowsTerminal` is "Skip"

## 6. Verify DefaultUserSettings.json

- [x] 6.1 Confirm `NoToastApplicationNotification` is "Apply"
- [x] 6.2 Confirm `TurnOffWindowsCopilot` is "Skip"
- [x] 6.3 Verify no Edge update suppression settings exist (UpdatesSuppressedDurationMin, UpdatesSuppressedStartHour, UpdatesSuppressedStartMin)

## 7. Verify PolicyRegSettings.json

- [x] 7.1 Confirm `CEIPEnable` is "Skip"
- [x] 7.2 Confirm `DisableInventory` is "Skip"
- [x] 7.3 Confirm `EnableDiagnostics` is "Skip"
- [x] 7.4 Confirm `EnabledExecution` is "Skip"
- [x] 7.5 Confirm all 7 `ScenarioExecutionEnabled` GUIDs are "Skip"
- [x] 7.6 Confirm `DoNotShowFeedbackNotifications` is "Apply"
- [x] 7.7 Confirm `DisableSetup` (WinRE) is "Apply"
- [x] 7.8 Verify no Internet Explorer registry paths exist in PolicyRegSettings.json
  - Note: One IE reference exists in EdgeSettings.json for NotifyDisableIEOptions (set to Skip) - this is acceptable as it controls Edge-to-IE notification behavior
- [x] 7.9 Verify no Edge update suppression settings exist

## 8. Update Documentation

- [x] 8.1 Update `Configurations/README.md` to document W365-CloudPC profile
- [x] 8.2 Add section to main `README.md` about Windows 365 Cloud PC usage
- [ ] 8.3 Move `Configurations/Templates/1.1Changes.md` to archived location or update with completion status
  - Note: Left in place as reference documentation for the changes

## 9. Testing

- [ ] 9.1 Run `Windows_Optimization.ps1 -ConfigProfile "W365-CloudPC" -Optimizations All -AcceptEULA` in test environment
- [ ] 9.2 Verify no errors related to missing LanManWorkstation.json
- [ ] 9.3 Verify LanmanServer and LanmanWorkstation services are disabled
- [ ] 9.4 Verify DiagTrack and other telemetry services remain running
- [ ] 9.5 Verify Intune can collect Endpoint Analytics data post-optimization
- [ ] 9.6 Verify Windows Autopatch can update Edge

> **Note:** Tasks 9.1-9.6 require a Windows 365 Cloud PC test environment. Profile structure and JSON validity have been verified.

## 10. Version Update

- [x] 10.1 Update WDOT version tracking in `HKLM:\SOFTWARE\WDOT` to reflect v1.1
  - Note: Version is set dynamically at runtime by Windows_Optimization.ps1; README badges already show v1.1
- [x] 10.2 Update any version references in scripts or documentation
  - Note: README.md already has v1.1 in badges and changelog

## Implementation Summary

**Files Created:**
- `Configurations/W365-CloudPC/` directory with 8 configuration files

**Files Modified:**
- `Configurations/W365-CloudPC/Services.json` - LanmanServer and LanmanWorkstation set to "Apply"
- `Configurations/W365-CloudPC/EdgeSettings.json` - Fixed BOM encoding issue
- `Configurations/README.md` - Added W365-CloudPC profile documentation
- `README.md` - Added Cloud PC usage example and updated changelog

**All JSON files validated successfully.**
