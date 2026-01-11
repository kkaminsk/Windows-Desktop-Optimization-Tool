# Proposal: Add WiX Installer for WDOT Deployment

## Why

Currently, deploying WDOT requires manual file copying and PowerShell execution with administrator privileges. A WiX-based MSI installer enables:

1. **Enterprise deployment** via SCCM, Intune, or Group Policy
2. **Silent installation** for automated provisioning
3. **Consistent file placement** with proper permissions
4. **Automatic optimization execution** during installation
5. **Uninstall capability** (removes files, but optimizations persist)

## What Changes

### New Files

1. **Installer/** - New directory containing WiX installer project
   - `WDOT.wxs` - Main WiX source file
   - `Product.wxs` - Product definition and features
   - `Files.wxs` - File components (auto-generated or manual)
   - `CustomActions.wxs` - PowerShell custom action definitions
   - `Build.cmd` - Build script for creating MSI

2. **Build artifacts**
   - `WDOT-1.1-W365CloudPC.msi` - Built installer package

### Installer Behavior

**Installation:**
1. Installs WDOT files to `C:\Program Files\WDOT\`
   - `Windows_Optimization.ps1`
   - `Functions\*.ps1` (14 function modules)
   - `Configurations\W365-CloudPC\*.json` (8 config files)
   - `EULA.txt`

2. Executes custom action (deferred, as SYSTEM):
   ```powershell
   powershell.exe -ExecutionPolicy Bypass -File "C:\Program Files\WDOT\Windows_Optimization.ps1" `
     -ConfigProfile "W365-CloudPC" `
     -Optimizations All `
     -AdvancedOptimizations All `
     -AcceptEULA
   ```

3. Logs output to Windows Event Log (WDOT log)

**Uninstallation:**
- Removes installed files
- Does NOT revert applied optimizations (by design - would require tracking)

### Configuration

| Setting | Value |
|---------|-------|
| Install Path | `C:\Program Files\WDOT` |
| Config Profile | `W365-CloudPC` |
| Optimizations | `All` |
| Advanced Optimizations | `All` (Edge, RemoveOneDrive, RemoveLegacyIE) |
| Run As | Local System (deferred custom action) |
| Silent Install | `msiexec /i WDOT.msi /qn` |

## Impact

- **Affected specs**: None existing (new capability)
- **Affected code**: None (installer wraps existing scripts)
- **New dependencies**: WiX Toolset v4+ for building MSI
- **Breaking changes**: None

## Risks

| Risk | Mitigation |
|------|------------|
| Custom action failure blocks install | Use `Execute="commit"` to run after file copy; log errors |
| Optimizations break target system | Same risk as manual execution; test in lab first |
| Large MSI size | Include only W365-CloudPC profile, not all templates |
| Build environment requirements | Document WiX Toolset installation; provide pre-built MSI |

## Out of Scope

- MSI transforms for different profiles (future enhancement)
- Rollback/revert of optimizations on uninstall
- UI for selecting optimizations during install
- Signing the MSI with a code signing certificate
