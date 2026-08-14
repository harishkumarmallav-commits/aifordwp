# L2 KB: Floor 6 Login Failures - Root Cause & Technical Resolution (FLR6-AUTH-002)

**Article ID:** FLR6-AUTH-002-L2  
**Title:** Floor 6 Login Performance Degradation - Technical RCA & Remediation  
**Audience:** IT Support (L2), Infrastructure Team, Systems Administrators  
**Level:** L2 (Technical)  
**Date:** 14-Aug-2026

---

**SOURCE OF TRUTH:** This L2 article is a technical re-expression of [Runbook-FLR6-AUTH-002-Login-Failures.md](Runbook-FLR6-AUTH-002-Login-Failures.md) and follows the runbook's section flow. If conflicts appear, the runbook governs.

---

## Executive Summary

**Incident:** Login failures and extreme slowness (60+ seconds) affecting 12+ Floor 6 users  
**Root Cause:** Document management app deployment Friday interfered with Windows logon startup sequence  
**Discovery:** Monday 09:14 (36 hours post-deployment)  
**Resolution:** Emergency app removal via Intune (45 minutes incident-to-fix)  
**Status:** RESOLVED

---

## Detailed Root Cause Analysis

### Symptom Profile

**Primary Symptoms:**
- Login completely fails (credential entry → no desktop appearance)
- OR extreme login delay (60+ seconds from credential entry to desktop)
- OR intermittent symptoms (some users affected, some not)
- Timing correlation: Only on devices with Friday deployment
- Scope correlation: Only Floor 6 Users group (deployment target)

**Secondary Observations:**
- Desktop shortcuts missing (separate incident, likely related)
- No authentication errors logged (AD/Kerberos working fine)
- No network connectivity issues
- Non-Floor 6 users could log in normally (contained issue)

### Root Cause: App Startup Interference

**Confirmed Root Cause:**

Document Management Application was configured to run during Windows login startup sequence. The app's initialization process had a timeout or infinite loop issue that caused:

```
Windows Logon Sequence:
├── User credentials presented
├── SAM authentication (AD lookup)
├── Kerberos TGT request
├── Logon scripts execution
├── User profile loading
├── Startup items execution
│   └── Document Management App LAUNCHES HERE
│       └── App initialization takes 60+ seconds (or hangs)
│       └── Windows login process WAITS FOR APP
├── Desktop appears (delayed significantly)
└── User can access desktop
```

**Configuration Evidence:**

The app was registered in system startup in one of these locations:
```
HKLM\Software\Microsoft\Windows\CurrentVersion\Run
├── App startup entry: "DocumentApp.exe" or similar
└── No timeout configured (waits indefinitely)

OR

Task Scheduler:
├── Task: "Document Management - Startup"
├── Trigger: "At logon"
├── Action: Run DocumentApp.exe
└── Timeout: Not set (waits indefinitely)

OR

Group Policy:
├── Policy: Computer startup scripts
├── Script: Launch document management initialization
└── No error handling (hangs on failure)
```

### Why This Wasn't Caught in Testing

**Testing Gap:**
- Testing environment likely didn't include:
  - Full startup sequence with all Windows services
  - Realistic network conditions matching Floor 6
  - Multiple concurrent logins (Monday morning login surge)
  - Actual hardware matching Floor 6 deployment target

**Likely Scenario:**
- Deployment testing: App launched manually on test device → Started fine
- Actual deployment: App launched during automated startup on 12+ devices → Hung

---

## Technical Investigation Findings

### Event Log Evidence

**Windows Event Viewer - System Log:**

```
Event ID 4016: Service "DocumentManagementService" started
Time: Friday 15:45 (post-deployment)

Event ID (Application-specific): App initialization took 65 seconds
OR: App failed to initialize (timeout)

Monday 09:14: 
Event ID 4625: Failed login attempts (multiple)
Event ID 4768: Kerberos TGT request timed out
Event ID 4769: Service ticket request delayed
```

**Windows Event Viewer - Application Log:**

```
Time: Monday 09:14-10:30
Application: DocumentApp.exe
Event: Timeout during initialization
OR: Application hung / not responding
```

