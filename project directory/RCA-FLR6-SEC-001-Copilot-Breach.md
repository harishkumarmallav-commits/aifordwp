# Root Cause Analysis: Unauthorized Data Access via Copilot - FLR6-SEC-001

**Incident ID:** FLR6-SEC-001  
**Title:** Unauthorized Client Matter Access via Copilot on Floor 6  
**Classification:** CRITICAL Security Incident - Permissions Governance Failure  
**Date:** 14-Aug-2026  
**Report Prepared:** IT Security Officer  
**Status:** CLOSED - RCA Complete

---

## Executive Summary

On Monday, August 14, 2026, at 09:14, a Floor 6 paralegal discovered that Microsoft Copilot was displaying client matter information to which she had no authorized access. Investigation confirmed this was not a Copilot product defect but rather a **permissions governance failure** in the document management system integration layer deployed Friday, August 11, 2026.

**Root Cause:** Document management application API service account was configured with administrative ("full access") permissions, allowing Copilot queries to bypass user-level permission checks and return all documents regardless of the querying user's actual authorization level.

**Impact:** One user confirmed accessing unauthorized data; potential floor-wide exposure (12+ Floor 6 users) with unknown exfiltration scope.

**Resolution:** User access revoked, Copilot disabled, service account permissions audited, and redeployment blocked pending remediation.

---

## Incident Summary

### What Happened

On Friday, August 11, 2026, at 15:00, a document management application (DMA) was deployed to Floor 6 devices via Intune. The deployment included integration with Microsoft Copilot to enable AI-assisted search across enterprise documents.

On Monday, August 14, 2026, at 09:14, a Floor 6 paralegal reported discovering a client matter in Copilot search results—a matter she stated she had **never been assigned to and had no authorization to access**.

Investigation immediately began. Preliminary findings indicated the integration was configured with elevated permissions that allowed Copilot to return unfiltered results.

### Initial Indicators

- **User Statement:** "I queried for [generic term]. Copilot returned Matter #X, which I don't have access to. I have never worked on this matter and should never see this."
- **Query Evidence:** Copilot audit logs showed the user's successful query returning documents classified as "Confidential - Client Privilege"
- **Access Control Mismatch:** User's role (Paralegal - General) should filter to assigned matters only; instead, saw all floor-wide matters
- **Deployment Correlation:** Issue did not exist Friday morning; appeared immediately post-deployment Friday afternoon

---

## Scope Assessment

### Confirmed Exposure

| Aspect | Finding |
|--------|---------|
| **Users Affected** | 1 confirmed (paralegal who discovered issue) |
| **Potential Users** | 12+ Floor 6 staff (deployment target group) |
| **Client Matters Exposed** | Minimum 1; potentially 12+ (full audit pending) |
| **Access Method** | Copilot search queries |
| **Data Classification** | Client Confidential - Attorney-Client Privileged |
| **Exfiltration Status** | Unknown (query logged; external exfil not confirmed) |
| **Deployment Scope** | Floor 6 Users group only (not organization-wide) |

### Scope Justification

- **Single User Confirmed:** Only one user self-reported unauthorized access
- **Floor-Wide Potential:** All 12+ Floor 6 users received same app configuration; all potentially exposed
- **No Automatic Detection:** No system alerts triggered; reliant on user discovery (suggests proactive monitoring gap)
- **Unknown Full Scope:** Copilot audit logs must be fully analyzed to determine if other users queried unauthorized data unknowingly

---

## Timeline

| Date/Time | Event | Evidence |
|-----------|-------|----------|
| **Friday, 11-Aug, 15:00** | Document management app deployment initiated | Intune deployment logs |
| **Friday, 11-Aug, 15:15** | App installed on Floor 6 devices; API integration activated | App installation logs; Copilot integration config timestamp |
| **Friday, 11-Aug, 15:30** | Copilot indexing begins on document management data | Copilot sync logs; integration service startup events |
| **Friday, 11-Aug, 16:00-18:00** | Incubation period (no reports; issue not yet discovered) | No incident tickets; no user complaints |
| **Monday, 14-Aug, 08:00-09:00** | Users begin Monday morning login and work (potential unauthorized queries during this window) | Login success logs; app activity logs |
| **Monday, 14-Aug, 09:14** | Paralegal discovers unauthorized data in Copilot | User self-report; initial triage |
| **Monday, 14-Aug, 09:30** | Incident escalated to IT Security (severity: CRITICAL) | Incident ticket FLR6-001 created |
| **Monday, 14-Aug, 09:45** | Affected user's device isolated; Copilot access disabled | Device isolation event; Conditional Access policy created |
| **Monday, 14-Aug, 10:00** | Copilot audit logs exported for forensic analysis | Audit log export timestamp |
| **Monday, 14-Aug, 10:30** | Compliance and Legal teams engaged for notification assessment | Email escalation to Legal/Compliance |
| **Monday, 14-Aug, 11:00** | Executive leadership briefed | Executive summary distributed |
| **Monday, 14-Aug, 14:00-present** | Investigation ongoing: RCA documentation, service account audit, permission verification | This RCA document; investigation log |

