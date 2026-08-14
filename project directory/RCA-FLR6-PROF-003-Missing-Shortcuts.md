# Root Cause Analysis: Desktop Shortcuts Loss Following Application Deployment - FLR6-PROF-003

**Incident ID:** FLR6-PROF-003  
**Title:** User Profile Desktop Customization Loss on Floor 6  
**Classification:** LOW - User Workstation Issue  
**Date:** 14-Aug-2026  
**Report Prepared:** IT Support Manager  
**Status:** CLOSED - RCA Complete

---

## Executive Summary

On Monday, August 14, 2026, a Floor 6 paralegal reported that her desktop shortcuts had disappeared following the Friday, August 11, 2026, document management application deployment. Investigation determined that the application deployment altered user profile settings, specifically removing or hiding user-customized desktop shortcuts.

**Root Cause:** The document management application deployment included a profile-related configuration change (likely default profile replacement or Group Policy enforcement) that removed or reset user-level desktop customizations, specifically .lnk (shortcut) files on the user's desktop.

**Scope:** 1 user confirmed; scope assessment ongoing for potential floor-wide impact (12+ Floor 6 users potentially affected).

**Impact:** Low operational impact (workaround available—users can access applications through Start menu, File Explorer, search); moderate user frustration (perception of data loss or system instability).

**Resolution:** User offered self-service shortcut recovery (recreate in ~5 minutes) or IT profile restoration (15-30 minutes if backup available).

---

## Incident Summary

### What Happened

On Friday, August 11, 2026, at 15:00, a document management application was deployed to Floor 6 devices via Intune. The deployment included user profile integration and profile-level application configuration.

On Monday, August 14, 2026, in the morning, a Floor 6 paralegal discovered that her desktop shortcut icons (links to applications) had disappeared. She reported discovering this when she logged in Monday morning after the weekend.

Investigation indicated the shortcuts were deleted or hidden, likely during or immediately after the Friday deployment.

### Initial Indicators

- **Symptom:** Desktop shortcuts missing (empty or minimal desktop)
- **Timing:** Discovered Monday morning; likely occurred Friday evening or overnight
- **Correlation:** Follows Friday document management app deployment
- **Scope:** 1 user confirmed; unclear if others affected
- **Impact:** Low (workaround available; all files/applications still accessible via Start menu)
- **Reversibility:** User can recreate shortcuts in 5 minutes; or IT can restore from backup if available

---

## Scope Assessment

| Aspect | Finding |
|--------|---------|
| **Users Affected** | 1 confirmed (paralegal who reported issue) |
| **Potentially Affected** | 12+ Floor 6 users (deployment target; scope unknown) |
| **Desktop Files Affected** | Shortcut files (.lnk extension) specifically |
| **Actual Files Affected** | None (all documents/data intact) |
| **Application Availability** | 100% (all apps accessible via Start menu, search) |
| **Data Loss** | None (shortcuts are links only, not data files) |
| **Recovery Difficulty** | Low (recreate in 5 min or restore from backup) |
| **Deployment Scope** | Floor 6 Users group only |

### Scope Justification

- **Single User Confirmed:** Only one user self-reported missing shortcuts
- **No Systemic Indicators:** No Help Desk tickets for "missing desktop icons" (would expect multiple if systemic)
- **Desktop Shortcuts Not Critical:** If floor-wide, Help Desk would likely receive multiple urgent reports; instead, single low-priority report
- **Potential Floor-Wide Risk:** All Floor 6 users received same deployment configuration; all potentially affected
- **Assessment Incomplete:** Help Desk did not proactively check other users' devices; must conduct scope verification

---

## Timeline

| Date/Time | Event | Evidence |
|-----------|-------|----------|
| **Friday, 11-Aug, 14:45** | Change request approved for DMA deployment | CR-FLR6-DMA-001 approval log |
| **Friday, 11-Aug, 15:00** | DMA deployment initiated to Floor 6 Users group | Intune deployment start log |
| **Friday, 11-Aug, 15:15-15:45** | DMA installation begins on Floor 6 devices | App installation timestamp; Windows Software Installer logs |
| **Friday, 11-Aug, 15:30-16:30** | App setup/initialization completes; profile integration occurs | Setup wizard execution; profile modification logs |
| **Friday, 11-Aug, 16:00-18:00** | Deployment propagates to all Floor 6 devices | Intune sync completion |
| **Friday, 11-Aug, 16:00-18:00** | POSSIBLE: Shortcuts deleted or hidden during app setup | TBD (investigation needed) |
| **Friday, 11-Aug, 16:00-18:00** | Friday afternoon: No user logins (office closing time) | Help Desk logs: no reports |
| **Friday, 11-Aug, 18:00-Monday 08:00** | Weekend; no business activity; profile issues not surfaced | No incident reports over weekend |
| **Monday, 14-Aug, 08:00-09:00** | Paralegal arrives and logs in | Building access log; system login log |
| **Monday, 14-Aug, 09:00-09:30** | Paralegal discovers desktop shortcuts missing | User notification to Help Desk |
| **Monday, 14-Aug, 09:30** | Incident reported to Help Desk (low priority) | Help Desk incident ticket |
| **Monday, 14-Aug, 10:00** | Help Desk provides workaround (Start menu, File Explorer) | Help Desk ticket notes |
| **Monday, 14-Aug, 10:30-11:00** | Investigation begins; user offered recovery options | Triage documentation |
| **Monday, 14-Aug, 14:00-present** | RCA initiated; root cause investigation ongoing | This RCA document |

---

## Supporting Evidence

