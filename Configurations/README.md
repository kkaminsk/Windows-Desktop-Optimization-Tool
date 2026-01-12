# Windows Desktop Optimization Tool - Configuration Files

This document provides a detailed description of all configuration files located in the `Templates` folder. These JSON and XML files define what optimizations will be applied when running the Windows Desktop Optimization Tool.

## Configuration File Structure

Each configuration item contains an `OptimizationState` property:
- **"Apply"**: The optimization will be executed
- **"Skip"**: The optimization will be skipped (default for all items)

By default, all optimizations are set to "Skip" to ensure a conservative approach. Use the `Set-WVDConfigurations.ps1` script to interactively enable specific optimizations.

---

## Services.json

Configures Windows services to be disabled. Contains **24 services** that can be disabled to reduce resource consumption.

### Services Included:

| Service Name | Description |
|--------------|-------------|
| `InstallService` | Provides infrastructure support for the Microsoft Store |
| `autotimesvc` | Cellular Time service - sets time based on NITZ messages from a Mobile Network |
| `BcastDVRUserService` | Used for Game Recordings and Live Broadcasts |
| `defragsvc` | Optimize drives (disk defragmentation) |
| `DiagSvc` | Diagnostic Execution Service |
| `DiagTrack` | Connected User Experiences and Telemetry |
| `DPS` | Diagnostic Policy Service - enables problem detection and troubleshooting |
| `DusmSvc` | Data Usage service - network data usage, data limit, metered networks |
| `icssvc` | Windows Mobile Hotspot (tethering) service |
| `lfsvc` | Geolocation Service - monitors current location and manages geofences |
| `MapsBroker` | Downloaded Maps Manager |
| `MessagingService` | Service supporting text messaging and related functionality |
| `RmSvc` | Radio Management and Airplane Mode Service |
| `SEMgrSvc` | Payments and NFC/SE Manager |
| `SmsRouter` | Microsoft Windows SMS Router Service |
| `SysMain` | Maintains and improves system performance over time (Superfetch) |
| `VSS` | Volume Shadow Copy |
| `WdiSystemHost` | Diagnostic System Host |
| `WerSvc` | Windows Error Reporting Service |
| `XblAuthManager` | Xbox Live Auth Manager |
| `XblGameSave` | Xbox Live Game Save service |
| `XboxGipSvc` | Xbox Accessory Management |
| `XboxNetApiSvc` | Xbox Live Networking Service |
| `LanmanServer` | Server service - SMB file sharing (v1.1) |
| `LanmanWorkstation` | Workstation service - SMB client (v1.1) |

---

## AppxPackages.json

Configures Microsoft Store (AppX) applications to be removed. Contains **54 applications** that can be uninstalled.

### Applications Included:

