# L1 KB: Copilot Data Access Issue - Floor 6 (FLR6-SEC-001)

**Article ID:** FLR6-SEC-001-L1  
**Title:** What You Need to Know: Copilot Security Issue on Floor 6  
**Audience:** Floor 6 Users, General Staff  
**Level:** L1 (End User)  
**Date:** 14-Aug-2026

---

**⚠️ SOURCE & AUDIENCE:** This article is extracted from the Unauthorized Copilot Access Incident Runbook ([Runbook-FLR6-SEC-001-Copilot-Breach.md](Runbook-FLR6-SEC-001-Copilot-Breach.md)), simplified for end users, and kept in the same section order as the runbook. If you're on the IT support team needing procedures, refer to the runbook instead.

---

## In Plain Language

**What happened:** A Floor 6 employee discovered that Copilot (our AI assistant) was showing them information they shouldn't see.

**What we're doing:** We've temporarily stopped that employee's access to Copilot while we investigate and fix the problem.

**What you need to do:** Nothing right now. Keep working normally. We'll update you once we know more.

---

## Quick Facts

| Question | Answer |
|----------|--------|
| **Is my data safe?** | Yes. We caught this immediately and locked down access. |
| **Does this affect me?** | Probably not, unless you're on Floor 6. See below. |
| **Do I need to change my password?** | Not right now. |
| **Will Copilot be available?** | Floor 6 Copilot access is temporarily suspended while we fix this. |
| **When will it be fixed?** | Within 24-48 hours. |

---

## If You're on Floor 6

**Your Copilot access is temporarily disabled.**

This means:
- ❌ You cannot use Copilot right now
- ✓ All your files and email work normally
- ✓ You can still access documents through normal search and File Explorer

We're working to fix the underlying issue and restore your access as soon as possible.

---

## If You're NOT on Floor 6

**No action needed.** This issue is specific to Floor 6's system configuration and doesn't affect other departments.

---

## What Happened (Technical Overview)

A software update on Friday deployed a new document management app to Floor 6 devices. That app appears to have been misconfigured, allowing Copilot to show information to users who shouldn't have access to it.

**This was NOT:**
- A hacking or security breach from outside
- Intentional by employees
- A virus or malware
- A Copilot product bug
- A system-wide vulnerability

**It WAS:** A security governance and configuration failure in our deployment.

Reasoning in plain language:
- Copilot only shows what the connected system returns.
- Our connected document system returned data too broadly.
- Therefore the failure is in permissions setup, not in Copilot itself.

---

## What We're Doing

✓ **Already completed:**
- Isolated the affected employee's device
- Reviewed Copilot logs to understand what happened
- Notified our legal and compliance teams

🔄 **In progress:**
- Investigating whether other Floor 6 users are affected
- Analyzing the document management app configuration
- Determining if data was actually lost or just accessed

📋 **Next steps:**
- Fix the app configuration
- Retest before deploying again
- Update deployment procedures to catch this in the future

---

## FAQ for Regular Employees

**Q: Does this affect my work?**  
A: No, unless you're on Floor 6 and need Copilot access right now.

**Q: Should I worry about my files?**  
A: No. This is a Copilot-specific issue. Your files and data are safe.

**Q: Will this happen again?**  
A: Unlikely. We're adding safeguards to prevent this in the future.

**Q: Do I need to do anything?**  
A: No. Just continue working normally.

---

## Contact Us

**For questions:** Contact IT Help Desk (Extension 555-1234)

**For security concerns:** Email IT Security (see your company directory)

**Reference:** Incident FLR6-001

---

**Version:** 1.0  
**Status:** Ongoing Investigation  
**Last Updated:** 14-Aug-2026