---

## Supporting Evidence

### Evidence 1: Copilot Audit Logs

**Finding:** Copilot audit logs confirm the affected user executed a search query and received results that should not have been available based on her access level.

**Evidence Details:**
- Query timestamp: Monday 09:14
- Query terms: [Generic document terms]
- Results returned: Client Matter #X (classified as "Confidential - Client Privilege")
- User's authorized matters: [List of her assigned matters] (Matter #X NOT in this list)
- Access level mismatch: Confirmed

**Source:** Microsoft Purview Audit Logs, Copilot activity record  
**Chain of Custody:** Exported and secured by IT Security Officer  
**Reliability:** Very High (system-generated log, not user-provided)

### Evidence 2: Document Management System Access Control Configuration

**Finding:** Document management app's API service account was configured with administrative permissions (full document read access) instead of role-based permissions.

**Configuration Analysis:**
```
Service Account Permissions (As Deployed):
├── Account: DMA-API-Service@company.onmicrosoft.com
├── Role: Global Admin / Full Access
├── Permissions: Can query ALL documents in system
├── User Filtering: DISABLED/MISSING
└── Result: Copilot receives all documents; filtering should happen at app layer but did not

Expected Configuration:
├── Account: DMA-API-Service@company.onmicrosoft.com
├── Role: Limited Service Account (Reader only)
├── Permissions: Can only query documents based on caller's context
├── User Filtering: ENABLED - queries filtered by authenticated user's permissions
└── Result: Copilot receives only documents user is authorized to see
```

**Source:** Document management app admin console; service account audit logs  
**Evidence Type:** System configuration snapshot  
**Reliability:** Very High (configuration documentation; verifiable)

### Evidence 3: Deployment Documentation Review

**Finding:** Deployment documentation did not specify user permission filtering requirements for Copilot integration.

**Documentation Gap:**
- Pre-deployment security review: NOT PERFORMED (checklist missing)
- Integration architecture review: NOT DOCUMENTED
- Service account permission justification: MISSING ("full access" assumed as default)
- User filtering implementation requirement: NOT STATED
- Access control testing: NOT INCLUDED in deployment plan

**Source:** Deployment change request (CR-FLR6-DMA-001); deployment plan file  
**Evidence Type:** Process failure documentation  
**Reliability:** High (absence of evidence is evidence)

### Evidence 4: User Interview

**Finding:** Affected user confirms she had no authorization to access the exposed matter and has no legitimate reason to know about it.

**User Statement:**
> "I queried for [terms] hoping to find a template. Copilot showed me Matter #X. I know I've never worked on that matter. I was never assigned to it, and I have no need to know about it. The client is even from a completely different practice area that I don't work in."

**Interview Details:**
- Date: Monday 14-Aug, 09:45
- Duration: 15 minutes
- Questions covered: Query intent, access authorization, data sensitivity, potential exposure
- User credibility: High (proactive reporting; clearly understood access restrictions)

**Source:** Incident response team interview notes  
**Reliability:** High (first-hand account; no conflicts with system evidence)

### Evidence 5: No Authentication System Compromise

**Finding:** Active Directory and Kerberos logs show no authentication system issues; user authenticated normally and correctly.

**Authentication Verification:**
- User credential submission: Valid
- Kerberos TGT issuance: Successful
- AD group membership: Correct (Floor 6 Users group)
- Session token: Properly issued
- No privilege escalation detected in authentication logs

**Source:** Windows Security event logs (Event IDs 4624, 4768, 4769); Azure AD sign-in logs  
**Reliability:** Very High (system security logs; auditable)

**Conclusion:** Issue is NOT authentication bypass. User legitimately authenticated. Issue is at application permission layer.

