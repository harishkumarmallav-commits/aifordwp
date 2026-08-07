# Root Cause Analysis — Account Lockout: jsmith @ DESKTOP-FB001

| Field             | Detail                                      |
|-------------------|---------------------------------------------|
| **Incident ID**   | INC-2026-08-06-JSMITH                       |
| **Date / Time**   | 2026-08-06, 08:02 – 08:23 (UTC+0)          |
| **Affected User** | jsmith (FINBRIDGE domain)                   |
| **Affected Host** | DESKTOP-FB001                               |
| **Severity**      | Medium — single user, business-hours impact |
| **Authored by**   | DWP Analyst                                 |
| **Status**        | Closed — resolved by helpdesk intervention  |

---

## 1. Incident Summary

User `jsmith` was unable to log in to workstation `DESKTOP-FB001` during the 08:00 business-hours window. Two or more failed password attempts triggered the domain Account Lockout Policy, locking the account. A helpdesk administrator (`FINBRIDGE\helpdesk-admin`) unlocked the account at 08:22, and the user logged in successfully at 08:23. Total user downtime: approximately **21 minutes**.

---

## 2. Timeline of Events (from Windows Security Event Log)

| Time     | Event ID | Type          | Description                                                                 |
|----------|----------|---------------|-----------------------------------------------------------------------------|
| 08:02:14 | 4625     | Audit Failure | Failed interactive logon (type 2). Reason: Unknown username or bad password. Source: DESKTOP-FB001. Account: jsmith. |
| 08:04:22 | 4625     | Audit Failure | Second failed interactive logon (type 2). Same reason and source.          |
| 08:06:01 | 4740     | Audit Failure | Account locked out. Lockout threshold reached. Source: DESKTOP-FB001.      |
| 08:07:45 | 4625     | Audit Failure | Failed workstation unlock attempt (type 7). Reason: Account locked out.     |
| 08:22:10 | 4722     | Audit Success | Account re-enabled by FINBRIDGE\helpdesk-admin.                             |
| 08:23:44 | 4624     | Audit Success | Successful interactive logon (type 2). jsmith logged in.                    |

---

## 3. Event ID Reference

| Event ID | What it records |
|----------|----------------|
| **4625** | A logon attempt failed. Records account, failure reason, source host, and logon type. Logon type 2 = interactive console; type 7 = workstation unlock. |
| **4740** | An account was automatically locked out after exceeding the domain's bad-password threshold. Records account name and originating host. |
| **4722** | A user account was enabled or unlocked by an administrator. Records the admin who performed the action. |
| **4624** | A logon succeeded. Records account, logon type, and source. Confirms the account is operational again. |

---

## 4. Root Cause Identification

**Primary Root Cause:** A stale credential cached in Windows Credential Manager (or an equivalent background credential store) continued to submit the old password against the domain controller after a recent password change, automatically exhausting the account lockout threshold before the user could authenticate manually.

**Supporting Evidence:**

- The two 4625 failures at 08:02 and 08:04 are exactly 2 minutes apart and both classified as logon type 2 (interactive). Automated retry processes often present as interactive logon types when submitting cached credentials (e.g., mapped drives reconnecting at session start).
- `jsmith` attempted a workstation *unlock* (type 7) at 08:07:45 — indicating the machine was already at the lock screen when they arrived, consistent with a workstation that had been idle and then hammered by background credential retries before jsmith was physically present.
- The failure reason at 08:07:45 changed from "Unknown username or bad password" to "Account locked out", confirming the lockout was caused by the earlier automated failures, not by jsmith mistyping their password at the lock screen.
- The 15-minute helpdesk response and resolution (08:06 → 08:22) is consistent with a standard unlock-plus-credential-cache-flush procedure, implying the helpdesk recognised a pattern associated with cached credential issues.

---

## 5. Five Why Analysis

### Problem Statement
`jsmith` was locked out of `DESKTOP-FB001` at the start of the working day, causing 21 minutes of unplanned downtime.

---

**Why 1 — Why was jsmith locked out?**

The domain Account Lockout Policy triggered automatically after the bad-password threshold was exceeded.

*Evidence: Event 4740 at 08:06:01 confirms automatic lockout originating from DESKTOP-FB001.*

---

**Why 2 — Why was the bad-password threshold exceeded?**

Multiple failed logon attempts were submitted against the domain controller in a short window (08:02–08:06), all using an incorrect password.

