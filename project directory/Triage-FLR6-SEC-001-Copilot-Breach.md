# Floor 6 Incident Triage Report – STREAM 1
**Issue Name:** Unauthorized Client Data Access via Copilot (FLR6-SEC-001)  
**Date:** 2026-08-14 | **Time Reported:** 09:14 | **Reporter:** IT Ops Lead | **Floor:** 6  
**Incident:** Unauthorized Data Access / Information Disclosure  
**Status:** TRIAGE IN PROGRESS

---

## EXECUTIVE SUMMARY
Paralegal on Floor 6 discovered Copilot displaying client matter she has no authorized access to. Incident discovered this morning following Friday afternoon deployment of new document management app. **Security and compliance risk: CRITICAL.** Immediate investigation required to determine access extent, whether data was exfiltrated, and if other users are affected.

---

## INCIDENT DETAILS

### UNAUTHORIZED DATA ACCESS / INFORMATION DISCLOSURE
**Priority:** CRITICAL (P1)  
**Reported by:** Paralegal (specific user TBD)  
**Incident Time:** Unknown (discovered this morning)

#### Business Impact
- **Severity Indicator:** CRITICAL
  - Information security breach involving client-privileged information
  - Potential regulatory compliance violation (attorney-client privilege)
  - Data may have been accessed outside authorization scope
  - Risk of reputational damage and client notification obligations
- **Scope:** Minimally 1 confirmed, potentially affects floor-wide access controls
- **Affected Asset:** Microsoft Copilot / AI system displaying unauthorized client matter

#### Known Facts
- One paralegal confirmed accessing client matter through Copilot
- User stated she has **never had access** to this specific matter (explicit testimony)
- Timing: Discovered this morning (09:14 report)
- Correlation: Occurred after Friday afternoon document management app deployment
- Access method: Copilot (appears to be AI-assisted search/retrieval)

#### Missing Critical Information
- **How many users attempted unauthorized access?** (Only 1 discovered, others unknown)
- **Which specific client matter(s) were exposed?** (Identification needed for scope)
- **How long was unauthorized data visible?** (Friday afternoon → Thursday morning = ~13 hours minimum)
- **What data was accessed/viewed?** (Documents, metadata, scope of exposure)
- **Did access occur through search, chat, or other Copilot features?** (Attack vector unclear)
- **Can we identify all Copilot queries from this user since deployment?** (Query history audit)
- **Does the issue affect other users on Floor 6?** (Systematic vs. isolated)
- **What backend systems did Copilot query?** (Document management app integration?)
- **Are there data classification controls in Copilot?** (Access policy enforcement)
- **Was the new document management app configured with correct access controls?** (Root cause likely here)

#### First Investigation Checks (ORDER OF PRIORITY)
1. **Immediate:** Isolate affected user's device network access temporarily (preserve evidence, prevent further unauthorized queries)
2. **Immediate:** Query Copilot audit logs for this user since Friday deployment
   - All queries submitted
   - All results returned
   - Access attempt timestamps
3. **High:** Identify which specific client matter(s) were accessed
4. **High:** Retrieve all document access logs from new document management app (Friday-present)
5. **High:** Review integration/authentication layer between Copilot and document management app
6. **Medium:** Interview paralegal for exact query terms, what was displayed, screenshot if available
7. **Medium:** Check if user's account permissions were modified or elevated during/after deployment
8. **Medium:** Scan other Floor 6 user queries to new document management app (pattern detection)

#### Evidence Required
- [ ] Copilot audit logs (user queries, results returned, timestamp)
- [ ] Document management app access logs (all users, Friday-present)
- [ ] User's device query history (Copilot chat history export)
- [ ] Screenshot/recording of Copilot result (if available from user)
- [ ] Client matter document access logs (who viewed, when, from which source system)
- [ ] New app deployment documentation (access control configuration)
- [ ] App integration code/API calls (Copilot ↔ Document Management)
- [ ] User account audit log (permission changes, group membership changes)
- [ ] Document management app permissions matrix (current effective permissions)

#### Reason for CRITICAL Priority
- **Regulatory exposure:** Potential GDPR/attorney-client privilege violation
- **Data classification:** Client confidential matters accessed outside authorization
- **Unknowns far outweigh knowns:** Could be 1 user or 12; could be read-only or exfiltration
- **Irreversible action possible:** Data already viewed; scope of exposure cannot be recovered
- **Deployment correlation:** Friday change window directly precedes discovery
- **Must determine:** Whether this is isolated user behavior vs. systemic access control failure

