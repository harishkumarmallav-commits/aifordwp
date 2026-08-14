# Immediate Response & Containment Plan
## Floor 6 Document Management App Deployment Issue
**Issue IDs:** FLR6-AUTH-002 + FLR6-PROF-003  
**Root Cause:** Friday document management app deployment (Hypothesis #1 confirmed)  
**Severity:** HIGH – 12+ users unable to log in, profile corruption reported  
**Status:** ACTIVE REMEDIATION  
**Timeline:** Deployment Friday 15:00 | Issues discovered Monday 09:14 | Response initiated Monday 10:30

---

## EXECUTIVE DECISION AUTHORITY

**Decision:** Rollback document management app deployment to Floor 6 devices

**Rationale:**
- Evidence collection confirmed app is in login startup path
- App initialization hangs during login process (causing login delays/failures)
- App modifies user profile during startup (causing shortcut loss)
- Single root cause identified; single remediation path available
- Rollback is faster than troubleshooting and fixing deployment issues
- Business impact: $900+/hour per hour of continued downtime
- Risk: Rollback is lower risk than continued investigation during outage

**Approval Chain:** [IT Director approval required before executing]

---

## SECTION 1: IMMEDIATE CONTAINMENT ACTIONS (0-15 minutes)

### ACTION 1.1: ISOLATE AFFECTED DEVICES FROM ROLLOUT
**Owner:** Intune Administrator  
**Timeline:** 5 minutes  
**Reasoning:** Prevent app deployment from spreading to additional devices (currently Floor 6 only)

**Steps:**
1. Log into Intune Admin Center: https://intune.microsoft.com/
2. Navigate to: **Devices** → **Windows** → **Configuration profiles**
3. Search for: "Floor 6" or deployment-related policy name
4. Find the document management app deployment policy
   - Typical path: Policies → "Document Management App - Floor 6"
   - Or: **Apps** → **Windows apps** → [App name]
5. Select the policy/app deployment
6. Click **Edit** (or **Properties** → **Edit**)
7. Navigate to **Assignments** tab
8. Check current assignment:
   - Should show "Floor 6 Users" group or "Floor 6 Devices" collection
9. **DO NOT REMOVE YET** – Document current state first (screenshot for audit trail)
10. Confirm: Are ONLY Floor 6 devices assigned? If not, investigate further assignments

**Success Criteria:**
- [ ] Policy identified and documented
- [ ] Current assignments verified
- [ ] No additional floors/users added to deployment accidentally

**Evidence to Preserve:**
- Screenshot of assignment configuration
- Screenshot of deployment schedule
- Record of who is assigned and how many devices

---

### ACTION 1.2: COMMUNICATE INCIDENT TO AFFECTED USERS
**Owner:** IT Support Manager / Communications  
**Timeline:** 5 minutes (parallel with 1.1)  
**Reasoning:** Users experiencing login failures need immediate status update; reduces panic/workaround attempts

**Message Template (Plain Language – See Section 6 for full version):**
```
Subject: Floor 6 System Issue - Login Problems [INCIDENT #FLR6-002]

We've identified an issue affecting Floor 6 users' login access this morning. 
A software application deployed Friday is interfering with the login process.

WHAT TO DO NOW:
- Do NOT keep retrying login (this delays our fix)
- Report failed login to IT Help Desk (Ticket #: _____) if not already done
- Check email on your phone or laptop if available

WHAT WE'RE DOING:
- We are rolling back the problematic software deployment
- Expected fix time: Within 30 minutes
- We will send an update as soon as devices are fixed

We apologize for the disruption. IT leadership is engaged.
```

**Channel for Communication:**
- Email to all Floor 6 staff (immediate)
- Teams/Slack announcement (if available)
- IT Help Desk call greeting (scripted message for incoming calls)

**Why This Matters:**
- Transparency reduces anxiety and speculation
- Prevents users from attempting workarounds (which create additional issues)
- Sets expectations: users know fix is in progress, not ignored
- Reduces help desk call volume (users know they're not alone)

---

### ACTION 1.3: BRIEF IT LEADERSHIP & GET ROLLBACK APPROVAL
**Owner:** Incident Commander / IT Director  
**Timeline:** 5 minutes  
**Reasoning:** Rollback is reversible remediation; decision authority is required before execution

**Briefing Content:**
- Issue: 12+ users unable to log in due to app startup process hanging
- Root cause: Document management app deployment Friday
- Evidence: App found in HKLM\Software\Microsoft\Windows\CurrentVersion\Run (startup registry)
- Evidence: Scheduled task created by app deployment
- Solution: Rollback app deployment to pre-Friday state
- Timeline: Rollback deploy time is 15-30 minutes; user device sync is additional 5-10 minutes
- Rollback risks: [See Section 5 for details]

**Approval Decision Points:**
- [ ] Director approves rollback execution
- [ ] Director confirms rollback communications approved
- [ ] Director confirms user notification timing

**Proceed Only After Approval**

---

### ACTION 1.4: PREPARE ROLLBACK DOCUMENTATION FOR AUDIT TRAIL
**Owner:** Intune Administrator  
**Timeline:** 5 minutes (during approval wait)  
**Reasoning:** Change management and compliance require documented justification

**Documentation to Create:**
1. **Incident Justification**
   - Incident ID: FLR6-AUTH-002
   - Change type: EMERGENCY ROLLBACK
   - Business justification: Users unable to log in; $900+/hour downtime cost
   - Root cause: App deployment causing login process hang
   - Evidence references: [Link to evidence collection results, triage documents]

2. **Rollback Plan**
   - Current state: App deployed to Floor 6 devices via policy "Document Management App - Floor 6"
   - Target state: Remove app from Floor 6 devices; restore to pre-Friday baseline
   - Rollback method: Remove policy assignment in Intune
   - Rollback timeline: 15-30 minutes (policy deployment + device sync)
   - Success criteria: Users can log in normally; login time <60 seconds

3. **Risk Assessment**
   - Risks of rollback: See Section 5
   - Risks of NOT rolling back: 12+ users unable to work; compliance exposure if data access issues continue
   - Mitigation: Post-rollback verification; user testing

**File Storage:** Save in incident folder or change management system

---

## SECTION 2: TECHNICAL REMEDIATION ACTIONS (15-45 minutes)

### REMEDIATION 2.1: REMOVE APP DEPLOYMENT ASSIGNMENT IN INTUNE

**Owner:** Intune Administrator  
**Timeline:** 10 minutes (deployment time) + 15 minutes (device sync)  
**Reasoning:** Removing assignment from Intune policy manager uninstalls app from all assigned devices automatically during next device check-in

**Prerequisite:** Decision approval from Section 1.3 completed

**Intune Portal Steps:**

**Step 1: Access the App Deployment Policy**
1. Log into Intune: https://intune.microsoft.com/
2. Navigate: **Apps** → **Windows apps** (or **Mobile apps** if app is stored as mobile app)
3. Search: "Document Management" or app display name
4. Click on the app name to open details

**Step 2: Locate and Edit Assignments**
1. In the app details page, click: **Properties** → **Edit**
   - OR click directly on **Assignments** tab (if visible)
2. You should see "Groups" or "Assignments" section with:
   - Include assignments: [Should show "Floor 6 Users" or group name]
   - Exclude assignments: [May be empty]
3. Screenshot this state for audit trail before making changes

**Step 3: Remove Assignment**
1. Find the assignment row for Floor 6 Users group
2. Click the **X** or **Remove** button next to the assignment
   - Interface varies; look for delete/remove icon
3. Confirm removal in any dialog that appears
   - Dialog may ask: "Are you sure you want to remove this assignment?"
   - Click **Yes** or **Confirm**

**Step 4: Save Changes**
1. Click **Save** or **Apply** at top/bottom of page
2. Intune will show: "Assignment updated" or similar confirmation message
3. Wait for confirmation (should be immediate)

**Alternative Method (if app shown as Configuration Policy):**

If the app is deployed as a configuration profile instead of direct app assignment:

1. Navigate: **Devices** → **Configuration profiles**
2. Search for deployment name (e.g., "Document Management App - Floor 6")
3. Click on the policy name
4. Click: **Edit** or **Properties**
5. Go to: **Assignments** tab
6. Remove "Floor 6 Users" or "Floor 6 Devices" assignment
7. Save

**Post-Action Verification:**
- [ ] Assignment removed from Intune
- [ ] No Floor 6 groups/devices showing in assignment list
- [ ] Change saved successfully (confirmation message displayed)

**What Happens Next:**
- Intune sends policy update to all Floor 6 devices
- Devices receive update during next device sync (typically within 5-30 minutes)
- Device sync triggers uninstallation of app
- App is removed from device automatically (Windows Installer handles uninstall)

**Success Metric:** Assignment shows as "Removed" or "No assignments" in Intune

---

### REMEDIATION 2.2: VERIFY POLICY REMOVAL AND DEVICE SYNC

**Owner:** Intune Administrator / Help Desk  
**Timeline:** 15-30 minutes (monitoring)  
**Reasoning:** Verify devices are receiving the removal policy and uninstalling app

**Monitoring Steps:**

**In Intune Portal:**
1. Navigate: **Devices** → **Manage devices** → **Windows**
2. Search for Floor 6 device name (e.g., "FLOOR6-PC-001")
3. Click on device name to open device details
4. Check: **Device status** → **Device sync status**
   - Look for: "Last sync time: [recent timestamp]"
   - Should show sync within last 5-10 minutes
5. Navigate to: **Troubleshoot + support** tab
   - This shows device health and recent policy applications
6. Verify device has received the removal policy
   - Look for: Policy name, "Status: Succeeded" or "Applied"

**Manual Verification on Device (if user cooperation available):**
1. On affected device, open Command Prompt (as Administrator)
2. Run: `wmic product list brief`
   - Look for "Document Management" or similar app name in output
   - If app is listed: It's still installed (wait for sync)
   - If app is NOT listed: It's been uninstalled (success)

3. Alternative (PowerShell):
   ```powershell
   Get-WmiObject -Class Win32_Product | Where-Object { $_.Name -like "*Document*" }
   ```
   - If no results: App successfully uninstalled

**Monitor Device Health:**
1. In Intune, navigate: **Devices** → **Monitor** → **Device compliance**
2. Check if Floor 6 devices show "Compliant" status
3. Navigate: **Devices** → **Monitor** → **Hardware health**
4. Verify no failed policy applications or sync errors

**Success Criteria:**
- [ ] Devices show recent sync timestamp (within 10 minutes)
- [ ] Policy application shows "Succeeded"
- [ ] App no longer appears in `wmic product list` on devices
- [ ] No errors in device troubleshooting view

**Timeline Expectations:**
- **5-10 minutes:** Fast device sync (connected, configured for frequent sync)
- **10-30 minutes:** Standard device sync (normal Intune sync interval)
- **30-60 minutes:** Slow device sync (poor network, offline briefly, or configured for longer intervals)
- **If >60 minutes:** Investigate device connectivity or sync settings

---

### REMEDIATION 2.3: FORCE DEVICE SYNC ON FLOOR 6 DEVICES (OPTIONAL - ACCELERATE REMEDIATION)

**Owner:** Intune Administrator  
**Timeline:** 5 minutes to trigger sync; 2-5 minutes for device to sync  
**Reasoning:** Device sync can be forced to accelerate policy update delivery (faster remediation vs. waiting for scheduled sync)

**Prerequisites:**
- Intune app installed on device (standard Windows device management)
- Device has network connectivity

**Method 1: Remote Sync from Intune Portal**
1. In Intune: **Devices** → **Manage devices** → **Windows**
2. Search and click on Floor 6 device
3. Click: **Sync** button (usually at top of device page)
4. Confirm dialog: "Sync this device?"
5. Click: **Yes** or **Confirm**
6. Intune sends sync command immediately
7. Device receives command and syncs policies (should complete within 2-5 minutes)

**Method 2: Manual Sync on Device (If User Cooperation Available)**
1. Instruct user or tech to run on their device:
   - Open: Settings → **System** → **About**
   - Click: **Advanced system settings** (Windows 10/11)
   - Find: **Device sync status** or similar section
   - Click: **Sync** button
   - OR: Settings → **Update & Security** → **Device options** → **Sync your settings** → **Sync now**

2. Alternative via Settings app:
   - Settings → **Accounts** → **Sync your settings**
   - Toggle: **Sync settings** OFF then ON (forces refresh)

3. Alternative via Intune app (if available):
   - Open: **Company Portal** app (or **Intune** app)
   - Look for: **Sync** button
   - Click to force immediate policy sync

**Method 3: PowerShell Remote Command (If Device Accessible)**
1. On device, open PowerShell (Admin):
   ```powershell
   # Trigger Intune device sync
   Get-ScheduledTask -TaskName "Intune Management Extension Scheduled Task" | Start-ScheduledTask
   ```
2. This forces device to sync with Intune immediately

**Monitoring After Sync:**
1. Check Intune device page: **Last sync time** should update to current time
2. Wait 2-5 minutes
3. Check app removal status (see REMEDIATION 2.2 for verification steps)

**Success Metric:**
- Device sync timestamp updates to within last 5 minutes
- App uninstallation completes shortly after (5-15 minutes)

---

## SECTION 3: VERIFICATION AND SUCCESS CRITERIA

### VERIFICATION 3.1: LOGIN FUNCTIONALITY TEST

**Owner:** IT Support / Help Desk  
**Timeline:** 30-45 minutes after remediation  
**Reasoning:** Confirm primary issue (login failures) is resolved before declaring incident closed

**Test Procedure:**

**Phase 1: Local Testing on One Device (Canary Test)**
1. Select one Floor 6 device (preferably from user who reported issue)
2. If user available: Have them attempt login with their normal credentials
3. Measure: How long does login take?
   - Normal: 20-45 seconds
   - Slow but acceptable: 45-60 seconds
   - Still slow: >60 seconds (investigate further)
4. After login, ask:
   - "Can you access your files?"
   - "Does Outlook open normally?"
   - "Can you open Teams?"
5. Record results

**Phase 2: Batch Testing (5-10 Devices)**
1. Contact 5-10 Floor 6 users
2. Ask each to attempt login and report:
   - Did you successfully log in? (Yes/No)
   - How long did it take? (approximate time)
   - Are you getting any error messages?
3. Record results in spreadsheet

**Success Metrics (Phase 1 & 2):**
- [ ] 100% of tested users can log in successfully
- [ ] Login time: 20-60 seconds (normal range)
- [ ] No timeout errors
- [ ] No authentication failures
- [ ] Users report no unusual delays

**If Failed:**
- If some users can log in, others cannot: Targeted issue (investigate specific device/user)
- If all users still have issues: App may not have uninstalled; investigate device sync status

---

### VERIFICATION 3.2: PROFILE INTEGRITY TEST

**Owner:** IT Support / Help Desk  
**Timeline:** 30-60 minutes after remediation  
**Reasoning:** Confirm secondary issue (missing shortcuts/profile corruption) is resolved or can be recovered

**Test Procedure:**

**Phase 1: Check Recycle Bin (User-Accessible Recovery)**
1. Contact user who reported missing shortcuts
2. Have user check Windows Recycle Bin:
   - Open File Explorer
   - Click: **Recycle Bin** (left sidebar)
   - Search for: ".lnk" files (shortcut file extension)
   - If shortcuts appear in Recycle Bin → They can be restored
3. If shortcuts found in Recycle Bin:
   - Select shortcuts
   - Right-click → **Restore**
   - Confirm: Shortcuts reappear on desktop

**Phase 2: Restore from Profile Backup (If Organization Uses Roaming Profiles)**
1. IT Admin accesses profile server:
   - Network path: `\\[ProfileServer]\Profiles\` or `\\[ProfileServer]\USERData\`
   - Find: User profile folder (typically username)
2. Check: Are previous versions available?
   - Right-click folder → **Properties** → **Previous Versions**
   - Select version from Friday before deployment
   - Click **Restore**
3. Sync profile back to device
4. User logs in; shortcuts should reappear

**Phase 3: Refresh Desktop Settings**
1. If no backup available, refresh Windows desktop to default:
   - User: Right-click desktop → **Personalize**
   - Reset to default theme (not destructive; only appearance settings)
   - Add commonly-used shortcuts back manually (5-10 minutes per user)

**Success Metrics (Phase 1, 2, or 3):**
- [ ] User can recover shortcuts from Recycle Bin, OR
- [ ] Profile restored from backup with shortcuts intact, OR
- [ ] User confirms shortcuts manually re-created successfully
- [ ] Desktop is functional and contains working shortcuts

**If All Failed:**
- Shortcuts are permanently deleted (rare)
- Mitigation: Document lost items; provide user list of shortcuts to recreate
- Prevention: Implement regular profile backups

---

### VERIFICATION 3.3: SYSTEM PERFORMANCE METRICS

**Owner:** IT Operations / Monitoring  
**Timeline:** 30-120 minutes after remediation  
**Reasoning:** Confirm resource consumption returned to normal (no lingering app processes or hooks)

**Metrics to Monitor:**

**CPU Usage During Login:**
- **Before Fix:** Spiked to 80-100% during login (app consuming resources)
- **After Fix:** Normal range 20-40% during login
- **How to Measure:** Task Manager → **Performance** tab → watch login process
- **Success:** CPU returns to baseline <30 seconds after login completes

**Disk I/O During Login:**
- **Before Fix:** Sustained high disk activity (>50% busy time) for 60-120 seconds
- **After Fix:** Low disk activity (<20% busy time) after 30-45 seconds
- **How to Measure:** Task Manager → **Disk** usage during login
- **Success:** Disk activity completes within normal timeframe

**Memory Usage:**
- **Before Fix:** High memory consumption (app holding resources)
- **After Fix:** Stable memory at normal user baseline (~2-3GB for typical user session)
- **How to Measure:** Task Manager → **Memory** tab after login completes
- **Success:** Stable memory usage post-login

**Login Time Baseline Comparison:**
- Document baseline login time (pre-deployment Friday) if available from logs
- Measure login time post-remediation
- **Success Metric:** Login time within 10% of baseline (or <60 seconds absolute)

**Where to Collect Metrics:**
1. **Intune:** Devices → Monitor → Hardware health (aggregate view)
2. **Event Logs:** Event Viewer → Windows Logs → System (logon events)
3. **Microsoft Defender:** Security and Compliance Center → Device health
4. **Third-party monitoring:** If Splunk, DataDog, or similar is deployed

---

### VERIFICATION 3.4: EVENT LOG REVIEW (FORENSIC VERIFICATION)

**Owner:** IT Support / Security Engineering  
**Timeline:** 60-90 minutes after remediation  
**Reasoning:** Confirm from logs that issue is resolved and no new errors introduced

**Events to Review:**

**System Event Log - Check For:**
- [ ] **Event ID 4649 (Logon success):** Timestamps show normal login pattern
- [ ] **Event ID 4625 (Logon failure):** Should STOP appearing after app removed
- [ ] **Event ID 1001 (Application hang):** Should not appear in logs post-remediation
- [ ] **Event ID 10005 (Service startup):** App-related services should NOT appear

**Application Event Log - Check For:**
- [ ] Errors from document management app → Should stop appearing
- [ ] Installer events (uninstall) → Should appear once (showing app removal)
- [ ] No application crashes related to app startup

**Procedure:**
1. On Floor 6 device, open Event Viewer
2. Navigate: **Windows Logs** → **System**
3. Filter events (right-click → **Filter Current Log**):
   - Start time: Monday 09:00 AM (issue window)
   - End time: Current time
   - Event levels: Error, Warning
4. Scan for login-related errors
5. Compare: Errors BEFORE remediation vs. AFTER
   - **Before:** Many Event ID 4625, 1001 errors
   - **After:** No new errors of same type

**Success Metric:**
- [ ] Error rate drops to zero for app-related failures
- [ ] Normal logon events (4624 success) appear consistently
- [ ] No new unexpected errors introduced

---

## SECTION 4: RISKS OF ROLLBACK

### RISK 1: APP FUNCTIONALITY LOSS (User Impact)

**Risk Description:**
Removing document management app means users lose access to its features during rollback period.

**Severity:** MEDIUM

**Probability:** VERY HIGH (certain; app will be removed)

**Business Impact:**
- Users cannot use document management features
- Users must revert to previous document management method (e.g., file shares, older system)
- Estimated productivity impact: 30-60 minutes per user during rollback + re-configuration period

**Mitigation:**
1. **Pre-Rollback Communication:** Tell users exactly when app will be removed and when it will be restored
2. **Time-Window Selection:** Execute rollback during low-activity period (early morning, not mid-morning)
3. **Provide Workaround:** Make previous document management method available during rollback
4. **Accelerate Re-Deployment:** Schedule fixed version deployment immediately after verification (re-deploy within 4 hours)

**Residual Risk:** Users must work without app for 4-24 hours depending on fix timeline

---

### RISK 2: UNINTENDED DEVICE CHANGES (Policy Scope)

**Risk Description:**
If device assignment is incorrectly defined, rollback could affect devices beyond Floor 6 (e.g., if assignment is "All Devices" instead of "Floor 6 Users").

**Severity:** HIGH

**Probability:** LOW (Intune admin should have correct assignment, but verification is critical)

**Impact:** App removed from unintended devices; 50-500+ users lose access

**Mitigation:**
1. **Pre-Rollback Verification:** Manually confirm Intune assignment BEFORE removing
   - Screenshot showing assignment is Floor 6 Users only
   - Verify no "All Devices" or broader group assignment
2. **Rollback in Stages:** Remove assignment from only subset first (5 devices), verify, then full removal
3. **Rollback Cancellation Plan:** If error detected, immediately restore assignment

**Residual Risk:** Mitigated by careful verification; probability should be reduced to <1%

---

### RISK 3: INCOMPLETE UNINSTALLATION (Residual App State)

**Risk Description:**
App may not fully uninstall from some devices; registry entries, temp files, or services remain, continuing to cause problems.

**Severity:** MEDIUM

**Probability:** LOW (Windows Installer typically handles complete uninstall)

**Impact:** Issues persist for subset of devices despite rollback

**Mitigation:**
1. **Post-Rollback Verification:** Check installed apps on sampled devices (see VERIFICATION 3.2)
2. **Manual Cleanup Script:** Have PowerShell script ready to force registry and file cleanup if needed
3. **Device Reboot Requirement:** Instruct users to restart device after app removal (ensures all processes release)

**Residual Risk:** If 1-2 devices have incomplete uninstall, local IT support can manually clean up

---

### RISK 4: DATA LOSS (Unlikely but Possible)

**Risk Description:**
App removal could theoretically affect user data if app stored unsaved work or cached data in proprietary format.

**Severity:** CRITICAL (if data loss occurs)

**Probability:** LOW (app was recently deployed Friday; users unlikely to have substantial data in it)

**Impact:** Permanent loss of any work done in app since Friday

**Mitigation:**
1. **Pre-Rollback User Communication:** Warn users to save and export any work done in app
2. **App Data Location Audit:** Check where app stores data (should be standard Windows locations)
3. **Backup Before Rollback:** IT admin should export/backup any app data from device before rollback
4. **Rollback Timing:** Rollback early in week (Monday); users less likely to have accumulated significant work

**Residual Risk:** If any user had significant unsaved work in app since Friday, it will be lost (estimated 1-5 users at most)

---

### RISK 5: DEPLOYMENT REINTRODUCTION (Recurring Issue)

**Risk Description:**
If the app deployment isn't fixed, re-deploying the same broken app would recreate the issue.

**Severity:** CRITICAL

**Probability:** MEDIUM (app needs to be redeployed eventually; if underlying issue not fixed, will recur)

**Impact:** Same login/profile issues reappear; wasted remediation effort

**Mitigation:**
1. **Root Cause Fix Required:** Before re-deploying, app must be updated or configuration fixed:
   - Remove app from startup registry (if possible without removing functionality)
   - Modify app to not execute during Windows login phase
   - OR change deployment to install but not auto-launch
2. **Testing Before Re-Deployment:** Deploy fixed version to test group first (5-10 users on different floor)
3. **Staged Re-Deployment:** If test passes, deploy to Floor 6 one day at a time, not all at once

**Residual Risk:** Mitigated by requiring root cause fix before re-deployment; prevents recurrence

---

### RISK 6: INTUNE POLICY SYNC FAILURE (Incomplete Rollback)

**Risk Description:**
Some devices may not receive the removal policy due to network issues, device offline status, or Intune sync failures.

**Severity:** MEDIUM

**Probability:** MEDIUM (some devices typically have sync issues in large deployment)

**Impact:** 5-20% of devices retain app; issues persist for those users

**Mitigation:**
1. **Monitor Device Sync:** Watch Intune device compliance dashboard for sync failures
2. **Force Sync:** Use remote sync command (Section 2.3) for devices with sync delays
3. **Manual Uninstall:** For devices that don't sync within 30 minutes, have IT support manually uninstall via PowerShell
4. **Offline Device Plan:** Devices that are offline get rollback during next logon (automatic)

**Residual Risk:** By 24 hours post-rollback, 100% of devices should be compliant via combination of automatic sync + manual remediation

---

### RISK 7: APPLICATION DEPENDENCIES (Other Systems Affected)

**Risk Description:**
Other applications or systems may depend on document management app being present; removal could break those dependencies.

**Severity:** MEDIUM (if dependencies exist)

**Probability:** LOW (app was just deployed; unlikely other systems already depend on it)

**Impact:** Other systems or users fail after app removed

**Mitigation:**
1. **Pre-Rollback Dependency Audit:** App team should review if other systems reference document management app
2. **Staged Rollback Testing:** Test rollback on one device first; watch for cascading failures
3. **Documentation:** If dependencies found, create workaround or parallel system for those users

**Residual Risk:** None expected (app too new to have dependencies); if found, addressed via workaround

---

### RISK SUMMARY TABLE

| Risk | Severity | Probability | Mitigation | Residual Risk |
|------|----------|------------|-----------|---------------|
| App functionality loss | MEDIUM | VERY HIGH | Communication + workaround | Users offline 4-24 hours |
| Unintended device changes | HIGH | LOW | Pre-verification + staged rollback | <1% if verified |
| Incomplete uninstallation | MEDIUM | LOW | Post-verification + manual cleanup | 1-2 devices manual fix |
| Data loss | CRITICAL | LOW | User warning + backup | 1-5 users max |
| Deployment reintroduction | CRITICAL | MEDIUM | Root cause fix required before re-deploy | Prevented by fix requirement |
| Intune sync failure | MEDIUM | MEDIUM | Monitor + forced sync + manual uninstall | 100% compliant by 24 hours |
| App dependencies | MEDIUM | LOW | Dependency audit + workaround | None expected |

**Overall Risk Assessment:** Risks are manageable; remediation should proceed. Most risks are mitigated by verification and communication.

---

## SECTION 5: PLAIN-LANGUAGE COMMUNICATION FOR FLOOR 6 USERS

### COMMUNICATION 5.1: INITIAL INCIDENT NOTIFICATION (Send Immediately - 10:30 AM)

**Format:** Email to all Floor 6 staff  
**Subject:** URGENT: Floor 6 System Issue - Login Problems - Incident #FLR6-002  
**Recipient:** floor6-staff@company.com or equivalent group

```
Subject: URGENT: Floor 6 System Issue - Login Problems [Incident #FLR6-002]

Dear Floor 6 Team,

We've identified why some of you have had trouble logging in this morning, and we're working on a fix right now.

WHAT HAPPENED:
A software application that was installed Friday is interfering with the login process on Floor 6 devices. 
This is why:
- Some of you can't log in at all
- Some of you experience very slow logins (60+ seconds to get to the desktop)
- Some users noticed that desktop shortcuts disappeared

THIS IS NOT A SECURITY ISSUE. Your data is safe.

WHAT WE'RE DOING RIGHT NOW:
- We've identified the exact application causing the problem
- We're removing it from all Floor 6 devices
- We expect this fix to take about 30-45 minutes

WHAT TO DO IN THE MEANTIME:
1. STOP trying to log in repeatedly (each attempt delays our fix)
2. If you haven't already, please submit a help desk ticket (call extension 555-1234 or use IT Support portal)
3. Use an alternative device if available (laptop, tablet, phone for email)
4. Check email using the web portal: https://outlook.company.com/mail

IF YOU'RE WORKING FROM HOME OR OFF-SITE:
- You might experience the same login issues
- VPN is not required for web-based services
- Please contact IT Help Desk if you need an alternative device or method to access your work

YOUR DEVICES WILL FIX THEMSELVES:
You don't need to do anything on your end. When you try to log in after 11:00 AM, you should see:
- Login screen appears normally
- Login completes in 30-60 seconds (normal speed)
- Your desktop appears with your usual shortcuts
- All your files are in the normal locations

NEXT STEPS:
- At 11:00 AM, we'll send an update: "Ready to test logins"
- Please try logging in after 11:00 AM and let us know if it works
- If it doesn't work, contact IT Help Desk with your device name

We know this is frustrating. We're prioritizing this as our #1 issue right now. IT leadership is personally engaged.

Thank you for your patience.

IT Support Team
Incident #FLR6-002 | Command: [IT Director Name] | Status: IN PROGRESS
```

**Timing:** Send immediately after approval is granted (within 2 minutes)

---

### COMMUNICATION 5.2: "ALL CLEAR" NOTIFICATION (Send at 11:15 AM - After Verification)

**Format:** Email to all Floor 6 staff  
**Subject:** RESOLVED: Floor 6 System Issue - Login Fixed [Incident #FLR6-002]

```
Subject: RESOLVED: Floor 6 System Issue - Login Fixed [Incident #FLR6-002]

Dear Floor 6 Team,

GOOD NEWS: The login issue has been fixed. Your devices are ready.

WHAT WE DID:
- Identified the problematic software application (deployed Friday)
- Removed it from all Floor 6 devices
- Verified the fix on multiple devices
- Confirmed login is working normally

WHAT YOU NEED TO DO:
1. If you haven't already, try logging in on your device
2. You should now:
   - See the login screen immediately
   - Login should complete in 30-60 seconds (normal speed)
   - See your usual desktop with shortcuts restored
   - Access all your files and applications normally

IF YOU'RE STILL HAVING PROBLEMS:
Please contact IT Help Desk:
- Call: extension 555-1234
- Email: itsupport@company.com
- Portal: https://itsupport.company.com
- Provide: Your device name (e.g., FLOOR6-PC-001)

WHAT HAPPENS NEXT:
- We will deploy a corrected version of the software application
- Timeline: We'll communicate the new deployment date by EOD Friday
- Testing: We'll deploy to a small group first to ensure this doesn't happen again

WHAT WE'RE DOING DIFFERENTLY:
- We're working with the software vendor to fix the startup behavior
- We'll test the corrected version thoroughly before any deployment
- We'll deploy in stages (small group first) rather than floor-wide

We sincerely apologize for the disruption this morning. Thank you for your patience while we worked on this.

IT Support Team
Incident #FLR6-002 | Status: RESOLVED
```

**Timing:** Send after verification shows 90%+ devices are fixed (typically 11:00-11:30 AM)

---

### COMMUNICATION 5.3: HELP DESK SCRIPT (For Call Center & Support Team)

**Use This Script When Answering Floor 6 Calls:**

```
Caller: "Hi, I'm from Floor 6 and I can't log into my computer."

Support: "I understand, and I want to help you. We've identified a software issue affecting Floor 6 
this morning, and IT leadership is working on a fix right now. Here's the current status:

[CHECK CURRENT TIME]

If it's before 11:00 AM:
- We're in the process of rolling back the problematic software
- The fix should be complete by 11:00 AM
- Please try logging in again at 11:00 AM
- In the meantime, can you use an alternative device (laptop, phone) to check email?

If it's after 11:00 AM:
- The fix has been deployed to your device
- Can you try logging in now? [Wait while user tries]
- [If successful] Great! You should be all set. Anything else I can help with?
- [If unsuccessful] I see. Let me take your device name and escalate this to Level 2 support.

Escalation Info I Need:
1. Your device name (format: FLOOR6-PC-XXX)
2. Error message you're seeing (if any)
3. Number of login attempts
4. When was the last time you successfully logged in?

We appreciate your patience. This is being treated as our top priority."
```

**Key Points for Support Team:**
- Acknowledge the issue immediately (don't sound confused)
- Explain what's happening in simple terms
- Set clear expectation for when fix will be available
- Provide alternative workarounds
- Escalate gracefully if user's issue isn't resolved

---

### COMMUNICATION 5.4: CLOSURE COMMUNICATION (Send 24 hours after resolution - Tuesday morning)

**Format:** Email to all Floor 6 staff  
**Subject:** Incident #FLR6-002 - Post-Incident Report [CLOSED]

```
Subject: Incident #FLR6-002 - Post-Incident Report [CLOSED]

Dear Floor 6 Team,

INCIDENT STATUS: CLOSED

The Floor 6 login issue reported Monday morning has been fully resolved. All devices have been verified, 
and normal operations have resumed.

INCIDENT SUMMARY:
- Reported: Monday 09:14 AM (12+ users affected)
- Root Cause: Software application deployed Friday interfered with login process
- Action Taken: Application removed from all Floor 6 devices
- Fixed: Monday 11:00 AM
- Total Duration: ~2 hours

IMPACT:
- 12 users unable to log in
- Login delays for additional users
- Estimated 2-hour productivity loss

WHAT WE'VE LEARNED:
1. We will not deploy new software company-wide without testing first
2. We will deploy in stages (small group first) to catch problems early
3. We will create a better communication plan for future incidents

NEXT STEPS:
1. Corrected version of software application is being prepared
2. Will be tested on a smaller group before Floor 6 deployment
3. Expected re-deployment: TBD (will communicate separately)
4. We will NOT deploy without communicating the date/time in advance

YOUR FEEDBACK:
If you have comments about this incident or how we handled it, please email:
- IT Director: [director@company.com]
- Subject: Feedback on Incident #FLR6-002

We value your feedback and use it to improve how we respond to incidents.

Thank you again for your patience.

IT Support Team
Incident #FLR6-002 | Commander: [IT Director Name] | Final Status: CLOSED
```

**Timing:** Send 24 hours after issue is fully resolved (Tuesday morning)

---

## SECTION 6: ROLLBACK EXECUTION CHECKLIST

**Use this checklist to execute remediation in order:**

### PRE-EXECUTION (Authorization & Preparation)
- [ ] **1.1** IT Director approves rollback
- [ ] **1.2** Incident communication drafted and approved for sending
- [ ] **1.3** Incident justification documented for audit trail
- [ ] **1.4** Rollback plan reviewed by Intune admin and IT Director
- [ ] Rollback execution window confirmed (morning preferred to minimize downtime)

### INITIATE REMEDIATION
- [ ] **5.1** Send initial incident notification to Floor 6 staff (10:30 AM suggested)
- [ ] **2.1** Log into Intune portal
- [ ] **2.1** Locate and verify document management app assignment (Floor 6 Users only)
- [ ] **2.1** Take screenshot of assignment for audit trail
- [ ] **2.1** Remove app assignment from Floor 6 Users group
- [ ] **2.1** Confirm change saved in Intune

### MONITOR ROLLBACK DEPLOYMENT
- [ ] **2.2** Monitor Intune device sync status (refresh every 5 minutes)
- [ ] **2.3** [Optional] Force device sync for Floor 6 devices to accelerate uninstall
- [ ] **2.2** Verify app removal on canary device (sample 1-2 devices within 15 min)
- [ ] **2.2** Check event logs for policy application success
- [ ] **2.2** Confirm 80%+ of Floor 6 devices have received removal policy within 30 minutes

### VERIFY REMEDIATION
- [ ] **3.1** Contact 5-10 Floor 6 users; verify login works (11:00 AM)
- [ ] **3.1** Verify login time is normal (20-60 seconds)
- [ ] **3.2** Check for recovery of missing shortcuts (Recycle Bin or backup)
- [ ] **3.3** Spot-check system performance (CPU, disk, memory normal)
- [ ] **3.4** Review event logs for continued errors (should stop)

### COMMUNICATE ALL-CLEAR
- [ ] **5.2** Once 90% of users report successful login, send "ALL CLEAR" notification

### POST-INCIDENT
- [ ] **5.3** Continue staffing help desk for 2+ hours after all-clear (support remaining users)
- [ ] Document any devices that required manual intervention
- [ ] **5.4** Send post-incident closure report 24 hours later

---

## TIMELINE SUMMARY

| Time | Action | Owner | Status |
|------|--------|-------|--------|
| 10:30 | Rollback approved | IT Director | **GO** |
| 10:31 | Send incident notification | Comms | **SEND** |
| 10:35 | Remove app from Intune | Intune Admin | **EXECUTE** |
| 10:45 | Monitor device sync | Intune Admin | **MONITOR** |
| 10:50 | Verify app removal (sample) | IT Support | **VERIFY** |
| 11:00 | Verify login function (users) | IT Support | **TEST** |
| 11:15 | Send all-clear notification | Comms | **SEND** |
| 11:30 | Staff help desk (support stragglers) | Help Desk | **STAFF** |
| 14:00 | Declare incident resolved | Incident Commander | **CLOSE** |

**Total Time to Remediation:** ~2 hours (10:30 AM - 12:30 PM expected)

---

## DECISION RECORD

**Decision:** Execute rollback of document management app from Floor 6 devices

**Date/Time:** [To be filled in when decision made]

**Approved By:** [IT Director name and signature]

**Justification:**
- 12+ users unable to log in (>$900/hour downtime cost)
- Root cause identified: App startup process hangs during login
- Evidence collected and verified
- Rollback is lower risk than continued troubleshooting
- Rollback timeline is faster than fixing deployment issues

**Alternative Considered:** Continue troubleshooting app in production
**Reason Not Chosen:** Users are currently unable to work; business impact unacceptable

**Success Criteria:** 100% of Floor 6 users can log in within 60 seconds; login time baseline restored

**Approval Signature:** _________________________ | **Date/Time:** _________________
