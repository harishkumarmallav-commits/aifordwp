# Floor 6 Missing Desktop Shortcuts Runbook

**Title:** Desktop Shortcuts Loss - Profile Investigation & Recovery

**Version:** 1.0

**Date:** 14-Aug-2026

**Status:** Draft (Review before production use)

**Scenario:** Floor 6 user reported desktop shortcuts disappeared following Friday afternoon document management app deployment. Determine scope (isolated vs. systemic), investigate root cause, and execute profile recovery if needed.

**Estimated Duration:** 30-45 minutes (diagnosis + recovery per user)

---

## SECTION 1: BACKGROUND & CONTEXT

### What Happened
Friday 15:00 – Document management application deployed to Floor 6 devices via Intune  
Monday 09:14 – User reported desktop shortcuts disappeared after weekend (discovered Monday morning)  
Monday 10:45 – Incident investigated; unclear if isolated user issue or systemic profile problem

### Why This Matters
- Non-critical but annoying: Users can still access applications via Start menu, search, taskbar
- Reputational impact: Appears as data loss or system instability
- Pattern assessment: Could affect multiple users (scope unknown)
- Recovery straightforward: Desktop customizations easily recreated

### What This Runbook Does
Investigates desktop customization loss:
1. Confirm scope: Isolated user vs. Floor-wide issue
2. Verify shortcuts are actually deleted vs. hidden
3. Investigate root cause: App deletion, Group Policy, profile sync
4. Execute recovery (restore from backup OR recreate shortcuts)
5. Prevent future occurrences

### Approval Required Before Proceeding
- [ ] IT Support Manager approval obtained
- [ ] User consent for device investigation
- [ ] Incident ticket created (reference: FLR6-003)

---

## SECTION 2: PREREQUISITES

### Personnel Required
- **Primary:** IT Support Technician
- **Secondary:** Help Desk staff (for user interviews and coordination)
- **Tertiary:** Systems Administrator (if profile restoration needed)

### Access & Permissions Required
1. **Device Access**
   - Affected user's device available for investigation
   - Device must be accessible remotely via Intune or in-person
   - User can provide logon credentials if needed
   - Access to device's C:\Users folder (administrative)

2. **User Profile & Backup Access**
   - Access to user profile backup location (if available)
   - Backup location: Network shared drive or cloud storage
   - Restore permissions for profile files

3. **Group Policy Management (if applicable)**
   - Can access Group Policy console
   - Can query Group Policy logs for recent changes
   - Can view Group Policy applied to user's device

### Information to Gather Before Starting

**Collect this information immediately:**

1. **Affected User Details**
   - [ ] User name: `_____________________________`
   - [ ] Email: `_____________________________`
   - [ ] Device name: `_____________________________`
   - [ ] Device OS: Windows 10 / Windows 11 / Other: `_____________________________`

2. **Shortcut Details**
   - [ ] Which shortcuts are missing? (List all): `_____________________________`
   - [ ] Are ALL desktop shortcuts gone or just specific ones?: `_____________________________`
   - [ ] When were they last visible? Friday afternoon / Friday evening / Unknown: `_____________________________`
   - [ ] Were shortcuts user-created or system-provided?: `_____________________________`

3. **Device History**
   - [ ] When was device last used by user? (Before shortcuts disappeared): `_____________________________`
   - [ ] Any error messages during startup/login?: YES / NO / UNKNOWN
   - [ ] Any recent device restarts or updates?: YES / NO / UNKNOWN

4. **Scope Assessment Needed**
   - [ ] Have other Floor 6 users reported missing shortcuts?: YES / NO / UNKNOWN
   - [ ] How many other users potentially affected?: `_____________________________`

### System Requirements
- **Workstation:** Administrative console access or Intune remote management
- **Tools:** PowerShell, optional file backup/restore utilities
- **Access:** VPN if accessing remotely
- **Time:** 30-45 minutes per affected user

---

## SECTION 3: INITIAL INVESTIGATION (0-15 minutes)

### Step 1: Interview User (5 minutes)

**Action 1.1 – User Interview Script**

Ask user the following questions (record answers):

1. **Timing & Awareness**
   - When did you first notice the shortcuts were gone? (Exact time if possible)
   - Friday evening, Friday night, or Monday morning when you first saw it?
   - Have you restarted your device since Friday?
   - Any unusual error messages during startup or login?