---

## CRITICAL DECISION GATES

### Security Containment Decision
**Decision:** Is data exfiltration suspected or user negligence?
- **If exfiltration risk:** Escalate to security incident response, legal, compliance
- **If configuration error:** Plan access control remediation, notify affected users

---

## INVESTIGATION ROADMAP

### Phase 1: Immediate (Next 15 minutes)
1. Isolate affected user device network access (prevent further queries)
2. Preserve Copilot audit logs for this user (before rotation)
3. Brief legal/compliance on potential data exposure

### Phase 2: Investigation (30-120 minutes)
1. Query Copilot audit logs – all user queries since Friday deployment
2. Identify specific client matter(s) accessed
3. Review document management app access control configuration
4. Audit integration layer between Copilot and document app
5. Interview paralegal – exact query terms, what was displayed, screenshots
6. Check user account permissions for modifications or elevation

### Phase 3: Scope Assessment (120-180 minutes)
1. Scan all Floor 6 user Copilot queries for unauthorized access patterns
2. Determine if other users can access the same restricted client matter
3. Pull document access logs from document management system
4. Assess whether issue is isolated user or systemic access control failure

---

## NEXT STEPS

**Immediate (Next 30 minutes):**
- Escalate to Security, Compliance, and Legal
- Initiate data breach investigation protocol
- Preserve all evidence (Copilot logs, app config, user account audit)

**Follow-up Triage Meeting:** 10:30 AM
- Expected to have Copilot logs, affected client matter identification, access control review
- Decision point: Regulatory notification timeline

**Communication to Management:**
- Risk level: CRITICAL – potential data breach with legal/regulatory implications
- Timeline: Investigation ongoing; may require client notification
- Status: Updates every 2 hours or upon major finding
- **Exact number of affected users?** (12+ is range; need precise count)
- **When did login issues begin?** (Friday evening, overnight, this morning?)
- **Are login failures affecting all users or only some user accounts?** (Accounts vs. devices)
- **Is failure at domain authentication or application layer?** (AD/Entra vs. application)
- **Are login attempts recorded in authentication logs or failing silently?** (Logging status)
- **What is typical login time for Floor 6 users?** (Baseline for "slow" definition)
- **Are affected users on same subnet/network segment?** (Localized or distributed)
- **Is the new document management app part of login process?** (Direct correlation)
- **Have other floors experienced login issues?** (Scope containment question)
- **Did the app deployment change any network, firewall, or proxy settings?** (Infrastructure changes)

#### First Investigation Checks (ORDER OF PRIORITY)
1. **Immediate:** Get exact count of affected users (floor-wide survey or ticket count)
2. **Immediate:** Confirm: Is this Floor 6 only or wider impact? (Test login from other floors)
3. **Immediate:** Check authentication service health (AD/Entra ID status, replication, service availability)
4. **High:** Review Friday deployment change log
   - What services were modified?
   - Were any authentication-related services affected?
   - Were network/firewall rules changed?
5. **High:** Check for new document management app impacting login flow
   - Is app launched during startup/login?
   - Does app authenticate separately before login completes?
   - Are there hanging processes during login?
6. **High:** Pull authentication logs from affected user devices (last 12 hours)
   - Event ID 4768/4769/4771 (Kerberos)
   - Event ID 4625 (Failed login)
   - NTLM auth failures
7. **Medium:** Measure actual login times for affected vs. unaffected users
8. **Medium:** Check for resource contention (CPU, disk I/O, network) during login

#### Evidence Required
- [ ] List of all affected user account names and devices
- [ ] Friday deployment change documentation
- [ ] Document management app installation/deployment details
- [ ] Authentication service logs (AD event logs, Entra sign-in logs)
- [ ] Domain controller replication status
- [ ] Network/firewall logs (login timeframe)
- [ ] Device event logs (System, Security) from affected machines
- [ ] New app startup configuration and dependencies
- [ ] Process monitor trace during login (if reproducible)
- [ ] Network packet capture during slow login (if reproducible)

#### Reason for HIGH Priority
- **Blocks core business operations:** Users cannot access any systems
- **High-impact user population:** Finance/legal staff (high cost per hour of downtime)
- **Probable correlation:** Deployment timing suggests direct cause
- **Workaround limited:** Cannot bypass login to restore service quickly
- **Scope expansion risk:** If root cause is infrastructure-wide, other floors may be at risk
- **Duration unknown:** Could continue affecting users throughout business day