| Package Name | Description |
|--------------|-------------|
| `Bing Search` | Web Search from Microsoft Bing in Windows Search |
| `Clipchamp.Clipchamp` | Video creation app |
| `Microsoft.Copilot` | Microsoft AI app |
| `Microsoft.549981C3F5F10` | Cortana |
| `Microsoft.BingNews` | Microsoft News app |
| `Microsoft.BingWeather` | MSN Weather app |
| `Microsoft.DesktopAppInstaller` | App Installer for sideloading Windows apps |
| `Microsoft.Edge.GameAssist` | Edge Game Assist |
| `Microsoft.GamingApp` | Xbox app |
| `Microsoft.GetHelp` | Free support for Microsoft products |
| `Microsoft.Getstarted` | Windows 10/11 Tips app |
| `Microsoft.MicrosoftOfficeHub` | Office UWP app suite |
| `Microsoft.Office.OneNote` | OneNote for Windows 10 |
| `Microsoft.MicrosoftSolitaireCollection` | Solitaire suite of games |
| `Microsoft.MicrosoftStickyNotes` | Note-taking app |
| `Microsoft.OutlookForWindows` | Free email experience for Windows |
| `Microsoft.MSPaint` | Paint 3D app |
| `Microsoft.Paint` | Classic Paint app |
| `Microsoft.People` | Contact management app |
| `Microsoft.PowerAutomateDesktop` | Desktop automation app |
| `Microsoft.ScreenSketch` | Snip and Sketch app |
| `Microsoft.SkypeApp` | Instant message, voice or video call app |
| `Microsoft.StorePurchaseApp` | Store purchase app helper |
| `Microsoft.Todos` | Microsoft To Do - lists and tasks |
| `Microsoft.USNationalParks` | US National Parks app |
| `Microsoft.WinDbg.Fast` | Microsoft WinDbg debugger |
| `Microsoft.Windows.DevHome` | Developer control center with customizable widgets |
| `Microsoft.Windows.Photos` | Photo and video editor |
| `Microsoft.WindowsAlarms` | Alarm clock, world clock, timer, and stopwatch |
| `Microsoft.WindowsCalculator` | Microsoft Calculator app |
| `Microsoft.WindowsCamera` | Camera app for photos and video |
| `microsoft.windowscommunicationsapps` | Mail & Calendar apps |
| `Microsoft.WindowsFeedbackHub` | Feedback Hub for Windows |
| `Microsoft.WindowsMaps` | Microsoft Maps app |
| `Microsoft.WindowsNotepad` | Text editor for plain text documents |
| `Microsoft.WindowsStore` | Windows Store app |
| `Microsoft.WindowsSoundRecorder` | Voice recorder |
| `Microsoft.WindowsTerminal` | Terminal with tabs, panes, and GPU text rendering |
| `Microsoft.Winget.Platform.Source` | Windows Package Manager (winget) |
| `Microsoft.Xbox.TCUI` | Xbox Title Callable UI |
| `Microsoft.XboxGameOverlay` | Xbox Game Bar overlay |
| `Microsoft.XboxGamingOverlay` | Xbox Game Bar overlay |
| `Microsoft.XboxIdentityProvider` | Xbox Live PC connection |
| `Microsoft.XboxSpeechToTextOverlay` | Xbox game transcription overlay |
| `Microsoft.YourPhone` | Phone Link (Android to PC interface) |
| `Microsoft.ZuneMusic` | Groove Music app |
| `Microsoft.ZuneVideo` | Movies and TV app |
| `MicrosoftCorporationII.QuickAssist` | Microsoft remote help app |
| `MicrosoftWindows.Client.WebExperience` | Windows 11 Widgets |
| `Microsoft.XboxApp` | Xbox Console Companion |
| `Microsoft.MixedReality.Portal` | Windows Mixed Reality Portal |
| `Microsoft.Microsoft3DViewer` | 3D Viewer app |
| `MicrosoftTeams` / `MSTeams` | Microsoft Teams |
| `Microsoft.OneDriveSync` | OneDrive sync app |
| `Microsoft.Wallet` | Microsoft Pay for Edge browser |

---

## ScheduledTasks.json

Configures Windows scheduled tasks to be disabled. Contains **30 tasks** that can be disabled.

### Scheduled Tasks Included:

| Task Name | Description |
|-----------|-------------|
| `AnalyzeSystem` | Analyzes the system for conditions causing high energy use |
| `Cellular` | Related to cellular devices |
| `Consolidator` | Windows Customer Experience Improvement Program data collection |
| `Diagnostics` | DiskFootprint - storage I/O contribution tracking |
| `FamilySafetyMonitor` | Family Safety monitoring and enforcement |
| `FamilySafetyRefreshTask` | Synchronizes settings with Microsoft family features |
| `MapsToastTask` | Shows Map-related toast notifications |
| `*Compatibility*` | Program telemetry for CEIP |
| `Microsoft-Windows-DiskDiagnosticDataCollector` | Disk diagnostic reporting to Microsoft |
| `NotificationTask` | Background task for per-user and web interactions |
| `ProcessMemoryDiagnosticEvents` | Memory diagnostic scheduling |
| `Proxy` | Autochk SQM data collection |
| `QueueReporting` | Queue reporting task |
| `RecommendedTroubleshootingScanner` | Check for recommended troubleshooting |
| `RegIdleBackup` | Registry Idle Backup Task |
| `RunFullMemoryDiagnostic` | Detects and mitigates RAM problems |
| `ScheduledDefrag` | Optimizes local storage drives |
| `SpeechModelDownloadTask` | Speech model download |
| `Sqm-Tasks` | TPM, Secure Boot, and Measured Boot information gathering |
| `SR` | Creates regular system protection points |
| `StartComponentCleanup` | Servicing task for maintenance windows |
| `WindowsActionDialog` | Location notification |
| `WinSAT` | Measures system performance and capabilities |
| `XblGameSaveTask` | Xbox Live GameSave standby task |
| `UsbCeip` | Customer Experience Improvement Program task |
| `VerifyWinRE` | Validates Windows Recovery Environment |
| `Work Folders Logon Synchronization` | Work Folders sync at logon |
| `Work Folders Maintenance Work` | Work Folders maintenance |
| `Restore` | Handles restoring settings from the cloud |

