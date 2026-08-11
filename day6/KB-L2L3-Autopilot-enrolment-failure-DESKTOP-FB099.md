v 1.0, 11/08/2026, status : Draft

# KB: Windows Autopilot Enrolment Failure Due to Legacy MDM Conflict (DESKTOP-FB099) - L2/L3 Diagnostic and Recovery Guide

## Background: what the system does and why it matters
Windows Autopilot provisions corporate Windows devices into managed state via Microsoft Entra ID and Intune. Successful enrolment is required before security baselines and compliance policies can apply.

Why this matters:
- Users may sign in but device governance remains incomplete.
- Baseline controls can remain unapplied if enrolment fails.
- Reused devices are high-risk for stale legacy enrolment conflicts.

## Symptom: what the engineer observes and what the user reports
Engineer-observed pattern:
- Autopilot flow starts but does not complete.
- Enrolment status returns Failed.
- Required profiles show attempted but not applied.

User-reported pattern:
- Device setup loops or stops at company setup stage.
- User may see message that the device is already enrolled in MDM.

Incident reference signal:
- EnrollmentType: Autopilot
- EnrollmentState: Failed
- ErrorCode: 0x80180014
- ProfilesAttempted: 4
- ProfilesApplied: 0

## Root cause: the specific technical cause with the evidence that confirms it
Specific technical cause:
- A pre-existing legacy manual MDM enrolment state (2023-11-04) conflicted with the new Autopilot enrolment path.

Evidence confirming root cause:
- Diagnostic export explicitly reports: "The device is already enrolled in MDM" with 0x80180014.
- Licensing and network checks were healthy (licenses present, endpoints reachable, no proxy detection).
- Azure AD joined state was healthy.
- Compliance evaluation could not complete because enrolment did not complete.

Conclusion:
- The blocker is stale enrolment conflict, not primary network/license/AAD failure.

## Detection: exactly how to confirm this is the issue before acting
Target: confirm or rule out in under 5 minutes.

### A. Confirm core signature
Collect enrolment diagnostics (company standard export) and confirm all of the following:
- EnrollmentType = Autopilot
- EnrollmentState = Failed
- ErrorCode = 0x80180014
- ErrorDescription includes "already enrolled in MDM"

### B. Confirm related context is not primary blocker
Check in export/admin center:
- Intune and Autopilot licensing present.
- Azure AD join state = Yes.
- Network/service endpoints reachable.

### C. Confirm profile/compliance symptom
- ProfilesAttempted > 0 and ProfilesApplied = 0.
- Compliance/evaluation status indicates enrolment incomplete.

### D. Go/no-go rule
Treat as this known issue only when all are true:
- 0x80180014 + already enrolled message.
- Existing or historical legacy/manual MDM enrolment state found.
- No stronger competing blocker (license/network/AAD join) is present.

## Resolution: step-by-step fix with expected result after each step
Target time: 15 to 30 minutes excluding user availability.

1. Capture current object state for audit.
- Export current Intune device object details and timestamps.
Expected result:
- Pre-change evidence is retained.

2. Remove stale legacy management record(s) in Intune.
- Retire/delete stale duplicate or legacy record linked to the device.
Expected result:
- Conflicting old record is removed from management inventory.

3. Validate Autopilot device registration and profile assignment.
- Confirm device hash object exists and assigned profile is correct (FinBridge-Autopilot-Standard).
Expected result:
- Device is ready for clean Autopilot processing.

4. Clean endpoint-side stale work/school enrolment artifacts.
- On device, remove stale work/school connection only per runbook.
Expected result:
- Endpoint no longer presents conflicting enrolment identity.

5. Re-initiate Autopilot enrolment.
- Restart setup/onboarding flow and complete sign-in prompts.
Expected result:
- Enrolment transitions to success state.

6. Force or wait for check-in and policy sync.
- Trigger sync from Intune/Company Portal path as applicable.
Expected result:
- Device check-in timestamp updates.

7. Validate baseline and compliance.
- Confirm previously failed baseline now applies successfully.
Expected result:
- ProfilesApplied reflects successful deployment and compliance evaluation completes.

## Verification: how to confirm the fix worked
Pass only when all conditions are true:
- Enrolment status for Autopilot is successful.
- Device appears as active/current managed object with recent check-in.
- Required baseline/profile deployment succeeds (not 0/x).
- Compliance evaluation no longer reports enrolment incomplete.
- User can access workstation in expected managed state.

## Rollback: what to do if the fix makes things worse
Trigger rollback/escalation if:
- Enrolment still fails after cleanup with same code.
- New blocking code appears indicating different failure domain.

Rollback/escalation actions:
1. Stop repeated retries to avoid noisy duplicate records.
2. Re-check for hidden duplicate records across tenant scopes.
3. Re-validate hardware hash and assignment group targeting.
4. Escalate to Endpoint Engineering with full evidence pack:
- Device name, user, timestamps, error codes, record IDs, profile assignment proof, and post-change diagnostics.

## Prevention and hardening controls
1. Add mandatory pre-Autopilot legacy-enrolment conflict check to onboarding SOP.
2. Enforce stale record cleanup gate before Autopilot profile assignment.
3. Maintain weekly audit report for migration candidates with legacy/manual markers.
4. Require checklist sign-off (tenant-side and endpoint-side cleanup) before onboarding execution.