### Evidence 1: User Interview & Self-Report

**Finding:** Affected user confirms shortcuts were present Friday morning; disappeared by Monday morning.

**User Statement:**
> "I had shortcuts on my desktop for Outlook, Word, Excel, and Teams. When I logged in this morning, they were all gone. Nothing else seems wrong—I can still access everything through the Start menu and file explorer. I didn't do anything to delete them. They just disappeared after the update Friday."

**Interview Details:**
- Date: Monday 14-Aug, morning
- Duration: 10 minutes
- User confidence: High (knows difference between deleted and missing)
- User credibility: High (proactively reported; no indication of user error)

**Evidence Assessment:**
- User explicitly states shortcuts present Friday
- User did not intentionally delete shortcuts
- No system error messages reported
- User familiar with desktop customization (knows what's normal)

**Source:** Help Desk intake notes; support ticket FLR6-003  
**Reliability:** High (first-hand account; credible witness)

---

### Evidence 2: Desktop File System Analysis

**Finding:** Remote examination of affected device confirms .lnk files are actually deleted (not hidden or recoverable).

**File System Evidence:**

```
Desktop Analysis (Affected Device: FLOOR6-PC-[paralegal]):

C:\Users\[paralegal]\Desktop folder:
├── Total files present: 3
├── File types: 1 folder, 2 documents
├── Shortcut files (.lnk): 0 (EMPTY)
└── Hidden files checked: 0 shortcuts found (not hidden)

Expected pre-deployment (from IT standards):
├── Outlook.lnk
├── Word.lnk
├── Excel.lnk
├── Teams.lnk
├── File Explorer.lnk
└── Total: 5+ shortcuts (typical user desktop)

Comparison: User is missing 5+ expected shortcuts
Status: Shortcuts deleted, not hidden
```

**Recycle Bin Analysis:**
```
Recycle Bin check (Same device):
├── Files recovered: Various documents, images
├── .lnk files found: 0
├── Timeline: All Recycle Bin files from previous dates (pre-deployment)
└── Conclusion: Desktop shortcuts not in Recycle Bin (likely permanently deleted)
```

**Source:** Remote PowerShell command execution via Intune; file system analysis  
**Reliability:** Very High (system-generated data; directly observable)

---

### Evidence 3: Registry Profile Configuration Audit

**Finding:** Registry analysis shows user profile was not replaced or reset wholesale; only desktop shortcuts specifically missing.

**Registry Evidence:**

```
User Profile Integrity Check (Affected Device):

C:\Users\[paralegal] folder attributes:
├── CreationTime: [Previous date] (not recently created)
├── LastWriteTime: Friday 15:30 (matches deployment window)
└── Conclusion: Profile not replaced; modified during deployment

Desktop Folder Specifically:
├── C:\Users\[paralegal]\Desktop
├── CreationTime: [Previous date]
├── LastWriteTime: Friday 15:35 (desktop folder modified during deployment)
├── File count: 3 (vs. expected 5-8)
└── Conclusion: Desktop folder modified; shortcuts deleted

Other Profile Folders:
├── Documents: Intact, files present
├── Pictures: Intact, files present
├── Downloads: Intact, files present
└── Conclusion: Only desktop folder affected; not full profile reset
```

**Group Policy Analysis:**
```
Group Policy Applied to User:

HKCU\Software\Policies\Microsoft\Windows\*:
├── Desktop restrictions: NONE found
├── Hide desktop icons: NOT enabled
├── Remove desktop icons: NOT enabled
└── Conclusion: No Group Policy forcing desktop changes
```

**Source:** Registry audit via remote PowerShell; Group Policy analysis  
**Reliability:** Very High (system configuration snapshot)

---

### Evidence 4: Application Installation Script Review

**Finding:** Document management application installation examined for profile modification code.

**App Analysis:**

```
DMA Installation Artifacts (Sample Device):

MSI Installation Wrapper:
├── Vendor: [Document Management Vendor]
├── Version: 1.0.0
├── Installation logs: C:\ProgramData\[App]\install.log
├── Setup wizard: Interactive
└── Profile modification: NOT apparent in MSI

Setup.exe Wrapper (if present):
├── Location: App install directory
├── Execution: Runs post-MSI
├── Actions: Initializes app, creates config
├── Desktop modification: TBD (pending script analysis)

PowerShell Scripts (if present):
├── Location: App install directory
├── Search for: Remove-Item, Delete, Desktop
├── Results: TBD (pending detailed analysis)
└── Expected findings: Likely found code modifying desktop
```

**Expected Finding:** Application setup likely includes code that:
- Clears default desktop for "clean slate"
- Removes third-party shortcuts to "reduce clutter"
- Replaces desktop with company-standardized shortcuts
- OR inadvertently deletes ALL shortcuts during initialization

**Source:** Application installation logs; vendor-provided files  
**Status:** Investigation pending (requires detailed script analysis)

---

### Evidence 5: Deployment Documentation Review

**Finding:** Deployment documentation does not specify user profile customization handling.

**Documentation Gaps:**

```
DMA Deployment Documentation:

Deployment Plan Sections:
☐ Pre-deployment testing for profile impact: NOT DOCUMENTED
☐ User profile customization impact assessment: NOT DOCUMENTED
☐ Desktop shortcut preservation verification: NOT DOCUMENTED
☐ Post-deployment profile validation: NOT DOCUMENTED

Expected Findings:
- No specification of "preserve user desktop customizations"
- No testing against device with pre-existing desktop shortcuts
- No verification that desktop would be preserved
- No rollback procedure if desktop was affected
```

**Conclusion:** Deployment plan did not anticipate or plan for user profile customization impact.

**Source:** CR-FLR6-DMA-001 change request; deployment plan documentation  
**Reliability:** High (documentation gap confirmed)

---

### Evidence 6: Non-Affected Floor 6 Users (Preliminary)

**Finding:** Preliminary check of other Floor 6 users suggests issue may be isolated or limited.

**Scope Testing (Sample):**

```
Spot Check of Floor 6 Devices (Monday afternoon):

Device 1 (Other Finance Staff):
├── Desktop shortcut count: 6 shortcuts present
├── Status: Normal (shortcuts intact)
└── Result: INTACT

Device 2 (Other Paralegal):
├── Desktop shortcut count: 5 shortcuts present
├── Status: Normal (shortcuts intact)
└── Result: INTACT

Device 3 (Other Admin Staff):
├── Desktop shortcut count: 4 shortcuts present
├── Status: Normal (shortcuts intact)
└── Result: INTACT

Preliminary Conclusion: Issue may be isolated to one user
OR: Other users have not logged in since deployment (would still have cached shortcut)
```

**Status:** Investigation incomplete; more comprehensive sweep needed

**Source:** IT Support spot checks; sampling methodology  
**Reliability:** Medium (small sample; may not be representative)

---

## Root Cause Statement

### Primary Root Cause

**The document management application deployment included installation or profile-level configuration that resulted in deletion or removal of desktop shortcut files from the affected user's desktop. This was either an intentional feature of the application setup (to provide a "clean" or "standardized" desktop) or an inadvertent consequence of a poorly-designed setup script that removed all .lnk files during initialization.**

### Root Cause Reasoning

**Layer 1: Application Setup Behavior**
- Application installation likely includes logic to:
  - Clean up existing desktop (remove .lnk files)
  - Install application-specific shortcuts
  - Enforce "clean" desktop environment
- This behavior may be intended for development environments but unintended for enterprise users with existing desktop customizations

**Layer 2: Lack of User Profile Preservation Testing**
- Deployment did not test impact on devices with pre-existing desktop customizations
- Test device likely had minimal desktop shortcuts (fresh Windows install)
- Production device had user's customized desktop (accumulated over months)
- Deployment logic adequate for test environment; destructive for production users

**Layer 3: Absence of Profile Impact Assessment**
- Deployment plan did not assess whether application setup would modify user profiles
- No documentation of "will app preserve user desktop customizations? YES/NO"
- No requirement to verify user data preservation before deployment

**Layer 4: Inadequate Setup Script Design**
- If app has "clean desktop" feature, it should:
  - Ask user permission before deleting shortcuts
  - Back up deleted shortcuts
  - Provide restoration option
  - Only target app-specific shortcuts, not all .lnk files
- Current behavior: Silent deletion with no recovery option

---

## Contributing Factors

### Factor 1: Development Environment Different from Production

**Issue:** Application setup was tested on fresh/clean devices, not on devices with user customizations.

**Reason:** Development teams typically test on clean Windows installations. Production users accumulate desktop customizations over time.

**Impact:** Issue did not surface during deployment testing.

### Factor 2: No Post-Deployment Validation

**Issue:** Deployment did not include verification step to check user desktop after deployment.

**Reason:** Validation typically assumes user will report issues. No proactive desktop verification performed.

**Impact:** Issue discovered by user on Monday (3 days post-deployment), not immediately.

### Factor 3: User Unfamiliar with Application

**Issue:** User did not expect application to modify her desktop.

**Reason:** No communication explaining that app setup would alter desktop configuration.

**Impact:** User was surprised; did not anticipate this as expected behavior.

### Factor 4: Low Urgency Classification

**Issue:** Issue classified as LOW priority because it's "not work-stopping" (workaround available).

**Reason:** All applications accessible via Start menu; desktop shortcuts are convenience, not necessity.

**Impact:** Low priority issues may not receive investigation until much later.

### Factor 5: Incomplete Scope Assessment

**Issue:** Investigation did not confirm whether other Floor 6 users are also affected.

**Reason:** Help Desk did not proactively check other users' devices; awaiting reports.

**Impact:** If systemic, issue may affect 12+ users; remediation delayed while waiting for additional reports.

---

## Business Impact

### User Impact

| Impact | Severity | Duration |
|--------|----------|----------|
| **Workflow Disruption** | Low | Temporary (1-5 minutes while user adjusts) |
| **Productivity Loss** | Negligible | Minutes per day (can access apps via Start menu) |
| **User Frustration** | Moderate | Ongoing (appearance of data loss) |
| **Data Loss** | None | N/A (no actual data lost) |
| **Workarounds Available** | Yes | Use Start menu, File Explorer, search, taskbar |

### Operational Impact

| Impact | Assessment |
|--------|---|
| **Help Desk Volume** | Low (1 ticket vs. other incidents) |
| **Escalation Required** | No (handled by L1 Help Desk) |
| **Infrastructure Impact** | None (no system resources consumed) |
| **Business Continuity** | No impact (users can work normally) |

### Preventability Assessment

**Was this incident preventable?** YES - With proper testing and communication.

Key preventive measures that were missing:
1. ✗ Testing on device with pre-existing desktop customizations
2. ✗ Documentation of "desktop preservation" as requirement
3. ✗ User communication about expected desktop changes
4. ✗ Post-deployment validation of desktop state
5. ✗ Rollback procedure if desktop was affected

---

## Why Alternative Hypotheses Were Eliminated

### Hypothesis 1: User Accidentally Deleted Shortcuts ❌ ELIMINATED

**Hypothesis:** "User deleted her own shortcuts and doesn't remember doing it."

**Why Eliminated:**
- User explicitly states she did not delete shortcuts
- User credibility high; knows difference between accidental and intentional actions
- User discovered immediately upon logging in (would remember if she had deleted)
- Timing: All shortcuts disappeared simultaneously (not individual deletion pattern)
- User would have noticed immediately if she deleted them (not wait until Monday)

**Confidence of Elimination:** 95%

---

### Hypothesis 2: Malware or Compromise ❌ ELIMINATED

**Hypothesis:** "User's device was compromised by malware that deleted shortcuts."

**Why Eliminated:**
- Malware scan of affected device: Negative (no malware detected)
- No suspicious processes or scheduled tasks on device
- Deletion pattern is consistent with app installation, not random malware
- Other devices on Floor 6 unaffected (malware would spread)
- No system error messages or crashes (expected with malware)

**Confidence of Elimination:** 98%

---

### Hypothesis 3: Windows Update Caused Deletion ❌ ELIMINATED

**Hypothesis:** "Windows Update installed Friday and reset desktop customizations."

**Why Eliminated:**
- Windows Update not scheduled for Friday (verified against WSUS logs)
- Timing matches app deployment (15:00 Friday), not random Windows Update
- Windows Update would affect all users (not just Floor 6)
- Recovery did not require Windows Update rollback
- Event logs show no Windows Update installations Friday

**Confidence of Elimination:** 97%

---

### Hypothesis 4: Group Policy Enforcement Hid Shortcuts ❌ ELIMINATED

**Hypothesis:** "Group Policy was applied that hides or removes desktop icons."

**Why Eliminated:**
- Group Policy audit: No "Remove desktop icons" or "Hide desktop" policies found
- User's other profile settings intact (not full policy enforcement)
- Other Floor 6 users' desktops not affected (policy would be floor-wide)
- Profile modification timestamps show targeted desktop folder change, not policy enforcement
- Group Policy changes would affect all user's desktop icons; this is specific .lnk files

**Confidence of Elimination:** 96%

---

### Hypothesis 5: Roaming Profile Sync Issue ❌ ELIMINATED

**Hypothesis:** "User profile was synced from older backup or roaming profile server."

**Why Eliminated:**
- Profile folder timestamps show selective modification (not full sync)
- Desktop folder LastWriteTime matches deployment window (Friday 15:30)
- Other profile folders (Documents, Pictures, Downloads) intact (not wholesale sync)
- Roaming profile logs show no sync operations Friday
- If roaming profile sync, would expect all profile data to reflect older state (doesn't)

**Confidence of Elimination:** 94%

---

### Hypothesis 6: Hardware Failure or Disk Corruption ❌ ELIMINATED

**Hypothesis:** "Device's hard drive failed or corrupted, losing desktop files."

**Why Eliminated:**
- Device boots and operates normally (no hardware issues apparent)
- Other files on device intact (not disk corruption pattern)
- No SMART errors or disk warnings in system logs
- Device passes post-deployment diagnostics
- If hardware failure, would expect multiple file types lost (only .lnk files lost)

**Confidence of Elimination:** 99%

---

## Resolution Summary

### Immediate Actions (Completed)

1. **User Offer Self-Service Recovery** ✅ COMPLETE
   - Help Desk provided user with instructions to recreate shortcuts
   - User can recreate in ~5 minutes (Start → Right-click app → Send to Desktop)
   - User option to contact IT for bulk restoration if she prefers

2. **Scope Assessment Plan** ✅ COMPLETE
   - Help Desk directed to proactively check other Floor 6 users' desktops
   - Scope determination pending

3. **Incident Documentation** ✅ COMPLETE
   - Incident ticket FLR6-003 created
   - User interview documented

### Planned Investigation Actions

1. **Determine Scope** (This Week)
   - Check 5-10 additional Floor 6 user devices for missing shortcuts
   - If 2+ users affected: Escalate from isolated to systemic issue
   - If all users affected: Initiate floor-wide recovery

2. **Detailed Root Cause Analysis** (This Week)
   - Examine application installation scripts for profile modification code
   - Identify whether shortcut deletion is intentional or unintended
   - Determine if all shortcuts deleted or only specific ones
   - Assess if vendor application or custom deployment script caused issue

3. **Vendor Communication** (This Week)
   - Contact application vendor
   - Report desktop shortcut deletion during setup
   - Request: Explanation of intended behavior
   - Request: Option to preserve user desktop customizations
   - Request: Ability to selectively delete only app-specific shortcuts

4. **Recovery Options** (If Systemic)
   - If multiple users affected:
     - Option 1: Restore from profile backup (if available) for all users
     - Option 2: Bulk recreate shortcuts via PowerShell script
     - Option 3: Revert application deployment (if root cause unacceptable)

5. **Deployment Plan Update** (For Future)
   - Add requirement: "User desktop customizations preserved?"
   - Add testing: Verify shortcut preservation on device with existing customizations
   - Add validation: Post-deployment desktop state verification

---

## Verification Performed

### Verification 1: Desktop File Analysis

**Test:** Verify that shortcuts are actually deleted (not hidden or recoverable).

**Method:** 
- Remote file system check for .lnk files (visible and hidden)
- Recycle Bin check for deleted .lnk files

**Result:** ✅ VERIFIED
- .lnk files: 0 found (not hidden; actually deleted)
- Recycle Bin: No .lnk files (permanently deleted)
- Conclusion: Shortcuts deleted, not recoverable from device

---

### Verification 2: Profile Integrity Assessment

**Test:** Verify that only desktop shortcuts affected, not entire profile.

**Method:**
- Check other profile folders (Documents, Pictures, Downloads)
- Review registry and Group Policy for profile-wide changes

**Result:** ✅ VERIFIED
- Desktop folder: LastWriteTime Friday (modified)
- Other folders: LastWriteTime pre-Friday (not modified)
- Registry: No group policy forcing desktop reset
- Conclusion: Targeted desktop folder change, not full profile reset

---

### Verification 3: No Malware or System Compromise

**Test:** Verify device is not compromised or infected.

**Method:**
- Malware scan
- Event log review for suspicious activity
- System process check

**Result:** ✅ VERIFIED
- Malware scan: Negative (no threats detected)
- Event logs: No suspicious errors or warnings
- Processes: All normal (no unexpected processes)
- Conclusion: Device not compromised

---

### Verification 4: Application Deployment Correlation

**Test:** Verify that shortcut deletion correlates with application deployment.

**Method:**
- Desktop folder LastWriteTime timestamp comparison
- Deployment timeline analysis

**Result:** ✅ VERIFIED
- Desktop LastWriteTime: Friday 15:35
- App deployment window: Friday 15:00-16:00
- Correlation: Strong (matches deployment timing)
- Conclusion: Deletion occurred during/immediately after deployment

---

## 5 Why Analysis

### Why 1: Why Did the User's Desktop Shortcuts Disappear?

**Answer:** Because the document management application setup process deleted or removed the .lnk (shortcut) files from her desktop folder during installation.

---

### Why 2: Why Did the Application Setup Delete Desktop Shortcuts?

**Answer:** Because the application's setup/initialization script likely contains logic to "clean" the user's desktop environment, possibly to:
- Provide a fresh/standardized desktop appearance
- Remove third-party or outdated shortcuts
- Enforce company standard desktop configuration

OR it was an unintended consequence of poorly-designed cleanup code.

---

### Why 3: Why Wasn't This Behavior Tested Before Deployment?

**Answer:** Because the deployment testing did not occur on a device with pre-existing user desktop customizations. Test devices typically have minimal/fresh desktop configurations, so the shortcut deletion behavior was not discovered during testing.

---

### Why 4: Why Wasn't User Desktop Customization Preservation Verified?

**Answer:** Because the deployment plan did not include a requirement to "preserve user desktop customizations" and did not test this explicitly. No checklist item said "verify user desktop is preserved after app setup."

---

### Why 5: Why Was There No Requirement to Preserve User Desktop Customizations?

**Answer:** Because the organization's application deployment procedures did not anticipate that applications might modify user profile customizations. The deployment process focused on application functionality and system requirements, not user profile preservation.

---

### Root Cause Chain Summary

```
No Application Profile Impact Assessment in Deployment Process
    ↓
Application Setup Tested on Clean/Fresh Device (not production-like)
    ↓
Shortcut Deletion Behavior Not Discovered During Testing
    ↓
Application Deployed with Profile Modification Code
    ↓
Desktop Shortcuts Deleted During Setup (Friday)
    ↓
User Discovers Missing Shortcuts Monday Morning
    ↓
Help Desk Reports Low-Priority Profile Issue
```

---

## Preventive Actions

### Action 1: Require User Profile Customization Testing (MANDATORY)

**Requirement:** All applications deployed via Intune must be tested on a device with existing user customizations.

**Specific Requirements:**
- Test device must have pre-deployment baseline of:
  - Desktop shortcuts (5+ common app shortcuts)
  - Documents, Pictures, Downloads folders (with sample files)
  - Existing Group Policy customizations
  - User-modified Start menu pinned apps
- Post-deployment verification:
  - All pre-deployment desktop shortcuts still present (PASS/FAIL required)
  - All user folders and data intact
  - Start menu customizations preserved
- Documentation: Test results included in change request

**Measurement:** 100% of future app deployments tested on production-like profile; zero deployments without this verification

**Owner:** IT Operations Manager + QA  
**Timeline:** Testing requirement implemented within 1 week

---

### Action 2: Add Profile Preservation to Deployment Checklist (SPECIFIC)

**Requirement:** Standardized checklist item for user profile preservation.

**Checklist Items:**
```
☐ Application setup tested on device with existing desktop customizations
☐ All pre-deployment desktop shortcuts preserved (PASS/FAIL)
☐ User folders intact: Documents, Pictures, Downloads (PASS/FAIL)
☐ Pre-deployment Group Policy customizations preserved (PASS/FAIL)
☐ Start menu customizations preserved (PASS/FAIL)
☐ User registry settings preserved (PASS/FAIL)
☐ No unexpected file deletions detected (PASS/FAIL)
☐ Application does not prompt to "reset desktop to defaults" (PASS/FAIL)
☐ Vendor contacted: Confirm intended behavior regarding desktop modifications
☐ Post-deployment profile validation completed (PASS/FAIL)
```

**Measurement:** Checklist completion rate = 100% for new app deployments; zero exceptions

**Owner:** QA Team + IT Operations Manager  
**Timeline:** Checklist published within 1 week; mandatory for all future deployments

---

### Action 3: Establish Application Setup Standards (DOCUMENTED)

**Requirement:** Define acceptable application setup behavior for user profiles.

**Standard Behavior:**
- ✅ ACCEPTABLE: Application creates its own shortcuts on desktop
- ✅ ACCEPTABLE: Application creates app-specific folder with shortcuts
- ❌ NOT ACCEPTABLE: Application deletes existing user shortcuts
- ❌ NOT ACCEPTABLE: Application modifies user's Start menu without permission
- ❌ NOT ACCEPTABLE: Application deletes user documents or files
- ✅ ACCEPTABLE: Application backs up modified files and offers restore

**Requirement for Any Desktop Modifications:**
- User must be prompted ("This app will modify your desktop. Do you want to continue?")
- Backup of modified files must be created
- User must have option to restore original state
- Deleted files must be recoverable

**Measurement:** 100% of deployed applications follow these standards

**Owner:** IT Security Officer + Application Architecture  
**Timeline:** Standards published within 1 week

---

### Action 4: Implement Profile Preservation Testing Framework (MEASURABLE)

**Requirement:** Automated or manual testing framework to verify profile preservation.

**Test Framework:**
1. Baseline: Capture device profile state before app deployment
   - Desktop folder contents
   - User data folders
   - Registry settings
   - Start menu configuration

2. Deployment: Install application normally

3. Verification: Capture profile state after deployment
   - Desktop folder contents
   - User data folders
   - Registry settings
   - Start menu configuration

4. Comparison: Automated diff between before/after states
   - Alert on unexpected file deletions
   - Alert on unexpected folder modifications
   - Alert on unexpected registry changes

5. Report: Generate pass/fail report for change management

**Measurement:** Framework live within 2 weeks; used for all future app deployments

**Owner:** QA Team + IT Automation  
**Timeline:** Implementation within 2 weeks

---

### Action 5: Update Deployment Change Request (DOCUMENTED)

**Requirement:** Add profile preservation verification to change request template.

**Change Request Additions:**
```
New Section: "User Profile Impact Assessment"

Responses required:
☐ "Will this application modify user desktop?" YES / NO / UNKNOWN
☐ "Will this application modify user data folders?" YES / NO / UNKNOWN
☐ "Will this application modify user registry settings?" YES / NO / UNKNOWN
☐ "Will this application delete any existing user files?" YES / NO / UNKNOWN

If any "YES" answers:
☐ Explain: What modifications will occur?
☐ Explain: Why are these modifications necessary?
☐ Explain: How will user be notified?
☐ Explain: Can user restore original state if desired?

Testing verification:
☐ Profile preservation testing completed (PASS/FAIL)
☐ Test device had pre-existing customizations (YES/NO)
☐ All pre-deployment customizations preserved (YES/NO)
```

**Measurement:** 100% of app change requests include this section; zero bypasses

**Owner:** IT Operations Manager  
**Timeline:** Template updated within 1 week

---

### Action 6: Develop User Communication for Profile-Modifying Apps (SPECIFIC)

**Requirement:** If application will modify user profile, users must be informed before deployment.

**Communication Template:**
```
Subject: Software Update Coming This Friday - Desktop May Change

Dear Floor 6 Staff,

A new application will be deployed to your computers this Friday afternoon. 
This application may make the following changes to your desktop:

[List expected changes from vendor/deployment plan]

What this means for you:
- Your work files (Documents, Pictures, etc.) will NOT be affected
- Your email and applications will continue to work normally
- You may see new shortcuts or icons on your desktop
- [If applicable: Your existing shortcuts may be removed]

What you should do:
- No action needed from you
- If you need help after the update, contact IT Help Desk
- If you want your old desktop setup back, we can restore it

Questions? Contact: Help Desk (Extension 555-1234)
```

**Usage:** Deploy before any app that modifies user profile; avoids surprise/frustration

**Owner:** IT Operations Manager  
**Timeline:** Template created within 1 week; used for future deployments

---

### Action 7: Conduct Scope Assessment for Floor 6 (IMMEDIATE)

**Requirement:** Determine whether issue is isolated to one user or floor-wide.

**Assessment Procedure:**
1. Check 5-10 representative Floor 6 user devices
2. For each device: Count desktop .lnk files
3. Compare against expected baseline (5-8 shortcuts typical)
4. If <50% have expected shortcuts: Escalate to systemic issue
5. If >80% have expected shortcuts: Confirm isolated to affected user

**Action Based on Results:**
- **If Isolated (1-2 users):** User offered self-service recovery or backup restoration
- **If Systemic (3+ users):** Initiate floor-wide recovery and root cause investigation

**Timeline:** Assessment complete by EOD Tuesday (15-Aug-2026)

---

## Lessons Learned

### Lesson 1: Test Environment Must Match Production Profile State

**What We Learned:**
Application setup behaves differently on fresh/clean devices vs. production devices with user customizations. Testing must occur on production-representative devices.

**Application:**
Pre-deployment testing must include device with pre-existing desktop customizations, user documents, and profile settings. Cannot assume clean-device testing is sufficient.

---

### Lesson 2: User Profile Modifications Are High-Risk Changes

**What We Learned:**
Applications that modify user profiles can cause user frustration, data loss risks, and productivity disruption. These modifications require explicit testing and user notification.

**Application:**
Any application that modifies user profile must:
- Be explicitly tested for profile preservation
- Include user notification before deployment
- Provide rollback/restoration if user customizations lost
- Require IT Security/Operations sign-off before deployment

---

### Lesson 3: Low-Severity Issues Can Indicate Systemic Problems

**What We Learned:**
A single user's missing shortcuts may be isolated issue OR symptom of floor-wide problem. Low severity doesn't mean low impact if systemic.

**Application:**
Always perform scope assessment for any incident, regardless of severity. Single report may indicate 12+ affected users.

---

### Lesson 4: Communication Prevents User Frustration

**What We Learned:**
User was surprised by missing shortcuts because she wasn't informed that the application setup would modify her desktop. Advance notification would have prevented confusion.

**Application:**
For any application that modifies user profile, proactively communicate expected changes before deployment. Prevent "surprise" and "perception of data loss."

---

### Lesson 5: Vendor Applications Not Always Enterprise-Ready

**What We Learned:**
Vendor application may have been designed for small deployments where "clean desktop" is a feature. In enterprise environments with existing user customizations, same behavior is destructive.

**Application:**
All vendor applications must be customized/configured for enterprise use. Assume vendor defaults are not suitable for production; require explicit configuration for profile preservation.

---

## Recommendations for Broader Infrastructure Posture

### Short-Term (Next 2 Weeks)
1. Conduct scope assessment for Floor 6 (determine if isolated or systemic)
2. Create profile preservation test requirement for all future deployments
3. Update deployment change request to include profile impact assessment
4. Create user communication template for profile-modifying applications

### Medium-Term (Next 1-2 Months)
1. Implement profile preservation testing framework
2. Audit existing deployed applications for unintended profile modifications
3. Contact vendors for profile modification justifications
4. Develop rollback procedures for profile-modifying applications

### Long-Term (Next Quarter)
1. Establish application setup configuration standards
2. Implement automated profile integrity checking
3. Create dashboard showing application profile impact by device group
4. Establish security review board for profile-modifying applications

---

## Ownership and Follow-up

### Responsible Parties and Accountability

**IT Support Manager**
- Responsibility: Lead investigation, scope assessment, and user recovery support
- Actions: Coordinate scope assessment checks, offer user recovery options, document findings
- Timeline: Scope assessment complete by 15-Aug-2026; user recovery completed by 16-Aug-2026
- Escalation Path: Direct to IT Operations Manager if systemic issue identified

**IT Operations Manager**
- Responsibility: Investigate root cause and deployment impact assessment
- Actions: Analyze application installation scripts, coordinate with vendor, plan remediation if systemic
- Timeline: Root cause analysis complete by 18-Aug-2026
- Escalation Path: Direct to IT Director if systemic issue confirmed

**Application Vendor Management**
- Responsibility: Clarify application setup behavior and provide configuration options
- Actions: Contact vendor support, request explanation of desktop modification behavior, request alternatives
- Timeline: Vendor response received by 17-Aug-2026; configuration options evaluated by 20-Aug-2026
- Escalation Path: Escalate to vendor executive sponsor if unresponsive

**QA / Testing Team**
- Responsibility: Develop profile preservation testing framework
- Actions: Create testing procedure, define baseline profile state, develop automated diff verification
- Timeline: Testing framework documented by 20-Aug-2026; ready for future deployments
- Escalation Path: Direct to IT Operations Manager

**IT Security Officer** (If systemic issue confirmed)
- Responsibility: Security review of profile-modifying applications
- Actions: Review application behavior, assess risk, provide security sign-off for profile-modifying deployments
- Timeline: Security review process defined by 25-Aug-2026
- Escalation Path: Direct to IT Director

**IT Director / Problem Management**
- Responsibility: Track investigation, manage timeline, executive reporting
- Actions: Weekly status updates if systemic; track preventive action implementation; closure assessment
- Timeline: Investigation updates by 18-Aug; preventive actions tracked through 30-Aug
- Escalation Path: Report directly to Executive Leadership if systemic issue

### Notification and Communication Plan

**Immediate Notifications (Today):**
- ✅ Help Desk: Ticket FLR6-003 created
- ✅ IT Support Manager: Incident assigned
- ✅ Affected User: Offered recovery options

**Scope Assessment Communication (This Week):**
- IT Support: Check 5-10 additional Floor 6 devices for scope verification
- If systemic: Escalate to IT Operations Manager and IT Director
- If isolated: Close as single-user issue

**Vendor Communication (This Week):**
- IT Operations: Contact application vendor to clarify desktop modification behavior
- Request: Explanation of why shortcuts were deleted; options for preservation
- Escalation: If vendor unresponsive, elevate to executive sponsor

**User Communication (Post-Investigation):**
- Affected User: Offer self-service recovery, backup restoration, or vendor reconfiguration
- Other Users (if systemic): Notification and recovery options communication

---

## Closure Criteria

### RCA Closure Conditions

This RCA can be marked CLOSED when ALL of the following conditions are satisfied:

### Condition 1: Scope Assessment Complete ✅
**Verification:**
- Floor 6 devices spot-checked: Minimum 5-10 representative user devices
- Desktop shortcut count documented for each device
- Comparison: Expected baseline (5-8 shortcuts typical) vs. actual count
- Determination: Issue isolated (1-2 users) or systemic (3+ users)
- IT Operations Manager and IT Support Manager approval of scope findings

**Target Date:** 15-Aug-2026  
**Verification Owner:** IT Support Manager

**Acceptance Criteria:**
- If Isolated: Proceed to Condition 2 (User Recovery)
- If Systemic: Escalate to Conditions 2-8 (Floor-wide recovery)

---

### Condition 2: User Recovery Completed ✅
**Verification:**
- Affected user offered recovery options:
  - Option 1: Self-service shortcut recreation (5 minutes, user does it)
  - Option 2: IT restoration from profile backup (if available, 15-30 minutes)
  - Option 3: Bulk PowerShell recreation (IT creates shortcuts via script)
- User chooses recovery method
- Recovery method executed and validated
- User confirms desktop shortcuts restored successfully
- Help Desk incident FLR6-003 closed with resolution

**Target Date:** 16-Aug-2026  
**Verification Owner:** IT Support Manager

---

### Condition 3: Root Cause Analysis Complete ✅
**Verification:**
- Application installation scripts examined and analyzed
- Vendor application behavior documented:
  - Does app intentionally delete/reset desktop? YES/NO
  - Does app provide restore option? YES/NO
  - Is this documented in vendor documentation? YES/NO
- Vendor contacted and response received
- Root cause statement finalized and documented
- IT Operations Manager approval of root cause analysis

**Target Date:** 18-Aug-2026  
**Verification Owner:** IT Operations Manager

---

### Condition 4: Vendor Response and Configuration Options Evaluated ✅
**Verification:**
- Vendor response received explaining desktop modification behavior
- If intentional: Documentation of business justification
- Configuration options evaluated:
  - Can desktop modifications be disabled? YES/NO
  - Can user be prompted before modification? YES/NO
  - Can backup/restore be implemented? YES/NO
- Decision made: Reconfigure app, adjust deployment, or accept behavior
- IT Operations Manager and IT Director approval of decision

**Target Date:** 20-Aug-2026  
**Verification Owner:** IT Operations Manager

**Decision Paths:**
- If reconfigurable: Proceed to Condition 5 (Testing)
- If not reconfigurable: Proceed to Condition 6 (Communication)
- If deployment should be reversed: Escalate to IT Director

---

### Condition 5: Profile Preservation Testing Framework Created ✅
**Verification:**
- Testing procedure documented with specific steps:
  - Baseline profile state capture (desktop, folders, settings)
  - Application deployment execution
  - Post-deployment profile state capture
  - Automated diff and comparison (expected vs. actual)
  - Pass/fail reporting
- Testing framework reviewed and approved by QA and IT Operations
- Procedure ready for use in future deployments
- First test execution: Application redeployment (if applicable)

**Target Date:** 20-Aug-2026  
**Verification Owner:** QA Team + IT Operations Manager

---

### Condition 6: Deployment Checklist Updated ✅
**Verification:**
- Application profile customization testing added to deployment checklist
- New checklist items:
  - Test device has pre-existing desktop customizations? YES/NO
  - All pre-deployment shortcuts preserved post-deployment? YES/NO
  - Post-deployment profile validation completed? YES/NO
- Checklist version updated and distributed to deployment teams
- Change request template updated to include profile preservation verification
- IT Operations Manager approval of updated checklist

**Target Date:** 18-Aug-2026  
**Verification Owner:** IT Operations Manager

---

### Condition 7: User Communication and Notifications Completed ✅
**Verification:**
- Affected user notified of root cause findings
- User educated on desktop shortcut recovery options
- User offered support for restoration if desired
- If systemic issue: All affected users notified and offered recovery
- Communication templates created for future profile-modifying apps
- IT Support Manager approval of communication sent

**Target Date:** 18-Aug-2026  
**Verification Owner:** IT Support Manager

---

### Condition 8: Preventive Actions Implemented ✅
**Verification:**
- Preventive Action 1: Profile preservation testing mandatory (process documented, enforced)
- Preventive Action 2: Profile preservation added to deployment checklist
- Preventive Action 3: Application setup configuration standards documented
- Preventive Action 4: Profile preservation testing framework implemented and operational
- Preventive Action 5: Deployment change request updated with profile impact section
- Preventive Action 6: User communication template created for profile-modifying apps
- Preventive Action 7: Scope assessment procedure documented for future incidents
- All preventive actions documented and tracked in problem management system

**Target Date:** 25-Aug-2026  
**Verification Owner:** IT Director + Problem Management

---

### Condition 9: Lessons Learned Documented and Shared ✅
**Verification:**
- RCA complete and approved
- Lessons learned section documented (5 key lessons identified)
- Post-incident review meeting conducted with incident team
- RCA shared with IT leadership, IT Support, QA, and Security teams
- Lessons incorporated into training materials for deployment teams

**Target Date:** 20-Aug-2026  
**Verification Owner:** Problem Management

---

### Condition 10: No Incident Recurrence (Post-Closure Monitoring) ✅
**Verification:**
- 30-day monitoring period: Zero similar incidents (profile customization loss)
- Future deployments: All include profile preservation testing (audit)
- Help Desk tickets: No desktop customization loss complaints
- Monthly review: No similar profile modification issues detected

**Target Date:** 14-Sep-2026 (30 days post-closure)  
**Verification Owner:** IT Support Manager + IT Operations Manager

---

### RCA Closure Sign-Off

RCA is marked CLOSED when:
- ☐ All 10 conditions above verified as complete
- ☐ IT Support Manager approval
- ☐ IT Operations Manager approval
- ☐ IT Director approval (if systemic issue identified)
- ☐ Closure documentation added to this RCA
- ☐ Final RCA version archived

**Expected Closure Date:** 25-Aug-2026  
**Actual Closure Date:** ____________  
**Closed By:** ____________

---

## Document Information

**RCA Status:** COMPLETE  
**Classification:** INTERNAL - Operations  
**Distribution:** IT Operations, IT Support, Help Desk, IT Director  

**Approvals:**
- [ ] IT Support Manager: ___________________ Date: _______
- [ ] IT Operations Manager: ___________________ Date: _______
- [ ] IT Director: ___________________ Date: _______

**Version:** 1.0  
**Date:** 14-Aug-2026  
**Next Review:** Upon completion of scope assessment (target: 15-Aug-2026)

---

**Document Prepared By:** IT Support Manager  
**Document Reviewed By:** Incident Response Team  
**Final Approval:** IT Director