---

## DefaultUserSettings.json

Configures default user profile registry settings applied to new user profiles. Contains **58 registry settings** affecting user experience and privacy.

### Categories of Settings:

#### Start Menu and Taskbar
- `Start_IrisRecommendations` - Disable Start menu recommendations
- `TaskbarMn` - Hide Chat icon from taskbar
- `TaskbarAnimations` - Disable taskbar animations

#### Cloud Content and Suggestions
- `DisableThirdPartySuggestions` - Disable third-party app suggestions
- `DisableTailoredExperiencesWithDiagnosticData` - Disable tailored experiences
- `DisableWindowsSpotlightFeatures` - Disable Windows Spotlight

#### Explorer and Search
- `NoResolveSearch` - Disable search resolution
- `QueryLimit` - Limit directory UI queries to 1500
- `NoWindowMinimizingShortcuts` - Disable Aero Shake
- `NoThumbnailCache` - Disable thumbnail caching
- `DisableSearchBoxSuggestions` - Disable search box suggestions
- `DisableThumbsDBOnNetworkFolders` - Disable thumbs.db on network folders
- `NoRemoteDestinations` - Disable remote jump lists

#### Notifications
- `TaskbarNoNotification` - Disable taskbar notifications
- `NoToastApplicationNotification` - Disable toast notifications **(Set to Apply in v1.1)**
- `NoToastApplicationNotificationOnLockScreen` - Disable lock screen notifications

#### Visual Effects
- `IconsOnly` - Show icons only (no thumbnails)
- `ListviewAlphaSelect` - Disable transparent selection rectangle
- `ListviewShadow` - Disable icon shadow
- `VisualFXSetting` - Custom visual effects (value: 3)
- `EnableAeroPeek` - Disable Aero Peek
- `DragFullWindows` - Disable full window drag
- `MinAnimate` - Disable minimize/maximize animations

#### Privacy and Data Collection
- `DisableMFUTracking` - Disable most frequently used tracking
- `HttpAcceptLanguageOptOut` - Opt out of HTTP Accept-Language
- `RestrictImplicitInkCollection` - Restrict ink data collection
- `RestrictImplicitTextCollection` - Restrict text data collection
- `HarvestContacts` - Disable contact harvesting

#### Background Apps
- Disable background access for: Photos, Skype, YourPhone, Edge, Cortana

#### Edge
- `StartupBoostEnabled` - Disable Edge startup boost

> **Note (v1.1):** Edge update suppression settings (`UpdatesSuppressed*`) have been removed to allow Windows Autopatch to manage Edge updates.

#### Gaming
- `UseNexusForGameBarEnabled` - Disable Game Bar Nexus
- `AppCaptureEnabled` - Disable app capture/Game DVR

#### Copilot
- `TurnOffWindowsCopilot` - Disable Windows Copilot

---

## PolicyRegSettings.json

Configures local group policy registry settings. Contains **85 policy settings** affecting system behavior, privacy, and features.

> **Note (v1.1):** Internet Explorer settings have been removed (deprecated for Windows 11). Edge update suppression settings have been removed to allow Windows Autopatch management.

### Categories of Settings:

#### Search and Cloud
- `ConnectedSearchUseWeb` - Disable web search
- `AllowCloudSearch` - Disable cloud search
- `AllowNewsAndInterests` - Disable News and Interests
- `EnableFeeds` - Disable Windows Feeds
- `EnableDynamicContentInWSB` - Disable dynamic content in search

