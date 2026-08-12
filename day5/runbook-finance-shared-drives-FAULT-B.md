Title: Runbook - Finance Team Cannot Access Shared Drives (FAULT-B)
Version: 1.1
Date: 10/08/2026
Author: Sathishbabu
Reviewed: self
Status: draft
Change: command-first revision aligned to RCA timeline and recovery pattern

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

9. In Intune admin center, open Devices -> Scripts and remediations -> Platform scripts -> Map-FinBridgeDrives.ps1 -> Properties. [ELEVATED]
Expected result: Script assignment and run context are visible.

10. Validate current configuration runs in SYSTEM context and has no retry readiness gate.
Expected result: RCA-matching risky configuration is confirmed.

11. On affected endpoint, run command `Get-Content "C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\IntuneManagementExtension.log" | Select-String "Map-FinBridgeDrives|SYSTEM|exit code 1|network name cannot be found"`.
Expected result: Log evidence confirms SYSTEM context + UNC failure + exit code 1 pattern.

12. On affected endpoint, run command `Get-WinEvent -FilterHashtable @{LogName='System'; Id=7036,98; StartTime=(Get-Date).AddHours(-4)} | Select-Object TimeCreated, Id, ProviderName, Message`.
Expected result: Event 7036 (Workstation running) appears after the mapping attempt and Event 98 confirms S: assignment failure.

13. Apply immediate containment by restoring mapping execution to USER context (preferred: re-enable prior GPO logon script behavior for Finance OU). [ELEVATED]
Expected result: USER-context mapping path is active for Finance sign-ins.

14. If GPO rollback is not immediately possible, update Intune script logic with readiness checks and retry/backoff (for example, wait for Workstation running and test UNC reachability before mapping). [ELEVATED]
Expected result: Script has gating and retry behavior to prevent early startup failure.

15. Force policy/script refresh on one pilot affected endpoint using `Invoke-Command`/Intune sync or run command `dsregcmd /refreshprt` followed by Company Portal sync.
Expected result: Updated mapping mechanism is applied to pilot endpoint.

16. Sign out and sign back in on pilot endpoint with affected test user.
Expected result: Drive S: maps successfully during user sign-in.

17. Expand remediation to remaining affected Finance endpoints.
Expected result: Updated mapping behavior rolls out to incident scope.

18. Capture before/after evidence in ticket (missing S: before, mapped S: after, and key log lines).
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

7. Run PowerShell command `Get-Content "C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\IntuneManagementExtension.log" -Tail 200 | Select-String "Map-FinBridgeDrives|exit code|network name"`.
Expected result: No new exit code 1 or network-name failure entries in recent execution.

8. Update incident ticket with verification timestamp, sample endpoints, and outcomes.
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

6. Confirm rollback success with command `Get-PSDrive -Name S` on at least two pilot endpoints after sign-in.
Expected result: S: drive is present via legacy USER-context mapping path.

## 5) Notes
- RCA indicates dual failure mode: execution context regression (USER to SYSTEM) and startup timing race condition.
- Primary evidence chain: SYSTEM context log line, UNC failure at script runtime, Workstation service readiness event after failure, and no retry configured.
- Group Policy processing itself was successful in evidence, so treat this as mapping execution design issue, not baseline GP outage.
- Related source: day4 incident analysis for Finance shared-drive access (2024-03-15).