# L2 KB: Desktop Customization Loss - Profile Investigation (FLR6-PROF-003)

**Article ID:** FLR6-PROF-003-L2  
**Title:** User Profile Desktop Customization Loss - Root Cause & Recovery  
**Audience:** IT Support (L2), Systems Administrators, Help Desk Advanced  
**Level:** L2 (Technical)  
**Date:** 14-Aug-2026

---

**SOURCE OF TRUTH:** This L2 article is a technical re-expression of [Runbook-FLR6-PROF-003-Missing-Shortcuts.md](Runbook-FLR6-PROF-003-Missing-Shortcuts.md) and follows the runbook's section flow. If conflicts appear, the runbook governs.

**TRACEABILITY MAP:**
- Runbook Section 3 (Initial Investigation) -> Technical Investigation Steps
- Runbook Section 4 (Root Cause Investigation) -> Root Cause Confirmation Matrix
- Runbook recovery procedures -> Recovery Options

---

## Executive Summary

**Incident:** Floor 6 user's desktop shortcuts disappeared following Friday document management app deployment  
**Severity:** LOW (P3) - Non-critical usability issue  
**Impact:** Single user confirmed; scope assessment ongoing  
**Root Cause Hypothesis:** App deployment script or Group Policy change modified user profile desktop customizations  
**Status:** User self-service recovery in progress; IT profile restoration available if needed

Reasoning for this conclusion:
- Symptom timing aligns with the deployment change window.
- Evidence pattern is specific to shortcut visibility/deletion states.
- Recovery tests (unhide/restore/recreate) match profile customization impact.

---

## Technical Analysis

### Symptom Profile

**Reported Issue:**
- User's desktop shortcuts (.lnk files) disappeared
- Discovered Monday morning (likely occurred Friday evening or overnight)
- Timeline: Post-deployment (Friday 15:00) to discovery (Monday 09:14)
- Only affects desktop customization, not actual files/applications

**Scope Assessment Status:**
- Confirmed users affected: 1 (one Floor 6 paralegal)
- Potentially affected: All Floor 6 Users (12+)
- Investigation status: In progress (checking other users)

### Root Cause Investigation

**Hypothesis 1: App Deletion Script (40% confidence)**

Document management app's installation script may have included:
```powershell
# Potential problematic code in app installer:
Remove-Item -Path "$env:USERPROFILE\Desktop\*.lnk" -Force
# OR
Set-ItemProperty -Path "$env:USERPROFILE\Desktop" -Name "ClearDesktop" -Value 1
```

**Investigation Path:**
- [ ] Examine app MSI/installer for desktop modification code
- [ ] Check app installation logs for file deletion operations
- [ ] Review app setup script (if separate .ps1 or .bat exists)
- [ ] Query WMI object Win32_Product for uninstall string

**Hypothesis 2: Group Policy Change (30% confidence)**

Group Policy deployed Friday may include:
```
Computer Configuration\Administrative Templates\Desktop\
  → "Remove desktop icons" policy
  → OR "Hide desktop icons" policy
  → OR "Restore default desktop" policy applied
```

**Investigation Path:**
- [ ] Check gpresult output for policies affecting desktop
- [ ] Review HKCU\Software\Policies\Microsoft\Windows\* for restrictions
- [ ] Check domain Group Policy change logs (Friday timestamp)
- [ ] Verify if policy applies to Floor 6 OU or security group

**Hypothesis 3: User Profile Replacement/Sync (20% confidence)**

User profile may have been:
- Replaced with clean default profile during deployment
- Synced from backup (older version without shortcuts)
- Roaming profile sync pulled older version Friday evening

**Investigation Path:**
- [ ] Check C:\Users folder for profile backup/alternate versions
- [ ] Review profile modification timestamps (LastWriteTime = Friday afternoon?)
- [ ] Check roaming profile server logs for sync operations
- [ ] Verify profile integrity (missing shortcut files vs. hidden)

**Hypothesis 4: User Accidental Deletion (10% confidence)**

User may have intentionally deleted shortcuts (unlikely given testimony but worth documenting)

---

## Technical Investigation Steps

### Step 1: Verify File Existence vs. Hidden State

**Remote Execution on Affected Device:**

```powershell
# Check if shortcuts physically exist (hidden or not)
$desktopPath = "C:\Users\[username]\Desktop"

# List visible files
Get-ChildItem -Path $desktopPath -Filter "*.lnk" | Select-Object Name, FullName

# List hidden files
Get-ChildItem -Path $desktopPath -Filter "*.lnk" -Hidden | Select-Object Name, FullName

# Expected findings:
# A) No results from both commands → Shortcuts deleted
# B) Results only from -Hidden command → Shortcuts hidden (easy fix)
# C) Results from both → Mixed state (rare)
```

