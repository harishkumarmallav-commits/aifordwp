# Ranked Differential Analysis: Floor 6 Login & Profile Issues
**Analysis Date:** 2026-08-14 | **Incidents Analyzed:** FLR6-AUTH-002 (Login Failures) + FLR6-PROF-003 (Missing Shortcuts)  
**Timeline:** Issues discovered Monday 09:14 | Deployment window: Friday afternoon  
**Analysis Purpose:** Rank most likely causes explaining BOTH login delays AND profile corruption

---

## ANALYSIS FRAMEWORK

**Scope:** Identify root causes that could explain BOTH incidents simultaneously on Floor 6, given:
- Login failures: 12+ users unable to authenticate or experiencing extreme delays
- Missing shortcuts: 1 confirmed user (likely more), profile customizations disappeared
- Deployment correlation: New document management app deployed Friday afternoon, ~36 hours before incidents
- Geographic correlation: Both incidents reported from same floor (Floor 6)
- Timing correlation: Both symptoms emerge Monday morning at same time

**Methodology:** Rank by likelihood, then test each hypothesis with fastest diagnostic check, supporting evidence, contradicting evidence, and deployment causation evidence.

**Key Principle:** Friday deployment timing is weighted heavily as potential common cause, but causation is not assumed—evidence will determine causation.

---

## RANKING SUMMARY

| Rank | Cause | Likelihood | Common Mechanism | Deployment Link |
|------|-------|-----------|------------------|-----------------|
| **#1** | New app integrated into login/startup process | VERY HIGH | App hangs during login + corrupts profile during init | DIRECT: App deployment |
| **#2** | Group Policy changes applied Friday to Floor 6 | HIGH | GP script slows login + GP removes/resets shortcuts | DIRECT: Change deployment |
| **#3** | Roaming profile server issue (sync/performance) | HIGH | Profile load timeout causes slow login + sync fails = corruption | INDIRECT: Deployment increased load |
| **#4** | Network/firewall rule changes on Floor 6 segment | MEDIUM-HIGH | Blocked auth traffic = slow login + blocked profile share = corruption | INDIRECT: Deployment requires rule changes |
| **#5** | New app dependency consuming startup resources | MEDIUM | Resource starvation delays login + prevents profile load completion | DIRECT: App process startup |

---

## HYPOTHESIS #1: NEW APP INTEGRATED INTO LOGIN/STARTUP PROCESS

**Rank:** #1 – VERY HIGH LIKELIHOOD  
**Why This Fits the Evidence:** New document management app deployed Friday. If app is launched during startup or login phase, it could:
- Hang the login process (user waits for app initialization) → slow/failed logins
- Execute profile initialization routine that clears shortcuts → missing shortcuts
- Single point of failure explains both symptoms appearing simultaneously across multiple users

**Fastest Check (5 minutes):**
1. Examine app installation/deployment documentation
2. Check if app has startup entry in:
   - HKLM\Software\Microsoft\Windows\CurrentVersion\Run (system-wide startup)
   - User startup folder: C:\Users\[user]\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup
   - Task Scheduler for login-time tasks
3. Determine: Does app execute during login or before desktop loads?

**Evidence Supporting This Hypothesis:**
- [ ] App MSI/installation script includes startup registry entries
- [ ] App has service that starts during boot (before user login completes)
- [ ] App requires authentication separate from Windows login (adds delay)
- [ ] App has profile initialization routine that clears shortcuts or resets desktop
- [ ] App deployment timing matches symptom onset (Friday → Monday morning)
- [ ] Deployment documentation mentions "profile setup" or "user initialization"
- [ ] Help Desk reports users seeing "[App Name] loading" or similar message during login
- [ ] Process monitor shows app startup consuming significant CPU/disk during login
- [ ] Multiple users report same login delay (10-60 seconds additional time)
- [ ] Users with app installed show symptoms; users without app do not

