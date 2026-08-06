# Disk Health Reporter Script

A PowerShell 5.1 script for DWP engineers that reports disk health and optimization status.

This script is strictly read-only and does not run defragmentation.

---

## Files

| File | Description |
|------|-------------|
| `disk-health-reporter.ps1` | Main script |

---

## Requirements

- PowerShell 5.1 or later
- Elevated (Administrator) session recommended for complete visibility on some endpoints

---

## Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `-ShowRecentDefragEvents` | Switch | Off | Include recent defrag/optimization events from Application log |
| `-DryRun` | Switch | Off | Compatibility switch; behavior is unchanged because the script is always read-only |
| `-EventCount` | Int | `5` | Number of recent events to display when `-ShowRecentDefragEvents` is used |

---

## Usage Examples

### Standard read-only health report
```powershell
.\disk-health-reporter.ps1
```

### Explicit dry-run mode (same behavior)
```powershell
.\disk-health-reporter.ps1 -DryRun
```

### Include recent optimization events
```powershell
.\disk-health-reporter.ps1 -ShowRecentDefragEvents -EventCount 10
```

---

## What the Script Reports

1. Physical disk health (health status, operational status, media type, size)
2. Logical volume status (filesystem, free space, volume health)
3. SMART failure prediction indicators (if exposed by hardware/drivers)
4. Optimization schedule status from `ScheduledDefrag` task
5. Defrag service (`defragsvc`) status
6. Optional recent optimization-related events from Windows logs

---

## Read-Only Guarantee

- No file system writes are performed by this script.
- No registry values are modified.
- No services or scheduled tasks are changed.
- No defrag/optimization actions are executed.

The script only queries system state and logs.