2. **Scope of Loss**
   - Which specific shortcuts are missing? (Get exact list)
   - Are ALL your desktop icons gone or just some?
   - Do you have icons in the taskbar or Start menu?

3. **Recent Activity**
   - Did you intentionally delete any desktop shortcuts?
   - Did anyone else use your device since Friday?
   - Any software installations or updates that you initiated?

4. **System Behavior**
   - Is everything else working normally (files, applications, etc.)?
   - Any other system oddities or problems noticed?

**Expected Result:** Clear timeline and scope of shortcut loss documented.

---

### Step 2: Verify Shortcuts Are Actually Deleted (5 minutes)

**Action 2.1 – Check for Hidden Files**

Navigate to affected user's device desktop:

1. Open File Explorer
2. Go to: C:\Users\[username]\Desktop
3. Click "View" tab → Check "Hidden items" checkbox
4. Observe: Are missing shortcuts now visible (but hidden)?

**If shortcuts reappear when hidden items shown:**
- Root cause: Group Policy or app set desktop icons to hidden
- Resolution: Simply unhide files (Step 2.2)

**If shortcuts still missing:**
- Root cause: Files are actually deleted
- Resolution: Proceed to recovery (Section 4)

**Action 2.2 – Unhide Files (If Hidden)**

If shortcuts appear when hidden items enabled:

```powershell
# Run on affected device with administrative privileges:

# Option 1: Via File Explorer GUI
# Right-click desktop folder → Properties → Hidden (unchecked) → Apply

# Option 2: Via PowerShell
$desktopPath = "C:\Users\$env:USERNAME\Desktop"
$files = Get-Item -Path "$desktopPath\*" -Hidden
foreach ($file in $files) {
    Set-ItemProperty -Path $file.FullName -Name Attributes -Value "Normal"
    Write-Host "Unhiding: $($file.Name)"
}

# Expected Result: Shortcuts reappear on desktop
```

**Action 2.3 – Check Windows Recycle Bin**

If shortcuts are deleted (not hidden):

1. Open Recycle Bin on affected device
2. Search for shortcut files (.lnk extension)
3. If found: Right-click → Restore
4. If not found: Shortcuts may be permanently deleted or backup needed

**Expected Result:** Shortcuts recovered OR need to proceed to recovery/rebuild.

---

## SECTION 4: ROOT CAUSE INVESTIGATION (5-10 minutes)

### Step 3: Investigate Root Cause

**Action 3.1 – Check Document Management App Installation**

```powershell
# Run on affected device via Intune Run Command:

# Check if app installed any "cleanup" or "profile reset" functionality
$appPath = "C:\Program Files\*Document*", "C:\Program Files (x86)\*Document*"
Get-ChildItem -Path $appPath -Recurse -Include *.ps1, *.bat, *.cmd -ErrorAction SilentlyContinue | 
Select-Object FullName, LastWriteTime

# Look for suspicious scripts that might have deleted shortcuts
# Check app installation logs for any profile modifications
```

**Expected findings:**
- App has initialization script that clears desktop (common in some managed environments)
- App installation included user profile reset or default profile replacement

**Action 3.2 – Check Group Policy for Desktop Customization Changes**

```powershell
# Query Group Policy for recent changes affecting desktop

# Check for policies removing shortcuts or desktop icons:
Get-ChildItem -Path "HKLM:\Software\Policies\Microsoft\Windows\*" -Recurse | 
Where-Object { $_.Name -like "*Desktop*" -or $_.Name -like "*Shortcut*" } | 
Select-Object Name, Property, PSPath

# Expected findings:
# - Policies restricting desktop customization
# - Policies hiding desktop icons
# - Policies enforcing default profile (removes user customizations)

# Check when policy was last updated:
Get-WmiObject Win32_GroupPolicyContainer | Select-Object DisplayName, CreationClassName
```

**Action 3.3 – Check User Profile Sync/Replacement**

```powershell
# Check if user profile was replaced or synced from backup

# View profile directories:
Get-Item "C:\Users\$env:USERNAME*" | Format-Table FullName, CreationTime, LastAccessTime

# Check profile modification timestamps around Friday:
Get-Item "C:\Users\$env:USERNAME\Desktop" | Select-Object Name, CreationTime, LastWriteTime

# If LastWriteTime = Friday afternoon after deployment: 
# → Likely profile was replaced or reset by app deployment process
```

**Action 3.4 – Check Device Event Logs**