**File Attribute Verification:**

```powershell
# Check file attributes
Get-Item -Path "$desktopPath\*.lnk" | Select-Object Name, @{Name='Hidden'; Expression={$_.Attributes -band [IO.FileAttributes]::Hidden}}

# Expected: Attributes include "Hidden" flag if hidden
```

### Step 2: Check Recycle Bin for Deleted Files

```powershell
# Query Recycle Bin for recently deleted .lnk files
$recycleRoot = "$env:USERPROFILE\$Recycle.Bin"
Get-ChildItem -Path $recycleRoot -Recurse -Filter "*.lnk" | 
Select-Object Name, CreationTime, LastWriteTime |
Sort-Object LastWriteTime -Descending

# Expected findings:
# A) Recent .lnk files with Friday/Monday timestamps → Deleted during deployment
# B) No .lnk files → Permanently deleted or emptied Recycle Bin
```

### Step 3: Investigate App Installation Script

```powershell
# Examine app installation artifacts

# Check MSI for uninstall string
Get-WmiObject -Class Win32_Product -Filter "Name like '%Document%'" |
Select-Object Name, InstallSource, UninstallString

# Extract and examine installer log
# Typical location: C:\Windows\Logs\MoSetup.log or [App]\setup.log
Get-Content "C:\ProgramData\[AppName]\install.log" -Tail 100 | 
Where-Object { $_ -like "*Desktop*" -or $_ -like "*Remove*" -or $_ -like "*Delete*" }

# Check for leftover installation scripts
Get-ChildItem -Path "C:\Program Files\*Document*" -Recurse -Include "*.ps1", "*.bat", "*.cmd" |
Select-Object FullName

# Examine suspicious scripts for desktop modification
Get-Content -Path "[suspicious script]" | Select-String -Pattern "Desktop|Remove-Item|Set-Item|Icon"
```

### Step 4: Check Group Policy Configuration

```powershell
# Get effective Group Policy applied to user
gpresult /h "C:\Temp\gpresult.html"
# Then search HTML for "Desktop" or "Remove" or "Hide"

# Query registry for policy-applied desktop restrictions
Get-ItemProperty -Path "HKCU:\Software\Policies\Microsoft\Windows\*" -Recurse |
Where-Object { $_.PSObject.Properties.Name -like "*Desktop*" -or $_.PSObject.Properties.Value -like "*Desktop*" } |
Select-Object PSPath, Name, Value

# Check for hidden desktop icons policy
Get-ItemProperty -Path "HKCU:\Software\Policies\Microsoft\Windows\Explorer" -Name "NoDesktop" -ErrorAction SilentlyContinue
# Expected: If NoDesktop = 1, desktop is hidden (policy-based)
```

### Step 5: Analyze User Profile Timestamps

```powershell
# Check when profile was last modified
$profilePath = "C:\Users\[username]"
Get-Item -Path $profilePath | Select-Object CreationTime, LastWriteTime, LastAccessTime

# Check Desktop folder specifically
$desktopPath = "C:\Users\[username]\Desktop"
Get-Item -Path $desktopPath | Select-Object CreationTime, LastWriteTime, LastAccessTime

# Check for profile backups or alternate versions
Get-ChildItem -Path "C:\Users" -Filter "*[username]*" | 
Select-Object Name, CreationTime, LastAccessTime |
Sort-Object CreationTime -Descending

# Expected findings:
# A) Desktop LastWriteTime = Friday 15:00-20:00 → Modified during/after deployment
# B) Multiple profile versions → Profile sync or replacement occurred
```

### Step 6: Check Event Logs for Profile Operations

```powershell
# Check for profile-related events
Get-WinEvent -LogName System -FilterXPath "*[System[TimeCreated[@SystemTime > '2026-08-11T14:00:00Z'] and @SystemTime < '2026-08-12T02:00:00Z']]]" |
Where-Object { $_.Message -like "*Profile*" -or $_.Message -like "*User*" } |
Select-Object TimeCreated, EventId, Message

# Expected event IDs:
# 1509: User profile path not found (profile corruption)
# 1511: User profile initialization failed
# 1515: Removal of cached profile
# 1000: Application error during profile load
```

---

## Root Cause Confirmation Matrix

