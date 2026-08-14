# Floor 6 Application Deployment Rollback - L2/L3 Technical Knowledge Article

**Title:** Floor 6 Document Management Application - Emergency Deployment Rollback  
**Version:** 1.0  
**Date:** 14-Aug-2026  
**Audience:** L2/L3 Support, Intune Administrators, IT Support Technicians  
**Status:** Technical Reference for Incident #FLR6-002

---

## Background

On Friday 15:00, Document Management Application (exact name: `[Document Management]`) was deployed via Intune to the Floor 6 Users group with assignment type "Assigned".

Monday 09:14 – 12+ users on Floor 6 reported login failures and extreme slowness (60+ second login times). Investigation identified root cause: application startup process configured in Windows startup sequence (likely HKLM\Software\Microsoft\Windows\CurrentVersion\Run or scheduled task at login phase) causing login process hang.

**Business Impact:**
- 12+ users unable to access systems
- Downtime cost: $900+/hour
- 36-48 hour incident incubation (Friday 15:00 → Monday 09:14)
- Rollback selected as faster remediation than troubleshooting deployment issues

---

## Symptoms

**Primary Indicators:**
- Login failures on Floor 6 devices (100% of affected Floor 6 Users group)
- Login timeouts or extreme delays (60+ seconds from credential entry to desktop)
- Users report "login hangs" or "stuck on loading screen"
- Desktop shortcuts missing after successful login (indicates profile corruption/incomplete sync)

**Secondary Indicators:**
- Intermittent symptom appearance (some users within Floor 6 affected, others unaffected - suggests staggered deployment rollout)
- Symptom timing correlation with Friday afternoon deployment (15:00) and Monday morning login attempts (09:14)

