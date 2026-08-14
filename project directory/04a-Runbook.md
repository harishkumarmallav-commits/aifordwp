# Floor 6 Application Deployment Rollback Runbook

**Title:** Floor 6 Application Deployment Rollback Runbook

**Version:** 1.0

**Date:** 14-Aug-2026

**Status:** Draft (Review before production use)

**Scenario:** Document management application deployment has caused login failures on Floor 6. This runbook executes emergency rollback via Intune.

**Estimated Duration:** 45-60 minutes (Intune removal + device sync + verification)

---

## SECTION 1: BACKGROUND & CONTEXT

### What Happened
Friday 15:00 – Document management application was deployed to Floor 6 devices via Intune  
Monday 09:14 – Users reported inability to log in, slow logins (60+ seconds), missing desktop shortcuts  
Monday 10:30 – Root cause identified: App startup process hangs during Windows login phase

### Why We're Rolling Back
- Application interferes with normal login process
- 12+ users unable to access work
- Business impact: $900+/hour downtime cost
- Rollback is faster remediation than troubleshooting and fixing deployment issues

### What This Runbook Does
Removes the document management application from Floor 6 devices via Intune by:
1. Removing Floor 6 Users group from the app assignment
2. Allowing Intune to deploy removal policy to devices
3. Verifying app uninstallation and login restoration
4. Confirming system performance return to baseline

### Approval Required Before Proceeding
- [ ] IT Director approval obtained
- [ ] User communication approved
- [ ] Incident ticket created (reference: FLR6-002)

**If approval not obtained:** STOP. Return to incident commander for authorization.

---

## SECTION 2: PREREQUISITES

### Personnel Required
- **Primary:** Intune Administrator (or IT admin with Intune permissions)
- **Secondary:** IT Support technician (for user verification calls)
- **Tertiary:** Help Desk coordinator (for communications)

### Access & Permissions Required
1. **Intune Admin Access**
   - Must have: Global Admin or Intune Service Administrator role
   - Verify by: Can access https://intune.microsoft.com/ without error
   - If insufficient access: Escalate to IT Director for temporary elevation

2. **Intune Tenant Access**
   - Must be authenticated to company's Azure AD tenant
   - Must have multi-factor authentication (MFA) enabled
   - Verify by: MFA challenge appears when accessing Intune

3. **Device Connectivity**
   - Floor 6 devices must have internet connectivity
   - Devices must be enrolled in Intune (should already be)
   - Intune policy sync should be working (check via device health dashboard)

### Information to Gather Before Starting

**Collect this information now; you'll need it later:**

1. **Application Details**
   - [ ] Application name in Intune: `_____________________________`
   - [ ] Current assignment: `_____________________________`
   - [ ] Target group for removal: `Floor 6 Users` (or: `_____________________________`)

2. **User Contact List**
   - [ ] Floor 6 staff email group: `floor6-staff@company.com` (or: `_____________________________`)
   - [ ] IT Help Desk contact: `extension 555-1234` (or: `_____________________________`)
   - [ ] Incident ticket number: `FLR6-002` (or: `_____________________________`)

3. **Device Sample**
   - [ ] Device name for testing: `FLOOR6-PC-001` (or: `_____________________________`)
   - [ ] Device contact person (user on that device): `_____________________________`

### System Requirements
- **Workstation:** Must have internet access to Azure
- **Browser:** Edge, Chrome, or Firefox (Internet Explorer NOT supported)
- **Network:** VPN not required if on corporate network; required if remote
- **Time:** Minimum 60 minutes uninterrupted (do not start if you might be interrupted)

### Pre-Check: Verify Intune Access

**Before you start, run this verification:**

1. Open web browser
2. Navigate to: `https://intune.microsoft.com/`
3. **Expected Result:** You are prompted to sign in or already logged in
4. **If error:** "Unauthorized" or "Access Denied"
   - → Call IT Director; request temporary Intune admin access elevation
   - → Do NOT proceed without access

5. Once logged in, look for "Microsoft Intune" at top left (logo/title)
6. **Expected Result:** Can see left sidebar menu with "Devices", "Apps", "Compliance" options
7. **If error:** Menu items missing or grayed out
   - → Insufficient permissions; request access elevation

