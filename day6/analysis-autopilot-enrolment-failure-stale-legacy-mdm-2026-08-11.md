# Analysis: Autopilot Enrolment Failure Caused by Stale Legacy MDM Enrolment

Date: 2026-08-11  
Device: DESKTOP-FB099  
User: FINBRIDGE\\rthomas  
OS: Windows 11 (22621.2861)

## 1) Confirmed Root Cause
Autopilot enrolment failed because the device already had an existing legacy manual MDM enrolment record (from 2023-11-04), creating a conflicting enrolment state.

Evidence from diagnostic export:
- EnrollmentState: Failed
- ErrorCode: 0x80180014
- ErrorDescription: The device is already enrolled in MDM
- MDMEnrolled: Yes (previous enrolment)
- EnrolmentSource: Legacy manual MDM enrolment
- ProfilesApplied: 0 of 4
- LastError: 0x80070005 (Access denied)
- AzureADJoined: Yes
- IntuneP1License: Yes
- AutopilotLicense: Yes
- Network: Required endpoints reachable, no proxy

## 2) Exact Remediation Steps

### A. Intune admin center cleanup
1. [Admin Center Only] Sign in to Microsoft Intune admin center: https://intune.microsoft.com.
2. [Admin Center Only] Go to **Devices > All devices**.
3. [Admin Center Only] Search for `DESKTOP-FB099` and review duplicate or older records.
4. [Admin Center Only] For stale/legacy-managed record(s), select the old object and use **Delete** (or **Retire** first, then **Delete** if your process requires retire-before-delete).
5. [Admin Center Only] Go to **Devices > Windows > Windows enrollment > Devices** (Autopilot devices).
6. [Admin Center Only] Locate `DESKTOP-FB099` by serial/hardware hash and verify it is present and assigned to the correct Autopilot profile (`FinBridge-Autopilot-Standard`).
7. [Admin Center Only] If assignment is incorrect, set/reassign the intended Autopilot deployment profile.
8. [Admin Center Only] Go to **Users > All users > FINBRIDGE\\rthomas > Licenses** and reconfirm Intune/Autopilot-capable licensing remains assigned.

### B. Device-side cleanup of old enrolment
1. [Device Access Required - local admin, physical or remote] On the target device, open **Settings > Accounts > Access work or school**.
2. [Device Access Required] Disconnect any old work/school account connection tied to previous manual MDM enrolment.
3. [Device Access Required] Open an elevated Command Prompt and run:

```cmd
mdmdiagnosticstool.exe -area Autopilot;DeviceEnrollment;DeviceProvisioning -cab C:\Windows\Temp\post-cleanup-precheck.cab
```

4. [Device Access Required] Confirm no active legacy MDM enrolment remains in Settings and management account connections.
5. [Device Access Required] If device state is uncertain or heavily stale, perform a Windows reset suitable for Autopilot reprovisioning (retain organizational process controls).

### C. Trigger fresh Autopilot flow
1. [Device Access Required] Reboot and start OOBE/Autopilot sign-in flow.
2. [Device Access Required] Sign in with intended user (`FINBRIDGE\\rthomas`) and complete enrolment.
3. [Admin Center Only] Monitor new device object registration and MDM check-in in Intune admin center during provisioning.

## 3) Correct Order of Operations
1. [Admin Center Only] Remove stale legacy Intune device/enrolment record(s).
2. [Admin Center Only] Verify Autopilot device record and correct profile assignment.
3. [Admin Center Only] Confirm user licensing is still correct.
4. [Device Access Required] Disconnect/remove old work/school MDM connection(s) on device.
5. [Device Access Required] Reboot/reset as needed to ensure clean enrolment state.
6. [Device Access Required] Run Autopilot OOBE enrolment again.
7. [Admin Center Only] Validate new managed device object and successful policy/application state.

## 4) Verification Checks (Post-Remediation)
Use all checks below to confirm Autopilot succeeded end-to-end.

### Device checks
1. [Device Access Required] In **Settings > Accounts > Access work or school**, confirm active organizational connection is present and corresponds to current enrolment.
2. [Device Access Required] Run `dsregcmd /status` and confirm AzureAdJoined remains `YES`.
3. [Device Access Required] Trigger a sync from **Settings > Accounts > Access work or school > Info > Sync**.

### Intune checks
1. [Admin Center Only] In **Devices > All devices**, confirm a current device record with recent check-in timestamp.
2. [Admin Center Only] Confirm compliance and configuration profile deployment progresses from pending to success.
3. [Admin Center Only] Verify `FinBridge-Win11-Security-Baseline` no longer shows blocked/failed due to prior enrolment conflict.

Success criteria:
- Enrolment state reports successful completion.
- Device appears as actively managed in Intune under the new enrolment instance.
- Assigned Autopilot and security baseline profiles apply successfully.

## 5) Preventive Action for Other Legacy-Enrolled Devices
Implement a pre-Autopilot hygiene gate before assigning/starting Autopilot provisioning:

1. [Admin Center Only] Build a precheck report (Intune/Entra) to identify devices with indicators of previous manual/legacy MDM enrolment.
2. [Admin Center Only] Define a standard cleanup workflow: retire/delete stale objects and confirm only intended Autopilot record remains.
3. [Admin Center Only] Add a service desk runbook control: no device enters Autopilot until legacy enrolment conflict checks pass.
4. [Device Access Required] Where legacy tie remains on endpoint, mandate device-side disconnect/cleanup before provisioning window.
5. [Admin Center Only] Track recurring incidents with a problem record and weekly audit of legacy-enrolled devices pending migration.

## 6) Resolution Statement
The Autopilot failure was caused by conflicting pre-existing legacy MDM enrolment. Remediation is to remove stale enrolment state in Intune and on the endpoint, then rerun Autopilot with validated profile assignment and licensing. This directly addresses the observed failure pattern (0x80180014 with existing enrolment present).