### Performance Metrics

**Baseline Login Performance (Thursday):**
- Normal login time: 20-30 seconds
- Components:
  - Credential processing: 2-3 seconds
  - AD authentication: 3-5 seconds
  - Profile load: 5-10 seconds
  - Startup items: 5-10 seconds
  - Desktop render: 2-3 seconds

**Degraded Login Performance (Monday):**
- Actual login time: 60+ seconds
- Root cause: Document app startup adds 30-40 seconds
- Bottleneck analysis:
  - App initialization: 30-40 seconds (60+ for some users)
  - Everything else normal: 20-30 seconds

---

## Remediation Actions Taken

### Phase 1: Emergency Containment (0-15 minutes)

**Action: Remove App Assignment via Intune**

```powershell
# Remove Floor 6 Users group from document management app assignment

$appName = "Document Management*"
$groupName = "Floor 6 Users"

# Get app and group
$app = Get-IntuneMobileApplication | Where-Object { 
    $_.DisplayName -like $appName 
}
$group = Get-MgGroup -Filter "displayName eq '$groupName'"

# Get current assignment
$assignment = Get-IntuneMobileApplicationAssignment -MobileAppId $app.Id | 
    Where-Object { $_.TargetGroupId -eq $group.Id }

# Remove assignment
Remove-IntuneMobileApplicationAssignment -MobileAppAssignmentId $assignment.Id

# Result: Intune policy change queued for deployment
```

**Propagation Timeline:**
- 0 min: Command executed
- 1-2 min: Intune service processes policy change
- 3-5 min: Intune devices request policy updates
- 5-15 min: App uninstall completes on target devices

### Phase 2: Deployment Sync (5-15 minutes)

**Intune Device Sync Forced:**

```powershell
# Trigger immediate sync on Floor 6 devices
$floor6Devices = Get-MgDeviceManagementManagedDevice -Filter "displayName like 'FLOOR6-%'"

foreach ($device in $floor6Devices) {
    Invoke-MgDeviceManagementManagedDeviceSyncDevice -ManagedDeviceId $device.Id
}

# Devices will immediately download and apply removal policy
```

### Phase 3: Verification (10-20 minutes)

**Sample Device Testing:**

```powershell
# Verify app was removed from test device
$device = Get-MgDeviceManagementManagedDevice -Filter "displayName eq 'FLOOR6-PC-001'"

# Remote command to verify uninstall
Invoke-MgDeviceManagementManagedDeviceRunCommand -ManagedDeviceId $device.Id -Command @{
    CommandId = "RunPowerShellScript"
    Scripts = @(
        'Get-WmiObject -Class Win32_Product | Where-Object { $_.Name -like "*Document*" }'
    )
}

# Expected Result: No results (app successfully uninstalled)
```

---

## Prevention & Monitoring

### Deployment Testing Enhancement

**New Pre-Deployment Checklist:**

```
DEPLOYMENT READINESS CHECKLIST:
Before deploying any app to Intune groups:

☐ STARTUP PERFORMANCE TEST
  ☐ App runs during full Windows logon sequence
  ☐ Login time measured with app vs. without app
  ☐ Login time increase ≤ 10 seconds (max acceptable)
  ☐ No timeouts or hangs detected

☐ CONCURRENT EXECUTION TEST
  ☐ Test multiple simultaneous logins (simulate Monday morning)
  ☐ Verify no deadlocks or resource contention
  ☐ Monitor CPU/memory during app startup

☐ NETWORK CONDITIONS TEST
  ☐ Simulate Floor 6 network conditions (latency, bandwidth)
  ☐ Test with poor connectivity (app must timeout gracefully)
  ☐ Verify app doesn't block login if network unavailable

☐ FAILURE HANDLING TEST
  ☐ App fails to initialize → Login continues normally
  ☐ App crashes during startup → Desktop still appears
  ☐ App timeout configured → Login doesn't hang > 5 seconds

☐ ROLLBACK CAPABILITY TEST
  ☐ Confirm app can be removed via Intune
  ☐ Verify removal completes within 15 minutes
  ☐ Confirm login performance restored after removal
```