**Absence of:**
- Application crashes or error dialogs (application doesn't fail, just hangs)
- Authentication errors (Kerberos/NTLM still working, but delayed)
- Network connectivity issues (devices can connect, but login process blocked)

---

## Root Cause

**Confirmed Root Cause:** Document Management Application initialization process interferes with Windows login startup sequence.

**Technical Mechanism:**
- Application has registry entry or scheduled task configured at Windows startup/login phase
- Registry Location (suspected): `HKLM\Software\Microsoft\Windows\CurrentVersion\Run` (system-wide startup)
- Alternative: Scheduled task triggered at user login with no timeout handling
- Application initialization takes 60+ seconds or enters infinite loop
- Windows login process (SAM authentication, profile loading, logon scripts) waits for app initialization to complete
- Results in user-visible "stuck login" experience

**Why This Hypothesis (Ranked #1 - 70-80% confidence from runbook):**
- Temporal correlation: Deployment Friday 15:00 → Issues Monday 09:14 (fits staggered device sync + Monday morning login surge)
- Geographic/scope correlation: Only Floor 6 Users group affected (app targeted to exact group)
- Deployment causation: Issue did not exist Friday afternoon; exists Monday morning post-deployment
- Fastest check validates hypothesis (5-10 minutes): Query event logs for uninstall events; verify app removal correlates with login speed recovery

---

## Detection

### 4.1 Event Log Analysis

**Windows Event Log Locations & Event IDs:**

**Login-Related Events (Event Viewer → Windows Logs → Security):**
- Event ID 4624: Successful logon (check for delays in event timestamp succession)
- Event ID 4625: Failed logon attempt (check for patterns during 09:14-10:30 window)
- Event ID 4768: Kerberos TGT request (check for timeouts or retries)
- Event ID 4769: Kerberos service ticket request (check for delays)

**Application Installation/Uninstallation (Event Viewer → Windows Logs → System):**
- Event ID 11707: Successful software uninstall
  - **Search criteria:** Provider = "MsiInstaller", EventID = 11707, TimeCreated > [deployment time]
  - **Expected finding:** Should appear on Floor 6 devices 5-30 minutes after Intune assignment removal
  - **Forensic value:** Confirms Intune policy reached device and app uninstalled successfully

**System/Application Performance (Event Viewer → Applications and Services Logs → Microsoft-Windows-Diagnostics-Performance):**
- Check for "Fast User Switch" or "Logon" performance logs during incident window
- Events showing extended logon times (>60 seconds) may indicate app hanging during initialization

**Startup Process (Event Viewer → Windows Logs → System):**
- Event ID 4016: Service startup
- Event ID 7000: Driver load failed (check if app driver caused issues)

### 4.2 Validation Checks (PowerShell)

**Check 1: Verify App Installation Status on Device**
```powershell
# Run with admin privileges on target device
# Should return app details if installed; returns nothing if uninstalled

Get-WmiObject -Class Win32_Product | Where-Object { $_.Name -like "*Document*" }

# Expected Output (if app installed):
# Name                : Document Management Application
# Vendor              : [Company Name]
# Version             : [Version Number]
# InstallDate         : 20260815
#
# Expected Output (if uninstalled):
# (blank - no results)
```

**Check 2: Verify App is Not Running**
```powershell
# Check for running app processes
Get-Process | Where-Object { $_.Name -like "*Document*" -or $_.ProcessName -like "*DocMgmt*" }

# Expected Output (after uninstall):
# (blank - no results)
```

**Check 3: Verify App Startup Registry Entry (if suspected)**
```powershell
# Check system startup registry for app entry
Get-Item -Path 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Run' -ErrorAction SilentlyContinue | Get-ItemProperty | Select-Object *

# Look for app name in results
# Expected (if app uninstalled): App name should not appear

# Alternative: Check user startup
Get-Item -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run' -ErrorAction SilentlyContinue | Get-ItemProperty | Select-Object *
```

**Check 4: Verify Scheduled Tasks**
```powershell
# List all scheduled tasks with app name
Get-ScheduledTask | Where-Object { $_.TaskPath -like "*Document*" -or $_.TaskName -like "*Document*" }

# Expected (if uninstalled):
# (blank - no results)
```

**Check 5: Monitor System Performance During Login**
```powershell
# Collect performance metrics (CPU, Memory, Disk) at login
# On test device, ask user to log in while monitoring:
# Task Manager: Performance tab
#   - CPU usage: Should NOT stay >40% during login
#   - Memory: Should stabilize at 2-3 GB (not continuously increasing)
#   - Disk I/O: Should NOT stay >20% busy

# PowerShell performance baseline (optional):
Get-Counter -Counter "\Processor(_Total)\% Processor Time" -SampleInterval 1 -MaxSamples 30
Get-Counter -Counter "\Memory\% Committed Bytes In Use" -SampleInterval 1 -MaxSamples 30
```

### 4.3 Intune Portal Validation Paths

**Portal Access:**
- **Primary Console:** https://intune.microsoft.com/
- **Authentication:** Azure AD tenant credentials + MFA required
- **Required Role:** Global Admin or Intune Service Administrator

**Navigate to App Details:**
1. Left sidebar → **Apps**
2. Click → **Windows apps** (submenu under Apps)
3. Search box → Type "Document Management"
4. Click app name → Opens app details page

**Verify Current Assignment:**
- On app details page, click → **Assignments** tab
- **Expected state (before removal):**
  - Floor 6 Users group listed with status "Assigned"
  - NO "All Devices" or "Company" assignments (confirms scope limit)
  - Assignment Type shows "Assigned" or "Required"
- **Expected state (after removal):**
  - Floor 6 Users group NOT listed
  - Assignments table empty (or shows only other unrelated assignments)

**Monitor Device Sync Status:**
1. Left sidebar → **Devices**
2. Click → **Monitor** (submenu)
3. Click → **Device compliance**
4. Filter by location "Floor 6" (if available) or search "FLOOR6-*"
5. **Check for each device:**
   - **Last sync time:** Should show recent timestamp (within 5-10 minutes of current time)
   - **Compliance status:** Should show "Compliant" (not "Non-Compliant" or "Error")
   - **Expected timeline:** 80%+ of Floor 6 devices should sync within 30 minutes post-removal

**Force Device Sync (if needed):**
- Click individual device name → Device details page
- Click **Sync** button (top right)
- Confirmation message appears: "Sync initiated"
- Wait 5-10 minutes; refresh page to see updated "Last sync time"

---

## Resolution

### 5.1 Prerequisites Verification

**Access Control:**
- Operator must have: Global Admin OR Intune Service Administrator role
- Verification: Can access https://intune.microsoft.com/ without "Access Denied" error
- **Escalation trigger:** If insufficient permissions, request temporary elevation from IT Director (5-10 minute wait)

**Device Eligibility:**
- Floor 6 devices must be Intune-enrolled (check via Device compliance dashboard)
- Devices must have internet connectivity
- Device health dashboard must show devices in "Compliant" or "Not Applicable" state (not "Failed")

**Information Gathering (Pre-Flight):**
- [ ] Exact app name in Intune: "Document Management" or variant from change ticket
- [ ] Confirm assignment target: "Floor 6 Users" group ONLY
- [ ] Sample test device: FLOOR6-PC-001 (or similar device from Floor 6)
- [ ] Sample test user: Contact person on test device
- [ ] Incident ticket number: FLR6-002

### 5.2 Removal Procedure (6 Steps)

**Step 1: Access App in Intune Portal (5 minutes)**
- Navigate: https://intune.microsoft.com/ → Apps → Windows apps
- Search: "Document Management"
- Click app name to open details page
- Verification: Breadcrumb shows "Apps > Windows apps > [App Name]"

**Step 2: Verify Current Assignment (3 minutes)**
- Click: Assignments tab
- Scan for: "Floor 6 Users" group in assignment table
- **CRITICAL CHECK:** Verify NO "All Devices" or "Company" assignments exist
  - If broader assignments found: **STOP** → Escalate to Intune admin before proceeding
- Screenshot before state for audit trail: `Intune-Floor6App-Assignment-Before.png`

**Step 3: Remove Floor 6 Assignment (5 minutes)**
- Click: Edit button (Assignments section)
- Find: "Floor 6 Users" row
- Click: Remove/Delete button at end of row
- Confirm dialog if prompted
- Click: Save button
- Verification: Confirmation message "Assignment updated"; Floor 6 Users no longer visible
- Screenshot after state: `Intune-Floor6App-Assignment-After.png`

**Step 4: Monitor Device Sync (10-15 minutes)**
- Navigate: Devices → Monitor → Device compliance
- Filter/search for Floor 6 devices (FLOOR6-* or "Floor 6" location)
- Observe: Last sync timestamp for each device
- If sync >30 minutes delayed:
  - Click device name
  - Click Sync button
  - Wait 5-10 minutes
- **Success metric:** 80%+ of Floor 6 devices show sync within last 10 minutes

**Step 5: Verify Application Uninstallation (10 minutes)**
- Contact sample device user
- User verification method: Settings → Apps → Apps & features → Search "Document Management"
  - Expected: App NOT listed (uninstalled)
- PowerShell verification (if remote access available):
  ```powershell
  Get-WmiObject -Class Win32_Product | Where-Object { $_.Name -like "*Document*" }
  ```
  - Expected: No results (blank)
- Event log verification (optional): Event Viewer → System → Event ID 11707 (uninstall success)

**Step 6: Test Login Functionality (10 minutes)**
- Contact sample device user
- Ask user to log out and log back in (or wait until next boot)
- Measure/report login time (should be 20-60 seconds, not 60+ seconds)
- Contact batch of 5-10 Floor 6 users
- Collect results: Success/Failure, approximate login time per user
- Expected: 100% success rate, all login times <60 seconds

### 5.3 Timing & Escalation Triggers

**Timeline Targets (45-60 minute total):**
- Step 1: 5 min
- Step 2: 3 min
- Step 3: 5 min
- Step 4: 10-15 min (LONGEST STEP - device sync inherent delay)
- Step 5: 10 min
- Step 6: 10 min

**Escalation Triggers (Stop and Escalate to Level 2 if):**
- Cannot access Intune (permissions)
- Cannot locate Document Management app (name unknown)
- Device sync still pending after 30 minutes (>20% devices not synced)
- App still installed after 1 hour on sample device
- More than 2 users report login still failing after 1 hour
- Discover app assigned beyond Floor 6 (unintended scope)
- Any unexpected error message appears

**Escalation Contact (Level 2):**
- Title: Intune Administrator
- Expected response time: 5 minutes

---

## Verification

### 6.1 Core Success Criteria (All Four Must Pass)

**Criterion 1: Application Successfully Uninstalled (Metric: 100% of tested devices)**
- Verification Method 1: User reports app NOT in Settings → Apps → Apps & features
- Verification Method 2: PowerShell returns no results for `Get-WmiObject -Class Win32_Product | Where-Object { $_.Name -like "*Document*" }`
- Verification Method 3: Event Viewer shows Event ID 11707 (successful uninstall) in System log within 30 minutes of assignment removal
- **Pass Criteria:** At least 2 of 3 verification methods confirm uninstall

**Criterion 2: Login Functionality Restored (Metric: 0 failures, <60 second login time)**
- Sample device user: Successfully logs in with normal credentials
- Batch test (5-10 users): 100% report successful login
- Login speed: Average 20-60 seconds (return to baseline before incident)
- Error logs: No authentication errors (Event ID 4625 - failed logons) post-remediation
- **Pass Criteria:** Sample + batch both show 100% success, no error events

**Criterion 3: System Performance Normalized (Metric: CPU/Disk/Memory within baseline)**
- CPU usage during login: <40% peak (not sustained 80-100%)
- Disk I/O during login: <20% busy time (not sustained high)
- Memory usage post-login: 2-3 GB stable (not continuously increasing)
- Device compliance dashboard: Shows "Compliant" status for 90%+ of Floor 6 devices
- **Pass Criteria:** All 4 performance metrics within acceptable range

**Criterion 4: No Unintended Collateral Damage (Metric: Only Floor 6 devices affected)**
- Scope verification: Devices from other floors NOT affected by removal
- Application scope: Only Document Management app removed (no other apps uninstalled)
- Device health: No unexpected "Non-Compliant" status on devices outside Floor 6
- Assignment verification: Review Intune console to confirm Floor 6 assignment cleanly removed
- **Pass Criteria:** All 4 scope checks confirm Floor 6-only impact

### 6.2 Detailed Verification Checklist (Post-Remediation)

**Performance Dashboard Checks:**
- [ ] Intune dashboard shows 0 device errors for Floor 6 cohort
- [ ] Device compliance page shows 90%+ "Compliant" status
- [ ] Last sync timestamps show recent activity (within 15 minutes current time)

**Application Verification Checks:**
- [ ] Sample device: App confirmed uninstalled (user visual confirmation)
- [ ] Sample device: App shortcuts NOT on desktop
- [ ] Event Viewer: Event ID 11707 present in System log
- [ ] PowerShell: No running processes matching app name (Get-Process)

**Login Functionality Checks:**
- [ ] 5-10 test users report successful login
- [ ] Average login time: 20-60 seconds per user
- [ ] Event Viewer: No Event ID 4625 (failed logon) errors in Security log
- [ ] No "account locked" or "authentication timeout" reports from users

**Communication & Handoff Checks:**
- [ ] All-clear notification drafted and ready to send to Floor 6
- [ ] Help Desk briefed on issue resolution and closure criteria
- [ ] Incident ticket FLR6-002 updated with resolution details
- [ ] Screenshots collected and archived: Assignment-Before, Assignment-After, Device-Sync-Status

---

## Rollback

### 7.1 Rollback Scenario & Decision Points

**Use Rollback Procedure ONLY if:**
- Assignment removal affected devices beyond Floor 6 (unintended scope)
- Critical business process requires Document Management app immediately (cannot wait for permanent fix)
- Wrong application was removed (misidentification)
- User or business demands app restoration pending investigation

**Do NOT use Rollback if:**
- Issue is simply taking longer than expected to resolve (wait 1-2 hours)
- Individual user requests app back (defer to business owner decision)
- Device sync delays appear to be cause (wait additional 30 minutes)

### 7.2 Rollback Restoration Procedure

**Restore Floor 6 Assignment (Reverse of Step 3):**

1. Navigate: https://intune.microsoft.com/ → Apps → Windows apps
2. Search: "Document Management"
3. Click app name → Open details
4. Click: Assignments tab
5. Click: Edit button
6. Click: Add Groups (or Add Assignment button)
7. Search: "Floor 6 Users"
8. Select checkbox for Floor 6 Users group
9. Assignment Type: Select "Assigned" (or match original state)
10. Click: Save / Select button
11. Confirmation message: "Assignment updated"
12. Navigate: Devices → Monitor → Device compliance
13. Filter Floor 6 devices
14. Observe: Device sync should occur within 15-30 minutes
15. Verify: Devices show recent last sync timestamp

**Expected Result:** App begins reinstalling on Floor 6 devices within 30 minutes

### 7.3 Post-Rollback Communication

**Notify users that app restoration is underway:**
```
Subject: Floor 6 - Application Restored [Incident #FLR6-002]

The Document Management application is being restored to Floor 6 devices.

REASON: Additional investigation needed before permanent fix.

EXPECTED TIMELINE: App will be restored by [TIME] today.

IMPORTANT: You may experience login delays temporarily while we investigate 
the root cause. Thank you for your patience.

We will provide an update by [DATE] with permanent solution.
```

### 7.4 Post-Rollback Escalation

**Immediately after Rollback:**
- Escalate to IT Director (Level 3)
- Escalate to Application Owner (identify root cause of app startup interference)
- Request emergency fix for app startup behavior

**Do NOT leave system in Rollback state:**
- Rollback restores the BROKEN configuration
- This is temporary measure only
- Root cause MUST be fixed before returning to normal

---

## Prevention

### 8.1 Application Pre-Deployment Validation Checklist

**Before deploying ANY app to production via Intune:**

**Technical Review (Required):**
- [ ] Application startup mechanism documented (registry, scheduled task, service)
- [ ] Startup location (HKLM vs HKCU) specified and justified
- [ ] Initialization timeout maximum specified (must be <10 seconds)
- [ ] Login phase startup disabled or deferred until post-login
- [ ] Application does NOT block Windows login process
- [ ] Test: Device rebooted; login time measured (baseline <30 seconds)

**Deployment Staging (Required):**
- [ ] App first deployed to test group (not production cohort)
- [ ] Test group includes 5-10 devices with diverse hardware (laptop, desktop, different CPU tiers)
- [ ] 24-hour observation period for stability
- [ ] Login time verification on test devices
- [ ] Event log analysis for errors during startup
- [ ] Test group users report "no issues" before production deployment

**Change Management (Required):**
- [ ] Change ticket filed 5+ business days before deployment
- [ ] Risk assessment document includes: "Login interference risk: Y/N"
- [ ] Rollback plan documented in change ticket (procedure to remove via Intune)
- [ ] Approval from application owner + IT operations
- [ ] Deployment window chosen for off-peak time (not Monday morning)

**Deployment Monitoring (Required):**
- [ ] First hour: Help Desk on alert; users instructed to report login issues immediately
- [ ] Performance dashboard monitored: CPU/Disk/Memory during deployment window
- [ ] Event logs monitored: Check for errors within 30 minutes post-deployment
- [ ] Escalation trigger: >1 login issue report triggers rollback decision

### 8.2 Monitoring & Detection Enhancement

**Post-Incident Recommendations (implement after incident closes):**

1. **Intune Assignment Scope Validation:**
   - Policy: All app assignments must explicitly specify scope (Floor 6 Users, specific group)
   - No "All Devices" assignments except security/compliance apps
   - Assignment review: Quarterly audit of app targeting

2. **Startup Monitoring:**
   - Baseline login time per device type captured in asset management system
   - Alert if device login time exceeds baseline by >30 seconds
   - Automated detection: If Event 4624 (logon success) timestamp > baseline, trigger alert

3. **Event Log Monitoring:**
   - Query Event ID 4625 (failed logons) every 15 minutes
   - Alert if failed logon count spikes (>5 failures in 15 minutes for single user/device)
   - Query Event ID 11707 (uninstall) to track app removal events

4. **Application Vetting:**
   - Maintain registry of "approved" startup locations
   - Any new startup location requires IT security review
   - Automated scan: Monthly audit of production devices for unexpected registry run keys

---

## Related Documents

**Part of Floor 6 Incident Response Framework (Incident #FLR6-002):**

1. **[Triage-FLR6-AUTH-002-Login-Failures.md](Triage-FLR6-AUTH-002-Login-Failures.md)**
   - Purpose: Initial triage investigation framework for 12+ login failures
   - Contains: Known facts, missing information, 8 investigation checks, evidence checklist
   - Audience: L1/L2 Initial Responders

2. **[Triage-FLR6-PROF-003-Missing-Shortcuts.md](Triage-FLR6-PROF-003-Missing-Shortcuts.md)**
   - Purpose: Investigation framework for desktop profile corruption (missing shortcuts)
   - Contains: Profile investigation procedures, recovery options
   - Audience: Desktop Support, User Recovery Technicians

3. **[03-Ranked-Differential.md](03-Ranked-Differential.md)**
   - Purpose: Root cause hypothesis ranking (5 hypotheses ranked by probability)
   - Contains: Temporal correlation analysis, fastest-check procedures, confidence levels
   - Audience: Investigation Leadership

4. **[03a-PowerShell-Evidence-Collection.md](03a-PowerShell-Evidence-Collection.md)**
   - Purpose: Production-ready PowerShell evidence collection script
   - Contains: Startup programs inventory, scheduled tasks, filtered event logs, JSON export
   - Audience: L2/L3 Forensic Investigators

5. **[04-Immediate-Fix.md](04-Immediate-Fix.md)**
   - Purpose: Operational response plan with containment, remediation, verification
   - Contains: Risk assessment matrix, communication templates, metrics
   - Audience: IT Operations Leadership, Incident Commanders

6. **[04a-Runbook.md](04a-Runbook.md)**
   - Purpose: Complete step-by-step operational runbook for junior technicians
   - Contains: 6-step procedure, troubleshooting, escalation paths, screenshots
   - Audience: Help Desk, L1/L2 Technicians

7. **[04b-L1-KB.md](04b-L1-KB.md)**
   - Purpose: End-user self-service knowledge article (170 words, plain language)
   - Contains: What happened, what IT is doing, no user action needed, Service Desk contact
   - Audience: Floor 6 End Users

---

## Appendix: Advanced Troubleshooting

### A.1 Registry Analysis (Advanced)

**If PowerShell method insufficient, direct registry inspection:**

**Suspected Startup Location:**
```
Registry Path: HKLM\Software\Microsoft\Windows\CurrentVersion\Run
Registry Path: HKLM\Software\Microsoft\Windows\CurrentVersion\RunOnce
Registry Path: HKCU\Software\Microsoft\Windows\CurrentVersion\Run (per-user)
```

**Investigation Procedure:**
1. On affected device, open Registry Editor (regedit.exe)
2. Navigate to: `HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Run`
3. Right-click → Export → Save as "Run-Keys-Before.reg"
4. After app uninstall, repeat export → Save as "Run-Keys-After.reg"
5. Compare files to confirm app entry removed
6. Share .reg files with Intune admin for forensic review

**Interpretation:**
- Entry format: `"AppName" = "C:\Path\To\Executable.exe" [args]`
- If entry present before uninstall and absent after → Confirms successful removal

### A.2 Scheduled Task Analysis (Advanced)

**If app configured as scheduled task (not registry run key):**

```powershell
# List all scheduled tasks
Get-ScheduledTask | Select-Object TaskPath, TaskName, State | Format-Table

# Find tasks containing "Document" or app name
Get-ScheduledTask | Where-Object { $_.TaskPath -like "*Document*" -or $_.TaskName -like "*Document*" }

# Deep inspection of suspect task
Get-ScheduledTask -TaskName "Suspected-Task-Name" | Get-ScheduledTaskInfo

# Export task details for review
Get-ScheduledTask -TaskName "Suspected-Task-Name" | Export-ScheduledTask > C:\task-export.xml
```

**Interpretation:**
- Look for trigger conditions: "At logon", "At startup"
- Look for action: Executable path and arguments
- Timeout setting: If <10 seconds and app needs more time → Can cause hang

### A.3 WMI Event Monitoring (Advanced)

**Real-time monitoring of app installation/removal events:**

```powershell
# Create listener for MSI events
$query = "SELECT * FROM __InstanceCreationEvent WITHIN 1 WHERE TargetInstance ISA 'Win32_Product'"
Register-WmiEvent -Query $query -Action {
    Write-Host "App Event: $($Event.SourceEventArgs.NewEvent.TargetInstance.Name)"
}

# This runs continuously and logs any app installation/removal events
# Useful for monitoring rollback during Intune sync
```

---

**END OF TECHNICAL KB ARTICLE**

**Document Version:** 1.0  
**Last Updated:** 14-Aug-2026  
**Next Review:** 21-Aug-2026  
**Technical Review Status:** DRAFT (Review before publication)