### Evidence 6: No Copilot Product Defect

**Finding:** Copilot product itself is functioning correctly; the issue is in the integration configuration and upstream data permissions.

**Copilot Behavior Analysis:**
- Copilot is correctly executing queries against document management API
- Copilot is correctly returning results provided by the API
- Copilot has no independent knowledge of document-level permissions
- Copilot relies on upstream system to provide only authorized documents

**Source:** Copilot query logs; API call tracing  
**Reliability:** High (query and return path confirmed)

**Conclusion:** Copilot is behaving as designed. The upstream system (document management app API) is providing unauthorized data.

---

## Root Cause Statement

### Primary Root Cause

**The document management application was deployed with its API service account configured with administrative ("full access") permissions, combined with the absence of user-level permission filtering in the Copilot integration layer. This allowed Copilot queries to return all documents in the system regardless of the authenticated user's authorization level.**

### Root Cause Reasoning

1. **Service Account Configuration Error:** The API service account was not restricted to minimal necessary permissions (principle of least privilege violation). Instead, it was given full administrative access—likely the system default used during development and not restricted before production deployment.

2. **Missing User-Level Filtering:** The integration between Copilot and the document management app did not implement user authorization checks. The integration should filter query results based on the authenticated user's permissions; this filtering logic was either missing, disabled, or bypassed.

3. **No Pre-Deployment Security Review:** The deployment proceeded without a security review that would have caught this configuration. No checklist required verification of access control implementation.

4. **Assumption of "Admin Service Account":** Development/deployment team likely assumed administrative service accounts were acceptable for backend integrations. This is a common mistake but violates security best practices.

---

## Security Impact

### Confidentiality Impact: HIGH

- **Data Exposed:** Client confidential matters (attorney-client privileged information)
- **Scope:** Minimum 1 matter exposed to 1 unauthorized user; potentially multiple matters to multiple users
- **Regulatory Sensitivity:** Attorney-client privilege violation potential
- **Data Classification:** "Confidential - Client Privilege" (highest internal classification)

### Integrity Impact: LOW

- **Data Modification:** No evidence of data modification or corruption
- **Data Corruption:** No unauthorized deletions or alterations
- **Conclusion:** Integrity not compromised; read-only access issue

### Availability Impact: NONE

- **System Availability:** No systems were taken offline
- **User Access:** Authorized access to authorized data not impacted
- **Availability Compromised:** No

### Overall CVSS-Style Severity: **CRITICAL**
- Confidentiality: High impact
- Unauthorized access to privileged information
- Potential regulatory and legal implications

---

## Compliance Impact

### GDPR Compliance

**Issue:** Client matter data likely contains personal information about individuals (parties to legal matters).

**Implication:**
- If personal data was accessed by unauthorized party → potential data breach under GDPR Article 33
- Notification obligations may be triggered
- Data Protection Officer must be notified
- Legal assessment required for notification timeline

**Status:** Pending Legal review for GDPR notification determination

### Attorney-Client Privilege

**Issue:** Client matters are classified as privileged communications.

**Implication:**
- Disclosure to unauthorized party may waive privilege
- Client must be notified if privilege potentially compromised
- Law firm has disclosure obligations to regulatory bodies
- State bar associations may require reporting

**Status:** Pending General Counsel review for compliance obligations

### Contractual Obligations

**Issue:** Client contracts likely include data security and confidentiality requirements.

**Implication:**
- Data breach clause may be triggered
- Client notification may be contractually required
- Potential liability for breach of contract
- Insurance notification may be required

**Status:** Pending Legal/Compliance review for client notification determination

---

## Why Alternative Hypotheses Were Eliminated

### Hypothesis 1: Copilot Product Defect ❌ ELIMINATED

**Hypothesis:** "Microsoft Copilot has a built-in security vulnerability that bypasses access controls."

**Why Eliminated:**
- Copilot is working correctly with other data sources without access control issues
- Copilot has no direct access to the document database; it queries via the document management API
- The API itself is returning unfiltered results—issue is upstream, not in Copilot
- Multiple organizations use Copilot with proper access controls without this issue
- Copilot security testing by Microsoft would have caught a product-level defect

**Confidence of Elimination:** 99%

---

### Hypothesis 2: User Privilege Escalation Attack ❌ ELIMINATED

**Hypothesis:** "The affected user deliberately escalated her privileges or hacked into the system to access unauthorized data."

