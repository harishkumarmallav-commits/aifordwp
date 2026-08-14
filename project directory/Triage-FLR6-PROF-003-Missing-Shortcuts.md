# Floor 6 Incident Triage Report – STREAM 3
**Issue Name:** Missing Desktop Shortcuts on Floor 6 (FLR6-PROF-003)  
**Date:** 2026-08-14 | **Time Reported:** 09:14 | **Reporter:** IT Ops Lead | **Floor:** 6  
**Incident:** Desktop Customization Loss / Missing Shortcuts  
**Status:** TRIAGE IN PROGRESS

---

## EXECUTIVE SUMMARY
One Floor 6 user reported desktop shortcuts vanished this morning. Incident discovered at 09:14, timing correlates with Friday afternoon deployment of new document management app. **Business impact: MEDIUM.** Non-critical functionality loss; workarounds available. Investigation required to determine if issue is isolated user problem or systemic profile corruption caused by deployment. Likely pattern: Profile-level change or Group Policy impact.

---

## INCIDENT DETAILS

### DESKTOP CUSTOMIZATION LOSS / MISSING SHORTCUTS
**Priority:** MEDIUM (P3)  
**Reported by:** One Floor 6 user (identity TBD)  
**Incident Time:** Unknown (discovered this morning, likely Friday evening or overnight)  
**Affected User Count:** 1 confirmed, likely more (pattern assessment pending)

#### Business Impact
- **Severity Indicator:** MEDIUM
  - Workflow disruption for affected users (inconvenience, not work stoppage)
  - User productivity reduced (must recreate shortcuts or navigate through Start menu)
  - Reputational impact: Users perceive loss of data or system instability
  - Easily recoverable: Desktop customizations are typically non-critical data
  - Workarounds abundant: Users can access applications through Start menu, search, file explorer, taskbar
- **Scope:** Minimally 1 confirmed user; pattern suggests possibly 2-20+ users (TBD)
- **Affected Asset:** Desktop customization/shortcuts (stored in user profile or roaming profile cache)

#### Known Facts
- At least one user reported desktop shortcuts disappeared
- Timeframe: Discovered this morning (09:14 report), but shortcuts likely deleted Friday evening/overnight
- Correlation: Follows Friday afternoon document management app deployment
- Type: Desktop shortcuts (could be application shortcuts, file shortcuts, or both)
- User state: User reports this is unexpected, suggests not intentional deletion

#### Missing Critical Information
- **How many users are actually affected?** (1 reported or widespread pattern?)
- **Are shortcuts missing for single user or multiple users?** (Isolated incident or batch change)
- **What specific shortcuts are missing?** (System shortcuts, custom app shortcuts, file links?)
- **When exactly were shortcuts removed?** (Friday evening, overnight, or this morning?)
- **Are shortcuts physically deleted or just hidden?** (Data loss vs. display issue)
- **Does new document management app include desktop utility?** (Direct modification path)
- **Does app have profile modification logic?** (Initialization, cleanup, or reset routine)
- **Did app perform roaming profile replacement or sync?** (Profile synchronization impact)
- **Was Group Policy updated Friday that could remove shortcuts?** (Policy-based removal)
- **Are missing shortcuts standard Windows shortcuts or user-created?** (System vs. user-generated)

#### First Investigation Checks (ORDER OF PRIORITY)
1. **Immediate:** Interview affected user (within 15 minutes, before memory fades)
   - Which specific shortcuts are missing? (List exact names/locations)
   - Are ALL shortcuts gone or only specific ones?
   - Any other desktop changes noticed? (Icons, theme, settings)
   - Any error messages during startup/login? (Hung processes, failed tasks)
   - When was last time shortcuts were visible? (Friday afternoon?)
2. **High:** Check affected user device for hidden files
   - Enable "Show hidden files" on desktop folder
   - Verify shortcuts are actually deleted vs. hidden
   - Check Windows Recycle Bin for recently deleted shortcuts
   - Check "Show desktop icons" setting (might just be visibility toggle)
3. **High:** Review new document management app installation/configuration
   - Examine app installation script or MSI for profile modifications
   - Does app have "initialization" or "first-run" routine that clears shortcuts?
   - Does app have "cleanup" or "reset to defaults" logic?
   - Check app directory for any profile-related scripts or executables
   - Review app configuration files for user profile settings
4. **High:** Check Friday's Group Policy updates for policy-based removal
   - Was any Group Policy applied Friday that restricts or removes shortcuts?
   - Are policies targeting Floor 6 users (OU, security group)?
   - Could policy affect roaming profiles or default profiles?
5. **Medium:** Check user profile backup/roaming profile sync logs
   - Was user profile synced from backup or older version Friday?
   - Any profile replacement or refresh operations Friday evening?
   - Does organization use roaming profiles (if so, check profile server logs)?