**✓ PROCEED ONLY if you can successfully access Intune Admin Center**

---

## SECTION 3: PROCEDURE

### STEP 1: ACCESS THE DOCUMENT MANAGEMENT APP DEPLOYMENT IN INTUNE (5 minutes)

**Starting Point:** You are logged into https://intune.microsoft.com/

**Action 1.1: Navigate to Apps Section**
1. Look at left sidebar menu (vertical list on left side of screen)
2. Click on: **Apps** (between "Devices" and "Compliance" in menu)
   - Expected display: Submenu expands showing app management options
3. Under Apps section, click on: **Windows apps**
   - Expected display: List of Windows applications deployed in your tenant

**Expected Result After Step 1.1:**
- You see a table/list titled "Windows apps"
- Table contains rows, each row is one application
- Columns include: Name, Publisher, Assignments, Status

**Action 1.2: Search for Document Management Application**
1. Look for search box at top of the Windows apps list (may say "Search" or have magnifying glass icon)
2. Click in search box
3. Type: `Document Management`
4. Press: **Enter** or wait for auto-search results
   - Expected display: List filters to show only apps matching "Document Management"

**Expected Result After Step 1.2:**
- Search results show 1-3 applications containing "Document Management" in name
- Common names might be:
  - "Document Management Application"
  - "Document Portal"
  - "[Company Name] Document App"
- If 0 results: App may be named differently; ask Intune admin or check change management ticket from Friday for exact app name

**Action 1.3: Select the Document Management App**
1. Click on the application name (the row/link for the app, not a button)
   - Expected display: App details page opens; shows app properties, assignments, etc.
2. Once details page opens, look at top of page for breadcrumb trail
   - Should show: **Apps** > **Windows apps** > **[App Name]**

**Expected Result After Step 1.3:**
- App details page is open
- You can see app properties (Name, Publisher, Version, etc.)
- You can see "Assignments" tab or "Manage" → "Assignments" option
- Page title/header confirms this is the correct app

**VERIFICATION CHECKPOINT:** Take a screenshot of this page for audit trail. Document:
- [ ] App name confirmed
- [ ] Publisher confirmed
- [ ] You can see Assignments section

---

### STEP 2: VERIFY CURRENT ASSIGNMENT (3 minutes)

**Starting Point:** You are on the Document Management App details page in Intune

**Action 2.1: Locate Assignments Tab**
1. Look for tabs/buttons at top or middle of the app details page
2. Find and click on: **Assignments** tab
   - Alternative location: May be under "Manage" dropdown or "Properties" → "Edit"
   - If you don't see it: Click **Edit** button; Assignments should appear in edit view

**Expected Result After Step 2.1:**
- Assignments section is displayed
- You see table showing current assignments with columns:
  - Group Name
  - Assignment Type (Assigned, Excluded, Available)
  - Status

**Action 2.2: Identify Floor 6 Assignment**
1. Scan the Assignments table for entries related to Floor 6
2. Look for rows containing:
   - "Floor 6"
   - "Floor 6 Users"
   - "FLR6" 
   - "F6" 
   - Device group names that include floor identifier
3. Note the assignment type (should be "Assigned" or "Required")
4. Check if there are any other assignments beyond Floor 6
   - Look for: "All Users", "All Devices", "Company", "Enterprise"
   - If you see broad assignments: **STOP** → This app is assigned beyond Floor 6 → Escalate to supervisor before proceeding

**Expected Result After Step 2.2:**
- You identify the Floor 6 assignment row
- Assignment type confirms it's active deployment ("Assigned", "Required", or similar)
- Confirm NO assignments to "All Devices" or "Company" (if these exist, this is broader than expected)

**Action 2.3: Document Current State (Screenshot)**
1. Take screenshot of Assignments table showing:
   - Floor 6 Users group assignment
   - Any other assignments
   - Entire table visible
2. Save screenshot with filename: `Intune-Floor6App-Assignment-Before.png`
3. Purpose: Audit trail showing what was deployed before rollback

**Expected Result After Step 2.3:**
- Screenshot captured and saved
- You have documented proof of current assignment state

