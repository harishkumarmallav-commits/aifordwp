# Floor 6 Incident Update – Partner Communication
**Incident ID:** FLR6-002  
**Date:** August 14, 2026 | 10:30 AM  
**Audience:** Legal Partners, Business Leadership  
**Status:** Active Investigation & Remediation  

---

## Summary

We are managing two separate incidents discovered this morning on Floor 6. Both are linked to a software deployment made Friday afternoon. We are actively investigating and executing remediation. This update covers what happened, what we're doing now, and what remains unknown.

---

## What Happened

**Incident 1: Security & Data Access Issue (CRITICAL)**

A Floor 6 employee discovered that our Copilot AI tool displayed confidential client information she was not authorized to access. The employee immediately reported this to IT. This indicates a **data access control failure**—specifically, the new document management software deployed Friday did not properly restrict who can view which client matters through Copilot.

**This is not a software defect in Copilot.** This is a governance problem: the new document management system either (1) was configured incorrectly, or (2) failed to enforce proper data access restrictions when integrated with Copilot. We are investigating which.

**Why This Is Critical:** Client confidential information was accessible to someone without authorization. This raises legal and regulatory concerns including attorney-client privilege, professional responsibility, and potential data protection violations. **All affected client matters must be identified immediately.**

**Incident 2: Operational Issue (HIGH)**

Separately, at least 12 Floor 6 employees reported they could not log into their computers, or experienced extreme login delays (over one minute). This appears to be caused by the same Friday software deployment—specifically, the new document management application may be interfering with the Windows login process.

---

## What We Are Doing Now

**For the Security Issue:**
- Securing Copilot audit logs immediately (logging all queries and results from Friday onwards)
- Identifying which specific client matters were exposed through Copilot
- Determining whether other employees can access unauthorized client information
- Reviewing how the new document management system was configured and integrated with Copilot
- **Timeline:** Investigation underway; preliminary findings expected within 4 hours

**For the Login Issue:**
- Preparing to remove (roll back) the new document management application from Floor 6 devices
- This is the fastest path to restore employee access to computers
- We do not yet know if this will also resolve the Copilot access issue, or if that requires separate fixes
- **Timeline:** App removal should restore login access within 30-60 minutes of rollback; estimated completion by noon today

**General Actions:**
- Notifying affected employees of status and expected resolution timeline
- Briefing IT leadership and obtaining rollback authorization
- Preserving all evidence (logs, configuration files, deployment records) for investigation
- Communicating with our security team and compliance officer

---

## What Remains Unknown

**Critical Unknowns:**
1. **Scope of Copilot exposure:** Did other employees access unauthorized client information? How many client matters are affected?
2. **Root cause of Copilot access failure:** Was the document management system misconfigured, or does Copilot's architecture lack proper data filtering?
3. **Whether rollback will fix both issues:** Will removing the app restore both login function AND Copilot access controls?
4. **Whether data was exfiltrated:** Did the exposed information leave our system, or was it only viewed?
5. **Which client matters are affected:** Identification needed immediately to assess regulatory notification obligations

These unknowns will be resolved through the security investigation (Incident 1) over the next 24-48 hours.

---

## Business Impact

- **Immediate:** 12+ employees unable to work; estimated cost $900+/hour
- **Legal:** Potential attorney-client privilege violations and data protection compliance exposure
- **Scope:** Currently limited to Floor 6, but Copilot access issue may be broader

---

## Reassurance Without Over-Promising

**What We Know Is Controlled:**
- The new app deployment was targeted to Floor 6 only (not company-wide)
- The security issue was immediately reported by an employee, showing our controls are partially working
- We have audit logs available for investigation
- Rollback of the problematic app is a straightforward technical action

**What Requires Investigation (Honest Assessment):**
- We cannot yet confirm whether the Copilot access failure affects one employee or many
- We cannot yet confirm whether the app misconfiguration was an isolated error or indicates a systemic problem
- The login issue's quick resolution does not guarantee the Copilot issue is resolved

---

## Communication Approach

**Transparent:** We are not hiding problems or downplaying severity. The Copilot issue is legitimately serious and requires legal/compliance involvement.

**Professional:** We are treating this as a security incident with proper investigation protocols, evidence preservation, and escalation authority.

**Honest Timeline:** We will know significantly more in 4 hours; we will provide complete preliminary findings within 24 hours.

---

## Next Update

**Timing:** 2:00 PM today (within 4 hours)  
**Expected Content:** 
- Confirmation of which client matters were accessible
- Count of affected employees (Copilot access)
- Initial findings on root cause
- Preliminary regulatory notification assessment

**Escalation Contacts:**
- **IT Director:** [Name/Contact] – Technical questions
- **Compliance Officer:** [Name/Contact] – Regulatory and privacy questions
- **Legal Counsel:** [Name/Contact] – Attorney-client privilege and disclosure questions

---

*This communication is part of our incident management protocol. We are following data breach investigation best practices and will provide updates as facts become clear. Do not share details outside the immediate leadership group pending compliance review.*
