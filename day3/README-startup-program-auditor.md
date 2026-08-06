# Startup Program Auditor Script

A PowerShell 5.1 script for DWP engineers to audit Windows startup programs and optionally disable a startup item by name.

The script reads startup entries from registry Run keys and Startup folders. In audit mode (default), it is read-only.

---

## Files

| File | Description |
|------|-------------|
| `startup-program-auditor.ps1` | Main script |

---

## Requirements

- PowerShell 5.1 or later
- Elevated (Administrator) session recommended for complete HKLM/Common Startup access

---

## Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `-Disable` | Switch | Off | Enables disable mode |
| `-ProgramName` | String | *(none)* | Startup program text to match (required with `-Disable`) |
| `-IncludeCommonStartup` | Switch | On | Include all-users Startup folder (`%ProgramData%`) |
| `-DryRun` | Switch | Off | Compatibility switch; audit mode is already read-only by default |
| `-WhatIf` | Switch | Off | Preview disable actions without changing anything |
| `-Confirm` | Switch | On (prompted by policy) | Prompt before each change in disable mode |

---

## Usage Examples

### Audit startup entries (read-only)
```powershell
.\startup-program-auditor.ps1
```

### Explicit dry-run mode (same behavior)
```powershell
.\startup-program-auditor.ps1 -DryRun
```

### Disable matching startup entries
```powershell
.\startup-program-auditor.ps1 -Disable -ProgramName Teams
```

### Preview disable actions only (no changes)
```powershell
.\startup-program-auditor.ps1 -Disable -ProgramName OneDrive -WhatIf
```

### Exclude all-users startup folder
```powershell
.\startup-program-auditor.ps1 -IncludeCommonStartup:$false
```

---

## What Gets Audited

1. `HKCU:\Software\Microsoft\Windows\CurrentVersion\Run`
2. `HKLM:\Software\Microsoft\Windows\CurrentVersion\Run`
3. `HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Run`
4. `%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup`
5. `%ProgramData%\Microsoft\Windows\Start Menu\Programs\Startup` (if enabled)

---

## Disable Behavior

- Registry entries:
  - Matched Run values are copied to a sibling key named `Run-DisabledByAudit`.
  - The original Run value is then removed from active startup.
- Startup folder entries:
  - Matching files are renamed from `<name>` to `<name>.disabled`.

---

## Safety Notes

- Audit mode (default) makes no changes.
- Use `-WhatIf` first to validate match results before disabling.
- Disabling HKLM entries and Common Startup items may require elevation.
