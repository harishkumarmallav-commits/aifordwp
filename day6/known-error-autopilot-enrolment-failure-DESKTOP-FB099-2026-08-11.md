Symptom: Windows Autopilot enrolment fails on DESKTOP-FB099 and required security/compliance profiles do not apply.

Cause: The device was already enrolled in MDM through a legacy manual enrolment from 2023-11-04. This stale enrolment state conflicted with Autopilot enrolment and blocked completion.

Scope: Affected onboarding path for reused/migrated Windows 11 devices that still contain legacy manual MDM enrolment state or stale management records. For this incident, impact was observed on DESKTOP-FB099 (FINBRIDGE\\rthomas).

Workaround: Remove stale legacy MDM enrolment state (tenant-side record cleanup and endpoint work/school connection cleanup), then re-run Autopilot onboarding.

Permanent fix: Enforce mandatory pre-Autopilot hygiene checks for legacy enrolment conflicts, retire/delete stale records before profile assignment, and gate onboarding until cleanup checks are recorded as passed.

How to spot it: Look for the signature chain in diagnostics/export:
- EnrollmentType: Autopilot
- EnrollmentState: Failed
- ErrorCode: 0x80180014
- ErrorDescription: "The device is already enrolled in MDM."
- ProfilesAttempted: 4, ProfilesApplied: 0
- Compliance cannot evaluate with reason equivalent to enrolment not complete.