#### Network and Connectivity
- `DeleteUserAppContainersOnLogoff` - Clean up firewall rules on logoff
- `DisableBranchCache` - Disable BITS BranchCache
- `DisablePeerCachingClient/Server` - Disable peer caching
- `Teredo_State` - Disable Teredo IPv6 tunneling
- `AutoConnectAllowedOEM` - Disable auto-connect to WiFi
- `LetAppsAccessCellularData` - Restrict cellular data access
- `DisableHomeGroup` - Disable HomeGroup

#### Lock Screen and Logon
- `LockScreenImage` - Set custom lock screen image
- `LockScreenOverlaysDisabled` - Disable lock screen overlays
- `DisableLockScreenAppNotifications` - Disable lock screen notifications
- `EnableFirstLogonAnimation` - Disable first logon animation
- `DisableAcrylicBackgroundOnLogon` - Disable blur on logon screen
- `NoWelcomeScreen` - Disable welcome screen

#### System Restore and Recovery
- `DisableSystemRestore` - Disable System Restore for device installation
- `DisableSR` - Disable System Restore
- `DisableSetup` - Disable Windows RE setup **(Set to Apply in v1.1)**

#### Telemetry and Diagnostics
- `CEIPEnable` - Disable Customer Experience Improvement Program
- `EnabledExecution` - Disable scheduled diagnostics
- `EnableDiagnostics` - Disable scripted diagnostics
- `DoNotShowFeedbackNotifications` - Hide feedback notifications **(Set to Apply in v1.1)**
- Various WDI scenario execution settings - Disable diagnostic scenarios

#### Privacy and Advertising
- `DisabledByGroupPolicy` - Disable advertising ID
- `DisableInventory` - Disable application inventory
- `AllowLinguisticDataCollection` - Disable linguistic data collection
- `PreventHandwritingDataSharing` - Prevent handwriting data sharing
- `PreventHandwritingErrorReports` - Prevent handwriting error reports

#### Location and Sensors
- `DisableLocation` - Disable location services
- `DisableSensors` - Disable sensors
- `DisableWindowsLocationProvider` - Disable Windows location provider

#### Maps
- `AllowUntriggeredNetworkTrafficOnSettingsPage` - Disable map network traffic
- `AutoDownloadAndUpdateMapData` - Disable map auto-download

#### Desktop Window Manager (Visual Effects)
- `DisableAccentGradient` - Disable accent gradient
- `DisallowAnimations` - Disable DWM animations
- `AllowEdgeSwipe` - Disable edge swipe gesture

#### Windows Update and Delivery Optimization
- `DODownloadMode` - Set Delivery Optimization mode to 99 (bypass)
- `EnableFeaturedSoftware` - Disable featured software in Windows Update
- `AllowBuildPreview` - Disable preview builds

#### AutoRun
- `NoDriveTypeAutoRun` - Disable AutoRun on all drive types (value: 255)
- `NoAutoRun` - Disable AutoRun

#### Miscellaneous
- `DisableSoftLanding` - Disable Windows consumer features tips
- `DisableWindowsConsumerFeatures` - Disable Windows consumer features
- `NoNewAppAlert` - Disable new app alerts
- `AllowWindowsInkWorkspace` - Disable Windows Ink Workspace
- `AllowGameDVR` - Disable Game DVR
- `AllowFindMyDevice` - Disable Find My Device
- `NtfsDisable8dot3NameCreation` - Disable 8.3 filename creation

---

## EdgeSettings.json

Configures Microsoft Edge browser policy settings. Contains **9 policy settings**.

### Settings Included:

| Setting | Value | Description |
|---------|-------|-------------|
| `BackgroundModeEnabled` | 0 | Disable Edge background mode at OS sign-in |
| `HideFirstRunExperience` | 1 | Hide First-run experience and splash screen |
| `HideInternetExplorerRedirectUXForIncompatibleSitesEnabled` | 1 | Hide IE redirection dialog |
| `ShowRecommendationsEnabled` | 0 | Disable recommendations and in-product notifications |
| `NotifyDisableIEOptions` | 0 | Disable IE standalone browser notification |
| `DefaultAssociationsConfiguration` | Path | Points to default file associations XML |
| `StartupBoostEnabled` | 0 | Disable Edge startup boost |
| `EfficiencyMode` | 0 | Disable efficiency mode |
| `WebWidgetAllowed` | 0 | Disable Edge search bar widget on desktop |