**✓ CRITICAL VERIFICATION:** Before proceeding to STEP 3:
- [ ] Confirmed: Assignment target is "Floor 6 Users" or equivalent Floor 6 group ONLY
- [ ] Confirmed: No "All Devices" or company-wide assignment exists
- [ ] Confirmed: Screenshot saved for audit trail
- **If you cannot confirm above: STOP and escalate to IT Director**

---

### STEP 3: REMOVE FLOOR 6 ASSIGNMENT (5 minutes)

**Starting Point:** You are viewing Assignments section with Floor 6 Users group visible

**Action 3.1: Enter Edit Mode**
1. Look for button at top/bottom of Assignments section
2. Click: **Edit** button (or if already in edit mode, continue to 3.2)
   - Expected display: Assignments section becomes editable; buttons appear for Add/Remove

**Expected Result After Step 3.1:**
- Assignment rows now have X, delete, or remove icons
- Buttons become active/clickable (not grayed out)
- If "Edit" is already active: Proceed to 3.2

**Action 3.2: Select Floor 6 Assignment for Removal**
1. Find the row containing "Floor 6 Users" (or Floor 6 group name)
2. Look for the **Remove**, **Delete**, or **X** button/icon at end of that row
3. Click the remove/delete button
   - Alternative: Some interfaces show a checkbox; check the box and look for "Remove Selected" button
   - Expected display: Row is highlighted or shows "marked for removal"

**Expected Result After Step 3.2:**
- Floor 6 Users row is marked for removal (may appear grayed out, struck-through, or highlighted)
- Remove button is acknowledged (no error message)

**Action 3.3: Confirm Removal**
1. Dialog box or popup may appear asking: "Are you sure you want to remove this assignment?"
2. If dialog appears:
   - Click: **Yes**, **Confirm**, or **Remove** button
   - Expected display: Dialog closes; assignment row disappears from table
3. If no dialog:
   - Proceed to 3.4

**Expected Result After Step 3.3:**
- Floor 6 Users row is no longer visible in Assignments table
- Table now shows only remaining assignments (if any)
- No error message appears

**Action 3.4: Save Changes**
1. Look for button at top or bottom of page
2. Click: **Save** button (may also be labeled "Apply", "OK", or "Update")
   - Expected display: Page shows "Saving..." briefly, then confirmation message appears

**Expected Result After Step 3.4:**
- Confirmation message appears: "Assignment updated", "Changes saved", or similar
- Button becomes inactive/grayed out briefly
- Page reloads with updated assignments
- Floor 6 Users group is completely removed from assignment list

**Action 3.5: Verify Removal in Intune**
1. After save confirmation, review the Assignments table again
2. Confirm Floor 6 Users group is no longer listed
3. If other assignments exist, verify they are NOT Floor 6 related
4. Take screenshot: `Intune-Floor6App-Assignment-After.png`

**Expected Result After Step 3.5:**
- Floor 6 assignment is gone
- No other Floor 6-related assignments visible
- Screenshot saved for audit trail

**✓ PROCEED ONLY if:**
- [ ] Confirmation message appeared
- [ ] Floor 6 Users removed from assignments
- [ ] After-removal screenshot captured

---

### STEP 4: MONITOR INTUNE DEVICE SYNC (10-15 minutes)

**Starting Point:** Assignment has been removed; Intune is deploying removal policy to devices

**Action 4.1: Navigate to Device Compliance Dashboard**
1. In Intune, click: **Devices** (in left sidebar menu)
2. Click: **Monitor** (in expanded Devices submenu)
3. Click: **Device compliance** (showing compliance status across devices)

**Expected Result After Step 4.1:**
- Page shows device compliance overview
- Displays percentage of compliant/non-compliant devices
- Shows list of devices with compliance status

**Action 4.2: Check Floor 6 Device Sync Status**
1. Look for a filter or search option on the Device compliance page
2. Filter by:
   - Location: "Floor 6" (if available)
   - Org Unit: "Floor 6" (if available)
   - Device name: "FLOOR6-*" (if available)
3. Apply filter
   - Expected display: Shows only Floor 6 devices and their compliance status

**Expected Result After Step 4.2:**
- Floor 6 devices listed with compliance status
- Status should show "Compliant" (or similar positive status)
- If showing "Non-Compliant": Investigate why (usually indicates sync issue)