**Evidence Contradicting This Hypothesis:**
- [ ] App is not in startup registry or Task Scheduler
- [ ] App only launches after login completes (not before)
- [ ] App does not modify user profiles or desktop
- [ ] Other floors have app deployed but no login issues
- [ ] Help Desk reports login issues began BEFORE app installation completed
- [ ] Users can log in fast by uninstalling app (not tested yet, but would disprove)
- [ ] Event logs show no app startup errors during login attempts
- [ ] Installation documentation explicitly states app does NOT run at login
- [ ] Shortcuts disappeared but app does not have profile modification code

**Evidence That Would Confirm Deployment as Root Cause:**
- [ ] Uninstall/rollback of app on test machine → login speed returns to normal
- [ ] Rollback of app to test group → login issues resolve in test group only
- [ ] Source code review shows app modifies Windows Registry HKCU\Software paths during init
- [ ] Test: Remove app from startup registry → missing shortcuts reappear (cached from backup?)
- [ ] Deployment change order explicitly approved changes to login scripts or profile defaults
- [ ] App's profile reset routine can be reproduced on lab machine → shortcuts disappear
- [ ] Multiple users (10+) report issues only after app deployment (not before)

**Evidence That Would Eliminate Deployment as Root Cause:**
- [ ] App does not run at login or startup (confirmed via Event Log)
- [ ] Other organizations with same app version report NO login issues
- [ ] Help Desk confirms login issues were reported BEFORE Friday deployment window
- [ ] Rollback of app in test environment → issues persist (proving app not cause)
- [ ] Shortcuts are hidden, not deleted (indicating display issue, not app deletion)
- [ ] Only 1-2 users affected (too isolated for app-based cause affecting all)
- [ ] Friday deployment was only configuration change, no app update deployed
- [ ] Users report shortcuts disappeared but app is not yet installed on their device

**Confidence Level:** 70-80% (if app confirmed in startup path) / 20-30% (if app not in startup)

---

## HYPOTHESIS #2: GROUP POLICY CHANGES APPLIED FRIDAY TO FLOOR 6

**Rank:** #2 – HIGH LIKELIHOOD  
**Why This Fits the Evidence:** Friday deployment could include Group Policy updates that affect Floor 6 organizational unit or security group:
- GP can slow login by adding login scripts or processing delays
- GP can remove/disable desktop shortcuts through policies (remove shortcuts from desktop)
- GP would affect all Floor 6 users (explains multiple affected users)
- Timing is perfect: GP changes typically take effect at next login (Friday evening or Monday morning)

**Fastest Check (10 minutes):**
1. Check Group Policy audit logs for Friday events
2. Query: Event ID 5136 (AD object modification - GP changes)
3. Identify: Were any policies applied to Floor 6 OU or security groups?
4. Confirm: Do policies include login script changes or desktop restrictions?

**Evidence Supporting This Hypothesis:**
- [ ] Group Policy audit logs show new policies created/modified Friday
- [ ] Policies target Floor 6 OU or security group "Floor 6 Users"
- [ ] Policies include logon script entries (could delay login)
- [ ] Policies include "Remove Run menu from Start Menu" or similar desktop restrictions
- [ ] Policies include "Disable desktop icons" or "Remove shortcuts from desktop"
- [ ] GPRESULT output for affected users shows new policies applied
- [ ] Policy processing time shown in event logs (indicates login delays during GP application)
- [ ] Deployment documentation mentions "Group Policy updates" or "security group changes"
- [ ] Multiple users report issues (typical of GPO, which affects group members)
- [ ] Issues appear only on devices joined to domain (not standalone machines)

**Evidence Contradicting This Hypothesis:**
- [ ] No Group Policy changes in audit logs for Friday
- [ ] Existing policies predate Friday deployment (old, not new)
- [ ] Policies that exist do not target Floor 6 or do not affect login/desktop
- [ ] Other floors with same policies applied do not report issues
- [ ] Help Desk confirms users can manually re-enable shortcuts (policy not preventing recreation)
- [ ] GPRESULT shows no policy changes since Thursday
- [ ] Shortcuts missing on devices without GP applied (standalone users unaffected)
- [ ] Only 1-2 users affected (GPO affects entire group, not individuals)

