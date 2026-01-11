# Configuration Templates Spec Delta

## ADDED Requirements

### Requirement: Windows 365 Cloud PC Configuration Profile

The system SHALL provide a dedicated configuration profile (`W365-CloudPC`) optimized for Windows 365 Cloud PC environments with Intune and Azure Monitor compatibility.

#### Scenario: User creates Cloud PC optimized configuration

- **WHEN** the user runs `New-WVDConfigurationFiles.ps1 -FolderName "MyCloudPC"` with templates from `W365-CloudPC` profile
- **THEN** the new configuration folder is created with Cloud PC-optimized settings pre-applied
- **AND** all Intune/Azure Monitor telemetry services and tasks remain enabled (Skip)
- **AND** SMB services (LanmanServer, LanmanWorkstation) are disabled (Apply)
- **AND** no Internet Explorer settings are included

### Requirement: SMB Service Disabling for Cloud PC

The `W365-CloudPC` profile SHALL configure `LanmanServer` and `LanmanWorkstation` services with `OptimizationState: "Apply"` to disable these services.

#### Scenario: SMB services disabled on Cloud PC

- **WHEN** the optimization runs with the `W365-CloudPC` profile
- **THEN** the LanmanServer service is disabled
- **AND** the LanmanWorkstation service is disabled
- **AND** no SMB file sharing functionality is available

### Requirement: Telemetry Services Protection for Cloud PC

The `W365-CloudPC` profile SHALL maintain the following services with `OptimizationState: "Skip"` to preserve Intune Endpoint Analytics functionality:
- DiagTrack
- DPS
- WdiSystemHost
- WerSvc
- DiagSvc
- InstallService
- VSS

#### Scenario: Endpoint Analytics continues to receive data

- **WHEN** the optimization runs with the `W365-CloudPC` profile
- **THEN** the DiagTrack service remains running
- **AND** Intune Endpoint Analytics can collect device telemetry

### Requirement: Telemetry Tasks Protection for Cloud PC

The `W365-CloudPC` profile SHALL maintain the following scheduled tasks with `OptimizationState: "Skip"`:
- *Compatibility* (pattern match for Compatibility Appraiser tasks)
- Microsoft-Windows-DiskDiagnosticDataCollector
- Consolidator
- Sqm-Tasks
- StartComponentCleanup
- Restore

#### Scenario: Compliance reporting continues to function

- **WHEN** the optimization runs with the `W365-CloudPC` profile
- **THEN** the Sqm-Tasks scheduled task remains enabled
- **AND** TPM and Secure Boot compliance data is reported to Intune

### Requirement: Productivity Apps Protection for Cloud PC

The `W365-CloudPC` profile SHALL maintain the following Appx packages with `OptimizationState: "Skip"`:
- Microsoft.Copilot
- Microsoft.MicrosoftStickyNotes
- Microsoft.Todos
- Microsoft.WindowsNotepad
- Microsoft.WindowsTerminal

#### Scenario: User retains productivity apps

- **WHEN** the optimization runs with the `W365-CloudPC` profile
- **THEN** Microsoft Copilot app remains installed
- **AND** Windows Terminal remains installed

### Requirement: No Internet Explorer Settings in Cloud PC Profile

The `W365-CloudPC` profile PolicyRegSettings.json SHALL NOT contain any Internet Explorer registry settings (paths containing `\Internet Explorer\`).

#### Scenario: Deprecated IE settings excluded

- **WHEN** the user inspects `W365-CloudPC/PolicyRegSettings.json`
- **THEN** no registry paths contain `\Internet Explorer\`
- **AND** no obsolete IE optimization attempts are made during execution

### Requirement: No Edge Update Suppression in Cloud PC Profile

The `W365-CloudPC` profile SHALL NOT contain Edge update suppression settings (`UpdatesSuppressedDurationMin`, `UpdatesSuppressedStartHour`, `UpdatesSuppressedStartMin`) to avoid conflicts with Windows Autopatch.

#### Scenario: Windows Autopatch manages Edge updates

- **WHEN** the optimization runs with the `W365-CloudPC` profile
- **THEN** no Edge update suppression registry values are set
- **AND** Windows Autopatch can control Edge update timing

### Requirement: No LanManWorkstation.json in Cloud PC Profile

The `W365-CloudPC` profile SHALL NOT include a `LanManWorkstation.json` file since SMB is disabled via Services.json.

#### Scenario: Network optimizations skip SMB tuning

- **WHEN** the optimization runs with the `W365-CloudPC` profile
- **THEN** `Optimize-WDOTNetworkOptimizations` logs "File not found - .\LanManWorkstation.json" as a warning
- **AND** the optimization continues without error

## MODIFIED Requirements

### Requirement: LanManWorkstation.json File Handling

The `Optimize-WDOTNetworkOptimizations` function SHALL handle missing `LanManWorkstation.json` files gracefully by logging a warning and continuing execution.

#### Scenario: Missing LanManWorkstation.json handled without error

- **WHEN** the LanManWorkstation.json file does not exist in the current configuration folder
- **THEN** the function logs a warning to the WDOT event log
- **AND** the function continues to configure network adapter buffer settings
- **AND** the overall optimization does not fail