**Action 4.3: Check Last Sync Timestamp**
1. Click on one Floor 6 device name (e.g., FLOOR6-PC-001)
2. Device details page opens
3. Look for field labeled: "Last sync time", "Last check-in", or similar
   - Expected display: Timestamp showing when device last synced with Intune
4. Note the current time and compare:
   - Recent sync (within 5 minutes): Good ✓
   - Older sync (5-30 minutes): Acceptable (device will sync on next interval)
   - Very old sync (>1 hour): Problem; investigate below in Action 4.4

**Expected Result After Step 4.3:**
- You can see last sync timestamp
- Ideally shows sync within last 10 minutes
- If no recent sync: Device may be offline

**Action 4.4: If Device Sync is Delayed (>30 minutes), Force Sync**

**ONLY DO THIS IF last sync is older than 30 minutes:**

1. While viewing device details page:
2. Look for button: **Sync** (usually at top right of device details)
3. Click: **Sync** button
   - Expected display: Confirmation message "Sync initiated" or similar

**Expected Result After Step 4.4:**
- Confirmation message appears
- Last sync timestamp will update in 2-5 minutes
- Device policy update accelerated

**Action 4.5: Wait for Device Synchronization**
1. Return to Device compliance page
2. Watch the Floor 6 device list for status changes
3. **Wait 15-30 minutes** (normal sync interval)
4. **If you forced sync in 4.4: Wait 5-10 minutes**
5. Refresh page every 5 minutes by clicking: **Refresh** button or pressing **F5**
   - Expected display: Last sync time updates; should be recent

**Expected Result After Step 4.5:**
- All Floor 6 devices show "Compliant" status (or at least no errors)
- Last sync timestamps are recent (within 5-10 minutes)
- No devices showing "Failed" or "Error" status

**✓ PROCEED ONLY if:**
- [ ] Confirmed: 80%+ of Floor 6 devices have synced with Intune (recent last sync timestamp)
- [ ] Confirmed: No devices showing "Failed" or "Error" status
- **If >1-2 devices still not synced after 30 minutes: Escalate to Intune admin (see Escalation Path)**

---

### STEP 5: VERIFY APPLICATION UNINSTALLATION ON SAMPLE DEVICE (10 minutes)

**Starting Point:** Intune sync is complete; devices should be receiving uninstall policy

**Action 5.1: Contact User on Sample Device**
1. You selected a sample device earlier (e.g., FLOOR6-PC-001)
2. Contact the user on that device via:
   - Phone: Call their desk
   - Email: Send quick message
   - Teams/Slack: Send message
3. Message: "Hi, we're testing the fix for the login issue. Can you check if the Document Management app is still on your computer? I'm looking for it in Control Panel > Programs."

**Expected Result After Step 5.1:**
- User responds with information about app presence
- User confirms they can see Control Panel and Programs list

**Action 5.2: Manual Verification Method - Check Program List (User Does This)**
1. Ask user to:
   a. Open: Settings app (Windows key + I)
   b. Navigate to: **Apps** → **Apps & features**
   c. Look for: "Document Management" or similar app name in the list
   d. Report: "Is the app still there?"

**Expected Result After Step 5.2:**
- User reports app presence/absence
- If app is GONE (not in list): ✓ Uninstall successful
- If app is STILL THERE: Device may not have synced yet; wait additional 10 minutes and recheck

**Action 5.3: Alternative Verification - PowerShell Check (IT Does This Remotely)**

**If you have PowerShell/remote access to the device:**

1. Open PowerShell as Administrator
2. Run command:
   ```powershell
   Get-WmiObject -Class Win32_Product | Where-Object { $_.Name -like "*Document*" }
   ```
3. Press Enter
4. **Expected Result:**
   - If app is uninstalled: Command returns NO results (blank)
   - If app still installed: Shows product name and version info

**Expected Result After Step 5.3:**
- PowerShell returns no results (app uninstalled) ✓ OR
- PowerShell shows product (app still installed) - wait longer and retry

**Action 5.4: Check Event Logs (Optional, Advanced)**

**Only if you have device access and want forensic confirmation:**

1. On device, open Event Viewer
2. Navigate to: **Windows Logs** → **System**
3. Look for recent event:
   - Event ID: 11707 (successful uninstall)
   - Event ID: 1040 (install started)
