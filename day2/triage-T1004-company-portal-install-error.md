# Triage Summary – Company Portal App Install Failure (Error 0x87D1041C)

**Ticket ref:** T-1004  
**Date:** 2026-08-04  
**Analyst:** [to-verify]

---

## Summary
Company app fails to install from Company Portal and shows error 0x87D1041C.

## Impact
- **Who:** Single end user (identity and role to-verify)
- **How many:** 1 user confirmed; may affect others if the app package or assignment is the root cause (to-verify)
- **Business urgency:** MEDIUM — user is blocked from accessing the required application; severity depends on business criticality of the app (to-verify)

## Known Facts
- The user is attempting to install a company app via Company Portal
- The installation fails with error code 0x87D1041C
- The failure occurs during an app install attempt rather than normal app launch or sign-in

## Missing Information to Gather
- Name of the application being installed (use placeholder e.g. APP_01 if sharing with AI tools)
- Device OS version and patch level
- Whether the device is Intune-enrolled and compliant (to-verify via Intune admin portal)
- Whether the app has installed successfully on other devices (to-verify scope)
- Whether the app was previously installed on this device and is being reinstalled
- Whether there is sufficient disk space on the device
- Whether the Intune Management Extension service is running on the device (to-verify)
- Whether any previous failed install attempts have left behind a partial installation
- Full error detail from the Company Portal or Intune portal device install status (do not paste logs containing device identifiers or user data into AI tools)
- Whether the device has been rebooted since the failed attempt
- Whether the app is required, available, or dependency-linked in Intune (to-verify)

## Likely Category
- **Primary:** Endpoint Management / Intune App Deployment
- **Sub-category (to-verify):** Company Portal app installation failure — possible causes include assignment, dependency, detection, or local install state issues

## First Diagnostic Step
Check the device record in the Intune admin portal and review the app install status for that device and app first. Confirm whether the device is enrolled and compliant, whether the app is correctly assigned, and whether Intune shows a more specific failure reason before retrying the install locally.
