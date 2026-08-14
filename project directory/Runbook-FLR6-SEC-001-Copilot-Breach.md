# Floor 6 Unauthorized Copilot Access Incident Runbook

**Title:** Unauthorized Client Data Access via Copilot - Security Containment & Investigation

**Version:** 1.0

**Date:** 14-Aug-2026

**Status:** Draft (Review before production use)

**Scenario:** Paralegal discovered Copilot displaying client matter data they have no authorized access to. Potential security breach and regulatory compliance violation requiring immediate containment, evidence preservation, and forensic investigation.

**Estimated Duration:** 30-45 minutes (containment + initial evidence collection)

---

## SECTION 1: BACKGROUND & CONTEXT

### What Happened
Friday 15:00 – Document management application deployed to Floor 6 devices via Intune  
Monday 09:14 – Paralegal reported Copilot displaying unauthorized client matter access  
Monday 09:30 – Incident classified as CRITICAL (P1) security breach with potential regulatory implications

### Why This is Critical
- Attorney-client privilege violation (information disclosure)
- Potential GDPR/regulatory compliance breach
- Scope unknown: Could affect multiple users on Floor 6
- Data integrity: Client confidential information may have been exfiltrated
- Immediate containment required: Prevent further unauthorized access

### What This Runbook Does
Executes emergency containment and evidence preservation:
1. Isolate affected user's device network access (preserve evidence, prevent further queries)
2. Disable user's Copilot access temporarily pending investigation
3. Capture Copilot audit logs for forensic analysis
4. Document client matters exposed for compliance team notification
5. Initiate security investigation without alerting potential threat actors

### Approval Required Before Proceeding
- [ ] IT Security Officer approval obtained
- [ ] Compliance/Legal review notified
- [ ] Incident ticket created (reference: FLR6-001)
- [ ] Executive escalation completed (CTO/Chief Security Officer)

**If approval not obtained:** STOP. Return to IT Security immediately for authorization.

---

## SECTION 2: PREREQUISITES

### Personnel Required
- **Primary:** IT Security Officer or Senior IT Admin (must have privileged access)
- **Secondary:** Intune Administrator (for account/device management)
- **Tertiary:** Compliance Officer (for regulatory review and documentation)
- **Quaternary:** Forensic Investigator or IT Auditor (for log analysis)

### Access & Permissions Required
1. **Intune Admin Access**
   - Must have: Global Admin or Intune Service Administrator role
   - Must have: Security Administrator role for device containment
   - Verify access to Microsoft Defender for Endpoint (if available)

2. **Copilot & Document Management System Access**
   - Must have: Administrator access to Copilot audit logs
   - Must have: Document management app audit logs access
   - Must have: User query history and result logging

3. **Azure AD/Entra ID Access**
   - Must have: Conditional Access policy modification rights
   - Must have: User account suspension/restriction rights
   - Verify by: Can access https://portal.azure.com/ with admin roles

### Information to Gather Before Starting

**Collect this information now:**

1. **Affected User & Device Details**
   - [ ] User name/email: `_____________________________`
   - [ ] Device name: `_____________________________`
   - [ ] Device enrollment status in Intune: `_____________________________`

2. **Incident Details**
   - [ ] Time breach discovered: `_____________________________`
   - [ ] Client matter(s) exposed: `_____________________________`
   - [ ] Copilot access timestamp(s): `_____________________________`
   - [ ] Reported by (witness): `_____________________________`

3. **Contact Information**
   - [ ] Compliance Officer contact: `_____________________________`
   - [ ] IT Security Officer contact: `_____________________________`
   - [ ] Incident ticket number: `FLR6-001` (or: `_____________________________`)

### System Requirements
- **Workstation:** Must have internet access and privileged admin console access
- **Tools:** PowerShell with Azure AD/Intune modules installed
- **Access:** VPN required if accessing remotely
- **Time:** Minimum 45 minutes uninterrupted (do not start if you might be interrupted)

---

## SECTION 3: IMMEDIATE CONTAINMENT (PHASE 1)

### Step 1: Network Isolation (First 2 minutes)

**Objective:** Prevent further unauthorized queries while preserving device evidence

**Action 1.1 – Option A: Complete Network Disconnection**
```powershell
# If device is physically accessible
# Unplug network cable from device
# OR disable WiFi adapter on device directly
# Time: Immediate
```

**Action 1.2 – Option B: Network Isolation via Intune (Preferred for Remote Devices)**
```powershell
# Create Conditional Access policy to block user's sign-in
# Navigate to: https://portal.azure.com/ → Azure AD → Conditional Access → New policy

# Policy Name: "EMERGENCY-FLR6-Breach-Containment-[DATE]"
# Assignments → Users → Select affected user (ONLY this user)
# Conditions → Cloud apps → Select "Copilot" and "Document Management App"
# Grant → Block access
# Enable policy: Yes
```