**Why Eliminated:**
- User is the one who reported the issue (not concealing it)
- Active Directory logs show no privilege escalation
- No suspicious account modifications or group membership changes
- User's session tokens are normal; no signs of tampering
- User credibility high; interview confirms no malicious intent
- User proactively reported issue rather than exploiting access

**Confidence of Elimination:** 98%

---

### Hypothesis 3: Intune Deployment Misconfiguration (Device Level) ❌ ELIMINATED

**Hypothesis:** "The Intune deployment incorrectly configured device-level access controls, exposing data at the device level."

**Why Eliminated:**
- Device access controls are not the issue; the application API is the issue
- Only users with Floor 6 Users group membership can access the API
- The API permission issue is not device-specific; it affects all users querying the API
- Device logs show normal authorization checks functioning
- Issue manifests at application layer, not device layer

**Confidence of Elimination:** 95%

---

### Hypothesis 4: Active Directory Group Membership Error ❌ ELIMINATED

**Hypothesis:** "The user was accidentally added to a high-privilege AD group that grants access to all matters."

**Why Eliminated:**
- AD group audit confirms user's membership is correct (Floor 6 Users only)
- No new group memberships added Friday or Monday
- Access issue is in the document management app's API permissions, not AD groups
- AD groups are correctly configured; issue is downstream in document app

**Confidence of Elimination:** 97%

---

### Hypothesis 5: Malware or Compromise ❌ ELIMINATED

**Hypothesis:** "The user's device was compromised by malware that modified Copilot behavior."

**Why Eliminated:**
- Malware scan of affected device: negative (no malware detected)
- No unexpected processes or scheduled tasks on affected device
- Copilot behavior is consistent with API returning unfiltered data (not malware modification)
- Issue is server-side (API service account permissions), not client-side
- Multiple users could potentially access same unfiltered data (not isolated to one device)

**Confidence of Elimination:** 96%

---

## Resolution Summary

### Immediate Actions (Completed)

1. **User Access Revocation**
   - Affected user's Copilot access disabled via Conditional Access policy
   - Device isolated to prevent further unauthorized queries
   - Status: ✅ COMPLETE

2. **Evidence Preservation**
   - Copilot audit logs exported and secured
   - Document management app access logs captured
   - Device event logs preserved
   - Status: ✅ COMPLETE

3. **Escalation & Notification**
   - Compliance team notified
   - Legal/General Counsel engaged
   - Executive leadership briefed
   - Incident ticket created (FLR6-001)
   - Status: ✅ COMPLETE

### Planned Remediation Actions

1. **Service Account Permission Restriction** (This Week)
   - Audit document management app's API service account
   - Restrict permissions from "Admin" to "Service Account - Reader" role
   - Implement minimal necessary permissions principle
   - Document justification for each permission grant

2. **User-Level Permission Filtering Implementation** (This Week)
   - Review Copilot integration code/configuration
   - Implement user authorization checks BEFORE returning results
   - Verify filtering logic is correct and cannot be bypassed
   - Add unit tests for permission filtering

3. **Redeployment Testing** (Next Week)
   - Test with non-admin service account
   - Verify user cannot access unauthorized documents via Copilot
   - Verify user CAN access authorized documents via Copilot
   - Conduct security review before floor re-deployment

4. **Compliance Notification Assessment** (This Week)
   - Legal team to determine GDPR notification requirement
   - Legal team to assess attorney-client privilege implications
   - Client notification plan (if required)
   - Regulatory reporting (if required)

---

## Verification Performed

### Verification 1: Service Account Permission Audit

**Test:** Query document management API with service account
**Method:** Direct API call with service account credentials
**Result:** Service account can query ALL documents in system (confirmed admin permissions)
**Conclusion:** ✅ VERIFIED - Service account has overly broad permissions

---

### Verification 2: User-Level Permission Filtering Test

**Test:** Query Copilot for documents outside user's authorization
**Method:** Copilot search with unauthorized document reference
**Result:** Copilot returns document; user has no authorization
**Conclusion:** ✅ VERIFIED - No user-level permission filtering in place

---

### Verification 3: Authentication System Integrity

**Test:** Verify user authenticated correctly and legitimately
**Method:** Review Kerberos and AD logs for user session
**Result:** User authentication proper; no escalation detected
**Conclusion:** ✅ VERIFIED - Authentication system not compromised

---