**Evidence That Would Confirm Deployment as Root Cause:**
- [ ] GPO audit logs show policies modified Friday by deployment automation account
- [ ] Change order explicitly approves new Group Policy for Floor 6
- [ ] GPRESULT from affected user shows policy: "Remove Desktop Shortcuts: Enabled"
- [ ] Logon event 4672 shows increased policy processing time Monday morning (vs. baseline)
- [ ] Test: Disable policy on test GPO → shortcuts reappear and login speed improves
- [ ] Rollback of AD changes from Friday backup → issues resolve
- [ ] Policy processing script logs show slowness during login (Event ID 4016 - GP processing time > 30 seconds)

**Evidence That Would Eliminate Deployment as Root Cause:**
- [ ] No Group Policy changes in Friday audit logs
- [ ] Policies that do affect desktop predate Friday by weeks/months
- [ ] Other floors with identical policies applied do not report issues
- [ ] Users report issues BEFORE any Group Policy would have applied
- [ ] GPRESULT shows no policies related to shortcuts or login
- [ ] Reverting policy changes does not fix issues (proving policy not root cause)
- [ ] Issues persist on machines outside domain (GPO does not apply)

**Confidence Level:** 60-70% (if policy changes confirmed) / 20-30% (if no policy changes found)

---

## HYPOTHESIS #3: ROAMING PROFILE SERVER ISSUE (SYNC/PERFORMANCE)

**Rank:** #3 – HIGH LIKELIHOOD  
**Why This Fits the Evidence:** If organization uses roaming profiles (common in finance/legal):
- Profile loading delay during login (roaming profile sync from server) → slow logins
- Profile synchronization failure or corruption → shortcuts lost during sync/fallback
- New app deployment could increase profile sync load (new app settings, increased data)
- Single server issue affects all Floor 6 users if they share profile server

**Fastest Check (10 minutes):**
1. Check if organization uses roaming profiles (query HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows\System for "UserProfilePath")
2. Query profile server logs for Friday-Monday timeframe
3. Check: Any errors during profile synchronization?
4. Measure: Profile sync time (should be <30 sec; if >60 sec = performance issue)

**Evidence Supporting This Hypothesis:**
- [ ] Organization uses roaming/folder redirection profiles
- [ ] Profile server logs show sync failures or errors Friday/Monday
- [ ] Profile server CPU/disk usage spiked Friday (deployment data increase)
- [ ] Profile sync timeout increased Monday (slow network or server = timeout)
- [ ] Users report "Waiting for user profile to load" message during login
- [ ] Event Log shows USERENV warnings about profile load delays
- [ ] Profile size increased Friday (app added settings to profile)
- [ ] Network trace shows profile server connections hanging/timing out Monday
- [ ] Profile backup/shadow copy shows shortcuts in backup (existed before, but sync failed)
- [ ] Help Desk reports: Users who log in from OTHER floors DO NOT have missing shortcuts (points to profile server, not local issue)

**Evidence Contradicting This Hypothesis:**
- [ ] Organization does not use roaming profiles (local profiles only)
- [ ] Profile server has no errors or performance issues in logs
- [ ] Profile server is on different physical network (not affected by Floor 6 deployment)
- [ ] Users who bypass profile server (use cached local profile) still report missing shortcuts
- [ ] Shortcuts missing but profile size unchanged (app did not increase profile data)
- [ ] Other users with roaming profiles (different floor) do not report issues
- [ ] Profile server was not modified or restarted during deployment window

