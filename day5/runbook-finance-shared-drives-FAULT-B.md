Title: Runbook - Finance Team Cannot Access Shared Drives (FAULT-B)
Version: 1.0
Date: 07/08/2026
Author: Sathishbabu
Reviewed: self
Status: draft
Change: initial version from RCA

# Runbook - Finance Team Cannot Access Shared Drives (FAULT-B)

## 1) Prerequisites
- Pre-flight checklist (complete all before starting):
- [ ] Access confirmed: rights to edit GPO logon scripts for Finance OU. [ELEVATED]
- [ ] Access confirmed: rights to view and edit Intune PowerShell script assignment for Finance devices. [ELEVATED]
- [ ] Access confirmed: local admin on at least one affected endpoint and one control endpoint for log collection. [ELEVATED]
- [ ] Tool ready: Event Viewer available on target endpoints (eventvwr.msc).
- [ ] Tool ready: PowerShell 5.1 or later available on target endpoints.
- [ ] Tool ready: access to Intune logs (Intune Management Extension logs).
- [ ] Tool ready: incident ticket open and editable.
- [ ] Mandatory end-user information captured: first failure time, affected usernames, impacted drive letter (S:), and whether manual UNC access works.
- [ ] Mandatory environment information captured: affected device naming pattern (DESKTOP-FB*), OU=Finance, and one known-good control endpoint.
- [ ] Mandatory change information captured: migration details from GPO USER-context script to Intune SYSTEM-context script on 2024-03-14 23:30.

## 2) Procedure
1. Open incident ticket and record current impact count and business impact for Finance users.
Expected result: Ticket contains up-to-date impact statement and initial timestamp.

2. On one affected endpoint, open File Explorer and check whether drive S: is mapped.
Expected result: S: is missing or unavailable on affected user session.

3. On the same endpoint, test UNC path access by entering \\finbridge-fs01\Finance in File Explorer while signed in as the affected user.
Expected result: Path is reachable from user context, confirming share is generally available.

4. Open Event Viewer (eventvwr.msc) on the affected endpoint.
Expected result: Event Viewer console opens.

5. Go to Windows Logs -> System and filter for Event ID 7036 around incident time.
Expected result: Workstation service running event appears near startup timeline.

6. In Event Viewer, filter Windows Logs -> System for Event ID 98 (Ntfs) around incident time.
Expected result: Event indicates drive letter S: could not be assigned.

7. Collect Intune Management Extension log entries for the incident window from C:\ProgramData\Microsoft\IntuneManagementExtension\Logs.
Expected result: Log lines show script start, SYSTEM context, UNC failure, and exit code 1.

8. Confirm timeline pattern in logs: script attempts mapping before Workstation service is fully ready.
Expected result: Evidence shows timing race (script failure before service readiness) and no retry.

9. In Intune admin center, locate the drive mapping script deployment for Finance devices. [ELEVATED]
Expected result: You can view execution context and assignment for the mapping script.

10. Validate current configuration runs script in SYSTEM context.
Expected result: SYSTEM context configuration is confirmed as current state.

11. Apply immediate containment by restoring mapping execution to USER context (preferred: re-enable prior GPO logon script behavior for Finance OU). [ELEVATED]
Expected result: USER-context mapping path is active for Finance sign-ins.

12. If GPO rollback is not immediately possible, update Intune script logic with readiness checks and retry/backoff (for example, wait for Workstation running and test UNC reachability before mapping). [ELEVATED]
Expected result: Script has gating and retry behavior to prevent early startup failure.

13. Force policy/script refresh on one pilot affected endpoint.
Expected result: Updated mapping mechanism is applied to pilot endpoint.

14. Sign out and sign back in on pilot endpoint with affected test user.
Expected result: Drive S: maps successfully during user sign-in.

15. Expand remediation to remaining affected Finance endpoints.
Expected result: Updated mapping behavior rolls out to incident scope.

16. Capture before/after evidence in ticket (missing S: before, mapped S: after, and key log lines).
Expected result: Ticket contains auditable remediation evidence.

## 3) Verification
1. On at least three previously affected endpoints, sign in with Finance user accounts.
Expected result: Drive S: is present and accessible after sign-in.

2. Open File Explorer on each validated endpoint and browse S:.
Expected result: Finance share content loads without delay or access errors.

3. Run PowerShell command `Get-PSDrive -Name S` in user session.
Expected result: Command returns drive S with expected provider and root path.

4. Run PowerShell command `Test-Path \\finbridge-fs01\Finance` in user session.
Expected result: Command returns True.

5. Review Intune Management Extension logs on a remediated endpoint for latest execution.
Expected result: No new exit code 1 for drive-mapping workflow in current observation window.

6. Review System log for fresh Event ID 98 (Ntfs) entries related to S: mapping.
Expected result: No new mapping-failure events after remediation.

7. Update incident ticket with verification timestamp, sample endpoints, and outcomes.
Expected result: Closure evidence is complete and supports service restoration.

## 4) Rollback
Target: Execute containment rollback in under 5 minutes.

1. If updated script causes instability, disable the new Intune mapping script assignment for Finance device group. [ELEVATED]
Expected result: New script execution stops on targeted endpoints.

2. Re-enable known-good GPO USER-context logon mapping script for Finance OU. [ELEVATED]
Expected result: Legacy mapping path becomes primary again at sign-in.

3. Trigger policy update on a pilot endpoint and perform sign-out/sign-in test.
Expected result: Pilot endpoint receives legacy mapping and S: appears.

4. Keep Intune script disabled until root fix is retested with readiness and retry controls.
Expected result: User impact remains contained while engineering validates a corrected script.

5. Record rollback action, timestamp, and validation result in incident ticket.
Expected result: Change history is complete and auditable.

## 5) Notes
- RCA indicates dual failure mode: execution context regression (USER to SYSTEM) and startup timing race condition.
- Primary evidence chain: SYSTEM context log line, UNC failure at script runtime, Workstation service readiness event after failure, and no retry configured.
- Group Policy processing itself was successful in evidence, so treat this as mapping execution design issue, not baseline GP outage.
- Related source: day4 incident analysis for Finance shared-drive access (2024-03-15).