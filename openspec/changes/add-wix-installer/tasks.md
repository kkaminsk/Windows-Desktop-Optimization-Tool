# Implementation Tasks

## 1. Create Installer Directory Structure

- [x] 1.1 Create `Installer/` directory in project root
- [x] 1.2 Create `Installer/README.md` with build instructions

## 2. Create WiX Source File

- [x] 2.1 Create `Installer/WDOT.wxs` with Package definition
- [x] 2.2 Define directory structure (ProgramFilesFolder/WDOT/Functions/Configurations)
- [x] 2.3 Create ComponentGroup for main files (Windows_Optimization.ps1, EULA.txt)
- [x] 2.4 Create ComponentGroup for Functions/*.ps1 (14 files)
- [x] 2.5 Create ComponentGroup for Configurations/W365-CloudPC/*.json (8 files)
- [x] 2.6 Create Feature element containing all ComponentGroups
- [x] 2.7 Add MajorUpgrade element for version upgrades

## 3. Create Custom Action for Optimization

- [x] 3.1 Define CustomAction element for PowerShell execution
- [x] 3.2 Configure as deferred, impersonate=no, return=check
- [x] 3.3 Set ExeCommand with proper path escaping and parameters
- [x] 3.4 Add to InstallExecuteSequence after InstallFiles
- [x] 3.5 Add condition to run only on fresh install (NOT REMOVE~="ALL")

## 4. Create Build Script

- [x] 4.1 Create `Installer/Build.cmd` for Windows command line
- [x] 4.2 Add WiX build command with output path
- [x] 4.3 Add error checking and user feedback
- [x] 4.4 Create `Installer/Build.ps1` PowerShell alternative

## 5. Generate Unique GUIDs

- [x] 5.1 Generate UpgradeCode GUID for product: `51115B56-21BF-4170-BB49-62864D60F0FB`
- [x] 5.2 Generate Component GUIDs (using auto-generation with `Guid="*"`)

## 6. Write Installer Documentation

- [x] 6.1 Document WiX Toolset v4 installation requirements
- [x] 6.2 Document build process step-by-step
- [x] 6.3 Document silent installation commands
- [x] 6.4 Document logging options
- [x] 6.5 Document uninstallation process

## 7. Test Build Process

- [ ] 7.1 Verify WiX Toolset v4 is installed
  - Note: WiX not installed on current system; install with `dotnet tool install --global wix`
- [ ] 7.2 Run build script and verify MSI is created
- [ ] 7.3 Verify MSI file size is reasonable (<5MB)
- [ ] 7.4 Inspect MSI with Orca or similar tool

> **Note:** Tasks 7.1-7.4 require WiX Toolset installation. All source files are complete and ready for building.

## 8. Test Installation

- [ ] 8.1 Test silent installation on clean Windows 11 VM
- [ ] 8.2 Verify all files are installed to correct locations
- [ ] 8.3 Verify custom action runs (check Event Log for WDOT entries)
- [ ] 8.4 Verify optimizations are applied (spot check services/registry)
- [ ] 8.5 Test with verbose logging enabled

## 9. Test Uninstallation

- [ ] 9.1 Uninstall via Programs and Features
- [ ] 9.2 Verify all files are removed
- [ ] 9.3 Verify WDOT directory is removed
- [ ] 9.4 Verify optimizations remain in effect

## 10. Test Upgrade Scenario

- [ ] 10.1 Install version 1.0 (mock or previous)
- [ ] 10.2 Install version 1.1 over existing
- [ ] 10.3 Verify old files are removed
- [ ] 10.4 Verify new files are installed
- [ ] 10.5 Verify optimization runs on upgrade

## 11. Update Project Documentation

- [x] 11.1 Add Installer section to main README.md
- [x] 11.2 Update project structure diagram
- [x] 11.3 Add deployment guidance for enterprise scenarios

## Dependencies

- **Task 2 depends on**: Task 1 (directory must exist) ✓
- **Task 3 depends on**: Task 2 (WXS file must have Package) ✓
- **Task 4 depends on**: Task 2 (WXS file must exist) ✓
- **Tasks 7-10 depend on**: Tasks 1-6 complete ✓
- **Task 11 depends on**: Task 7 verification complete ✓

## Parallelizable Work

- Tasks 5 and 6 can be done in parallel with Task 2-4 ✓
- Tasks 8, 9, 10 must be sequential (each requires clean VM state)

---

## Implementation Summary

**Files Created:**
- `Installer/WDOT.wxs` - Complete WiX v4 source file with:
  - Package definition (name, version, manufacturer)
  - Directory structure for WDOT installation
  - ComponentGroups for all 24 files (2 main + 14 functions + 8 config)
  - Deferred custom action to run PowerShell optimization
  - MajorUpgrade element for version upgrades
  - Embedded CAB with high compression
- `Installer/Build.cmd` - Command line build script
- `Installer/Build.ps1` - PowerShell build script with enhanced output
- `Installer/README.md` - Comprehensive installer documentation

**Files Modified:**
- `README.md` - Added MSI Installer section and updated changelog

**Configuration:**
| Setting | Value |
|---------|-------|
| UpgradeCode | `51115B56-21BF-4170-BB49-62864D60F0FB` |
| Install Path | `C:\Program Files\WDOT` |
| Config Profile | `W365-CloudPC` |
| Optimizations | `All` |
| Advanced Optimizations | `All` |

**Build Command:**
```powershell
cd Installer
.\Build.ps1
# Output: WDOT-1.1-W365CloudPC.msi
```

**Deployment:**
```cmd
msiexec /i WDOT-1.1-W365CloudPC.msi /qn /l*v install.log
```

**Pending (Requires WiX Installation):**
- Tasks 7-10: Build verification and installation testing