```powershell
# Run on affected device via Intune Run Command:

# Check System and Application event logs for profile-related events
Get-WinEvent -LogName System -FilterXPath "*[System[TimeCreated[@SystemTime > '$([DateTime]::Now.AddDays(-2).ToUniversalTime().ToString('o'))']]]" | 
Where-Object { $_.Message -like "*Profile*" -or $_.Message -like "*User Data*" } | 
Select-Object TimeCreated, EventId, Message | 
Format-List

# Expected findings:
# Event ID 1509: User profile path not found (profile corruption)
# Event ID 1509: Default profile replaced (indicates profile reset)
```

**Expected Result:** Root cause identified as app-related, policy-related, or profile-sync-related.

---

## SECTION 5: RESOLUTION OPTIONS

### Step 4: Execute Recovery (Choose Appropriate Option)

---

### OPTION A: Simple Rebuild (If Only Few Shortcuts Missing)

**Objective:** Manually recreate missing shortcuts

**Action 4A.1 – Recreate Shortcuts Manually**

For each missing shortcut:

1. Locate the application or file
2. Right-click → Send to → Desktop (shortcut)
3. Rename if needed

**If building many shortcuts:**
```powershell
# PowerShell script to create shortcuts for common applications

$DesktopPath = [Environment]::GetFolderPath("Desktop")

# Common applications to recreate shortcuts
$Apps = @(
    @{ Name = "Outlook"; Target = "C:\Program Files\Microsoft Office\Office16\OUTLOOK.EXE" },
    @{ Name = "Word"; Target = "C:\Program Files\Microsoft Office\Office16\WINWORD.EXE" },
    @{ Name = "Excel"; Target = "C:\Program Files\Microsoft Office\Office16\EXCEL.EXE" },
    @{ Name = "File Explorer"; Target = "C:\Windows\explorer.exe"; Arg = "%userprofile%" }
)

foreach ($App in $Apps) {
    $ShortcutPath = Join-Path $DesktopPath "$($App.Name).lnk"
    $WshShell = New-Object -ComObject WScript.Shell
    $Shortcut = $WshShell.CreateShortcut($ShortcutPath)
    $Shortcut.TargetPath = $App.Target
    if ($App.Arg) { $Shortcut.Arguments = $App.Arg }
    $Shortcut.Save()
    Write-Host "Created shortcut: $($App.Name)"
}
```

**Expected Result:** Shortcuts recreated and visible on desktop.

---

### OPTION B: Profile Restore (If Backup Available)

**Objective:** Restore user profile from pre-deployment backup

**Prerequisite:** Organization maintains user profile backups

**Action 4B.1 – Initiate Profile Restore**

```powershell
# If your organization has profile backup system:

# Step 1: Locate pre-Friday backup of user profile
$BackupPath = "\\[backup-server]\User-Profiles\Backups\$env:USERNAME"
Get-ChildItem -Path $BackupPath -Filter "*Friday*" | 
Select-Object FullName, CreationTime

# Step 2: Compare desktop content from backup
$BackupDesktop = "\\[backup-server]\User-Profiles\Backups\$env:USERNAME\Desktop"
Get-ChildItem -Path $BackupDesktop | Select-Object Name

# Step 3: If pre-deployment backup contains shortcuts:
# Restore shortcuts from backup to current profile

Copy-Item -Path "$BackupDesktop\*.lnk" `
          -Destination "C:\Users\$env:USERNAME\Desktop\" `
          -Force

Write-Host "Shortcuts restored from backup"

# Expected Result: Shortcuts restored to their pre-deployment state
```

**Caution:** Before restoring, verify backup doesn't contain any corrupted or outdated configurations.

---

### OPTION C: Revert Profile to Default (If Systematic Issue)

**Objective:** Replace corrupted profile with clean default, then restore user data

**Use this option if:** Multiple users affected or user's entire profile seems corrupted

**Action 4C.1 – Create New Default Profile for User**

```powershell
# WARNING: This is destructive. Only use if backup available and user understands impact.

# Step 1: Backup current profile
$UserProfile = "C:\Users\$env:USERNAME"
Copy-Item -Path $UserProfile -Destination "C:\Users\$($env:USERNAME)_Backup_$(Get-Date -Format yyyyMMdd)" -Recurse

# Step 2: Delete corrupted profile
Remove-Item -Path $UserProfile -Recurse -Force

# Step 3: User logs in again (Windows creates new default profile from system default)
# User should log out and log back in