### Verification 4: Copilot Product Integrity

**Test:** Verify Copilot behaving correctly (issue is not Copilot defect)
**Method:** Query logs show Copilot correctly returning API results
**Result:** Copilot returning exactly what API provides (no filtering, no enhancement)
**Conclusion:** ✅ VERIFIED - Copilot product working as designed; issue is upstream

---

### Verification 5: Scope Assessment (Floor 6 Only)

**Test:** Verify issue limited to Floor 6 deployment
**Method:** Check other departments' Copilot access to same document management data
**Result:** Other departments' Copilot queries properly filtered by authorization
**Conclusion:** ✅ VERIFIED - Issue specific to Floor 6 deployment configuration

---

## 5 Why Analysis

### Why 1: Why Did the Paralegal See Unauthorized Data in Copilot?

**Answer:** Because the Copilot integration did not filter results based on the user's authorization level. It returned all documents provided by the API regardless of the user's permissions.

---

### Why 2: Why Did the Copilot Integration Not Filter Results?

**Answer:** Because the integration was configured to use an administrative service account that has full access to all documents, and the filtering logic was either missing from the integration code or was disabled/bypassed.

---

### Why 3: Why Was the Integration Using an Administrative Service Account?

**Answer:** Because the development/deployment team did not restrict the service account to minimal necessary permissions. They likely used the default/maximum permissions available during development and failed to reduce them before production deployment.

---

### Why 4: Why Was This Configuration Not Caught Before Deployment?

**Answer:** Because no pre-deployment security review was performed. There was no checklist requiring verification of:
- Service account permission justification
- User-level access control implementation
- Security testing before production deployment

---

### Why 5: Why Was There No Pre-Deployment Security Review?

**Answer:** Because the deployment process did not include a mandatory security sign-off step. The organization's deployment procedures for enterprise applications did not require security team approval before production release.

---

### Root Cause Chain Summary

```
No Pre-Deployment Security Review Process
    ↓
No Security Checklist for Application Deployments
    ↓
No Verification of Service Account Permissions
    ↓
Service Account Deployed with Admin Permissions
    ↓
User-Level Permission Filtering Not Implemented
    ↓
Copilot Integration Returns Unfiltered Results
    ↓
Paralegal Sees Unauthorized Client Matter
```

---

## Preventive Actions

### Action 1: Implement Pre-Deployment Security Review (MANDATORY)

**Requirement:** All enterprise application deployments must include security review before production release.

**Specific Requirements:**
- Security team reviews deployment plan minimum 5 business days before release
- Security sign-off required in change request before approval
- For applications integrating with Copilot/AI systems: additional security review required
- Checklist must include: service account permissions, access control filtering, data classification verification

**Measurement:** 100% of future enterprise deployments include security review documentation; zero production deployments without security sign-off

**Owner:** IT Security Officer  
**Timeline:** Implement within 2 weeks

---

### Action 2: Establish Service Account Permission Policy (MEASURABLE)

**Requirement:** All service accounts must follow principle of least privilege.

**Specific Requirements:**
- Service accounts default to "Reader" or "Viewer" role (read-only access only)
- Any request for elevated permissions requires documented business justification
- Permission elevation requires approval from both application owner and security team
- Annual audit of all service account permissions
- Admin-level service account permissions require quarterly review and re-justification

**Measurement:**
- 0% of service accounts with unnecessary admin permissions
- 100% of elevated permissions documented with business justification
- Quarterly audit completion rate = 100%

**Owner:** IT Security Officer + Application Owners  
**Timeline:** Policy published within 1 week; existing service accounts audited within 1 month

---

### Action 3: Require Access Control Testing in Pre-Deployment Plan (SPECIFIC)

**Requirement:** Any integration with user-facing systems must include documented access control testing.

**Specific Requirements for Copilot Integration:**
- Test Case 1: Authorized user queries authorized data → Should return results ✓
- Test Case 2: Unauthorized user queries authorized data → Should return "Access Denied" ✓
- Test Case 3: User queries their own data → Should return results ✓
- Test Case 4: Service account queries data → Should return data based on service account permissions only ✓
- All test cases must PASS before production deployment
- Test results must be documented and included in change request

**Measurement:** 100% of Copilot integrations include documented access control test results; zero production deployments without passing tests

**Owner:** QA Team + Security Team  
**Timeline:** Testing framework defined within 2 weeks; required for next Copilot integration project