---

### STREAM 3: DESKTOP CUSTOMIZATION LOSS / MISSING SHORTCUTS
**Priority:** MEDIUM (P3)  
**Reported by:** One user on Floor 6  
**Incident Time:** Unknown (discovered this morning)  
**User Count:** 1 confirmed, likely more

#### Business Impact
- **Severity Indicator:** MEDIUM
  - Workflow disruption for affected users
  - User productivity reduced (must recreate shortcuts or find files through alternative navigation)
  - Reputational impact: Users perceive loss of data or system instability
  - Recoverable: Desktop customizations are typically non-critical and can be restored
- **Scope:** Minimally 1 confirmed user; pattern suggests possibly multiple users
- **Affected Asset:** Desktop customization/shortcuts (likely stored in user profile or roaming profile)

#### Known Facts
- At least one user reported desktop shortcuts vanished
- Timeframe: Discovered this morning
- Correlation: Follows Friday afternoon document management app deployment
- Type: Desktop shortcuts (could be application shortcuts, file shortcuts, or links)

#### Missing Critical Information
- **How many users lost shortcuts?** (1 reported or pattern?)
- **Were shortcuts lost for one user or multiple?** (Isolated or batch change)
- **What shortcuts are missing?** (System shortcuts, custom app shortcuts, file links?)
- **When exactly were shortcuts removed?** (Friday evening, overnight, this morning?)
- **Are shortcuts physically deleted or hidden?** (Data loss vs. display issue)
- **Does the new document management app include a desktop utility or profile hook?** (Likely cause)
- **Has a roaming profile update/sync occurred?** (Profile synchronization timing)
- **Was there a Group Policy update deployed?** (Could remove/restrict shortcuts)
- **Are missing shortcuts standard Windows shortcuts or custom links?** (System vs. user-created)

#### First Investigation Checks (ORDER OF PRIORITY)
1. **Immediate:** Interview user whose shortcuts disappeared
   - Which specific shortcuts?
   - Any other desktop changes noticed?
   - Any error messages during startup/login?
2. **High:** Check affected user's device for hidden files (enable show hidden)
   - Verify shortcuts are actually deleted vs. hidden
   - Check Recycle Bin for recently deleted items
3. **High:** Review new document management app installation/configuration
   - Does app modify user profile on install?
   - Does app have "cleanup" or "default settings" routine?
   - Check app's directory for anything related to desktop customization
4. **High:** Check Friday's Group Policy updates
   - Were any policies applied that restrict/remove shortcuts?
   - Are policies targeting Floor 6 users?
5. **Medium:** Check user profile backup/roaming profile sync logs
   - Was profile synced from backup or older version?
   - Any profile replacement operations Friday evening?
6. **Medium:** Scan other Floor 6 users for similar reports (pattern detection)

#### Evidence Required
- [ ] Affected user's device registry (shortcuts may be stored in registry)
- [ ] User profile directory structure and file listing (Desktop folder, Documents, etc.)
- [ ] Windows Event Logs (System, Application) from affected device (Friday-present)
- [ ] Document management app installation log/audit trail
- [ ] Group Policy audit logs (if policies deployed Friday)
- [ ] Roaming profile sync logs (if applicable)
- [ ] User's home directory backup (if available)
- [ ] Interview notes from user describing exactly which shortcuts

#### Reason for MEDIUM Priority
- **Non-critical functionality:** Shortcuts are convenience feature, not core business process
- **Recoverable:** Shortcuts can be recreated or restored from backup
- **Isolated so far:** Only 1 confirmed report; may be user-specific
- **Workaround available:** Users can access applications through Start menu or direct file navigation
- **Lower business impact:** Productivity hit is inconvenience, not complete work stoppage
- **Likely benign root cause:** Deployment-related profile change more probable than security issue

---

## INVESTIGATION SEQUENCING & RESOURCE ALLOCATION

### PHASE 1: IMMEDIATE (Next 30 minutes)
**Objective:** Contain risk and establish incident scope

| Stream | Action | Owner | Est. Time | Rationale |
|--------|--------|-------|-----------|-----------|
| **STREAM 1** | Isolate affected user device (network isolation if necessary) | Network Ops | 5 min | Prevent further unauthorized data access |
| **STREAM 1** | Query Copilot audit logs for this user | Security/AI Admin | 10 min | Determine access extent before logs rotate |
| **STREAM 2** | Confirm: Floor 6 only or wider impact? | Help Desk | 5 min | Establish containment and urgency |
| **STREAM 2** | Pull affected user count from tickets | Help Desk | 5 min | Quantify business impact |
| **STREAM 3** | Interview affected user | Level 2 Tech | 10 min | Establish facts before memory fades |

