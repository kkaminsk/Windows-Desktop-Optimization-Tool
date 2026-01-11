# Design: WDOT Configuration Audit Script

## Architecture Overview

```
Get-WDOTAudit.ps1 (orchestrator)
    │
    ├── Loads configuration JSON files
    │
    ├── Calls audit functions:
    │   ├── Get-WDOTAuditServices.ps1
    │   ├── Get-WDOTAuditAppxPackages.ps1
    │   ├── Get-WDOTAuditScheduledTasks.ps1
    │   └── Get-WDOTAuditRegistry.ps1
    │
    └── Outputs report (Console/JSON/HTML)
```

## Data Flow

1. **Input**: Configuration profile name (e.g., "W365-CloudPC")
2. **Load**: JSON configuration files from `Configurations/<Profile>/`
3. **Query**: Current system state via PowerShell cmdlets
4. **Compare**: Actual state vs expected state from config
5. **Output**: Compliance report

## Audit Result Object Schema

Each audit function returns an array of `[PSCustomObject]` with consistent properties:

```powershell
[PSCustomObject]@{
    Category     = "Services"           # Services|AppxPackages|ScheduledTasks|Registry
    Name         = "LanmanServer"       # Item identifier
    Description  = "SMB Server"         # From config file
    Expected     = "Disabled"           # What config says should happen
    Actual       = "Disabled"           # Current system state
    Compliant    = $true                # Expected matches Actual
    Details      = "Startup: Disabled"  # Additional context
}
```

## Compliance Logic by Category

### Services
| Config State | Expected Service State | Compliant When |
|--------------|------------------------|----------------|
| Apply | Disabled | StartupType = Disabled |
| Skip | (not checked) | Always compliant |

### AppX Packages
| Config State | Expected | Compliant When |
|--------------|----------|----------------|
| Apply | Not Installed | Package not found via Get-AppxPackage/Get-AppxProvisionedPackage |
| Skip | Installed | (not checked, always compliant) |

### Scheduled Tasks
| Config State | Expected | Compliant When |
|--------------|----------|----------------|
| Apply | Disabled | Task.State = Disabled |
| Skip | (not checked) | Always compliant |

### Registry (PolicyRegSettings)
| Config State | Expected | Compliant When |
|--------------|----------|----------------|
| Apply | Value set | Registry value matches config |
| Skip | (not checked) | Always compliant |

## Error Handling

- **Missing config file**: Log warning, skip that category
- **Service not found**: Mark as "Not Found" (may be compliant if removed feature)
- **Registry path not found**: Mark as "Not Configured"
- **Access denied**: Mark as "Access Denied" with warning

## Output Formats

### Console (Default)
- Color-coded output using `Write-Host`
- Summary statistics at end
- Suitable for interactive use

### JSON
```json
{
  "AuditDate": "2026-01-11T15:30:00",
  "ConfigProfile": "W365-CloudPC",
  "Summary": {
    "TotalChecks": 51,
    "Compliant": 48,
    "Drift": 3,
    "CompliancePercent": 94.1
  },
  "Results": [
    {
      "Category": "Services",
      "Name": "LanmanServer",
      "Expected": "Disabled",
      "Actual": "Disabled",
      "Compliant": true
    }
  ]
}
```

### HTML (Future)
- Styled table with compliance highlighting
- Suitable for reports/documentation

## Security Considerations

- **Read-only**: No system modifications
- **No elevation required**: Queries don't require admin (except some registry paths)
- **No network calls**: Purely local audit
- **No secrets**: Doesn't read or expose sensitive data

## Performance

- Expected runtime: < 30 seconds on typical system
- Main bottleneck: `Get-AppxPackage -AllUsers` (can be slow)
- Consider `-Categories` parameter to audit specific areas only
