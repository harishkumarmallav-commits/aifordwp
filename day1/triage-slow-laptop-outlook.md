# Triage Summary — Slow Laptop / Outlook Not Loading

**Logged:** 2026-08-04  
**Analyst role:** DWP Service Desk

---

## Summary
End user reports laptop running slowly since this morning with Outlook failing to open on a newly deployed Windows 11 device.

---

## Impact
- **Who:** Single end user (name/username — to confirm)
- **How many affected:** 1 reported; unknown whether others on same deployment batch are affected — to confirm
- **Business urgency:** Medium — user cannot access email, which may affect time-sensitive casework or communications; full business impact depends on user's role and whether they have an alternative access route (for example OWA via browser — to confirm)

---

## Known Facts
- Laptop is slow since this morning (2026-08-04 — onset time to confirm)
- Outlook fails to launch; application hangs on load (spinning)
- Other applications appear to be functioning — to confirm (user's own assessment, not verified)
- Device is a new Windows 11 machine deployed within the last week
- Issue is isolated to this device based on current information

---

## Missing Information to Gather
1. Username and device name/asset tag (needed to pull device logs and Intune/SCCM status)
2. Exact time the slowness started — did it follow a reboot, login, or specific event?
3. Has the device been rebooted since the issue started?
4. Which version of Outlook is installed — Microsoft 365 Apps, or classic MSI? (to confirm)
5. Is the user able to access Outlook Web Access (OWA) via Edge/Chrome as a workaround?
6. Are there any on-screen error messages or event log pop-ups visible?
7. Was any software installed or a Windows Update applied overnight? (check Intune/SCCM deployment logs)
8. Is the device on-site (wired/Wi-Fi) or remote (VPN)? VPN status if remote?
9. Are other users from the same Win11 deployment batch reporting similar issues? (check for pattern)
10. Is the device domain-joined / Entra-joined and showing as compliant in Intune? (to confirm)

---

## Likely Category
**Endpoint Performance / Application Launch Failure — New Device Post-Deployment**  
Possible sub-causes (in order of likelihood):
1. Background Windows Update or Intune policy/software deployment consuming CPU/disk on first full login
2. Outlook profile not yet fully provisioned (new device, first-time cache build or AutoDiscover still running)
3. OneDrive or backup agent sync consuming disk I/O on new device
4. Antivirus initial scan on new device competing for resources
5. Insufficient resource allocation or hardware fault — to confirm

---

## Suggested First Diagnostic Step
**Ask the user to open Task Manager (Ctrl + Shift + Esc) → Performance tab** and read out:
- CPU %, Memory %, and Disk % usage
- Under the Processes tab, identify the top resource consumer

This will immediately show whether a background process (Windows Update, Defender, OneDrive, Intune IME) is saturating the system, and guides the next action without requiring remote access as a first step.

> If disk usage is at or near 100%, escalate to remote session to check Windows Update status and Intune enrollment logs (`C:\ProgramData\Microsoft\IntuneManagementExtension\Logs`).

---

*Generated in accordance with DWP Personal AI Usage Charter v1.0 — no real user PII used, all unknown values marked 'to confirm'.*