**Evidence That Would Confirm Deployment as Root Cause:**
- [ ] New app added registry entries to user profile HKCU (profile size increased)
- [ ] New app required profile sync during deployment (pre-populating settings)
- [ ] Deployment added new profile server load (increased login traffic by 5x)
- [ ] Profile server CPU/memory hit 90%+ during deployment window
- [ ] Rollback profile server to pre-deployment backup → shortcuts reappear and logins fast
- [ ] Disable roaming profiles (use local) → login speed returns to normal immediately
- [ ] Deployment documentation mentions "profile integration" or "settings synchronization"
- [ ] Compare: Users with roaming profiles have issues; users with local profiles do not

**Evidence That Would Eliminate Deployment as Root Cause:**
- [ ] Organization does not use roaming profiles
- [ ] Profile server logs show no activity Friday or Monday (no sync issues)
- [ ] Profile server was not touched by deployment (different system entirely)
- [ ] Users report issues regardless of profile server status (local and roaming users both affected)
- [ ] Restore profile from backup does not fix issues (proving profile not root cause)
- [ ] Other organizations deploying same app do not report profile issues

**Confidence Level:** 60-70% (if roaming profiles confirmed + errors found) / 10-20% (if no roaming profiles or no errors)

---

## HYPOTHESIS #4: NETWORK/FIREWALL RULE CHANGES ON FLOOR 6 SEGMENT

**Rank:** #4 – MEDIUM-HIGH LIKELIHOOD  
**Why This Fits the Evidence:** Deployment could require network changes for new app communication:
- Firewall rules added/modified Friday could block authentication traffic → slow/failed logins
- Same rules could block profile server access or SMB traffic → profile sync failures = missing shortcuts
- New app might require new ports or servers (causing rules to be added incorrectly)
- Could affect entire Floor 6 segment if rules applied at network level

**Fastest Check (10 minutes):**
1. Check firewall configuration logs for Friday changes
2. Query: What rules were added/modified Friday?
3. Test: Ping domain controller from Floor 6 machine (connectivity test)
4. Test: Network trace showing auth traffic (should be <100ms roundtrip)

**Evidence Supporting This Hypothesis:**
- [ ] Firewall change log shows rules added/modified Friday
- [ ] New rules block ports used by authentication (Kerberos 88, LDAP 389, etc.)
- [ ] New rules block SMB/file sharing ports (445, 139) used for profile server access
- [ ] Firewall rules are more restrictive than before (outbound connections blocked)
- [ ] Deployment documentation mentions firewall rule requirements
- [ ] Network trace shows increased latency or timeouts on Floor 6 segment
- [ ] Floor 6 users report but OTHER floors do not (indicates Floor 6-specific rules)
- [ ] Firewall rule has "App Name" or "New App" in description (ties to deployment)
- [ ] DNS resolution works but connection attempts timeout (firewall blocking)
- [ ] VPN/remote users on other networks do not have issues (points to Floor 6 network rules)

**Evidence Contradicting This Hypothesis:**
- [ ] No firewall rule changes in Friday logs
- [ ] Existing rules predate deployment (not new)
- [ ] Rules allow necessary ports (88, 389, 445 are open)
- [ ] Other floors with same firewall rules do not report issues
- [ ] Network troubleshooting shows no packet loss or latency
- [ ] Test: Disable firewall temporarily → issues persist (proving firewall not cause)
- [ ] Users on VPN report same issues (suggests not network/firewall specific)

**Evidence That Would Confirm Deployment as Root Cause:**
- [ ] Firewall rule added Friday with comment "Block [New App] traffic" or similar
- [ ] Rule was added by automated deployment process (service account in audit log)
- [ ] Rule accidentally blocks authentication or profile server traffic
- [ ] Network latency increased from <10ms to >500ms after Friday deployment
- [ ] Rollback firewall rules to pre-deployment state → issues resolve immediately
- [ ] Tcpdump/Wireshark shows connection timeouts on auth/profile server ports
- [ ] Change order explicitly approves firewall rule changes for new app
- [ ] Test: Add exception to rule for auth servers → login speed improves

