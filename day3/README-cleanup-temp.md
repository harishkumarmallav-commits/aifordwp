# Temp File Cleanup Script

A PowerShell 5.1 script for DWP engineers that safely removes temporary files from Windows endpoints.

Files are **moved** (not permanently deleted) to a timestamped backup location, enabling rollback. Every action is logged to a date-stamped log file.

---

## Files

| File | Description |
|------|-------------|
| `cleanup-temp.ps1` | Main script |
| `Logs\` | Auto-created; contains a timestamped `.log` file per run |
| `Backup\` | Auto-created; contains staged files organised by RunId |

---

## Requirements

- PowerShell 5.1 or later
- Elevated (Administrator) session recommended for full access to `%WINDIR%\Temp`

---

## Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `-DryRun` | Switch | Off | Preview files that would be removed — no changes made |
| `-OlderThanDays` | Int | `0` | Only process files older than this many days (`0` = all files) |
| `-Rollback` | Switch | Off | Restore files removed by a previous run |
| `-RunId` | String | *(latest)* | ID of the specific run to roll back (e.g. `20260805_143022`). Used with `-Rollback` only |
| `-LogDirectory` | String | `.\Logs` | Override the directory where log files are written |
| `-BackupDirectory` | String | `.\Backup` | Override the directory where removed files are staged |

---

## Usage Examples

### Preview files that would be removed
```powershell
.\cleanup-temp.ps1 -DryRun
```

### Remove all temp files (live run)
```powershell
.\cleanup-temp.ps1
```

### Remove only files older than 7 days
```powershell
.\cleanup-temp.ps1 -OlderThanDays 7
```

### Dry-run scoped to files older than 30 days
```powershell
.\cleanup-temp.ps1 -DryRun -OlderThanDays 30
```

### Roll back the most recent cleanup
```powershell
.\cleanup-temp.ps1 -Rollback
```

### Roll back a specific run by RunId
```powershell
.\cleanup-temp.ps1 -Rollback -RunId 20260805_143022
```

### Use custom log and backup directories
```powershell
.\cleanup-temp.ps1 -LogDirectory D:\Logs -BackupDirectory D:\TempBackup
```

---

## How It Works

1. **Scan** — Recursively enumerates `%TEMP%` and `%WINDIR%\Temp`.
2. **Age filter** — Skips files whose `LastWriteTime` is within the `OlderThanDays` window.
3. **Lock check** — Attempts to open each file exclusively. If the file is in use it is skipped and a `WARN` entry is written to the log; the script continues.
4. **Move** — Qualifying files are moved (not deleted) to `Backup\<RunId>\` preserving the original directory structure.
5. **Manifest** — A `manifest.csv` is written inside the backup folder, mapping each file's original path to its backup path. The manifest is updated after every file move so a mid-run crash still leaves a usable rollback record.
6. **Log** — Every action (`REMOVED`, `LOCKED`, `FAILED`, `DRY-RUN`) is appended to `Logs\cleanup-<RunId>.log` with a full timestamp.
7. **Summary** — A results table is printed to the console and appended to the log at the end of the run.

---

## Rollback

Because files are **moved** rather than deleted, a full rollback is possible at any time:

```powershell
# Restore the most recent cleanup run
.\cleanup-temp.ps1 -Rollback

# Restore a specific run
.\cleanup-temp.ps1 -Rollback -RunId 20260805_143022
```

The `RunId` is displayed in the summary at the end of every live run and matches the subfolder name inside `Backup\`.

---

## Idempotency

The script is safe to run multiple times:

- **Cleanup** — Files already removed in a previous run no longer exist in the source directories, so they are simply not found on subsequent runs.
- **Rollback** — If a rollback has already been performed for a given run, the backup files are gone and/or the originals already exist, so re-running rollback skips those entries gracefully.

---

## Targeted Directories

| Directory | Description |
|-----------|-------------|
| `%TEMP%` | Current user temporary files (`C:\Users\<user>\AppData\Local\Temp`) |
| `%WINDIR%\Temp` | Windows system temporary files (`C:\Windows\Temp`) |

---

## Log Format

Each entry follows this format:

```
[yyyy-MM-dd HH:mm:ss] [LEVEL] Message
```

| Level | Meaning |
|-------|---------|
| `INFO` | Normal operation (removed, started, summary) |
| `WARN` | Non-fatal issue (locked file, already restored) |
| `ERROR` | File-level failure (move failed, restore failed) |
| `DRY-RUN` | File that would be removed in a live run |

---

## Notes

- The script does **not** permanently delete any files; they are always staged in `Backup\` first.
- The `Backup\` directory will grow over time. Remove old run subfolders once you are confident they are no longer needed.
- Access-denied errors during directory enumeration are silently skipped (`-ErrorAction SilentlyContinue`); individual file errors are caught and logged.
