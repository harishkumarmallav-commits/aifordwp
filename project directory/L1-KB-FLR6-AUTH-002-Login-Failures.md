# L1 KB: Login Problems on Floor 6 - RESOLVED (FLR6-AUTH-002)

**Article ID:** FLR6-AUTH-002-L1  
**Title:** Floor 6 Login Issue - What Happened & What You Should Do  
**Audience:** Floor 6 Users  
**Level:** L1 (End User)  
**Date:** 14-Aug-2026

---

**⚠️ SOURCE & AUDIENCE:** This article is extracted from the Floor 6 Login Failures Emergency Response Runbook ([Runbook-FLR6-AUTH-002-Login-Failures.md](Runbook-FLR6-AUTH-002-Login-Failures.md)), simplified for end users, and kept in the same section order as the runbook. If you're on the IT support team needing procedures, refer to the runbook instead.

---

## The Issue is FIXED

**Problem:** Floor 6 computers were slow to log in on Monday morning (taking 60+ seconds instead of 30 seconds).

**Cause:** A new app deployed Friday was interfering with the login process.

**Solution:** We removed the problematic app. Your login is now fast again.

**Current Status:** ✅ RESOLVED at 10:30 AM Monday

---

## What You Should Do Now

**Simply log in normally.** That's it!

Your computer has been automatically updated. Next time you log in:
- Login should take 20-30 seconds (normal speed)
- No hangs or delays
- Everything works as usual

---

## If You Still Have Problems

**Your login is still slow?**

1. Completely restart your computer (power off, then back on)
2. Log in normally
3. Wait 5 minutes for your device to finish syncing
4. Try again

**Still slow after restart?**
- Call IT Help Desk: Extension 555-1234
- Email: servicedesk@company.com

---

## Your Files Are Safe

✓ All your documents, email, and files are completely safe  
✓ No data was lost  
✓ Everything is exactly where it was Friday afternoon

---

## What Happened (In Simple Terms)

**Friday 3:00 PM:**  
IT deployed a new document management app to Floor 6 computers

**Monday 9:14 AM:**  
Users reported that logging in was taking forever (60+ seconds)

**Root Cause:**  
The new app's startup process wasn't working right. It was getting stuck during login, causing Windows to wait for it to finish before letting users in.

**Our Response:**  
We removed the problematic app from all Floor 6 computers using our device management system. It took about 15 minutes total.

**Result:**  
Login times returned to normal within 30 minutes.

---

## Will This Happen Again?

**Probably not.** 

We're making changes so that:
- Software is better tested before deployment
- Login performance is monitored automatically
- Problems are caught before they affect users
- We can remove bad deployments even faster if needed

---

## FAQ

**Q: Why wasn't this tested before deployment?**  
A: The app passed initial testing, but the issue only appeared on Floor 6's specific network and hardware setup, which wasn't included in the test environment. We're now improving our testing.

**Q: Will the document management app come back?**  
A: Not until it's fixed and properly tested. If it's deployed again, we'll make sure it doesn't interfere with login first.

**Q: Do I need to reinstall anything?**  
A: No. Everything is automatic. Just log in normally.

**Q: How much productivity did we lose?**  
A: About 1.5 hours total (12 users unable to access systems for ~1 hour and 15 minutes).

**Q: Do I need to change my password?**  
A: No. This issue was about the login speed, not authentication.

---

## Timeline of Events

| Time | What Happened |
|------|---|
| Friday 3:00 PM | New app deployed to Floor 6 |
| Monday 9:14 AM | Users report slow login |
| Monday 9:30 AM | IT starts investigating |
| Monday 9:45 AM | Root cause found (bad app) |
| Monday 10:00 AM | Decision to remove app |
| Monday 10:15 AM | App removal sent to all Floor 6 devices |
| Monday 10:30 AM | Login times return to normal |

---

## Contact IT

**Slow login issues:**  
Phone: Extension 555-1234  
Email: servicedesk@company.com

**Incident Reference:**  
Ticket FLR6-002

---

**Version:** 1.0  
**Status:** RESOLVED  
**Last Updated:** 14-Aug-2026
