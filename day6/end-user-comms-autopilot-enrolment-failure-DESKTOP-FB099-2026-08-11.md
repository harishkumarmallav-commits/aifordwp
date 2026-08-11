# Incident End-User Communications — Autopilot Enrolment Failure (DESKTOP-FB099)

## Audience 1 - Non-technical executive
User data and access controls remain protected, and there is no evidence of data loss. A device onboarding issue affected DESKTOP-FB099 because an older device management registration conflicted with the new Autopilot setup. The issue is understood, cleanup and re-enrolment actions are defined, and preventive controls are being added to avoid repeat incidents.

## Audience 2 - Affected end-user
Hi — your files and account are safe. Your device (DESKTOP-FB099) could not complete company setup because an older management registration on the device conflicted with the new setup process. IT will remove the old registration, re-run setup, and confirm when your device is fully compliant. If prompted to sign in or restart during this process, please follow the instructions from IT support.

## Audience 3 - Engineer-to-engineer internal note
Root cause: stale legacy manual MDM enrolment state (dated 2023-11-04) conflicted with Autopilot MDM enrolment, returning 0x80180014 (already enrolled). Impact: onboarding failed for DESKTOP-FB099; profiles remained 0/4 and compliance evaluation could not complete because enrolment was incomplete. Action taken/required: remove stale Intune/management records, remove endpoint-side stale work/school connection artifacts, verify Autopilot registration/profile assignment, re-initiate onboarding, validate check-in + baseline success. Preventive actions: mandatory pre-Autopilot legacy-enrolment conflict check, stale record retirement before assignment, and weekly audit for migration candidates with legacy markers.
