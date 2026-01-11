# WiX Installer Capability Spec

## ADDED Requirements

### Requirement: MSI Package Generation

The project SHALL include a WiX-based installer that produces an MSI package for deploying WDOT to Windows machines.

#### Scenario: Build MSI from source

- **WHEN** the developer runs the build script from the `Installer/` directory
- **THEN** a valid MSI file is generated named `WDOT-1.1-W365CloudPC.msi`
- **AND** the MSI contains all required WDOT files
- **AND** the build completes without errors

### Requirement: Silent Installation Support

The MSI installer SHALL support fully silent installation for enterprise deployment scenarios.

#### Scenario: Silent install via command line

- **WHEN** an administrator runs `msiexec /i WDOT-1.1-W365CloudPC.msi /qn`
- **THEN** the installation completes without user interaction
- **AND** all WDOT files are installed to `C:\Program Files\WDOT`
- **AND** the Windows optimization is executed automatically

#### Scenario: Silent install with logging

- **WHEN** an administrator runs `msiexec /i WDOT-1.1-W365CloudPC.msi /qn /l*v install.log`
- **THEN** detailed installation logs are written to `install.log`
- **AND** the log includes custom action output from the optimization script

### Requirement: File Installation

The MSI installer SHALL install all required WDOT files to the target directory.

#### Scenario: Complete file installation

- **WHEN** the MSI installation completes successfully
- **THEN** `C:\Program Files\WDOT\Windows_Optimization.ps1` exists
- **AND** `C:\Program Files\WDOT\EULA.txt` exists
- **AND** `C:\Program Files\WDOT\Functions\` contains 14 PowerShell function files
- **AND** `C:\Program Files\WDOT\Configurations\W365-CloudPC\` contains 8 configuration files

### Requirement: Optimization Execution During Install

The MSI installer SHALL execute the Windows optimization script as a custom action during installation.

#### Scenario: Optimization runs as SYSTEM

- **WHEN** the MSI installation reaches the custom action phase
- **THEN** `Windows_Optimization.ps1` is executed with elevated privileges
- **AND** the script runs with parameters: `-ConfigProfile W365-CloudPC -Optimizations All -AdvancedOptimizations All -AcceptEULA`
- **AND** the optimization completes before installation finishes

#### Scenario: Optimization failure halts installation

- **WHEN** the optimization script returns a non-zero exit code
- **THEN** the MSI installation fails
- **AND** the error is logged to the MSI log file
- **AND** installed files are rolled back

### Requirement: Clean Uninstallation

The MSI installer SHALL support clean removal of installed files.

#### Scenario: Uninstall removes files

- **WHEN** an administrator uninstalls WDOT via Programs and Features or `msiexec /x`
- **THEN** all files in `C:\Program Files\WDOT` are removed
- **AND** the `C:\Program Files\WDOT` directory is removed
- **AND** applied optimizations remain in effect (not reverted)

### Requirement: Major Upgrade Support

The MSI installer SHALL support upgrading from previous versions.

#### Scenario: Upgrade replaces previous version

- **WHEN** WDOT 1.1 MSI is installed on a machine with WDOT 1.0 MSI already installed
- **THEN** the previous version is automatically uninstalled
- **AND** the new version is installed
- **AND** the optimization runs with the new version's configuration

### Requirement: Installer Metadata

The MSI installer SHALL include proper metadata for enterprise management.

#### Scenario: MSI properties are set correctly

- **WHEN** viewing the MSI properties in Windows Explorer or an MSI editor
- **THEN** the Product Name is "Windows Desktop Optimization Tool"
- **AND** the Manufacturer is "Microsoft"
- **AND** the Version matches the WDOT version (1.1.0.0)

### Requirement: Build Documentation

The project SHALL include documentation for building the MSI installer.

#### Scenario: Build instructions are available

- **WHEN** a developer reads `Installer/README.md`
- **THEN** they can identify the required WiX Toolset version
- **AND** they can follow step-by-step build instructions
- **AND** they can understand the installer structure
