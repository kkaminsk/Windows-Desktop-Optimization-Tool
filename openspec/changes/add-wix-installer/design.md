# Design: WiX Installer for WDOT

## Context

WDOT is a PowerShell-based optimization tool that requires:
- Administrator privileges
- PowerShell 5.1+ (Desktop edition)
- Multiple script files and JSON configuration files
- Execution during system provisioning (before user login)

Enterprise deployment scenarios (Intune, SCCM, Azure Image Builder) benefit from MSI-based installers that:
- Run elevated automatically
- Execute silently
- Integrate with Windows Installer infrastructure
- Provide consistent deployment experience

## Goals

1. Create a single MSI that deploys WDOT and runs optimization
2. Support silent installation for enterprise deployment
3. Run optimization as Local System during installation
4. Minimal installer size (include only required profile)
5. Clean uninstallation of files (optimizations persist)

## Non-Goals

- Reverting optimizations on uninstall
- Interactive UI for selecting options
- Multiple profiles in single MSI
- Code signing (can be added separately)
- WiX bundle (no prerequisites like .NET required)

## Decisions

### Decision 1: WiX Toolset Version

**Decision**: Use WiX Toolset v4 (wix.exe CLI)

**Rationale**:
- WiX v4 is the current stable version
- Simplified CLI-based build process (`wix build`)
- Better PowerShell custom action support via extensions
- No Visual Studio dependency for builds

**Alternative considered**: WiX v3 - Rejected due to legacy status and more complex build setup

### Decision 2: Custom Action Approach

**Decision**: Use PowerShell.exe deferred custom action with `Execute="commit"`

**Rationale**:
- Deferred custom actions run elevated (as SYSTEM)
- `Execute="commit"` runs after file installation is complete
- Allows script to reference installed files
- PowerShell.exe is guaranteed to exist on Windows 10/11

**Implementation**:
```xml
<CustomAction Id="RunOptimization"
              Execute="deferred"
              Impersonate="no"
              Return="check"
              Directory="INSTALLFOLDER"
              ExeCommand="powershell.exe -ExecutionPolicy Bypass -NoProfile -NonInteractive -File &quot;[INSTALLFOLDER]Windows_Optimization.ps1&quot; -ConfigProfile W365-CloudPC -Optimizations All -AdvancedOptimizations All -AcceptEULA" />
```

**Alternative considered**:
- WiX PowerShell extension - More complex, requires extension packaging
- Immediate custom action - Runs before files are installed, would fail

### Decision 3: File Organization

**Decision**: Flat file structure under `C:\Program Files\WDOT`

```
C:\Program Files\WDOT\
├── Windows_Optimization.ps1
├── EULA.txt
├── Functions\
│   ├── Disable-WDOTAutoLoggers.ps1
│   ├── Disable-WDOTScheduledTasks.ps1
│   ├── Disable-WDOTServices.ps1
│   └── ... (11 more function files)
└── Configurations\
    └── W365-CloudPC\
        ├── AppxPackages.json
        ├── Autologgers.Json
        ├── DefaultUserSettings.json
        ├── EdgeSettings.json
        ├── PolicyRegSettings.json
        ├── ScheduledTasks.json
        ├── Services.json
        └── DefaultAssociationsConfiguration.xml
```

**Rationale**:
- Mirrors source repository structure
- Scripts use relative paths (`$PSScriptRoot`)
- Easy to verify installation

### Decision 4: MSI Properties

| Property | Value | Purpose |
|----------|-------|---------|
| ProductName | Windows Desktop Optimization Tool | Display name |
| Manufacturer | Microsoft | Publisher |
| ProductVersion | 1.1.0.0 | Matches WDOT version |
| UpgradeCode | {GUID} | Enables major upgrades |
| InstallScope | perMachine | Requires admin |

### Decision 5: Error Handling

**Decision**: Custom action returns error code to MSI; installation fails if optimization fails