**Action 1.3 – Option C: Intune Remote Lock (Strongest Isolation)**
```powershell
# If device requires complete lockdown
# Intune Portal → Devices → All devices → Select device → Remote Lock
# Device will require PIN reset for recovery
# Use only if compromise is severe

# Command (PowerShell/Intune SDK):
# Invoke-MSGraphRequest -HttpMethod POST -Url /deviceManagement/managedDevices/{deviceId}/remoteLock
```

**Expected Result:** User cannot access Copilot, document management app, or network resources. Device preserved for forensics.

---

### Step 2: User Access Restriction (Minutes 2-5)

**Action 2.1 – Suspend User's Copilot Access**
```powershell
# Navigate to: Azure AD → Users → Select affected user
# Sign-in activity → Block sign-in
# OR Restrict conditional access for Copilot service specifically

# If using assignment-based access control:
# Remove user from Copilot user groups in Microsoft Entra
# Backup current group membership BEFORE removal
$userId = "affected-user@company.com"
$user = Get-MgUser -Filter "userPrincipalName eq '$userId'" -ErrorAction Stop
```

**Action 2.2 – Disable Document Management App Access**
```powershell
# Intune → Apps → Remove app assignment for affected user
# Or create Conditional Access block for user + document management app
# Prevent any further queries or data access
```

**Expected Result:** User completely isolated from Copilot and document management systems. No further queries possible.

---

### Step 3: Evidence Preservation (Minutes 5-15)

**Action 3.1 – Export Copilot Audit Logs**
```powershell
# Access Copilot audit/activity logs for affected user
# Time range: Friday 15:00 → Monday 09:14 (entire period)
# Export all queries, results, timestamps, and result content

# Command (if available in your Copilot management interface):
# Exact endpoint depends on Copilot deployment (Microsoft 365 / Microsoft Copilot)
# Likely location: Microsoft Purview Compliance Portal → Audit → Search

# Search criteria:
# - User: [affected user email]
# - Services: Copilot for Microsoft 365
# - Activities: "Accessed document" or "Searched" or custom Copilot logs
# - Date range: Friday 15:00 → Monday 09:14

# Export to: Encrypted USB or secure audit folder
# File format: CSV or JSON with full result sets
```

**Action 3.2 – Export Document Management App Access Logs**
```powershell
# Access document management app's audit trail
# Export all file access, document retrieval, and search queries
# For affected user (minimum 48 hours of activity)
# Include: Timestamp, query terms, documents accessed, user permissions at time of access

# Navigate to: Document Management App Admin Console → Audit Log
# Filter: User = [affected user], Date = Friday 15:00 → Monday 09:14
# Export to: Secure encrypted location
```

**Action 3.3 – Capture Device Event Logs**
```powershell
# Remote execution on affected device to preserve logs before evidence is lost

# Run via Intune → Devices → Run command:
# Command ID: RunPowerShellScript
# Scripts: 

wevtutil epl System "C:\ForensicsLogs\System.evtx"
wevtutil epl Security "C:\ForensicsLogs\Security.evtx"
wevtutil epl Application "C:\ForensicsLogs\Application.evtx"

# Then retrieve files from device
# Intune → Device → Files → Download logs
```

**Action 3.4 – Document Affected Data**
```
Create spreadsheet capturing:
- Client matter name(s) accessed
- Client name
- Matter classification (Confidential, Privileged, Restricted)
- Specific documents or data elements visible in Copilot
- Estimated number of documents/records exposed
- Regulatory implication (GDPR, attorney-client privilege, etc.)

This list is needed for compliance/legal notifications
```

**Expected Result:** All audit logs, queries, and event data captured and preserved. Device evidence intact.

---

## SECTION 4: INVESTIGATION HANDOFF (PHASE 2)

### Step 4: Prepare Evidence Package for Security Team

**Action 4.1 – Create Forensic Evidence Package**
```
Package contents:
1. Copilot audit log export (all queries, results, timestamps)
2. Document management app access log export
3. Device event logs (System, Security, Application)
4. User account audit history (permission changes since deployment)
5. Deployment details (Friday 15:00 document management app deployment scope)
6. Initial witness statement (paralegal's account of what was accessed)
7. Screenshots/recordings (if user captured Copilot result display)
8. Incident ticket reference (FLR6-001)

Store in: Encrypted folder, limited access
Location: \\[secure-server]\Forensics\FLR6-001-Copilot-Breach\
Classification: CONFIDENTIAL - Legal Hold
```