4. Look for timestamp from last 30 minutes
5. **Expected Result:** Should see uninstall event (11707) in recent logs

**Expected Result After Step 5.4:**
- Event logs show successful app uninstallation
- Timestamps confirm uninstall occurred after assignment removal

**✓ PROCEED TO VERIFICATION ONLY IF:**
- [ ] Confirmed: Sample device shows app is uninstalled (Program list)
- [ ] Confirmed: PowerShell check shows no app installed (if checked)
- [ ] Confirmed: Event log shows successful uninstall (if checked)

---

### STEP 6: TEST LOGIN FUNCTIONALITY (10 minutes)

**Starting Point:** App has been uninstalled; testing login to verify primary issue is resolved

**Action 6.1: Request User Login Test**
1. Contact sample device user
2. Ask them to:
   a. Log out from their device (or wait until next reboot)
   b. Attempt to log in to their device with their normal credentials
   c. Measure approximate login time (how many seconds from login screen to desktop?)
   d. Report: "Can you log in? How long did it take?"

**Expected Result After Step 6.1:**
- User successfully logs in (no error message)
- Login time is in normal range (20-60 seconds)
- User reports "login works" or "normal speed"

**If User Cannot Log In:**
- **Action:** Ask for error message they see
- **If error:** "Wrong password" → User may have forgotten password (not our issue)
- **If error:** "Network error", "Server unavailable" → Still an issue; proceed to Escalation
- **If error:** Same error as before remediation → App may not have uninstalled; investigate

**Action 6.2: Batch User Testing (5-10 Users)**
1. Contact 5-10 random Floor 6 users (not all from one department)
2. Ask each: "Can you log in to your computer? Did it work?"
3. Ask them to measure/estimate login time
4. Collect results:
   - Name
   - Device name
   - Login successful? (Yes/No)
   - Approximate login time
5. Record in spreadsheet or document

**Expected Result After Step 6.2:**
- 100% of tested users report successful login
- Login times cluster around 20-60 seconds (normal)
- No error messages or complaints
- If 1-2 users have issues: Collect their device names; investigate separately

**Expected Result Summary:**
- ✓ Login failures resolved (users can log in)
- ✓ Login speed restored to normal
- ✓ No error messages or unusual delays

**✓ PROCEED TO VERIFICATION SECTION IF:**
- [ ] Confirmed: Sample device user can log in
- [ ] Confirmed: Login time is normal (20-60 seconds)
- [ ] Confirmed: Batch testing shows 90%+ success rate

---

## SECTION 4: EXPECTED RESULT AFTER EACH STEP

| Step | Action | Expected Result | Success Metric |
|------|--------|-----------------|-----------------|
| 1 | Access app in Intune | App details page displays | Can see Assignments tab |
| 2 | Verify assignment | Floor 6 Users group visible | Assignment shows "Assigned" status |
| 3 | Remove assignment | Floor 6 group deleted from list | Confirmation message appears |
| 4 | Monitor device sync | Devices receive removal policy | 80%+ devices show recent sync |
| 5 | Verify uninstall | App not in Control Panel | PowerShell shows no product |
| 6 | Test login | User logs in successfully | Login time <60 seconds |

---

## SECTION 5: VERIFICATION

### VERIFICATION 5.1: CORE SUCCESS CRITERIA (All Must Pass)

Before declaring incident resolved, verify:

**Criterion 1: Application Uninstalled**
- [ ] Sample device: App not in Programs list (User confirmed)
- [ ] PowerShell check: `Get-WmiObject` returns no results
- [ ] Event log: Event ID 11707 (successful uninstall) appears
- **Metric:** 100% of tested devices show successful uninstall

**Criterion 2: Login Functionality Restored**
- [ ] Sample device: User can log in with normal credentials
- [ ] Batch test: 90%+ of Floor 6 users report successful login
- [ ] No authentication errors or timeouts reported
- **Metric:** Login time <60 seconds; 0 login failure errors

**Criterion 3: System Performance Normal**
- [ ] CPU usage during login: <40% (not pegged at 80-100%)
- [ ] Disk I/O during login: <20% busy time (not sustained high)
- [ ] Memory usage post-login: 2-3 GB (stable, not continuously increasing)
- **Metric:** Performance metrics return to baseline