**Rationale**:
- Ensures admin is aware of failures
- Prevents "silent success" when optimization didn't run
- MSI logs capture PowerShell output

**Alternative considered**:
- Ignore custom action errors - Rejected; optimization is the primary purpose
- Log and continue - Rejected; defeats purpose of installer

### Decision 6: Logging

**Decision**: MSI verbose logging + WDOT Event Log

**Usage**:
```cmd
msiexec /i WDOT.msi /qn /l*v install.log
```

**Rationale**:
- MSI log captures custom action stdout/stderr
- WDOT already writes to Windows Event Log (WDOT source)
- Combined provides full audit trail

## Installer Build Process

```
Source Files                    WiX Build                    Output
─────────────                   ─────────                    ──────
Windows_Optimization.ps1  ──┐
Functions/*.ps1           ──┼──> wix build ──> WDOT.wixobj ──> WDOT-1.1-W365CloudPC.msi
Configurations/W365-CloudPC/ ─┘     │
                                    │
Installer/WDOT.wxs ─────────────────┘
```

**Build Command**:
```cmd
wix build -o WDOT-1.1-W365CloudPC.msi Installer\WDOT.wxs -ext WixToolset.Util.wixext
```

## WiX Source Structure

### WDOT.wxs (Single File Approach)

```xml
<?xml version="1.0" encoding="UTF-8"?>
<Wix xmlns="http://wixtoolset.org/schemas/v4/wxs">
  <Package Name="Windows Desktop Optimization Tool"
           Manufacturer="Microsoft"
           Version="1.1.0.0"
           UpgradeCode="{UNIQUE-GUID}"
           Scope="perMachine">

    <!-- Directory structure -->
    <StandardDirectory Id="ProgramFilesFolder">
      <Directory Id="INSTALLFOLDER" Name="WDOT">
        <Directory Id="FunctionsFolder" Name="Functions" />
        <Directory Id="ConfigurationsFolder" Name="Configurations">
          <Directory Id="W365CloudPCFolder" Name="W365-CloudPC" />
        </Directory>
      </Directory>
    </StandardDirectory>

    <!-- Components for each file -->
    <ComponentGroup Id="MainComponents" Directory="INSTALLFOLDER">
      <Component>
        <File Source="..\Windows_Optimization.ps1" />
      </Component>
      <Component>
        <File Source="..\EULA.txt" />
      </Component>
    </ComponentGroup>

    <!-- Feature containing all components -->
    <Feature Id="Main" Level="1">
      <ComponentGroupRef Id="MainComponents" />
      <ComponentGroupRef Id="FunctionComponents" />
      <ComponentGroupRef Id="ConfigComponents" />
    </Feature>

    <!-- Custom action to run optimization -->
    <CustomAction Id="RunOptimization"
                  Execute="deferred"
                  Impersonate="no"
                  Return="check"
                  Directory="INSTALLFOLDER"
                  ExeCommand="..." />

    <InstallExecuteSequence>
      <Custom Action="RunOptimization" After="InstallFiles">
        NOT Installed
      </Custom>
    </InstallExecuteSequence>

  </Package>
</Wix>
```

## Risks / Trade-offs

| Risk | Mitigation |
|------|------------|
| PowerShell execution policy blocks script | Use `-ExecutionPolicy Bypass` |
| Antivirus blocks custom action | Document, sign MSI if needed |
| Custom action timeout (default 5 min) | Optimization typically completes in 1-2 min |
| No rollback if optimization fails | Log clearly; manual recovery documented |

## Open Questions

1. Should we create a WiX bundle to also install prerequisites if needed?
   - **Answer**: No, Windows 10/11 includes PowerShell 5.1

2. Should the installer support upgrades (reinstall over existing)?
   - **Answer**: Yes, use `MajorUpgrade` element for clean reinstalls

3. Should we include a post-install reboot prompt?
   - **Answer**: No, let the optimization script's `-Restart` parameter handle this if needed (currently not using it in silent mode)