**Action 4.2 – Notify Compliance/Legal Team**
```
Email to: [Compliance Officer], [General Counsel], [IT Security Officer]

Subject: URGENT - Security Incident FLR6-001 - Copilot Unauthorized Data Access

Body template:
- Incident ID: FLR6-001
- Severity: CRITICAL (P1)
- Type: Unauthorized information disclosure via Copilot
- Timeline: Friday 15:00 deployment → Monday 09:14 discovery
- Affected data: [client matter list]
- Immediate actions taken: User/device isolated, evidence preserved
- Evidence location: [forensic evidence path]
- Investigation leads: [list questions for compliance team]
- Notification obligations: [GDPR? Client notification required? Regulatory reporting required?]
- Request: Direction on client/regulatory notification timeline
```

**Action 4.3 – Escalate to IT Security Investigation Team**
```
Handoff to: IT Security Officer or Forensic Investigator
Responsibility transfer: Security team now owns investigation/root cause
IT Operations responsibility: Keep device isolated, preserve evidence, await security instructions

Investigation questions for security team:
1. How did unauthorized data reach Copilot result set?
2. Was document management app deployed with incorrect access controls?
3. Are other Floor 6 users also affected by same access control issue?
4. Was data exfiltrated or only viewed?
5. How long has this access control weakness existed (deployment-caused vs. pre-existing)?
6. What is required remediation? (App reconfiguration? Data access reset? User account review?)
7. Should all Floor 6 users' Copilot activity be audited for similar breaches?
```

**Expected Result:** Evidence secured, compliance team notified, investigation transferred to security team.

---

## SECTION 5: COMMUNICATION & DOCUMENTATION

### Step 5: Document Actions Taken

**Action 5.1 – Update Incident Ticket**
```
Ticket ID: FLR6-001
Timeline log:
- 09:14 – Incident reported (Copilot unauthorized access)
- 09:30 – Containment Phase initiated
- [TIME] – Network isolation completed
- [TIME] – User access suspended
- [TIME] – Copilot audit logs exported
- [TIME] – Device logs preserved
- [TIME] – Forensic evidence package prepared
- [TIME] – Compliance team notified
- [TIME] – Investigation transferred to IT Security

Current status: CONTAINED - Awaiting security investigation
Next action: Security team to determine root cause and remediation scope
```

**Action 5.2 – Notify Floor 6 Users (After Executive Approval)**
```
Do NOT communicate until IT Security/Compliance gives approval.
Risk: Premature communication may alert data subjects or regulatory bodies before 
       investigation scope is understood.

When approved, communication should:
- NOT describe technical details or confirm data breach scope
- Reassure Floor 6 users that IT is investigating login/app issues identified Friday
- Direct users to service desk for questions
- NOT mention Copilot incident or security breach yet

Template (after security approval):
"IT is investigating several issues identified on Floor 6 devices following Friday's 
software updates. We're working to resolve these quickly. If you experience any 
system issues, please contact the service desk."
```

---

## SECTION 6: ROLLBACK (If Required by Security Team)

### If Document Management App is Identified as Root Cause:

**Action 6.1 – Emergency Rollback Decision**
```
Security team may recommend:
Option 1: Rollback document management app deployment from all devices
Option 2: Reconfigure app access controls and retest
Option 3: Partial rollback from affected user group only

Escalation: Obtain approval from IT Director and Compliance Officer before rollback
If rollback approved: Execute using "Floor 6 Application Deployment Rollback Runbook"
```

---

## SECTION 7: POST-INCIDENT (After Investigation Complete)

### Step 7: Restoration & Prevention

**Action 7.1 – User Account Restoration**
```
Once security team confirms investigation complete and issue remediated:
1. Remove Conditional Access restrictions on user
2. Re-enable Copilot and document management app access
3. Verify user can access appropriate data (not unauthorized data)
4. Document findings for post-incident review
```

**Action 7.2 – Prevention Updates**
```
Based on investigation findings:
- Update data access controls in Copilot
- Review document management app permission matrix
- Audit deployment procedures for security control verification
- Update deployment testing checklist to include access control validation
```

---

## APPENDIX: QUICK REFERENCE

**Escalation Contacts:**
- IT Security Officer: [Contact]
- Compliance Officer: [Contact]
- IT Director: [Contact]

**Key Locations:**
- Copilot Admin Console: https://[your-tenant].microsoft.com/admin/copilot
- Document Management App Admin: [admin URL]
- Azure AD Conditional Access: https://portal.azure.com/#blade/Microsoft_AAD_ConditionalAccess/

**Critical Timestamps:**
- Deployment time: Friday 15:00
- Incident discovery: Monday 09:14
- Approved log retention period: [your retention policy]