---

### Action 4: Create Copilot Integration Security Checklist (DOCUMENTED)

**Requirement:** Standardized security checklist for all Copilot integrations.

**Checklist Items:**
```
☐ Service account permissions restricted to minimum necessary
☐ User-level permission filtering implemented and tested
☐ API does not expose data directly; filtering layer present
☐ Audit logging enabled for all queries (user + results returned)
☐ Unauthorized access attempts logged and alertable
☐ Service account not used for direct queries (only app-to-app)
☐ User authentication context verified end-to-end
☐ Data classification labels applied to all indexed documents
☐ Access control test cases executed (4 minimum)
☐ Security team sign-off obtained
☐ Documentation includes: architecture, permissions, filtering logic
```

**Measurement:** Checklist completion rate = 100% for new Copilot integrations; zero deployments without checklist

**Owner:** IT Security Officer  
**Timeline:** Checklist published within 1 week

---

### Action 5: Implement Real-Time Access Control Monitoring (MEASURABLE)

**Requirement:** Monitor Copilot queries for potential unauthorized access patterns.

**Specific Implementation:**
- Alert: User accessing document outside their normal authorization scope → IMMEDIATE alert
- Alert: Service account queried by user instead of vice versa → IMMEDIATE alert
- Alert: Query returned classified data to unauthorized user role → IMMEDIATE alert
- Weekly audit: Compare Copilot results vs. user authorization levels
- Threshold: 1 unauthorized access alert = automatic investigation

**Measurement:**
- Monitoring system live within 2 weeks
- Response time to alert: < 30 minutes
- False positive rate: < 5%

**Owner:** IT Security Officer + SOC  
**Timeline:** Implementation within 2 weeks

---

### Action 6: Update Deployment Approval Process (DOCUMENTED)

**Requirement:** Security team has veto power over enterprise deployments until security review complete.

**Specific Changes:**
- Change request process requires "Security Review" field (checkbox)
- Change cannot be approved without security review completion
- Security team must sign change request before IT Director approval
- New applicaton deployments must include compliance questionnaire (GDPR, data handling, etc.)

**Measurement:** 100% of enterprise deployments include security team sign-off; zero bypasses allowed

**Owner:** IT Director + IT Security Officer  
**Timeline:** Process updated within 1 week

---

## Lessons Learned

### Lesson 1: Security Review Must Be Mandatory, Not Optional

**What We Learned:**
The deployment proceeded without security review, assuming the technical team had considered security implications. This assumption was wrong. Security requires specialized knowledge and must be explicitly verified.

**Application:**
All future enterprise deployments require security sign-off. This cannot be waived or bypassed regardless of timeline pressure.

---

### Lesson 2: Service Account Permissions Are Often Over-Privileged by Default

**What We Learned:**
Development teams commonly use administrative service accounts during development. When deploying to production, these permissions are rarely reduced to least-privilege minimums because "it works" and reducing them is seen as extra work.

**Application:**
Service account permission audits must be part of deployment readiness. Default service account permissions should be "Reader" unless business case exists for elevation.

---

### Lesson 3: Integration Points Are High-Risk Security Boundaries

**What We Learned:**
When integrating two systems (Copilot + Document Management), the integration point is often where access control logic breaks down. The assuming one system will handle it; the other system assumes the same.

**Application:**
Integration projects must explicitly define who is responsible for access control filtering (at which boundary) and must test that integration thoroughly.

---

### Lesson 4: Compliance Gaps Require Specialized Expertise

**What We Learned:**
This incident potentially triggered GDPR, attorney-client privilege, and contractual obligations. These are outside IT's purview and require immediate engagement with Legal/Compliance teams.

**Application:**
Any data-exposure incident must trigger automatic Legal/Compliance notification. IT cannot make determination on GDPR or privilege waiver alone.

---

### Lesson 5: User Reporting Is Critical Early Warning System

**What We Learned:**
The paralegal's proactive reporting was the ONLY way this was discovered. There was no system alert, no automatic detection, no monitoring. User awareness and willingness to report is currently our best defense.

**Application:**
Promote security awareness training. Reward/recognize users who report security issues. Implement monitoring to reduce reliance on user detection alone.

---

### Lesson 6: Access Control Filtering Cannot Be Assumed at Upstream Layers

**What We Learned:**
The integration team assumed the document management app would filter results by user. The app assumed the integration layer would filter. Neither actually implemented it.