# Step 4: Restore user data from backup (Documents, Pictures, etc.)
Copy-Item -Path "$($env:USERNAME)_Backup_*\Documents" -Destination "$UserProfile\Documents" -Recurse -Force
Copy-Item -Path "$($env:USERNAME)_Backup_*\Desktop" -Destination "$UserProfile\Desktop" -Recurse -Force
```

**Expected Result:** Fresh profile created with proper defaults and user shortcuts recreated or restored.

---

## SECTION 6: SCOPE ASSESSMENT - Is This Floor-Wide?

### Step 5: Check if Other Floor 6 Users Affected

**Action 5.1 – Query Help Desk for Similar Reports**

Contact Help Desk:
- "Have any other Floor 6 users reported missing shortcuts this morning?"
- "Pull tickets from last 24 hours with keyword 'desktop' or 'shortcut'"

**Action 5.2 – Proactive Testing**

```powershell
# Test 2-3 other Floor 6 user devices
# Check if their desktop shortcuts are intact or missing

# Sample Floor 6 devices: [Device1], [Device2], [Device3]
# For each device, remotely check:

$Device = "[Floor6Device]"
$DesktopPath = "\\$Device\c$\Users\[username]\Desktop"
$Shortcuts = Get-ChildItem -Path $DesktopPath -Filter "*.lnk"
$ShortcutCount = $Shortcuts.Count
Write-Host "$Device has $ShortcutCount shortcuts"
```

**If one user only:**
- Scope: Isolated
- Cause: Likely user-initiated deletion or account-specific profile issue
- Escalation: Not required (resolve individual user)

**If multiple users affected:**
- Scope: Systemic
- Cause: Likely app deployment or Group Policy change
- Escalation: Escalate to IT Director for Floor-wide resolution

---

## SECTION 7: ROOT CAUSE REMEDIATION

### If Document Management App Caused Deletion:

**Action 7.1 – Disable App Profile Modification (If Possible)**

Consult app documentation:
- Does app have configuration option to skip desktop customization?
- Can app's "first-run" profile reset be disabled?
- Can app's startup script be modified to exclude desktop operations?

**Action 7.2 – If Necessary, Rollback App**

If app continues to delete user desktop customizations:
- Initiate emergency app rollback (see FLR6-AUTH-002 Runbook, Section 3)
- Redeploy app with profile modification disabled or app version that doesn't delete shortcuts

---

## SECTION 8: DOCUMENTATION & PREVENTION

### Step 6: Document Incident

**Action 6.1 – Update Incident Ticket**

```
Ticket ID: FLR6-003
Status: RESOLVED (or ESCALATED if systemic)

Incident: User desktop shortcuts disappeared following Friday app deployment
Root Cause: [app deletion / Group Policy / profile replacement / user error]
Scope: [1 user / multiple users on Floor 6 / floor-wide]

Resolution Taken:
- [Profile recovery / Shortcut rebuild / Policy correction]
- User confirmed shortcuts restored
- Desktop productivity restored

If systemic (multiple users):
  Escalation: Requires Floor-wide remediation
  Recommended action: Investigate app deployment or policy change
  Prevention: Add desktop preservation to deployment testing checklist
```

**Action 6.2 – Prevention for Future Deployments**

```
Update deployment procedures:
1. Add test: Verify app does NOT delete or modify user desktop customizations
2. Add test: Verify app does NOT restrict desktop icon display via policy
3. Add test: Verify user profile is preserved during installation
4. Deployment checklist: "Desktop customizations preserved?" → MUST PASS
```

---

## APPENDIX: QUICK REFERENCE

**Escalation Contacts:**
- IT Help Desk: [Contact]
- IT Director: [Contact]
- Profile Administration: [Contact]

**Key File Paths:**
- User Desktop: C:\Users\[username]\Desktop
- Desktop Backup (if applicable): \\[backup-server]\User-Profiles\Backups\[username]\Desktop
- Group Policy location: C:\Windows\System32\GroupPolicy

**Quick Checks:**
1. Hidden files check: View tab → Hidden items checkbox
2. Recycle Bin check: Restore recently deleted .lnk files
3. Group Policy check: HKLM\Software\Policies\Microsoft\Windows\*
4. App scripts check: C:\Program Files\*Document*\*.ps1, *.bat, *.cmd

**Success Criteria:**
✓ Shortcuts visible and accessible on user desktop
✓ All expected applications/files accessible from shortcuts
✓ No hidden files or Group Policy restricting desktop icons
✓ User confirms productivity restored
