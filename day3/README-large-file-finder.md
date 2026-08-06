# Large File Finder Script

A PowerShell 5.1 read-only script for DWP engineers that finds and reports large files.

The script recursively scans a target path and lists files whose size is greater than or equal to the threshold value.

---

## Files

| File | Description |
|------|-------------|
| `large-file-finder.ps1` | Main script |

---

## Requirements

- PowerShell 5.1 or later
- Read permission on the target path(s)

---

## Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `-Path` | String | Current directory | Root path to scan recursively |
| `-ThresholdMB` | Int | `100` | File size threshold in MB |
| `-Top` | Int | `100` | Maximum number of largest matching files to display |

---

## Usage Examples

### Scan current directory with default threshold (100 MB)
```powershell
.\large-file-finder.ps1
```

### Scan a specific path with 250 MB threshold
```powershell
.\large-file-finder.ps1 -Path C:\Users -ThresholdMB 250
```

### Return only top 25 large files at or above 50 MB
```powershell
.\large-file-finder.ps1 -Path D:\Data -ThresholdMB 50 -Top 25
```

---

## Output Columns

| Column | Meaning |
|--------|---------|
| `SizeMB` | File size in megabytes |
| `LastWriteTime` | Last modified timestamp |
| `FullName` | Full file path |

---

## Notes

- Read-only script: no files are modified, moved, or deleted.
- Access-denied folders are skipped so the scan can continue.
- Larger paths can take time; narrow `-Path` when needed for faster results.