| Investigation Result | Root Cause | Confidence |
|---|---|---|
| Files hidden (found with -Hidden) | Hidden by policy or app | 85% |
| Files deleted (Recycle Bin found) | App deletion script | 75% |
| Files deleted (Recycle Bin empty) | Permanent deletion by app | 60% |
| App installer has desktop code | App installation script | 80% |
| Group Policy "NoDesktop" = 1 | Group Policy restriction | 95% |
| Desktop LastWriteTime = Friday PM | Profile modified during deployment | 80% |
| Multiple profile versions present | Profile replacement occurred | 70% |

---

## Recovery Options

### Option A: Unhide Files (If Hidden)

**Complexity:** Very Low  
**Success Rate:** 95%  
**Time:** < 5 minutes

```powershell
# Unhide all .lnk files on desktop
$desktopPath = "C:\Users\[username]\Desktop"
Get-Item -Path "$desktopPath\*.lnk" -Hidden |
ForEach-Object {
    Set-ItemProperty -Path $_.FullName -Name Attributes -Value "Normal"
}

# Verify
Get-ChildItem -Path $desktopPath -Filter "*.lnk" | Select-Object Name
```

### Option B: Restore from Recycle Bin (If Present)

**Complexity:** Low  
**Success Rate:** 85%  
**Time:** 5-10 minutes

```powershell
# Restore .lnk files from Recycle Bin
$recycleRoot = "$env:USERPROFILE\$Recycle.Bin"
$lnkFiles = Get-ChildItem -Path $recycleRoot -Recurse -Filter "*.lnk"

foreach ($file in $lnkFiles) {
    # Move back to desktop (note: Recycle Bin files have mangled names)
    # Recommend manual restore via Recycle Bin GUI for accuracy
}

# Better: Manual restore via GUI
# Open Recycle Bin → Search for .lnk files → Right-click → Restore
```

### Option C: Restore from Profile Backup (If Available)

**Complexity:** Medium  
**Success Rate:** 90% (if backup exists)  
**Time:** 15-30 minutes (depending on backup system)

**Prerequisites:**
- Backup system exists (network share, backup solution, cloud storage)
- Pre-deployment backup available
- Backup includes Desktop folder

**Procedure:**

```powershell
# Identify backup location
$backupPath = "\\[backup-server]\User-Backups\[username]\Desktop"

# Verify backup contains shortcuts
Get-ChildItem -Path $backupPath -Filter "*.lnk" | Select-Object Name

# Restore shortcuts (with collision handling)
Copy-Item -Path "$backupPath\*.lnk" -Destination "C:\Users\[username]\Desktop\" -Force

# Verify restoration
Get-ChildItem -Path "C:\Users\[username]\Desktop" -Filter "*.lnk" | Select-Object Name
```

### Option D: Recreate Shortcuts Manually

**Complexity:** Low-Medium  
**Success Rate:** 100% (user recreates what they remember)  
**Time:** 5-15 minutes per user

```powershell
# User runs this script to recreate common shortcuts
$DesktopPath = [Environment]::GetFolderPath("Desktop")
$WshShell = New-Object -ComObject WScript.Shell

# Define common application shortcuts
$Shortcuts = @(
    @{ Name = "Outlook"; Target = "C:\Program Files\Microsoft Office\root\Office16\OUTLOOK.EXE" },
    @{ Name = "Word"; Target = "C:\Program Files\Microsoft Office\root\Office16\WINWORD.EXE" },
    @{ Name = "Excel"; Target = "C:\Program Files\Microsoft Office\root\Office16\EXCEL.EXE" },
    @{ Name = "Teams"; Target = "C:\Program Files\Microsoft\Teams\current\Teams.exe" },
    @{ Name = "File Explorer"; Target = "C:\Windows\explorer.exe"; Arg = "%userprofile%" }
)

foreach ($Shortcut in $Shortcuts) {
    $ShortcutPath = Join-Path $DesktopPath "$($Shortcut.Name).lnk"
    $NewShortcut = $WshShell.CreateShortcut($ShortcutPath)
    $NewShortcut.TargetPath = $Shortcut.Target
    if ($Shortcut.Arg) { $NewShortcut.Arguments = $Shortcut.Arg }
    $NewShortcut.Save()
    Write-Host "Created: $($Shortcut.Name)"
}
```

### Option E: Complete Profile Reset

**Complexity:** High  
**Success Rate:** 100% (creates clean profile)  
**Time:** 30-60 minutes (requires user coordination)

**Use Only If:**
- Backup available for user data recovery
- Other options failed
- Significant profile corruption suspected