**Evidence That Would Eliminate Deployment as Root Cause:**
- [ ] No firewall rule changes Friday (deployment did not require rule changes)
- [ ] Existing rules have been in place for months (not related to Friday)
- [ ] Firewall shows no timeouts or rejections in logs (rules allowing traffic)
- [ ] Users on different networks (not Floor 6) report same issues (not network specific)
- [ ] Firewall rule changes were pre-planned for months (not tied to new app)
- [ ] Network latency is normal (<50ms) Monday morning

**Confidence Level:** 50-60% (if firewall rule changes confirmed) / 10-20% (if no rule changes found)

---

## HYPOTHESIS #5: NEW APP SERVICE/DEPENDENCY CONSUMING STARTUP RESOURCES

**Rank:** #5 – MEDIUM LIKELIHOOD  
**Why This Fits the Evidence:** New app could include Windows service or background process that:
- Launches at startup and consumes significant CPU/disk/memory
- Causes resource starvation → login delays while system is busy
- Process starvation could prevent profile loading completion → shortcuts lost or corrupted
- Resource consumption increases over time or after reboot (explains Monday occurrence after weekend)

**Fastest Check (10 minutes):**
1. Check Services.msc for new services added Friday
2. Query: Do any services start at startup?
3. Check Task Manager during startup: CPU/disk at 100% during login?
4. Review: Which process is consuming resources?

**Evidence Supporting This Hypothesis:**
- [ ] New service added Friday in Service Control Manager (Services.msc)
- [ ] Service has startup type "Automatic" (starts at boot)
- [ ] Service name contains "App Name" or deployment-related keywords
- [ ] Task Manager shows service consuming 50%+ CPU or high disk I/O during login
- [ ] Event logs show service starting during login phase (not after login)
- [ ] Service has dependencies on other services that could delay startup chain
- [ ] Monday morning: Service resource usage high; eventually drops after a few minutes
- [ ] Help Desk reports: Users report 2-3 minute login delay (time for service to finish startup)
- [ ] Process monitor shows: While service starting, LSASS.exe and other auth processes blocked by disk I/O
- [ ] Help Desk reports: Killing service process causes login to complete faster (workaround)

**Evidence Contradicting This Hypothesis:**
- [ ] No new services added Friday
- [ ] Services that exist are not consuming significant resources
- [ ] Task Manager shows normal CPU/disk during login (<20% usage)
- [ ] Users report login issues but service shows no startup errors
- [ ] Only 1-2 users affected (service would affect all users, not individuals)
- [ ] Issues persist even when service is disabled (service not root cause)
- [ ] Help Desk confirms no slowdown on users who disable new app service

**Evidence That Would Confirm Deployment as Root Cause:**
- [ ] Service added by deployment automation account Friday
- [ ] Service startup type changed from Manual to Automatic during deployment
- [ ] Process monitor trace shows service consuming 80%+ disk I/O during login window
- [ ] Event logs show "Service started at [Friday time], process hung for 120 seconds"
- [ ] Test: Disable service start → login speed returns to normal
- [ ] Rollback service to pre-deployment state → issues resolve
- [ ] Resource consumption correlates with profile load delays (both happen during same 120-second window)

**Evidence That Would Eliminate Deployment as Root Cause:**
- [ ] New services do not exist (no service deployment)
- [ ] Existing services use minimal resources (<5% CPU, <10% disk)
- [ ] Service startup type is Manual, not Automatic (does not run at boot)
- [ ] Disabling service does not improve login speed (service not cause)
- [ ] Other organizations deploying same app do not report resource issues
- [ ] Help Desk confirms normal resource usage Monday morning

**Confidence Level:** 40-50% (if new service found consuming resources) / 10-20% (if no resource issues)

---

## COMPARATIVE LIKELIHOOD MATRIX