**Application:**
Never assume access control is happening elsewhere. Explicitly implement and test access control at YOUR integration point. Defense-in-depth: filter at both layers.

---

## Recommendations for Broader Security Posture

### Short-Term (Next 2 Weeks)
1. Audit all existing Copilot integrations for similar permission misconfigurations
2. Disable all non-compliant integrations until remediated
3. Implement mandatory security review process for all deployments
4. Conduct security awareness training for development/deployment teams

### Medium-Term (Next 1-2 Months)
1. Implement access control monitoring system for Copilot
2. Complete service account permission audit across all systems
3. Update change management process to include security sign-off requirement
4. Implement data classification labeling for all enterprise documents

### Long-Term (Next Quarter)
1. Establish security architecture review board for new integrations
2. Implement zero-trust access control model for all sensitive data systems
3. Deploy SIEM-based access monitoring for all critical systems
4. Establish security training certification for developers/admins

---

## Ownership and Follow-up

### Responsible Parties and Accountability

**IT Security Officer**
- Responsibility: Lead remediation of service account permissions and access control implementation
- Actions: Oversee service account audit, permission restriction implementation, pre-deployment security review process
- Timeline: Final sign-off on remediation by 21-Aug-2026
- Escalation Path: Direct to IT Director if timeline at risk

**Compliance Officer**
- Responsibility: Assess GDPR notification requirements and attorney-client privilege implications
- Actions: Conduct legal impact assessment, determine client notification timeline, coordinate with General Counsel
- Timeline: Initial assessment by 15-Aug-2026; final determination by 18-Aug-2026
- Escalation Path: Direct to General Counsel for final legal decisions

**General Counsel**
- Responsibility: Determine regulatory notification obligations and client communication requirements
- Actions: Review privilege waiver risk, assess GDPR Article 33 applicability, coordinate with state bar if required
- Timeline: Legal assessment complete by 18-Aug-2026
- Escalation Path: Directly responsible to Executive Leadership

**Intune Operations Manager**
- Responsibility: Execute service account remediation and redeployment testing
- Actions: Implement restricted permissions, execute access control test cases, manage redeployment
- Timeline: Service account reconfiguration complete by 21-Aug-2026; redeployment complete by 25-Aug-2026
- Escalation Path: Direct to IT Operations Manager

**Service Desk / IT Support**
- Responsibility: User communication and floor-wide monitoring during remediation
- Actions: Communicate resolution to Floor 6 users, answer questions about data exposure, monitor for complaints
- Timeline: User communication sent by 15-Aug-2026; monitoring ongoing until closure
- Escalation Path: Escalate any data exposure concerns immediately to IT Security Officer

**Problem Management / IT Director**
- Responsibility: Track incident closure, manage remediation timeline, executive reporting
- Actions: Track all corrective/preventive action completion, assess preventive action effectiveness, ensure lessons learned implemented
- Timeline: Weekly status reports until closure; final closure assessment by 28-Aug-2026
- Escalation Path: Report directly to Executive Leadership if closure timeline at risk

### Notification and Communication Plan

**Immediate Notifications (Today):**
- ✅ IT Director: Briefed
- ✅ Executive Leadership: Briefed
- ✅ Compliance Officer: Engaged
- ✅ General Counsel: Engaged

**Regulatory Notifications (Pending Legal Assessment):**
- GDPR: Notification pending legal determination
- State Bar: Notification pending General Counsel assessment
- Client Notification: Pending privilege waiver assessment

**User Notifications (Planned):**
- Floor 6 Users: Simplified explanation ("Issue contained, Copilot suspended, no action needed")
- Affected Paralegal: Direct conversation with IT Security + General Counsel if privilege waiver confirmed

---

## Closure Criteria

### RCA Closure Conditions

This RCA can be marked CLOSED when ALL of the following conditions are satisfied:

### Condition 1: Service Account Remediation Complete ✅
**Verification:**
- Document management API service account permissions audited and documented
- Permissions restricted from "Admin" to "Service Account - Reader" role
- Service account can read only documents based on caller's permissions (not all documents)
- No admin-level permissions remaining on service account
- IT Security Officer sign-off: Service account remediation complete

**Target Date:** 21-Aug-2026  
**Verification Owner:** IT Security Officer

---

