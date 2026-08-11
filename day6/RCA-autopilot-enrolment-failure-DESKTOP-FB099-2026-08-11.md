# Root Cause Analysis (RCA)

## Incident Summary
- Incident: Windows Autopilot enrolment failure
- Device: DESKTOP-FB099
- User: FINBRIDGE\\rthomas
- Date of failure event: 2024-03-15
- RCA date: 2026-08-11
- Environment: Windows 11, Intune-managed endpoint onboarding

## Executive Conclusion
Autopilot enrolment failed because the device already had an existing legacy manual MDM enrolment from 2023-11-04. This conflicting management state blocked new Autopilot MDM enrolment and prevented policy baseline application.

## Scope and Impact
- Affected service: Device onboarding and security baseline deployment via Autopilot + Intune.
- User impact: User could not complete expected managed onboarding state.
- Security/compliance impact: Required profile `FinBridge-Win11-Security-Baseline` was not applied (`0 of 4` profiles applied), leaving intended controls unapplied at that time.

## Supporting Evidence

### Primary diagnostic facts (from MDM export)
- EnrollmentType: Autopilot
- EnrollmentState: Failed
- ErrorCode: `0x80180014`
- ErrorDescription: "The device is already enrolled in MDM."
- MDMEnrolled: Yes (previous enrolment)
- EnrolmentSource: Legacy manual MDM enrolment (2023-11-04)
- AzureADJoined: Yes
- ProfilesAttempted: 4
- ProfilesApplied: 0
- LastError: `0x80070005 (Access denied)`
- FailedProfile: FinBridge-Win11-Security-Baseline
- IntuneP1License: Yes
- AutopilotLicense: Yes
- Network endpoints: reachable
- ProxyDetected: No

### Evidence interpretation (fact-based)
- Enrolment failure is explicit and directly attributed in export to pre-existing MDM enrolment.
- Licensing is present; this does not indicate license-related blocking.
- Network checks are healthy; this does not indicate connectivity/proxy blocking.
- Azure AD join state is healthy; this does not indicate AAD join failure.
- Policy application failure occurs in a context where enrolment was not completed; profile application remained at 0/4.

## Timeline (UTC local capture context)

| Time | Event | Evidence |
|---|---|---|
| 2023-11-04 | Legacy manual MDM enrolment established | `EnrolmentSource: Legacy (manual MDM enrolment, 2023-11-04)` |
| 2024-03-15 09:18:44 | Autopilot enrolment attempt fails | `EnrollmentState: Failed`, `ErrorCode: 0x80180014`, description shows already enrolled |
| 2024-03-15 09:19:01 | Policy manager attempts profiles; none apply | `ProfilesAttempted: 4`, `ProfilesApplied: 0`, `LastError: 0x80070005` |
| 2024-03-15 09:19:45 | Compliance evaluation cannot complete | `EvaluationResult: Could not evaluate`, `Reason: Enrolment not complete` |
| 2026-08-11 | RCA finalized | Current analysis date |

## 5 Whys Analysis
1. Why did Autopilot enrolment fail?
- Because the enrolment process returned failed state with `0x80180014` and explicit message that device is already enrolled in MDM.

2. Why was the device considered already enrolled?
- Because a prior legacy manual MDM enrolment existed on this endpoint from 2023-11-04.

3. Why did this prior enrolment conflict with Autopilot?
- Because Autopilot expected a clean/non-conflicting MDM enrolment state; existing legacy enrolment created a conflicting management identity/state.

4. Why was the conflicting legacy state not removed before Autopilot onboarding?
- Because pre-provisioning hygiene controls did not enforce mandatory stale-enrolment cleanup before Autopilot attempt.

5. Why were hygiene controls not preventing recurrence?
- Because there was no standardized gate/reporting workflow to identify and remediate legacy manual enrolments prior to Autopilot assignment/execution.

## Confirmed Root Cause
A stale legacy manual MDM enrolment state (created on 2023-11-04) remained on the device and/or corresponding management records, causing a conflict that blocked Autopilot enrolment completion.

## Contributing Factors
- Absence of a strict pre-Autopilot cleanup gate for legacy manual enrolments.
- Legacy and Autopilot management transition not validated by a mandatory checklist before execution.

## Corrective Actions Implemented / Required
1. Remove stale legacy Intune/management records for DESKTOP-FB099 in Intune admin center.
2. Verify correct Autopilot device registration and profile assignment (`FinBridge-Autopilot-Standard`).
3. Ensure device-side old work/school MDM connection is disconnected and stale enrolment artifacts are removed.
4. Re-initiate Autopilot flow on cleaned endpoint.
5. Validate successful check-in and profile deployment after re-enrolment.

## Verification of Resolution
Resolution is confirmed when all of the following are true:
- Enrolment state completes successfully for Autopilot flow.
- Device appears in Intune as current active managed object with recent check-in.
- Assigned baseline/profile deployment shows success (not `0 of 4`).
- Compliance evaluation runs to completion (no "Enrolment not complete" condition).

## Preventive Actions
1. Introduce a mandatory pre-Autopilot "legacy enrolment conflict" check in service desk/onboarding SOP.
2. Build recurring admin-center report to detect devices with legacy/manual MDM markers before Autopilot scheduling.
3. Enforce retire/delete of stale device records before assigning Autopilot profile to migration candidates.
4. Add a standard endpoint-side cleanup checklist (Access work or school disconnect + validation) for reused devices.
5. Add quality gate in change/onboarding workflow: no Autopilot execution until cleanup checks are recorded as passed.
6. Perform weekly audit for devices pending Autopilot with historical legacy enrolment indicators.

## Ownership and Follow-up
- Endpoint Engineering: implement and maintain precheck automation/reporting.
- Intune Operations: execute stale record cleanup and profile assignment validation.
- Service Desk: follow enforced runbook gates prior to Autopilot execution.
- Problem Management: track recurrence metric and closure criteria over next audit cycles.

## Closure Criteria
RCA can be closed when:
- DESKTOP-FB099 is successfully onboarded via Autopilot with expected profile/compliance success.
- Preventive workflow is published and adopted for all migration candidates.
- No repeat incidents of legacy-enrolment conflict are observed within agreed monitoring period.