### PHASE 2: PARALLEL INVESTIGATION (30-90 minutes)
**Objective:** Identify root causes and determine rollback necessity

**Stream 1 Track:**
- Analyze Copilot query results against access control matrix
- Review document management app configuration (access controls)
- Audit integration layer (Copilot ↔ document app API)

**Stream 2 Track:**
- Review Friday deployment change log
- Check authentication service health and logs
- Test new app's impact on login process
- Run network diagnostics on Floor 6 segment

**Stream 3 Track:**
- Check for Group Policy changes
- Verify user profile for traces of shortcuts
- Scan other Floor 6 users for similar reports

### PHASE 3: ROOT CAUSE DETERMINATION (90-180 minutes)
**Objective:** Establish causality and recommend action

- **Stream 1:** Determine if issue is isolated user activity, configuration error, or systemic access control failure
- **Stream 2:** Identify whether new app deployment directly caused login issues or coincidental infrastructure issue
- **Stream 3:** Determine if shortcuts were deleted by app, policy change, or user action

---

## CRITICAL DECISION GATES

### Gate 1: Security Containment (STREAM 1)
**Decision:** Is data exfiltration suspected or user negligence?
- **If exfiltration risk:** Escalate to security incident response, legal, compliance
- **If configuration error:** Plan access control remediation, notify affected users

### Gate 2: System Availability (STREAM 2)
**Decision:** Is new app the root cause?
- **If yes:** Rollback app vs. configuration fix (time vs. risk trade-off)
- **If no:** Investigate infrastructure, coordinate with platform team

### Gate 3: User Impact Scope (STREAM 3)
**Decision:** How many users affected?
- **If 1-2 users:** Repair individual profiles, low priority
- **If 3+ users:** Indicates systemic issue, may require profile restoration procedure

---

## REASONING FOR PRIORITY ASSIGNMENT

### Why STREAM 1 is CRITICAL (Not HIGH)
1. **Irreversibility:** Data already accessed; cannot undo the view
2. **Legal implications:** Attorney-client privilege, GDPR compliance, regulatory reporting
3. **Scope unknowns are dangerous:** Could be 1 user or 12; could be 1 document or 100
4. **Containment required:** Must prevent ongoing unauthorized access before it spreads
5. **Evidence decay risk:** Copilot logs may rotate; audit trails may be incomplete
6. **Client notification timeline:** May have 30-90 day regulatory notification requirement

### Why STREAM 2 is HIGH (Not CRITICAL)
1. **Business disruption is significant but not legal exposure**
2. **Users have workaround:** Physical login attempts, password reset procedures
3. **Scope is identified:** Minimum count established (12+ users)
4. **Likely technical fix:** Authentication issues typically resolvable quickly
5. **Reversibility:** If deployment caused it, rollback is possible

### Why STREAM 3 is MEDIUM (Not HIGH)
1. **Non-critical functionality:** Shortcuts are convenience, not business operation
2. **Workarounds abundant:** Users can launch apps from Start menu, file explorer, taskbar
3. **Easily recoverable:** Shortcuts can be recreated or restored from profile backup
4. **Isolated report:** Only 1 user has complained (suggests not widespread)
5. **No compliance risk:** Does not affect data security, access control, or audit requirements

---

## NEXT STEPS

**Immediate Actions (Next 15 minutes):**
1. Escalate STREAM 1 to Security/Compliance (data breach investigation protocol)
2. Dispatch Level 2 tech to Floor 6 for STREAM 2 investigation
3. Brief IT Ops lead on three-stream approach and timeline
4. Initiate evidence preservation for all streams

**Follow-up Triage Meeting:** 10:30 AM (60 minutes from initial report)
- Expected to have: User counts, deployment change details, initial authentication logs
- Decision point: Rollback vs. configuration fix for STREAM 2

**Communication to Management:**
- Confirmed: Three separate incidents, not single outage
- Risk: CRITICAL data access issue requires investigation; unlikely to resolve before EOD
- Expected: STREAM 2 resolution within 2-3 hours if deployment-related
- Status: Daily updates at 11:00 AM, 2:00 PM, EOD