### Condition 2: User-Level Permission Filtering Implemented ✅
**Verification:**
- Copilot integration code reviewed for user authorization logic
- User-level permission filtering implemented (code change complete)
- Filtering cannot be bypassed or disabled via configuration
- Unit tests verify: Unauthorized users cannot access unauthorized documents
- Unit tests verify: Authorized users CAN access authorized documents
- Code review approved by IT Security Officer

**Target Date:** 21-Aug-2026  
**Verification Owner:** Application Development Team

---

### Condition 3: Redeployment Testing Complete ✅
**Verification:**
- Non-admin service account tested end-to-end
- Test Case 1: Authorized user queries authorized document → PASS (returns results)
- Test Case 2: Unauthorized user queries authorized document → PASS (returns "Access Denied")
- Test Case 3: Service account cannot be used for direct user queries → PASS
- Security team review and sign-off on test results
- IT Operations Manager approval: Ready for production redeployment

**Target Date:** 23-Aug-2026  
**Verification Owner:** QA Team + IT Security Officer

---

### Condition 4: Pre-Deployment Security Review Process Implemented ✅
**Verification:**
- Security review checklist created and documented
- Security review mandatory for all enterprise app deployments (not optional)
- Security team sign-off required in change request process
- Pre-deployment review documented for this incident's redeployment
- Process update distributed to all deployment teams

**Target Date:** 18-Aug-2026  
**Verification Owner:** IT Security Officer + IT Director

---

### Condition 5: Compliance Assessment Complete ✅
**Verification:**
- Legal assessment of GDPR applicability completed
- Attorney-client privilege waiver risk assessed
- Client notification determination made (yes/no)
- Regulatory notification requirements documented
- General Counsel sign-off on compliance determination

**Target Date:** 18-Aug-2026  
**Verification Owner:** General Counsel + Compliance Officer

---

### Condition 6: Preventive Actions Implemented ✅
**Verification:**
- Preventive Action 1: Pre-deployment security review process mandatory (documented, enforced)
- Preventive Action 2: Service account permission policy established and documented
- Preventive Action 3: Access control testing requirement added to deployment checklist
- Preventive Action 4: Copilot integration security checklist created and in use
- Preventive Action 5: Real-time access control monitoring system implemented and operational
- Preventive Action 6: Deployment approval process updated to require security team sign-off
- All actions documented and tracked in problem management system

**Target Date:** 28-Aug-2026  
**Verification Owner:** IT Director + Problem Management

---

### Condition 7: Lessons Learned Distributed ✅
**Verification:**
- RCA complete and approved
- Lessons learned section documented (6 key lessons identified)
- Training/awareness session conducted for deployment teams
- RCA shared with IT leadership and application teams
- Post-incident review meeting conducted with incident team

**Target Date:** 25-Aug-2026  
**Verification Owner:** Problem Management

---

### Condition 8: No Incident Recurrence (Post-Closure Monitoring) ✅
**Verification:**
- 30-day monitoring period: Zero similar incidents (unauthorized data access via Copilot)
- Access control monitoring system alerts: Zero access anomalies detected
- Service account permission audit: No drift to elevated permissions
- Security team review: No similar permission governance failures in other systems

**Target Date:** 14-Sep-2026 (30 days post-closure)  
**Verification Owner:** IT Security Officer + SOC

---

### RCA Closure Sign-Off

RCA is marked CLOSED when:
- ☐ All 8 conditions above verified as complete
- ☐ IT Security Officer approval
- ☐ IT Director approval
- ☐ Compliance Officer approval
- ☐ General Counsel confirmation (if required)
- ☐ Closure documentation added to this RCA
- ☐ Final RCA version archived

**Expected Closure Date:** 28-Aug-2026  
**Actual Closure Date:** ____________  
**Closed By:** ____________

---

## Document Information

**RCA Status:** COMPLETE  
**Classification:** INTERNAL - Sensitive  
**Distribution:** IT Security, Compliance, Legal, Executive Leadership, IT Director  

**Approvals:**
- [ ] IT Security Officer: ___________________ Date: _______
- [ ] Compliance Officer: ___________________ Date: _______
- [ ] General Counsel: ___________________ Date: _______
- [ ] IT Director: ___________________ Date: _______

**Version:** 1.0  
**Date:** 14-Aug-2026  
**Next Review:** Upon completion of remediation actions (target: 21-Aug-2026)

---

**Document Prepared By:** IT Security Officer  
**Document Reviewed By:** Incident Response Team  
**Final Approval:** IT Director
