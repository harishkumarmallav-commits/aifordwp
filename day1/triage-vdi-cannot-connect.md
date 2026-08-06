# Triage Summary – VDI Connection Failure

**Date:** 2026-08-04  
**Analyst:** [to confirm]  
**Ticket ref:** [to confirm]

---

## Summary
User unable to connect to VDI from home today; connection was working on Friday.

## Impact
- **Who:** Single end user (identity to confirm)
- **How many:** 1 user affected (no indication of wider outage at this stage)
- **Business urgency:** User is unable to work remotely; productivity fully blocked until resolved

## Known Facts
- VDI connection is failing with a "cannot connect" error message (exact wording to confirm)
- Connection was working successfully on Friday (last known good state)
- User is working from home on a Wi-Fi connection
- Issue began today (2026-08-04)

## Missing Information to Gather
- Full error message text or error code displayed
- VDI client name and version (e.g. Citrix Workspace, VMware Horizon, AVD client)
- Device type and OS (corporate laptop, personal device, Windows/Mac/other)
- Whether the device is DWP-managed or personal
- Whether any Windows updates or client software updates occurred over the weekend
- Whether other internet services are working on the same Wi-Fi connection
- Whether the user has tried restarting the VDI client or the device
- Whether MFA/authentication prompt is appearing or the failure is pre-login
- Whether the issue is consistent or intermittent
- Whether other users on the same team are affected (to rule out service-wide incident)

## Likely Category
- **Primary:** Remote Access / VDI Connectivity
- **Sub-category (to confirm):** Client-side network or configuration issue, or VDI service degradation

## Suggested First Diagnostic Step
Ask the user to reboot the device, reconnect to Wi-Fi, and attempt the VDI connection again. While doing so, capture the exact error message or error code. Check the internal service status page or major incident channel to rule out a platform-wide VDI outage before proceeding with client-side troubleshooting.