---

## LanManWorkstation.json

> **Removed in v1.1:** This file has been removed for Windows 365 Cloud PC environments where SMB file sharing is not used. The LanmanServer and LanmanWorkstation services can be disabled via Services.json instead.

For environments that require SMB file sharing, you can recreate this file with the following settings:
- `DisableBandwidthThrottling` - Disable bandwidth throttling
- `FileInfoCacheEntriesMax` - Maximum file info cache entries
- `DirectoryCacheEntriesMax` - Maximum directory cache entries
- `FileNotFoundCacheEntriesMax` - Maximum "file not found" cache entries
- `DormantFileLimit` - Maximum dormant file handles

---

## Autologgers.json

Configures Windows Event Tracing (ETW) autologgers to be disabled. Contains **7 autologgers**.

### Autologgers Included:

| Logger | Description |
|--------|-------------|
| `Cellcore` | Cellular/SMS routing traces - not needed without mobile hardware |
| `ReadyBoot` | Boot acceleration cache - less effective in VDI environments |
| `WDIContextLog` | Wireless diagnostics context log |
| `WiFiDriverIHVSession` | Wi-Fi driver user-initiated feedback |
| `WiFiSession` | Wi-Fi diagnostic session |
| `ReFSLog` | ReFS filesystem diagnostic log |
| `Mellanox-Kernel` | Mellanox network adapter diagnostics |

These autologgers are typically not needed in VDI environments or when the associated hardware (cellular, Wi-Fi) is not present.

---

## DefaultAssociationsConfiguration.xml

Configures default file type and protocol associations for Microsoft Edge.

### Associations Defined:

| File Type/Protocol | Application |
|--------------------|-------------|
| `.html` | Microsoft Edge |
| `.htm` | Microsoft Edge |
| `http://` | Microsoft Edge |
| `https://` | Microsoft Edge |
| `.pdf` | Microsoft Edge |

This XML file is referenced by the `EdgeSettings.json` policy `DefaultAssociationsConfiguration` to set system-wide default application associations.

---

## Configuration Profiles

### Available Profiles

| Profile | Description |
|---------|-------------|
| `Templates` | Base templates with conservative defaults (all optimizations set to Skip) |
| `W365-CloudPC` | **NEW in v1.1** - Optimized for Windows 365 Cloud PC with Intune/Azure Monitor compatibility |
| `2009` | Legacy profile for Windows 10 2009 (may contain deprecated IE/Edge settings) |

### W365-CloudPC Profile

The `W365-CloudPC` profile is specifically designed for Windows 365 Cloud PC environments. Key differences from base templates:

**Services.json:**
- `LanmanServer` and `LanmanWorkstation` set to **Apply** (disabled) - SMB not needed on Microsoft-hosted network
- All telemetry services remain **Skip** (protected for Intune)

**No LanManWorkstation.json** - SMB tuning is not needed when SMB services are disabled

**All other files** - Identical to Templates with verified Intune/Azure Monitor compatibility

#### Using the W365-CloudPC Profile

```powershell
# Run optimization with Cloud PC profile
.\Windows_Optimization.ps1 -ConfigProfile "W365-CloudPC" -Optimizations All -AcceptEULA

# Or create a custom profile based on W365-CloudPC
Copy-Item -Path ".\Configurations\W365-CloudPC\*" -Destination ".\Configurations\MyCloudPC\" -Recurse
.\Windows_Optimization.ps1 -ConfigProfile "MyCloudPC" -Optimizations All -AcceptEULA
```

> **Warning:** Do NOT use the W365-CloudPC profile on traditional VDI or on-premises machines that require SMB file sharing - the disabled SMB services will break access to network shares and printers.

---

## Usage

### Creating a New Configuration Profile

```powershell
.\New-WVDConfigurationFiles.ps1 -FolderName "MyCustomProfile"
```

### Customizing Settings

```powershell
# Interactive mode
.\Set-WVDConfigurations.ps1 -ConfigurationFile "Services" -ConfigFolderName "MyCustomProfile"

# Apply all optimizations
.\Set-WVDConfigurations.ps1 -ConfigurationFile "AppxPackages" -ConfigFolderName "MyCustomProfile" -ApplyAll

# Skip all optimizations
.\Set-WVDConfigurations.ps1 -ConfigurationFile "ScheduledTasks" -ConfigFolderName "MyCustomProfile" -SkipAll
```