**Criterion 4: No Unintended Changes**
- [ ] Only Floor 6 devices affected (other floors not impacted)
- [ ] No other applications removed unintentionally
- [ ] Device compliance remains stable
- **Metric:** No unexpected changes to non-Floor 6 devices

### VERIFICATION 5.2: DETAILED VERIFICATION CHECKLIST

**Run this checklist after Step 6:**

**Performance Verification:**
- [ ] Check Intune dashboard for any device errors
- [ ] Verify no devices show "Non-Compliant" status
- [ ] Confirm last sync times are recent (within 15 minutes)

**Application Verification:**
- [ ] Sample device: App confirmed uninstalled
- [ ] Sample device: No app shortcuts on desktop
- [ ] Event log: Successful uninstall recorded
- [ ] Verify no app processes running (PowerShell: `Get-Process | grep -i document`)

**Login Verification:**
- [ ] 5-10 test users report successful login
- [ ] Login times average 20-60 seconds
- [ ] No login timeout errors in event logs
- [ ] No authentication failures reported

**User Communication Verification:**
- [ ] "All Clear" notification prepared and ready to send
- [ ] Help Desk briefed on issue resolution
- [ ] Escalation contact numbers provided to Help Desk

---

## SECTION 6: ROLLBACK OF ROLLBACK (Recovery/Undo)

**Use this section ONLY if you need to undo the removal and restore the app deployment.**

