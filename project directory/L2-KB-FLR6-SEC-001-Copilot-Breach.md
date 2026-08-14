# L2 KB: Copilot Unauthorized Data Access - Technical Analysis (FLR6-SEC-001)

**Article ID:** FLR6-SEC-001-L2  
**Title:** Copilot Access Control Breach - Technical Investigation & Remediation  
**Audience:** IT Support (L2), Security Team, Administrators  
**Level:** L2 (Technical)  
**Date:** 14-Aug-2026

---

**SOURCE OF TRUTH:** This L2 article is a technical re-expression of [Runbook-FLR6-SEC-001-Copilot-Breach.md](Runbook-FLR6-SEC-001-Copilot-Breach.md) and follows the runbook's section flow. If conflicts appear, the runbook governs.

---

## Executive Summary

**Incident:** Unauthorized data access via Copilot on Floor 6  
**Severity:** CRITICAL (P1)  
**Discovery:** Monday 09:14  
**Correlation:** Friday 15:00 document management app deployment  
**Status:** Contained - Investigation ongoing

**Root Cause Hypothesis:** Document management app deployed with overly permissive access controls in Copilot integration layer, allowing all Floor 6 users to query information outside their authorization scope.

---

## Incident Details

### Initial Report
- Time: Monday 09:14
- Reporter: IT Operations Lead
- Issue: Floor 6 paralegal discovered Copilot displaying client matter data she has no authorization to access
- User statement: "I have never had access to this matter. I don't know how it's showing here."

### Scope Assessment
- **Confirmed affected:** 1 user (so far)
- **Potentially affected:** All Floor 6 users (12+ staff)
- **Data exposure:** Client confidential matters (attorney-client privilege level)
- **Regulatory risk:** GDPR, attorney-client privilege violation potential
- **Timeline:** Friday 15:00 deployment → Monday 09:14 discovery (36-hour incubation)

---

## Technical Investigation

### Root Cause Analysis

**Primary Hypothesis (70-80% confidence):**

The document management app deployed Friday was integrated with Copilot through an API layer that:
1. Indexes document management data for Copilot search
2. Was deployed with access control configuration that allows any authenticated Floor 6 user to query all documents in the system
3. Bypasses the document management app's native access controls during Copilot queries
4. Returns full document content without filtering based on user permissions

**Evidence Supporting This:**
- Timing: Deployment Friday 15:00 → Issue Monday 09:14
- Scope: Only Floor 6 Users (deployment target group)
- Data source: Copilot querying document management app backend
- User permission mismatch: User accessed data outside her role's authorization

### Access Control Configuration Flaw

**Likely mechanism:**

```
Copilot Integration Layer Configuration (Probable):
├── API Service Account: [Document Management Service Account]
├── Service Account Permissions: Full access to all documents (admin account)
├── User Filtering Logic: MISSING or BYPASSED
├── Result: Copilot returns all documents regardless of user role
└── Expected: Filter by user permissions before returning results
```

**Missing component:** Copilot-Document Management integration should filter results based on authenticated user's authorization level in document management system. This filtering appears absent or misconfigured.

### Investigation Leads

**Immediate (Completed):**
- [ ] Query Copilot audit logs for affected user since Friday deployment
  - All queries submitted since Friday 15:00
  - All results returned (with full content)
  - Timestamps and query terms
- [ ] Review document management app's access control configuration
  - Current effective permissions for Floor 6 Users group
  - Whether access control is enforced during API calls from Copilot
  - Integration configuration: Is there a service account with elevated permissions?
- [ ] Check Copilot result filtering logic
  - Does Copilot apply document-level permissions filtering?
  - Is filtering based on authenticated user or service account?
  - Was filtering disabled during deployment?

**High Priority (In Progress):**
- [ ] Identify all documents accessed through Copilot since deployment
- [ ] Determine which specific client matters were exposed
- [ ] Audit other Floor 6 users' Copilot queries for similar unauthorized access patterns
- [ ] Review app deployment documentation: What permissions were configured?
- [ ] Check database-level access logs: Were access control filters bypassed?

**Medium Priority (Ongoing):**
- [ ] Interview affected user for query terms, what was displayed, any screenshots
- [ ] Audit user's account for suspicious activity or privilege escalation
- [ ] Check if similar issues existed pre-deployment (baseline)
- [ ] Review Copilot permission model and documentation

---

## Technical Remediation Path

### Phase 1: Immediate Containment (Completed)

**Access Revocation:**
```powershell
# Remove affected user from Copilot access groups
Remove-MgGroupMember -GroupId [CopilotAccess-FLR6] -DirectoryObjectId [userId]

# Create Conditional Access policy to block user's Copilot access
# Policy: "EMERGENCY-Copilot-Access-Block-FLR6-SEC-001"
# Target: Affected user only
# Action: Block access to Copilot service
```

**Evidence Preservation:**
```powershell
# Export Copilot audit logs (Microsoft Purview)
# Location: Microsoft Purview Compliance Portal → Audit Search
# Filters:
#   - User: [affected user UPN]
#   - Services: Copilot for Microsoft 365
#   - Activities: All Copilot activities
#   - Date: Friday 15:00 → Monday 09:14
# Export format: CSV with full query and result details
```

### Phase 2: Root Cause Remediation (In Progress)

**1. Document Management App Redeployment with Fixed Configuration**

