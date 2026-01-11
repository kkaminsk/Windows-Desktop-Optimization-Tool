# Proposal: Update Template Configurations for Windows 365 Cloud PC

## Why

Windows 365 Cloud PC environments require different optimizations than traditional VDI. Current v1.0 templates may disable services and settings critical for Intune Endpoint Analytics and Azure Monitor. Additionally, some legacy settings (Internet Explorer, Edge update suppression) are irrelevant or conflict with Windows Autopatch.

## What Changes

### Configuration Template Modifications

1. **Services.json**
   - Ensure telemetry services remain protected (Skip): `DiagTrack`, `DPS`, `WdiSystemHost`, `WerSvc`, `DiagSvc`, `InstallService`, `VSS`
   - Change `LanmanServer` and `LanmanWorkstation` from "Skip" to "Apply" (disable SMB for Cloud PCs)

2. **ScheduledTasks.json**
   - Ensure critical telemetry tasks remain protected (Skip): `*Compatibility*`, `Microsoft-Windows-DiskDiagnosticDataCollector`, `Consolidator`, `Sqm-Tasks`, `StartComponentCleanup`, `Restore`

3. **AppxPackages.json**
   - Ensure productivity apps remain protected (Skip): `Microsoft.Copilot`, `Microsoft.MicrosoftStickyNotes`, `Microsoft.Todos`, `Microsoft.WindowsNotepad`, `Microsoft.WindowsTerminal`

4. **DefaultUserSettings.json**
   - Verify `NoToastApplicationNotification` is set to "Apply" (disable notifications)
   - Verify `TurnOffWindowsCopilot` remains as "Skip" (keep Copilot enabled)
   - **Note**: Edge update suppression settings (`UpdatesSuppressedDurationMin`, `UpdatesSuppressedStartHour`, `UpdatesSuppressedStartMin`) are not in Templates but exist in `2009` profile - these should be removed if v1.1 profile is based on that

5. **PolicyRegSettings.json**
   - Ensure telemetry policies remain protected (Skip): `CEIPEnable`, `DisableInventory`, `EnableDiagnostics`, `EnabledExecution`, all 7 `ScenarioExecutionEnabled` GUIDs
   - Verify `DoNotShowFeedbackNotifications` is "Apply" (safe UI setting)
   - Verify `DisableSetup` (WinRE) is "Apply"
   - **REMOVE**: All Internet Explorer settings (IE is deprecated in Windows 11) - currently NOT in Templates but exist in `2009` profile

6. **LanManWorkstation.json**
   - **REMOVE entire file** from template (SMB irrelevant for Cloud PC)
   - `Optimize-WDOTNetworkOptimizations.ps1` already handles missing file gracefully

7. **EdgeSettings.json**
   - No changes required (verified)

8. **Autologgers.json**
   - No changes required (verified)

## Impact

- **Affected specs**: configuration-templates
- **Affected code**:
  - `Configurations/Templates/Services.json`
  - `Configurations/Templates/DefaultUserSettings.json` (verification only)
  - `Configurations/Templates/PolicyRegSettings.json` (verification only)
  - `Configurations/Templates/AppxPackages.json` (verification only)
  - `Configurations/Templates/ScheduledTasks.json` (verification only)
  - Potentially create new v1.1 configuration profile folder
- **Breaking changes**: None - all changes are opt-in via configuration

## Analysis Notes

After reviewing the current template files:

1. **Services.json** - Already has `LanmanServer` and `LanmanWorkstation` entries with "Skip" state. Need to change to "Apply" for Cloud PC.

2. **DefaultUserSettings.json** - `NoToastApplicationNotification` is already "Apply". `TurnOffWindowsCopilot` is "Skip" (correct). Edge update suppression settings do NOT exist in Templates (only in 2009 profile).

3. **PolicyRegSettings.json** - All critical telemetry settings are already "Skip". `DoNotShowFeedbackNotifications` and `DisableSetup` are already "Apply". IE settings do NOT exist in Templates (only in 2009 profile if any).

4. **Approach Decision**: The 1.1Changes.md mentions settings that exist in older configuration profiles (like 2009) but not in the base Templates. We should either:
   - **Option A**: Modify only the Template files (minimal change for new installations)
   - **Option B**: Create a new "W365-CloudPC" profile folder with optimized settings
   - **Option C**: Document that legacy profiles need manual cleanup

## Recommendation

Create a dedicated Windows 365 Cloud PC configuration profile rather than modifying the base templates, preserving backwards compatibility for other VDI scenarios.