| Hypothesis | Explains Login Delay? | Explains Missing Shortcuts? | Deployment Correlation | Scope (Floor 6 Only?) | Confidence |
|-----------|----------------------|------------------------------|------------------------|----------------------|------------|
| #1: App in startup | YES (app init delay) | YES (profile reset) | DIRECT | YES | 70-80% |
| #2: Group Policy | YES (GP processing) | YES (policy removal) | DIRECT | YES | 60-70% |
| #3: Profile server | YES (sync timeout) | YES (sync failure) | INDIRECT | MIXED | 60-70% |
| #4: Firewall rules | YES (blocked auth) | YES (blocked profile) | INDIRECT | YES | 50-60% |
| #5: Resource starvation | YES (CPU/disk wait) | MAYBE (if profile doesn't complete) | DIRECT | MAYBE | 40-50% |

---

## INVESTIGATION PRIORITY SEQUENCE

### PHASE 1: IMMEDIATE (0-15 minutes) – Fastest checks to narrow scope

**Check #1: App Startup Path (5 min)**
- Examine HKLM\Software\Microsoft\Windows\CurrentVersion\Run for new entries
- Check app installation directory for startup batch/script files
- Result: Confirms/eliminates Hypothesis #1

**Check #2: Group Policy Changes (5 min)**
- Query Event Viewer for Event ID 5136 (AD object modifications) Friday
- Check GPRESULT from affected user
- Result: Confirms/eliminates Hypothesis #2

**Check #3: Roaming Profile Status (3 min)**
- Query registry for roaming profile configuration
- Check if organization uses profile synchronization
- Result: Confirms/eliminates Hypothesis #3

**Check #4: Resource Usage (2 min)**
- Check Task Manager performance history (if available)
- Query System event log for resource alerts Friday/Monday
- Result: Confirms/eliminates Hypothesis #5

**Decision Point After Phase 1:**
- If Hypothesis #1 confirmed: Proceed to app uninstall test
- If Hypothesis #2 confirmed: Proceed to GPO reversal test
- If multiple hypotheses confirmed: Prioritize by likelihood percentage

### PHASE 2: VALIDATION (15-45 minutes) – Diagnostic checks

**For #1 App Startup:** Disable app from startup registry → retest login speed
**For #2 Group Policy:** Disable policy in test OU → retest
**For #3 Profile Server:** Check sync logs and profile size changes
**For #4 Firewall:** Review network trace for connection timeouts
**For #5 Resource:** Monitor resource usage during controlled login attempt

### PHASE 3: CONFIRMATION (45-120 minutes) – Rollback/fix testing

**For confirmed hypothesis:** Execute rollback on test machine → verify issue resolution → apply to production

---

## EVIDENCE COLLECTION CHECKLIST

### Tier 1: Immediate Collection (Required for all hypotheses)

- [ ] App installation/deployment documentation from Friday
- [ ] Active Directory Group Policy audit logs (Friday time range)
- [ ] System Event Log from affected user device (Friday-Monday)
- [ ] Application Event Log from affected user device
- [ ] Screenshot of current desktop (verify shortcuts missing)
- [ ] List of exactly which shortcuts are missing
- [ ] Current Task Manager / Services.msc screenshot
- [ ] Deployment change order (what was approved Friday?)

### Tier 2: Hypothesis-Specific Collection

**For Hypothesis #1:**
- [ ] App MSI/installer file
- [ ] App installation directory contents
- [ ] Registry export of HKLM\Software\Microsoft\Windows\CurrentVersion\Run
- [ ] Registry export of user startup folder path

**For Hypothesis #2:**
- [ ] GPRESULT /h report from affected user
- [ ] Active Directory Users & Computers export (Floor 6 OU)
- [ ] Group Policy Editor (gpedit.msc) screenshots of policies

**For Hypothesis #3:**
- [ ] Profile server error logs (if applicable)
- [ ] User profile size comparison (Friday vs. Monday)
- [ ] Profile sync history (if using sync software)
- [ ] Network trace of profile server connections

**For Hypothesis #4:**
- [ ] Firewall rule export (current state)
- [ ] Firewall audit log (Friday)
- [ ] Network trace showing latency/timeouts
- [ ] DNS resolution test results

