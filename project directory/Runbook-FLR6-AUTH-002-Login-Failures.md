# Floor 6 Login Failures Emergency Response Runbook

**Title:** Floor 6 Authentication Failures - Rapid Diagnosis & Rollback Response

**Version:** 1.0

**Date:** 14-Aug-2026

**Status:** Draft (Review before production use)

**Scenario:** 12+ users on Floor 6 unable to log in or experiencing severe login delays (60+ seconds). Issue correlates with Friday afternoon document management app deployment. Emergency response required to restore user access within 1 hour.

**Estimated Duration:** 30-45 minutes (diagnosis + remediation)

---

## SECTION 1: BACKGROUND & CONTEXT

### What Happened
Friday 15:00 – Document management application deployed to Floor 6 devices via Intune  
Monday 09:00-09:14 – Users report login failures and extreme login delays beginning Monday morning  
Monday 10:30 – Root cause confirmed: App startup process interferes with Windows login phase

### Why This is Critical
- 12+ users unable to access systems (complete productivity loss)
- High-cost user population (paralegal, finance staff = $75+/hour)
- Business impact: $900/hour minimum downtime cost
- Cascading effect: Email, file access, applications all blocked by authentication failure
- Rapid remediation required: Every 15 minutes = $225 in lost productivity

### What This Runbook Does
Executes rapid diagnosis and emergency remediation:
1. Confirm authentication service health (3 minutes)
2. Verify new app deployment is cause (5 minutes)
3. Execute emergency rollback OR alternative remediation (15-20 minutes)
4. Verify login restoration across Floor 6 users (10 minutes)
5. Monitor system stability (ongoing)

### Approval Required Before Proceeding
- [ ] IT Director approval obtained (or incident commander authorization)
- [ ] User communication approved
- [ ] Incident ticket created (reference: FLR6-002)

**If approval not obtained:** STOP. Return to incident commander immediately.

---

## SECTION 2: PREREQUISITES

### Personnel Required
- **Primary:** Intune Administrator or IT Admin with elevated privileges
- **Secondary:** IT Support technician (for user verification and device testing)
- **Tertiary:** Network administrator (if infrastructure issue suspected)

### Access & Permissions Required
1. **Intune Admin Access**
   - Must have: Global Admin or Intune Service Administrator role
   - Verify by: Can access https://intune.microsoft.com/ without error