6. **Medium:** Scan other Floor 6 users for similar shortcut loss
   - Query Help Desk for similar reports
   - Check if 2+ users report same issue (indicates systemic problem)

#### Evidence Required
- [ ] Affected user's device – direct inspection (what's actually on desktop now)
- [ ] User profile directory structure and file listing
  - C:\Users\[username]\Desktop – full contents and hidden files
  - C:\Users\[username]\AppData\Roaming\Microsoft\Internet Explorer\Quick Launch
  - C:\Users\[username]\AppData\Roaming\Microsoft\Windows\Start Menu
- [ ] Windows Event Logs from affected device (System, Application, Security)
  - Last 24 hours, focus on warnings/errors during startup
- [ ] Recycle Bin contents (look for .lnk files deleted Friday)
- [ ] User account audit log (profile changes, permissions, group membership changes)
- [ ] Document management app installation log/audit trail
  - Installer MSI execution log
  - Application installation directory contents
  - App configuration/initialization scripts
- [ ] Group Policy audit logs (if policies deployed Friday)
  - Policy application events
  - Scope and target of any new policies
- [ ] Roaming profile sync logs (if applicable)
  - Profile server logs for this user
  - Sync operations Friday/Saturday
- [ ] Screenshot or screenshot from user if available
- [ ] Interview notes from user describing exactly which shortcuts

#### Reason for MEDIUM Priority
- **Non-critical functionality:** Shortcuts are convenience feature, not business operation
- **Easily recoverable:** Shortcuts can be recreated in 30 minutes or restored from profile backup
- **Isolated report:** Only 1 user has complained out of 12+ on floor (doesn't suggest widespread issue)
- **Workarounds abundant:** Users can access applications through:
  - Start menu search
  - File Explorer navigation
  - Taskbar pinning
  - Direct file execution
- **No business data impact:** No files lost, no access restrictions, no data corruption
- **No compliance risk:** Does not affect data security, access control, audit requirements
- **Lower business impact:** Productivity hit is inconvenience (~5-10 min to recreate), not work stoppage
- **Likely benign root cause:** Deployment-related profile change more probable than security issue

---

## CRITICAL DECISION GATES

### Gate 1: Scope Assessment
**Decision:** How many users are affected?
- **If 1-2 users only:** User-specific issue or isolated device problem
- **If 3+ users:** Indicates systemic issue, likely deployment or policy-related
- **If 10+ users:** Major issue, immediate remediation required

### Gate 2: Root Cause Category
**Decision:** What caused the deletion?
- **If app-related:** New document management app modified profile
- **If policy-related:** Group Policy applied Friday removed shortcuts
- **If user action:** User deleted or cleared desktop (low probability)

### Gate 3: Recovery Strategy
**Decision:** Restore vs. Recreate?
- **If backup available:** Restore shortcuts from profile backup (fastest)
- **If isolated users:** Have users recreate shortcuts (minimal labor)
- **If systemic:** Batch restoration script needed for all affected users

---

## INVESTIGATION ROADMAP

### Phase 1: Immediate (Next 20 minutes)
1. Interview affected user – document exactly which shortcuts
2. Check user device desktop directly (enable hidden files)
3. Look in Recycle Bin for recently deleted .lnk files
4. Ask if other users on Floor 6 have reported similar issue

### Phase 2: Investigation (30-90 minutes)
1. Review new document management app installation/configuration
2. Check Friday Group Policy audit logs
3. Examine user profile sync logs (if roaming profile)
4. Query Help Desk for other shortcut-related tickets

### Phase 3: Root Cause & Remediation (90-180 minutes)
1. Determine if issue is isolated or affecting 3+ users
2. Identify root cause (app, policy, sync, or user action)
3. If isolated: User recreates shortcuts (~30 min per user, low cost)
4. If systemic: Restore from backup or deploy shortcut restoration script

---

## NEXT STEPS

**Immediate (Next 30 minutes):**
- Dispatch Level 1/2 tech to interview affected user
- Preserve evidence (user device state, event logs, profile)
- Query Help Desk for similar reports

**Follow-up Investigation:** 10:30 AM
- Expected to have: User interview notes, device inspection, Help Desk ticket scan results
- Decision point: Is this isolated or pattern? If pattern, initiate batch remediation

**Recovery Options (based on findings):**
- **Option A (Isolated, 1-2 users):** User recreates shortcuts manually (cost: ~30 min per user)
- **Option B (Pattern, 3+ users):** Restore from profile backup (cost: ~1 hour, affects all users)
- **Option C (App-caused):** Rollback deployment or remediate app configuration (cost: TBD)

**Communication to User:**
- "We're investigating the missing shortcuts issue."
- "Please use Start menu search or file explorer in the meantime."
- "We should have this resolved or a restore plan by end of day."