**Procedure:**

```powershell
# Step 1: Backup current profile
$userName = "[username]"
$profilePath = "C:\Users\$userName"
$backupPath = "$profilePath" + "_PreReset_$(Get-Date -Format yyyyMMdd)"
Copy-Item -Path $profilePath -Destination $backupPath -Recurse -Force

# Step 2: Rename current profile to force Windows to create new one
# (Requires admin + careful handling)
Rename-Item -Path $profilePath -NewName "$userName.old"

# Step 3: User logs in (Windows creates new clean profile from default)
# (User action: Restart computer, log in normally)

# Step 4: Restore user data from backup
Copy-Item -Path "$backupPath\Documents" -Destination "$profilePath\Documents" -Recurse -Force
Copy-Item -Path "$backupPath\Desktop" -Destination "$profilePath\Desktop" -Recurse -Force
Copy-Item -Path "$backupPath\Downloads" -Destination "$profilePath\Downloads" -Recurse -Force

# Step 5: Delete old profile backup
Remove-Item -Path $backupPath -Recurse -Force
```

---

## Scope Assessment

### Single User vs. Systemic Issue

**Investigation Question:** Does this affect only one user or all Floor 6 users?

**Test Procedure:**

```powershell
# Sample 3-5 Floor 6 user devices and check desktop shortcut counts
$floor6Users = @("FLOOR6-PC-001", "FLOOR6-PC-002", "FLOOR6-PC-003")

foreach ($device in $floor6Users) {
    $desktopPath = "\\$device\c$\Users\*\Desktop"
    $lnkCount = (Get-ChildItem -Path $desktopPath -Filter "*.lnk" -ErrorAction SilentlyContinue | Measure-Object).Count
    Write-Host "$device : $lnkCount shortcuts found"
}

# Expected:
# All devices have similar counts → Random variation (isolated issue)
# All devices have zero shortcuts → Systemic issue (Group Policy or app deletion)
```

**If Systemic (Multiple Users Affected):**
- Escalate to IT Director (requires Floor-6-wide remediation)
- Initiate root cause investigation (app or Group Policy)
- Implement floor-wide recovery (restore all users from backup OR reset all profiles)

**If Isolated (Single User):**
- Offer user self-service recovery (recreate shortcuts)
- OR offer IT profile restoration (faster)
- Document as low-priority incident

---

## Prevention Checklist

**For Future App Deployments:**

```
☐ PROFILE MODIFICATION CHECK
  ☐ Review app installer for desktop folder modifications
  ☐ Search installer for Remove-Item, Delete, Set-ItemProperty commands
  ☐ Verify app doesn't execute profile reset or default profile replacement
  ☐ Sign-off from security team before deployment

☐ GROUP POLICY VERIFICATION
  ☐ Confirm no Group Policy changes affect desktop customization
  ☐ Verify no "Remove desktop icons" or "Hide desktop" policies applied
  ☐ Check that user profile restrictions are not inadvertently enabled

☐ USER PROFILE TESTING
  ☐ Test on device with existing user profile customizations
  ☐ Verify desktop shortcuts survive app deployment
  ☐ Confirm user settings/preferences are preserved

☐ DEPLOYMENT IMPACT ASSESSMENT
  ☐ Desktop customization preserved? ✓ PASS or ✗ FAIL
  ☐ User profile integrity maintained? ✓ PASS or ✗ FAIL
```

---

## Monitoring & Alerts

**Post-Deployment Monitoring:**

```
Alert: User desktop shortcuts disappear after app deployment
├── Trigger: Help Desk ticket contains keywords: "desktop" + "shortcut" + "gone"
├── Severity: LOW
└── Action: Escalate if 2+ users report same issue (indicates systemic)

Preventive: Automated profile integrity check
├── Script: Weekly PowerShell scan of user desktops
├── Alert: If device loses >50% of previous shortcuts
└── Threshold: 2+ devices affected → Escalate to investigation
```

---

## Contact & Documentation

**Incident Reference:** FLR6-003  
**Severity:** LOW (P3)  
**Status:** User self-service / IT recovery options available

**Support Contacts:**
- L1 Help Desk: Extension 555-1234
- L2 Systems Admin: [Contact]
- Profile Management: [Contact]

**Related Incidents:**
- FLR6-001: Copilot data access issue
- FLR6-002: Login failures

**Document Classification:** INTERNAL - Technical Support

---

**Version:** 1.0  
**Last Updated:** 14-Aug-2026  
**Incident Status:** Ongoing (troubleshooting phase)
