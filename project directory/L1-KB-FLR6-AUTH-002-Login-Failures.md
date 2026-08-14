# L1 KB: Login Problems on Floor 6 - RESOLVED (FLR6-AUTH-002)

**Article ID:** FLR6-AUTH-002-L1  
**Audience:** Floor 6 Users  
**Version:** 1.1  
**Date:** 14-Aug-2026

Source: Re-expressed from [Runbook-FLR6-AUTH-002-Login-Failures.md](Runbook-FLR6-AUTH-002-Login-Failures.md).

Runbook traceability:
- Runbook Section 3 confirmed auth-platform health and startup-path interference.
- Runbook Section 4 drove the rollback decision.
- Runbook verification confirmed login timing returned to baseline.

Login delays on Floor 6 were caused by a Friday software update. The app was removed, and login speed is restored.

Why this conclusion is valid:
- Symptom onset matched the deployment window.
- Affected scope matched the Floor 6 assignment target.
- Rollback removed the delay pattern and restored normal sign-in.

What to do now:
1. Log in normally.
2. If login is still slow, restart your computer once.
3. Wait 5 minutes after restart, then try again.

If still slow, contact IT Help Desk:
- Ext 555-1234
- servicedesk@company.com

What this means for you:
- Your files and email are safe.
- No password reset is needed.
- No reinstall is needed.

Status: Resolved. IT is monitoring to prevent repeat issues.