2. **Device Access**
   - One Floor 6 device available for testing (with affected user's permission)
   - Device must be enrolled in Intune
   - Administrative console access for remote command execution

3. **Domain Controller Access (if needed)**
   - Access to on-premises Active Directory or Azure AD
   - Can query domain controller health and replication status
   - Access to domain controller event logs

### Information to Gather Before Starting

**Collect this information immediately:**

1. **Affected User Details**
   - [ ] Number of affected users: `_____________________________`
   - [ ] List of affected user names/emails: `_____________________________`
   - [ ] Is impact Floor 6 only or wider?: `_____________________________`

2. **Device & Network Details**
   - [ ] Test device name: `_____________________________`
   - [ ] Network segment (WiFi SSID or IP range): `_____________________________`
   - [ ] Are all affected devices on same network?: YES / NO / UNKNOWN

3. **Deployment Details**
   - [ ] Document management app name: `_____________________________`
   - [ ] Deployment time Friday: `_____________________________`
   - [ ] Target user group: `Floor 6 Users` (or: `_____________________________`)

4. **Baseline Information (For Comparison)**
   - [ ] Normal login time before Friday: `_____________________________` seconds
   - [ ] Current login time (if possible): `_____________________________` seconds

### System Requirements
- **Workstation:** Must have internet access and admin console access
- **Tools:** PowerShell with Azure AD modules installed
- **Access:** VPN required if accessing remotely
- **Time:** Minimum 45 minutes uninterrupted

---

## SECTION 3: IMMEDIATE DIAGNOSTICS (0-10 minutes)

### Step 1: Confirm Authentication Service Health (3 minutes)

**Action 1.1 – Check Azure AD/Domain Controller Status**
```powershell
# Option A: Azure AD (Cloud Authentication)
$status = Get-MgServiceHealth -All | Where-Object { $_.ServiceName -eq "Azure Active Directory" }
if ($status.HealthIssues.Count -eq 0) {
    Write-Host "Azure AD status: HEALTHY"
} else {
    Write-Host "Azure AD issues detected: $($status.HealthIssues)"
}

# Option B: On-Premises Active Directory
# Run on domain controller or administrative workstation:
# Check AD Replication Status
repadmin /replsum

# Check Domain Controller health
dcdiag /a /v

# Expected Result: No replication errors, all domain controllers replicating successfully
```

**Action 1.2 – Check Network Connectivity**
```powershell
# Verify network path to authentication services
# From Floor 6 device or network segment:

# Test DNS resolution
nslookup login.microsoftonline.com
# Expected: Returns valid IP address

# Test network connectivity to auth services
Test-NetConnection -ComputerName login.microsoftonline.com -Port 443
# Expected: TcpTestSucceeded = True

# Test domain controller connectivity (if on-premises AD)
Test-NetConnection -ComputerName [DC-name] -Port 389
```

**Action 1.3 – Review Authentication Logs for Errors**
```powershell
# Run on affected device via Intune Run Command:

# Retrieve recent authentication events (last 12 hours)
Get-WinEvent -LogName Security -FilterXPath "*[System[TimeCreated[@SystemTime > '$([DateTime]::Now.AddHours(-12).ToUniversalTime().ToString('o'))']]]" | 
Where-Object { $_.Id -in 4625, 4768, 4769, 4771 } | 
Select-Object TimeCreated, Id, Message | 
Out-String

# Event ID meanings:
# 4625 = Failed login attempt
# 4768 = Kerberos TGT request failed
# 4769 = Kerberos service ticket failed
# 4771 = Pre-authentication failed

# Expected Result: No unusual error patterns; errors should match known users
```

**Expected Result:** Authentication services confirmed healthy OR specific failure identified.

---

### Step 2: Identify Root Cause - New App or Infrastructure? (5 minutes)

**Action 2.1 – Check Friday's Deployment Activities**
```powershell
# Review Intune deployment history for Friday afternoon

# Navigate to: Intune Portal → Apps → App assignments
# Find: Document Management Application
# Check: Deployment time, target group, assignment type
# Verify: Deployment completed successfully or pending?

# Query Intune deployment status:
$appName = "Document Management*"  # Adjust to actual app name
$app = Get-IntuneMobileApplication | Where-Object { $_.DisplayName -like $appName }
$assignments = Get-IntuneMobileApplicationAssignment -MobileAppId $app.Id
$assignments | Select-Object TargetGroupId, @{Name="AssignmentType"; Expression={$_.IntentFilter}} | Format-Table
```

**Action 2.2 – Test Login WITHOUT App (Quick Verification)**
```powershell
# Option A: Test login from device NOT deployed with app
# Find a device on adjacent floor or network that was NOT in Friday deployment
# Have IT support test login from that device
# Expected Result: Login should be fast (baseline speed)
# If fast login on non-deployed device: App is likely cause

# Option B: Test login from safe mode (app startup bypassed)
# On affected Floor 6 device:
# Boot into Safe Mode with Networking
# Attempt user login
# Expected Result: If login is fast in Safe Mode, app startup is blocking normal boot

# If successful in Safe Mode: Confirms app is interfering with login
# Proceed to rollback (Section 4)
```

**Action 2.3 – Check App Startup Configuration**
```powershell
# Query app's registry startup entries on affected device
# Run via Intune Run Command:

Get-ItemProperty -Path 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Run' | 
Select-Object -Property * | 
ConvertTo-Json

# Look for: Document Management app or related processes
# Expected: May find app scheduled to run at startup
# If app hangs during startup: Explains login delays

# Alternative check: Scheduled tasks at startup
Get-ScheduledTask | Where-Object { $_.Triggers.Trigger.Enabled -eq $true } | 
ForEach-Object {
    if ($_.Actions.Execute -like "*Document*" -or $_.Actions.Execute -like "*Management*") {
        $_ | Select-Object TaskName, Triggers, State
    }
}
```

**Expected Result:** Root cause identified as either app-related or infrastructure-related.

---

## SECTION 4: REMEDIATION DECISION TREE

### Is Root Cause the New App? (Decision Point)

**If YES → Proceed to Step 3 (Rollback)**
**If NO → Proceed to Step 3B (Infrastructure Fix)**
**If UNCLEAR → Proceed to Step 3A (Containment)**

---

## SECTION 3A: CONTAINMENT (If Cause Unclear)

**Action 3A.1 – Immediate Workaround for Users**

```powershell
# While diagnostics continue, provide temporary workaround to users:
# Option: Boot device into Safe Mode + Networking (bypasses app startup)
# Users can access login via alternative method

# Communicate to users:
# "Please restart your device and select Safe Mode when prompted.
#  Log in normally. This temporarily bypasses the problematic app.
#  We're working on a permanent fix (rollback) within 30 minutes."
```

**Action 3A.2 – Continue Diagnostics in Parallel**
```powershell
# While users have workaround, continue investigation
# Proceed to Step 3 or 3B based on findings
```

---

## SECTION 3: EMERGENCY ROLLBACK (If App Cause Confirmed)

**Objective:** Remove problematic app from all Floor 6 devices within 15 minutes

**Action 3.1 – Remove App via Intune Assignment**

Navigate to: Intune Portal → Apps → All apps → Select Document Management Application

1. Click "Assignments"
2. Find assignment: "Floor 6 Users" or appropriate group
3. Click "..." menu → Delete assignment
4. Confirm deletion

**PowerShell Alternative:**
```powershell
# Remove app assignment for Floor 6 Users group
$appName = "Document Management*"  # Adjust to actual app name
$groupName = "Floor 6 Users"  # Adjust to actual group name

$app = Get-IntuneMobileApplication | Where-Object { $_.DisplayName -like $appName }
$group = Get-MgGroup -Filter "displayName eq '$groupName'"
$assignment = Get-IntuneMobileApplicationAssignment -MobileAppId $app.Id | 
    Where-Object { $_.TargetGroupId -eq $group.Id }

# Remove assignment
Remove-IntuneMobileApplicationAssignment -MobileAppAssignmentId $assignment.Id

Write-Host "App assignment removed. Devices will sync and uninstall app within 5-15 minutes."
```

**Action 3.2 – Force Intune Sync on Floor 6 Devices**

Navigate to: Intune Portal → Devices → Windows devices

For each Floor 6 device:
1. Select device
2. Click "Sync" button
3. Confirm sync initiated

**PowerShell Alternative:**
```powershell
# Force sync on all Floor 6 devices
$floor6Devices = Get-MgDeviceManagementManagedDevice -Filter "displayName like 'FLOOR6-%'" 

foreach ($device in $floor6Devices) {
    # Trigger device sync
    Invoke-MgDeviceManagementManagedDeviceSyncDevice -ManagedDeviceId $device.Id
    Write-Host "Sync triggered for device: $($device.DisplayName)"
}
```

**Expected Result:** All Floor 6 devices will uninstall the problematic app within 5-15 minutes.

**Action 3.3 – Monitor App Removal Completion (5 minutes)**

Wait for Intune policy sync completion. Typical timeline:
- Intune policy update: 2-3 minutes
- Device downloads removal policy: 3-5 minutes
- Device uninstalls app: 2-5 minutes
- **Total: 5-15 minutes**

**Check Uninstall Status:**
```powershell
# Verify app was removed from device
# Run via Intune Run Command on test device:

Get-WmiObject -Class Win32_Product | Where-Object { $_.Name -like "*Document*" } | Select-Object Name, Version

# Expected Result: App should NOT be returned (indicating successful uninstall)

# If app still present after 10 minutes: May need manual uninstall
# If app still present after 15 minutes: Escalate to Intune support
```

---

## SECTION 3B: INFRASTRUCTURE FIX (If Not App-Related)

**If diagnostics indicate infrastructure cause (AD replication, DNS, network):**

```powershell
# Network Issue:
If (network connectivity problem detected) {
    # Escalate to Network/Infrastructure team
    # Request: Verify Floor 6 network path to authentication servers
    # Request: Check firewall rules for authentication port access (443, 389)
    # Request: Verify DNS resolution to identity services
    Exit "Escalate to network team - not IT operations issue"
}

# Domain Controller Issue:
If (AD replication error detected) {
    # Escalate to Directory Services team
    # Request: Fix domain controller replication errors
    # Request: Force replication synchronization
    # Request: Restart affected domain controllers if necessary
    Exit "Escalate to AD support team"
}

# Authentication Service Issue:
If (Azure AD service issue detected) {
    # Issue: Cloud authentication service failure
    # Action: Monitor Microsoft 365 status page
    # Action: Contact Microsoft Support
    # Temporary: Enable cloud-only authentication fallback (if available)
    Exit "Escalate to Microsoft Support"
}
```

---

## SECTION 4: VERIFICATION & USER COMMUNICATION

### Step 4: Verify Login Restoration

**Action 4.1 – Test Login on Sample Floor 6 Device**

1. Select one Floor 6 device for testing
2. Request user login attempt
3. Measure login time
4. Compare against baseline (should return to pre-Friday speed)

**Expected Result:** Login completes in <30 seconds (normal speed). No hangs or delays.

**Action 4.2 – Verify Across Multiple Users**

```powershell
# Request IT Support team to call or message 3-5 Floor 6 users
# Verify each can:
#  1. Successfully log in
#  2. Access email and file shares
#  3. No unusual delays or errors

# Log results:
User 1: [Name] - Login time: __ seconds - Status: OK / FAILED
User 2: [Name] - Login time: __ seconds - Status: OK / FAILED
User 3: [Name] - Login time: __ seconds - Status: OK / FAILED
```

**Expected Result:** All Floor 6 users can log in normally.

---

### Step 5: User Communication

**Action 5.1 – Notify Floor 6 Users (After Fix Confirmed)**

```
Email to: floor6-staff@company.com

Subject: Login Issue Resolved - Floor 6 Devices Updated

Body:
Good news! We've resolved the login issues affecting Floor 6 this morning.

What happened:
A software update installed Friday was interfering with normal login processes.

What we did:
We've removed the problematic software from all Floor 6 devices via our device 
management system. Devices have been updated automatically.

What you should do:
Simply log in normally—your login should now be fast again. No action needed.

If you still experience:
• Slow login
• Login failures
• Missing files or applications
Please contact the Service Desk immediately:
  Phone: Extension 555-1234
  Email: servicedesk@company.com

Thank you for your patience.
```

---

## SECTION 6: DOCUMENTATION & FOLLOW-UP

### Step 6: Document Incident Resolution

**Action 6.1 – Update Incident Ticket**

```
Ticket ID: FLR6-002
Final Status: RESOLVED

Timeline:
- 09:14 – Incident reported (12+ users with login failures)
- 09:30 – Diagnostics initiated
- 09:45 – Root cause confirmed (Document Management app interference)
- 10:00 – Emergency rollback initiated (app removal via Intune)
- 10:15 – App removal completed across Floor 6
- 10:30 – Login restoration verified
- 10:35 – Users notified

Root cause: Document Management Application startup process configured 
in Windows logon sequence (likely HKLM\Run registry entry or scheduled task).
App initialization timeout caused login process to hang at authentication phase.

Resolution: Removed problematic app deployment via Intune app assignment removal.
Intune policy synced to all Floor 6 devices; automatic uninstall completed within 15 minutes.

Business impact recovery:
- 12+ users restored to productivity
- Cost recovery: ~$900/hour × 1.5 hours = $1,350 in prevented downtime losses
```

**Action 6.2 – Post-Incident Review**

Schedule post-incident review within 24 hours:
- What went wrong in deployment testing?
- How do we prevent similar app deployment issues?
- Should we add pre-deployment testing for login process interference?
- Update deployment checklist to include app startup behavior validation?

---

## APPENDIX: QUICK REFERENCE

**Escalation Contacts:**
- IT Director: [Contact]
- Intune Administrator: [Contact]
- Network/Infrastructure: [Contact]

**Key Locations:**
- Intune Portal: https://intune.microsoft.com/
- Azure AD: https://portal.azure.com/
- Microsoft 365 Status: https://status.microsoft365.com/

**Critical Decision Points:**
- Is it app-related? → Rollback (Section 3)
- Is it infrastructure-related? → Escalate (Section 3B)
- Is it unclear? → Containment + continue diagnosis (Section 3A)

**Success Criteria:**
✓ All Floor 6 users can log in successfully
✓ Login times return to <30 seconds (pre-Friday baseline)
✓ Users can access all applications and file shares
✓ No error messages or hanging processes