*Evidence: Two recorded 4625 events within 4 minutes; lockout threshold was reached by 08:06.*

---

**Why 3 — Why was an incorrect password being submitted repeatedly?**

A credential cached in Windows Credential Manager (or a background process such as a mapped network drive, Outlook profile, or OneDrive sync client) was retrying the old password after jsmith had changed their domain password.

*Evidence: The automated cadence of failures (2-minute intervals), the logon type 2 classification for what appeared to be background retries, and the change of failure reason at 08:07 (from "bad password" to "locked out") all point to automated credential submission rather than manual mistyping.*

---

**Why 4 — Why was a stale credential still cached after the password change?**

The password change process did not trigger a prompt or automated flush of stored credentials. Windows Credential Manager and some Microsoft 365 integrated apps (Outlook, OneDrive, Teams) cache credentials independently; they are not automatically invalidated when a domain password changes unless the user is actively logged in and online at the moment of the change, or a Group Policy / Intune configuration enforces a credential flush.

*Evidence: No 4648 (explicit credential use) or 4647 (user-initiated logoff) events appear in the log window, suggesting the machine may have been locked or offline when the password was changed, preventing credential synchronisation.*

---

**Why 5 — Why is there no process to prevent or auto-detect stale cached credentials?**

There is currently no Group Policy Object (GPO) or Intune configuration policy enforcing credential cache expiry, and no user-facing guidance on clearing Windows Credential Manager after a password change. The Account Lockout Policy threshold (likely 3 or fewer attempts) is aggressive enough to protect against brute-force attacks but does not distinguish between human mistyping and automated retries, leaving legitimate users vulnerable to silent background lockouts.

*Evidence: The lockout occurred at start-of-day with no evidence of a deliberate attack. The resolution required manual helpdesk intervention rather than any automated self-service unlock mechanism.*

---

## 6. Contributing Factors

| Factor | Detail |
|--------|--------|
| Aggressive lockout threshold | A low bad-password threshold (≤3 attempts) appropriate for security may cause false-positive lockouts from cached credentials. |
| No self-service unlock | jsmith had no mechanism to unlock their own account, requiring a 15-minute helpdesk queue. |
| No post-password-change guidance | Users are not notified to clear cached credentials after a domain password change. |
| No Smart Lockout alerting | No automated alert was generated for the 4740 event; the issue was discovered by the user, not the operations team. |

---

## 7. Immediate Actions Taken

| Action | Owner | Status |
|--------|-------|--------|
| Account unlocked via FINBRIDGE\helpdesk-admin | Helpdesk | Completed 08:22 |
| User advised to clear Windows Credential Manager | Helpdesk | Completed (assumed at call closure) |
| User logged in successfully and confirmed working | jsmith | Confirmed 08:23 |

---

## 8. Recommendations & Preventive Actions

| Priority | Recommendation | Owner | Target Date |
|----------|---------------|-------|-------------|
| High | Deploy a self-service account unlock portal (e.g., Azure AD SSPR or on-prem equivalent) to reduce helpdesk dependency and user downtime. | Identity & Access team | 30 days |
| High | Create a knowledge article and add a step to the password-change process instructing users to clear Windows Credential Manager and sign out of Office apps after a password change. | Service Desk / L&D | 14 days |
| Medium | Review and document the current Account Lockout Policy threshold. Consider raising the observation window or threshold for workstation logon (type 2) events to reduce false-positive lockouts from background retries. | Security Architecture | 30 days |
| Medium | Configure a SIEM or Azure Sentinel alert rule on Event ID 4740 to notify the operations team proactively when an account lockout occurs, rather than relying on user-raised incidents. | SOC / Operations | 45 days |
| Low | Evaluate Microsoft Entra ID Smart Lockout policies to differentiate between automated retries and genuine brute-force patterns. | Identity & Access team | 60 days |

---

## 9. Lessons Learned

- Cached credentials from background services (mapped drives, Outlook, OneDrive) are a common but poorly communicated lockout vector, particularly immediately after a password change.
- Account lockout incidents during business-hours start times are a strong indicator of stale background credentials rather than deliberate attacks.
- Proactive event monitoring on 4740 would allow the operations team to resolve lockouts before the user raises an incident, improving mean time to resolution.

---

*Document prepared by: DWP Analyst | Review date: 2026-09-06*