### SCENARIO: When Would You Need Rollback of Rollback?
- [ ] Tests reveal app was incorrectly removed from multiple floors (unintended impact)
- [ ] Critical business process requires Document Management app immediately (can't wait for fix)
- [ ] Wrong app was removed; need to restore it while investigating correct app
- [ ] Floor 6 director demands app be restored pending investigation of the issue

### PROCEDURE 6.1: RESTORE APP ASSIGNMENT IN INTUNE (Reverse of Step 3)

**Starting Point:** You are logged into Intune; access to Apps section

**Action 6.1.1: Navigate to Document Management App**
1. **Apps** → **Windows apps**
2. Search: "Document Management"
3. Click on app name to open details

**Expected Result:** App details page displays

**Action 6.1.2: Open Assignments Section**
1. Click: **Assignments** tab
2. Click: **Edit** button

**Expected Result:** Assignments section becomes editable

**Action 6.1.3: Add Floor 6 Assignment Back**
1. Look for: **Add Groups** or **Add Assignment** button
2. Click it
3. Search for: "Floor 6 Users" or Floor 6 group name
4. Select the group checkbox
5. Under "Assignment Type", select: **Assigned** (or **Required**)
6. Click: **Save** or **Select** button

**Expected Result:** Floor 6 Users group is added back to assignments list

**Action 6.1.4: Save Changes**
1. Click: **Save** or **Apply** at top/bottom of page
2. Confirmation message appears: "Assignment updated"

**Expected Result:** Floor 6 Users assignment is restored

**Action 6.1.5: Monitor Redeployment**
1. Follow STEP 4 again (Monitor Intune Device Sync)
2. Wait for devices to sync (15-30 minutes)
3. Verify: Devices show recent sync timestamp

**Expected Result:** Devices receive app redeployment policy; app begins reinstalling

**⚠️ IMPORTANT NOTES on Rollback of Rollback:**
- This restores the BROKEN version of the app
- Users will experience same login issues again
- Use only as emergency measure while root cause is being fixed
- **Do NOT leave in this state.** App must be fixed before restoring.

### PROCEDURE 6.2: COMMUNICATE ROLLBACK OF ROLLBACK TO USERS

**If you had to restore app deployment, users need to know:**

Send email to Floor 6:

```
Subject: Floor 6 - Application Restoration [Incident #FLR6-002]

The Document Management application is being restored to Floor 6 devices.

REASON: We need more time to fix the underlying issue.

WHAT TO EXPECT:
- You may experience login delays again (we are investigating root cause)
- App will be restored by [TIME]
- We will communicate a permanent fix by [DATE]

We apologize for the disruption and the need to reverse the removal.
```

---

## SECTION 7: NOTES & TROUBLESHOOTING

### Common Issues & Solutions

**Issue 7.1: "Access Denied" When Accessing Intune**
- **Cause:** Insufficient permissions
- **Solution:** Request temporary Intune Service Admin role from IT Director
- **Timeline:** 5-10 minutes to grant access
- **Do NOT proceed without access**

**Issue 7.2: Cannot Find Document Management App in Intune**
- **Cause:** App may be named differently than expected
- **Solution:** 
  - Check Friday's change management ticket for exact app name
  - Ask application owner for app name in Intune
  - Search for part of name (e.g., "Document", "Portal", "Management")
- **If still not found:** App may not be deployed as Intune app; check if it's a Group Policy or PowerShell script instead

**Issue 7.3: Device Sync Takes Longer Than 30 Minutes**
- **Cause:** Device offline, poor network, or sync interval configured for longer periods
- **Solution:**
  - Force sync using STEP 4 Action 4.4
  - Wait additional 30 minutes
  - If still not synced: Escalate to Intune admin (see Escalation Path)
- **Note:** Do NOT manually uninstall on device; let Intune handle it

**Issue 7.4: App Still Installed on Device After 1 Hour**
- **Cause:** Device sync failed, or app has uninstall issues
- **Solution:**
  - Verify device sync completed (check last sync time in Intune)
  - If device shows "Non-Compliant": Investigate compliance failure
  - If device shows "Compliant" but app still installed: Manual intervention needed
    - On device: Settings → Apps → Apps & features → Find app → Click **Uninstall** → Follow prompts
- **Escalation:** If more than 2 devices require manual intervention, escalate to Intune admin

**Issue 7.5: Users Still Cannot Log In After App Removal**
- **Cause:** 
  - App not fully uninstalled yet
  - Device restart required (login cache issue)
  - Different root cause than suspected
- **Solution:**
  - Ask user to restart device and try login again
  - Wait 30 seconds after restart; login should work
  - If still failing: Collect error message and escalate
- **Escalation Trigger:** If >2 users still cannot log in after 1 hour → Escalate to IT Director

**Issue 7.6: Wrong App Was Removed**
- **Cause:** Misidentified which app was causing issue
- **Solution:**
  - **IMMEDIATELY:** Reverse using SECTION 6 (Rollback of Rollback)
  - Investigate correct app causing issue
  - Identify correct app to remove
  - Repeat entire runbook with correct app
- **Prevention:** Always verify app name with application owner before Step 3

**Issue 7.7: App Removed From More Than Just Floor 6**
- **Cause:** Assignment scope was broader than expected (e.g., "All Devices" instead of "Floor 6 Users")
- **Solution:**
  - **IMMEDIATELY:** Reverse using SECTION 6 (Rollback of Rollback)
  - Investigate why assignment was broader
  - Check with Intune admin about assignment configuration
  - Verify assignment scope before re-removing
- **Prevention:** Screenshot Intune assignment before Step 3; verify Floor 6 only

---

## SECTION 8: ESCALATION PATH

**Use this decision tree to determine when to escalate:**

### Level 1: Help Desk Technician (You Are Here)

**Authority:** Execute runbook steps, collect information

**Escalate UP if:**
- [ ] You cannot access Intune (permissions issue)
- [ ] App name cannot be identified
- [ ] More than 2 devices not syncing after 30 minutes
- [ ] More than 2 users still cannot log in after 1 hour
- [ ] You discover assignment is broader than Floor 6 only
- [ ] Any step produces unexpected error message
- [ ] You are unsure whether to proceed to next step

**Escalation Contact (Level 2):** 
- **Name:** IT Manager / Intune Administrator
- **Title:** Intune Administrator
- **Contact:** [Phone/Email] ___________________________
- **Expected Response:** Within 5 minutes

**What to Report When Escalating:**
1. Exact error message or issue
2. Which step/action was being performed
3. Screenshot of the issue
4. What you've already tried
5. Any device names or user names affected

---

### Level 2: Intune Administrator

**Authority:** Troubleshoot Intune issues, modify policies, grant access

**Escalate UP if:**
- [ ] Multiple floors affected (not just Floor 6)
- [ ] Widespread device sync failures (>30% of Floor 6)
- [ ] Evidence of malicious removal (not accidental)
- [ ] Root cause cannot be determined
- [ ] Need emergency policy override

**Escalation Contact (Level 3):**
- **Name:** IT Director
- **Title:** IT Operations Director
- **Contact:** [Phone/Email] ___________________________
- **Expected Response:** Within 10 minutes

---

### Level 3: IT Director

**Authority:** Decision authority, incident command, executive communication

**Escalate UP only if:**
- [ ] Business-critical system failure
- [ ] Data loss or data breach
- [ ] Executive visibility needed
- [ ] Decision to rollback of rollback needed

**Escalation Contact (Executive):**
- **Name:** Chief Information Officer (CIO)
- **Title:** CIO
- **Contact:** [Phone/Email] ___________________________

---

### Escalation Template (Use This When Escalating)

**When you need to escalate, send this:**

```
ESCALATION: Floor 6 Deployment Rollback
Incident #: FLR6-002
Current Step: [Which step/action]
Issue: [Describe problem]
Error Message: [Exact error text]
Screenshots: [Attached]
Devices Affected: [Device names]
Users Affected: [User names]
Timeline: Started at [TIME], escalating at [TIME]
Attempts Made: [What you've already tried]
Next Action Needed: [What you need help with]
Urgency: [HIGH/MEDIUM/LOW based on impact]

Can you assist? [Yes/No]
```

---

## SECTION 9: QUICK REFERENCE

### Key Portal Locations
```
Intune Admin Center: https://intune.microsoft.com/
Apps Section: Intune > Apps > Windows apps
Device Status: Intune > Devices > Manage devices > Windows
Compliance: Intune > Devices > Monitor > Device compliance
Group Membership: Azure AD > Groups > Search "Floor 6"
```

### Key Contacts
```
IT Manager: [___________________________]
Intune Admin: [___________________________]
IT Director: [___________________________]
Help Desk: [___________________________]
Incident Commander: [___________________________]
```

### Timeline Milestones
```
09:14 - Incident reported (login failures)
10:30 - Rollback decision made
10:31 - Initial user notification sent
10:35 - Step 1 (Access app in Intune)
10:45 - Step 3 (Remove assignment)
11:00 - Step 4 (Monitor sync)
11:15 - Step 5 (Verify uninstall)
11:30 - Step 6 (Test login)
12:00 - All-clear notification sent
14:00 - Incident closed
```

### PowerShell Commands Reference
```powershell
# Check if app is installed
Get-WmiObject -Class Win32_Product | Where-Object { $_.Name -like "*Document*" }

# If app still installed, you can uninstall (if needed)
Get-WmiObject -Class Win32_Product | Where-Object { $_.Name -like "*Document*" } | ForEach-Object { $_.Uninstall() }

# Force Intune sync
Get-ScheduledTask -TaskName "Intune Management Extension Scheduled Task" | Start-ScheduledTask
```

---

## SECTION 10: SIGN-OFF & AUTHORIZATION

### Executed By (Print Name & Sign)

**Name:** _________________________________

**Title:** _________________________________

**Date:** _________________________________

**Time Started:** ____________ | **Time Completed:** ____________

**Runbook Version Used:** 1.0

### Approved By (IT Director)

**Name:** _________________________________

**Title:** IT Director

**Signature:** _________________________________

**Date:** _________________________________

**Approval to Proceed:** ☐ Yes ☐ No

---

## APPENDIX: SCREENSHOT CHECKLIST

**Save these screenshots during the runbook for audit trail:**

- [ ] `01-Intune-Login.png` – Proof of Intune access
- [ ] `02-App-Details-Page.png` – Document Management app details
- [ ] `03-Assignment-Before.png` – Assignments before removal (Floor 6 Users visible)
- [ ] `04-Assignment-After.png` – Assignments after removal (Floor 6 Users gone)
- [ ] `05-Device-Sync-Status.png` – Device compliance showing recent sync
- [ ] `06-App-Uninstalled.png` – Programs list showing app uninstalled
- [ ] `07-Login-Success.png` – Screenshot of successful login (optional)

**Store screenshots in folder:** `C:\Incidents\FLR6-002\Screenshots\` (or per incident management procedure)

---

**END OF RUNBOOK**

**Version History:**
- v1.0 (14-Aug-2026): Initial draft for emergency deployment rollback

**Next Review Date:** 21-Aug-2026

**Approval Status:** DRAFT (Review before production use)