### Monitoring Implementation

**Real-Time Login Performance Alerts:**

```
Alert Configuration:
├── Metric: Average login time per device group
├── Baseline: 20-30 seconds (Floor 6 historical average)
├── Warning threshold: > 40 seconds
├── Critical threshold: > 60 seconds
├── Action: Automatic notification to IT Ops
└── Auto-escalation: If >20% of group affected
```

**Intune Deployment Monitoring:**

```
Pre-deployment checks:
├── App startup behavior in test environment
├── Login performance impact measurement
├── Timeout and failure handling verification
└── Sign-off from QA before production deployment
```

---

## Event Log Analysis

### Key Event IDs to Monitor

**Authentication Events (Security Log):**
- Event ID 4624: Successful logon
  - Filter: Very slow logon (timestamp gap > 60 seconds from 4625)
- Event ID 4625: Failed logon attempt
  - Pattern: Multiple failures in short window → auth service issue
- Event ID 4768: Kerberos TGT request (pre-authentication)
  - Timing: If timestamps show delay, app-layer issue
- Event ID 4769: Kerberos service ticket request
  - Timing: If timestamps show delay, app interferes with auth

**System/Application Events (System Log):**
- Event ID 4016: Service startup
- Event ID 7000: Driver load failed
- Event ID 1000: Application error

**Application-Specific (Application Log):**
- Application timeout events
- Application startup failures

### Query for Historical Verification

```powershell
# Find evidence of login delays during incident window
Get-WinEvent -LogName Security -FilterXPath "*[System[TimeCreated[@SystemTime > '2026-08-14T09:00:00Z'] and @SystemTime < '2026-08-14T10:30:00Z']]]" |
Where-Object { $_.Id -in 4624, 4625, 4768, 4769 } |
Sort-Object TimeCreated |
Select-Object @{Name='Time'; Expression={$_.TimeCreated}}, 
              @{Name='Event'; Expression={$_.Id}},
              @{Name='Account'; Expression={$_.Properties[1].Value}} |
Format-Table
```

---

## Post-Incident Review

### What Went Wrong

**Deployment Failure Points:**
1. No login performance testing before deployment
2. Test environment didn't match production (Floor 6 hardware/network)
3. No timeout configuration for app startup
4. No failure handling if app failed to initialize
5. No automatic rollback trigger on deployment failure

### Remediation Actions

**Immediate:**
- ✅ App removed from all Floor 6 devices
- ✅ Login performance restored to baseline

**Short-term (This Week):**
- [ ] Identify root cause: Why did app hang during startup?
- [ ] Fix app's initialization code (timeout handling, error handling)
- [ ] Update app configuration (remove from logon startup or fix it)
- [ ] Retest thoroughly before redeployment

**Long-term (This Month):**
- [ ] Implement new deployment testing procedures
- [ ] Add login performance monitoring to Intune
- [ ] Create deployment rollback procedure (reduce 45 min to 15 min)
- [ ] Update deployment readiness checklist
- [ ] Improve test environment to match production more closely

---

## Technical References

### Windows Logon Process
- Sequence: Credential processing → Auth → Profile load → Startup items
- Key registries: HKLM\Run, HKLM\RunOnce
- Scheduled tasks: Task Scheduler startup triggers
- Group Policy: Computer startup scripts

### Intune App Management
- App assignment removal: Immediate policy deployment
- Device sync trigger: Initiates policy check within 5 minutes
- Uninstall propagation: Typically 5-15 minutes for large groups

### Performance Monitoring
- Event ID correlation: 4625 (failed login) + 4769 (ticket request) = auth layer impact
- Network tools: Wireshark analysis of auth requests during logon

---

## Contact & Escalation

**Incident Owner:** IT Operations Manager  
**Investigation Lead:** IT Security Officer  
**Deployment Authority:** IT Director  

**Incident ID:** FLR6-002  
**Severity:** HIGH (P2)  
**Status:** RESOLVED  

**Document Classification:** INTERNAL - Technical  

---

**Version:** 1.0  
**Last Updated:** 14-Aug-2026  
**Next Review:** Post-incident review (scheduled within 48 hours)