```
Required Configuration Fixes:
✓ API Service Account permissions: Restrict to minimum necessary (not admin)
✓ User Filtering Logic: MUST be implemented in Copilot-App integration
✓ Query Authorization: Filter results by authenticated user's document access
✓ Role-based filtering: Map document classification to user role/department
✓ Testing: Verify unauthorized data no longer returns in Copilot results
```

**2. Copilot Permission Model Review**

```
Required Checks:
✓ Copilot applies document-level access controls for all integrated apps
✓ Service accounts used for app integration have minimal necessary permissions
✓ User authentication passed to backend systems (not service account auth)
✓ Access filtering happens before result display (not after)
✓ Audit logging captures all access attempts (authorized and denied)
```

**3. Access Control Configuration Validation**

```powershell
# Verify app was NOT deployed with these misconfigurations:
# ❌ App has global admin service account
# ❌ App bypasses document-level permissions
# ❌ App returns unfiltered results
# ❌ App access filtering is in Copilot (should be in app)

# Confirm app WAS deployed with these controls:
# ✓ Service account has role-based (minimal) permissions
# ✓ Document filtering happens in app backend
# ✓ User context authenticated end-to-end
# ✓ Results filtered by user's actual permissions
# ✓ Audit logging enabled for all queries
```

### Phase 3: Verification Before Redeployment

**Test Cases:**

```
Test 1: User without access to Document X tries Copilot search for it
Expected: Copilot returns "No results" or "Access denied"
Actual: [TEST RESULT]

Test 2: User with access to Document X searches for it
Expected: Copilot returns document with full content
Actual: [TEST RESULT]

Test 3: Service account queries directly (bypass Copilot)
Expected: Service account returns results based on its permissions (admin)
Actual: [TEST RESULT]

Test 4: Multiple Floor 6 users search same document
Expected: Each user sees only documents they have access to
Actual: [TEST RESULT]
```

---

## Compliance & Legal Impact

### Regulatory Review Required

**GDPR Implications:**
- Personal data processing: Client matter data may contain personal information
- Unauthorized access: Potential data subject rights violation
- Breach notification: Depends on whether data was exfiltrated

**Attorney-Client Privilege:**
- Privilege waiver risk: Exposure to non-authorized party
- Client notification: May be required if client data was compromised
- Regulatory reporting: State bar associations, compliance officers

### Notification Decision Matrix

```
IF data was viewed but NOT exfiltrated:
  → MAYBE client notification required
  → MAYBE regulatory notification required
  → Escalate to Legal for determination

IF data was exfiltrated (left our systems):
  → DEFINITELY client notification required
  → DEFINITELY regulatory notification likely
  → CRITICAL INCIDENT ESCALATION

IF only queried but result not delivered to user:
  → MAYBE no notification required
  → Escalate to Compliance for guidance
```

---

## Detection & Monitoring

### Post-Remediation Monitoring

**Copilot Query Monitoring:**
```powershell
# Monitor for future unauthorized access patterns
# Alert on:
#  - Query results that don't match user's expected permissions
#  - Access to restricted documents
#  - Queries from users outside normal pattern
#  - Service account queries from Copilot (should be user context)

# Implement in SIEM:
# Alert: Copilot query returned data outside user's authorization
# Threshold: 1 incident = immediate alert
# Severity: HIGH
```

**Audit Log Review:**
```
Weekly audits of:
- All Copilot access to document management data
- User query patterns vs. authorization levels
- Service account permissions and usage
- Access control configuration changes
```

---

## Escalation Path

**Immediate Escalations (Completed):**
- [x] IT Security Officer
- [x] Compliance Officer
- [x] General Counsel
- [x] Executive Leadership (CTO/CIO)

**Ongoing Escalations:**
- IT Director: Remediation status updates
- Legal: Notification decisions
- Compliance: Regulatory filing determination
- Board/Executive: If client notification required

---

## Prevention for Future Deployments

**Updated Deployment Checklist:**

```
Before deploying any app that integrates with Copilot:
☐ App integration architecture reviewed by security team
☐ Access control filters implemented in app (not assumed in Copilot)
☐ Service accounts have minimal necessary permissions (NOT admin)
☐ User authentication context verified end-to-end
☐ Access control testing completed (unauthorized users tested)
☐ Audit logging enabled for all queries
☐ Security sign-off obtained before deployment
```

---

## Timeline of Investigation

| Time | Action | Owner |
|------|--------|-------|
| Monday 09:14 | Incident reported | IT Ops |
| Monday 09:30 | Severity: CRITICAL assigned | IT Sec |
| Monday 09:45 | User device isolated | IT Ops |
| Monday 10:00 | Copilot logs exported | IT Sec |
| Monday 10:30 | Compliance team engaged | IT Sec |
| Monday 11:00 | Investigation plan documented | This KB |
| TBD | Root cause confirmed | IT Sec |
| TBD | Remediation completed | IT Ops |
| TBD | Verification testing passed | QA |
| TBD | Notification decisions finalized | Legal |
| TBD | Incident closure | IT Dir |

---

## Contact & Escalation

**Investigation Lead:** IT Security Officer  
**Compliance Lead:** Compliance Officer  
**Legal Lead:** General Counsel  
**Incident ID:** FLR6-001  

**Document Classification:** CONFIDENTIAL - Security Incident  
**Distribution:** Limited to Security/Compliance/Legal teams

---

**Version:** 1.0  
**Status:** Active Investigation  
**Last Updated:** 14-Aug-2026  
**Next Review:** Daily during investigation