**For Hypothesis #5:**
- [ ] Services.msc export (all services)
- [ ] Task Scheduler export (all scheduled tasks)
- [ ] Process Monitor trace during login
- [ ] Resource Monitor performance history

---

## DECISION TREE FOR ROOT CAUSE

```
START: Login delays + Missing shortcuts Monday morning

├─ Is new app in startup registry/Task Scheduler?
│  ├─ YES → Hypothesis #1: VERY HIGH priority
│  │        Proceed: Disable and retest
│  └─ NO → Continue to next check
│
├─ Were Group Policy changes applied Friday to Floor 6?
│  ├─ YES → Hypothesis #2: HIGH priority
│  │        Proceed: Review policy details, reverting test
│  └─ NO → Continue to next check
│
├─ Does organization use roaming/sync profiles?
│  ├─ YES → Hypothesis #3: HIGH priority
│  │        Proceed: Check sync logs and server performance
│  └─ NO → Continue to next check
│
├─ Were firewall rules modified Friday?
│  ├─ YES → Hypothesis #4: MEDIUM-HIGH priority
│  │        Proceed: Review rule changes, test rule modifications
│  └─ NO → Continue to next check
│
└─ Is new service consuming resources at startup?
   ├─ YES → Hypothesis #5: MEDIUM priority
   │        Proceed: Disable service, retest login
   └─ NO → Escalate to infrastructure team (unknown cause)
```

---

## REASONING: WHY FRIDAY DEPLOYMENT WEIGHTED HEAVILY

**Temporal Correlation:**
- Deployment Friday afternoon (~3-5 PM estimated)
- Issues discovered Monday 09:14 (~36-60 hours later)
- No issues reported Friday or Saturday (incubation period)
- Issues appear Monday morning (after weekend reboot cycle)
- **Inference:** Deployment set condition that triggered Monday morning

**Geographic Correlation:**
- Both issues Floor 6 only (not other floors)
- New app deployed specifically to Floor 6 (deployment scope)
- No other infrastructure changes Friday
- **Inference:** Floor 6-specific change (deployment) caused Floor 6-specific issues

**Temporal Alignment:**
- Login delays + Shortcuts missing at SAME TIME Monday morning
- Not sequential (login delays first, then shortcuts later)
- Not cumulative (different unrelated issues)
- **Inference:** Common root cause affecting both symptoms

**Deployment Characteristics:**
- New software installation typically modifies:
  - Registry (startup paths, configurations)
  - User profiles (settings, customizations)
  - System services (new Windows services)
  - Network configuration (firewall rules, ports)
- All of these could cause both login delays and profile issues
- **Inference:** Deployment is highest probability root cause container

**Alternative Explanations Less Likely:**
- Infrastructure issue (would affect other floors too)
- User action (why would multiple users independently delete shortcuts?)
- Random system failure (two simultaneous unrelated failures is unlikely)
- **Inference:** Single root cause within deployment scope most probable

---

## CONCLUSION: MOST LIKELY ROOT CAUSE

**Primary Hypothesis: Hypothesis #1 (New app integrated into login process)**  
**Confidence Level:** 70-80%  
**Reasoning:** Explains both symptoms, timing is perfect, direct deployment link, single point of failure

**Secondary Hypothesis: Hypothesis #2 (Group Policy changes)**  
**Confidence Level:** 60-70%  
**Reasoning:** Could explain both symptoms, affects all Floor 6 users, direct deployment link

**Investigation Recommendation:**
1. Execute Phase 1 checks (15 minutes) to narrow from 5 hypotheses to 1-2 most likely
2. Execute Phase 2 validation (30 minutes) on top hypothesis
3. Execute Phase 3 confirmation (60-120 minutes) by rollback/fix on test machine
4. Apply proven fix to production only after validation

**Next Action:** Dispatch Level 2 technical support with Phase 1 checklist to collect evidence within next 30 minutes.