### Running the Optimization

```powershell
.\Windows_Optimization.ps1 -ConfigProfile "MyCustomProfile" -Optimizations All -AcceptEULA
```

---

## Important Notes

1. **Test First**: Always test configurations in a non-production environment
2. **Conservative Defaults**: All items default to "Skip" for safety
3. **VDI Optimization**: Many settings are specifically designed for VDI/AVD environments
4. **Reversibility**: Some optimizations (like removing apps) may require reinstallation to reverse
5. **Dependencies**: Some services have dependencies that may prevent disabling

---

## Intune and Azure Monitor Compatibility

When deploying to Windows 365 Cloud PC or Intune-managed devices, certain services, tasks, and policies must remain enabled for Endpoint Analytics and Azure Monitor to function properly.

### Services - NEVER Disable for Intune/Azure Monitor

These services are required for telemetry and diagnostics:

| Service | Reason |
|---------|--------|
| `DiagTrack` | **CRITICAL** - Primary telemetry service for Endpoint Analytics |
| `DPS` | Diagnostic Policy Service - enables problem detection |
| `WdiSystemHost` | Diagnostic System Host - required for diagnostic hosting |
| `WerSvc` | Windows Error Reporting - required for app reliability |
| `DiagSvc` | Diagnostic Execution Service |
| `InstallService` | Required for Microsoft Store modern apps |
| `VSS` | Required for point-in-time restore capabilities |

### Scheduled Tasks - NEVER Disable for Intune/Azure Monitor

| Task | Reason |
|------|--------|
| `*Compatibility*` | **CRITICAL** - Microsoft Compatibility Appraiser for Endpoint Analytics |
| `Microsoft-Windows-DiskDiagnosticDataCollector` | Required for disk diagnostic telemetry |
| `Consolidator` | Required for CEIP/telemetry data collection |
| `Sqm-Tasks` | Required for TPM/Secure Boot compliance reporting |
| `StartComponentCleanup` | Required for persistent VDI disk maintenance |
| `Restore` | Required for cloud settings sync on persistent VDI |

### Policies - NEVER Apply for Maximum Telemetry

These policy settings must remain as "Skip" to ensure full telemetry:

| Setting | Reason |
|---------|--------|
| `CEIPEnable` | Required for Customer Experience data |
| `DisableInventory` | **CRITICAL** - Required for app inventory in Endpoint Analytics |
| `EnableDiagnostics` | Required for scripted diagnostics |
| `EnabledExecution` | Required for scheduled diagnostics |
| All `ScenarioExecutionEnabled` (7 WDI GUIDs) | Required for diagnostic scenarios |

### AppX Packages - Recommended to Keep

For productivity on Cloud PC environments, consider keeping:

| Package | Reason |
|---------|--------|
| `Microsoft.Copilot` | Microsoft AI assistant |
| `Microsoft.DesktopAppInstaller` | Required for winget package manager and app sideloading |
| `Microsoft.MicrosoftStickyNotes` | Productivity app |
| `Microsoft.Todos` | Task management app |
| `Microsoft.WindowsNotepad` | Essential text editor |
| `Microsoft.WindowsTerminal` | Modern terminal application |

---

## Version History

### v1.1 - Windows 365 Cloud PC Optimizations

Changes optimized for Windows 365 Cloud PC with Intune and Azure Monitor compatibility:

**Services.json:**
- Added `LanmanServer` and `LanmanWorkstation` services for Cloud PC environments without SMB

**DefaultUserSettings.json:**
- Set `NoToastApplicationNotification` to Apply
- Removed Edge update suppression settings (Autopatch manages Edge updates)

**PolicyRegSettings.json:**
- Set `DoNotShowFeedbackNotifications` to Apply
- Set `DisableSetup` (WinRE) to Apply
- Removed all Internet Explorer settings (deprecated for Windows 11)
- Removed Edge update suppression settings

**LanManWorkstation.json:**
- Removed (not needed for Cloud PC without SMB file sharing)

See `1.1Changes.md` for complete details.
