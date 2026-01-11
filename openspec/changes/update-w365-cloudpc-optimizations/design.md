# Design: Windows 365 Cloud PC Optimizations

## Context

Windows 365 Cloud PC is a cloud-based service running on Microsoft-hosted infrastructure. Unlike traditional VDI or on-premises desktops, Cloud PCs:

- Are managed through Microsoft Intune
- Report telemetry through Endpoint Analytics and Azure Monitor
- Use Windows Autopatch for update management
- Do not require SMB file sharing (no network shares in Microsoft-hosted environment)
- Run Windows 11 exclusively (Internet Explorer is deprecated)

The current WDOT v1.0 templates were designed for general VDI optimization and may inadvertently disable services/settings critical for Cloud PC management.

## Goals

1. Preserve Intune Endpoint Analytics and Azure Monitor telemetry
2. Remove irrelevant legacy settings (Internet Explorer)
3. Avoid conflicts with Windows Autopatch (Edge update suppression)
4. Disable unnecessary services for Cloud PC (SMB file sharing)
5. Maintain backwards compatibility with existing VDI deployments

## Non-Goals

- Modifying the core optimization engine (`Windows_Optimization.ps1`)
- Creating Intune deployment packages
- Automating Cloud PC provisioning

## Decisions

### Decision 1: Configuration Profile Approach

**Decision**: Create a new dedicated configuration profile folder (`W365-CloudPC`) rather than modifying base templates.

**Rationale**:
- Preserves backwards compatibility for existing VDI deployments
- Allows different optimizations for different scenarios
- Follows existing pattern (e.g., `2009` profile exists alongside `Templates`)
- Users can choose the profile appropriate for their environment

**Alternatives considered**:
1. Modify Templates directly - Rejected: breaks backwards compatibility, forces Cloud PC-specific settings on all users
2. Add conditional logic to scripts - Rejected: increases complexity, harder to maintain

### Decision 2: Telemetry Protection Strategy

**Decision**: Keep all telemetry-related services and tasks as "Skip" (do not disable).

**Protected Services**:
| Service | Purpose |
|---------|---------|
| DiagTrack | Primary Endpoint Analytics telemetry |
| DPS | Diagnostic Policy Service |
| WdiSystemHost | Diagnostic hosting |
| WerSvc | Windows Error Reporting / App reliability |
| DiagSvc | Diagnostic execution |
| InstallService | Microsoft Store apps |
| VSS | Point-in-time restore |

**Protected Scheduled Tasks**:
| Task | Purpose |
|------|---------|
| *Compatibility* | Microsoft Compatibility Appraiser |
| Microsoft-Windows-DiskDiagnosticDataCollector | Disk telemetry |
| Consolidator | CEIP data collection |
| Sqm-Tasks | TPM/Secure Boot compliance |
| StartComponentCleanup | Disk maintenance |
| Restore | Cloud settings sync |

**Rationale**: These components are essential for Intune to collect device health, compliance, and analytics data. Disabling them breaks cloud management visibility.

### Decision 3: SMB Service Handling

**Decision**: Set LanmanServer and LanmanWorkstation to "Apply" (disable) in Cloud PC profile.

**Rationale**:
- Windows 365 Cloud PCs on Microsoft-hosted network don't use SMB file sharing
- Reduces attack surface
- Saves system resources

**Warning**: This would break file/printer sharing if applied to on-premises VDI.

### Decision 4: Legacy IE Settings Removal

**Decision**: Remove all Internet Explorer registry settings from the Cloud PC profile.

**Rationale**: Internet Explorer is not available in Windows 11. These settings have no effect and add confusion.

### Decision 5: Edge Update Suppression

**Decision**: Do NOT include Edge update suppression settings in Cloud PC profile.

**Rationale**: Windows Autopatch manages Edge updates for Cloud PCs. Manual suppression conflicts with this management.

## Risks / Trade-offs

| Risk | Mitigation |
|------|------------|
| Users apply Cloud PC profile to traditional VDI | Clear naming (`W365-CloudPC`), documentation warnings, README update |
| Future Windows 365 requirements change | Version the profile, create update process |
| Missing telemetry settings not listed in 1.1Changes.md | Conduct thorough review of all template files against Microsoft documentation |

## Migration Plan

1. Create new `W365-CloudPC` profile folder
2. Copy templates from `Templates/` as base
3. Apply modifications per this design
4. Update documentation (README, Configurations/README.md)
5. Test with Windows 365 Cloud PC environment
6. Release as part of v1.1

**Rollback**: Delete `W365-CloudPC` folder; no changes to existing profiles.

## Open Questions

1. Should we also create an Azure Virtual Desktop (AVD)-specific profile with different settings than Cloud PC?
2. Should we add validation to warn users when applying Cloud PC profile to non-Cloud PC systems?
3. Do customers need Edge update suppression settings removed from the 2009 profile as well, or only from new profiles?
