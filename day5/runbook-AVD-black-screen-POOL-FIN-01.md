Title: Runbook - AVD Black Screen After Login (POOL-FIN-01)
Version: 1.0
Date: 07/08/2026
Author: Sathishbabu
Reviewed: self
Status: draft
Change: initial version from RCA

# Runbook - AVD Black Screen After Login (POOL-FIN-01)

## 1) Prerequisites
- Pre-flight checklist (complete all before starting):
- [ ] Access confirmed: Azure Portal role can view and edit AVD host pools and session hosts. [ELEVATED]
- [ ] Access confirmed: rights to set Drain mode and change session-host availability in POOL-FIN-01 and POOL-FIN-02. [ELEVATED]
- [ ] Access confirmed: local admin on at least one affected host and one control host for event-log collection. [ELEVATED]
- [ ] Access confirmed: permission to apply image/driver corrective change and roll back to prior baseline image. [ELEVATED]
- [ ] Tool ready: Azure Portal open to Azure Virtual Desktop.
- [ ] Tool ready: Event Viewer available on target hosts (eventvwr.msc).
- [ ] Tool ready: PowerShell 5.1 or later available on target hosts for event queries.
- [ ] Tool ready: Incident ticket open and editable.
- [ ] Mandatory end-user information captured: first failure time, affected usernames, exact symptom text (black screen, disconnect, or both), whether reconnect works, and whether issue is still active.
- [ ] Mandatory environment information captured: affected host pool (POOL-FIN-01), control pool (POOL-FIN-02), at least one affected host name, and at least one unaffected host name.
- [ ] Mandatory change information captured: latest image update time/version for POOL-FIN-01 and current baseline image/version for POOL-FIN-02.

## 2) Procedure
1. Open Azure Portal, then go to Azure Virtual Desktop -> Host pools -> POOL-FIN-01.
Expected result: POOL-FIN-01 overview page is displayed.

2. Click Properties -> Scheduling/Updates (or Image/Template section used by your tenant) and record the current image version and last update time in the ticket. [ELEVATED]
Expected result: Ticket contains POOL-FIN-01 image version and timestamp.

3. Open Azure Virtual Desktop -> Host pools -> POOL-FIN-02 -> Properties and record image version and last update time in the ticket. [ELEVATED]
Expected result: Ticket contains POOL-FIN-02 baseline image details for A/B comparison.

4. Open Azure Virtual Desktop -> Host pools -> POOL-FIN-01 -> Session hosts and select one affected host (for example SHFIN-01-A).
Expected result: Session-host details page opens for an affected host.

5. Start a remote admin session to the affected host using Connect from the session-host page. [ELEVATED]
Expected result: You have desktop access to the affected host.

6. On the affected host, open Event Viewer by running eventvwr.msc.
Expected result: Event Viewer console opens.

7. In Event Viewer, open Applications and Services Logs -> Microsoft -> Windows -> TerminalServices-LocalSessionManager -> Operational.
Expected result: Local Session Manager operational log is visible.

8. In the Local Session Manager log, click Filter Current Log and set Event IDs to 21,40 for the incident time window.
Expected result: You can see logon success (21) and disconnect (40) sequence entries.

9. In Event Viewer, open Windows Logs -> Application.
Expected result: Application log is visible.

10. In Application log, click Filter Current Log and set Event ID to 1000 for the incident window.
Expected result: Application Error entries are listed.

11. Open one Event 1000 entry and confirm Faulting application name is dwm.exe, Faulting module name is igdumd64.dll, and exception code is 0xc0000005.
Expected result: Crash signature is confirmed on affected host.

12. In Event Viewer, open Applications and Services Logs -> Microsoft -> Windows -> Desktop Window Manager -> Operational.
Expected result: DWM operational log is visible.

13. In DWM operational log, click Filter Current Log and set Event ID to 9009 for the incident window.
Expected result: DWM exit events are listed and align with the failure sequence.

14. Repeat steps 4 through 13 on one control host in POOL-FIN-02 (for example SHFIN-02-A).
Expected result: Control host shows stable behavior and no matching dwm.exe/igdumd64.dll crash pattern.

15. On the control host, confirm Event ID 9011 exists in DWM operational log during user logon period.
Expected result: DWM successful start is confirmed on control host.

16. In Azure Portal, go to Azure Virtual Desktop -> Host pools -> POOL-FIN-01 -> Session hosts and set Allow new sessions to No for all affected hosts. [ELEVATED]
Expected result: Affected hosts enter drain mode and stop accepting new sessions.

17. In Azure Virtual Desktop, direct impacted users to POOL-FIN-02 assignment path according to your tenant routing method. [ELEVATED]
Expected result: New user sessions land on POOL-FIN-02 instead of POOL-FIN-01.

18. Apply the approved rendering/driver corrective change to POOL-FIN-01 image path or directly to affected hosts via your image pipeline/change system. [ELEVATED]
Expected result: Corrective change record is completed and linked to the incident.

19. Reboot corrected POOL-FIN-01 session hosts from Azure Virtual Desktop -> Host pools -> POOL-FIN-01 -> Session hosts -> Restart. [ELEVATED]
Expected result: Hosts return to Available state after restart.

20. Set Allow new sessions to Yes on one canary host only in POOL-FIN-01. [ELEVATED]
Expected result: Only canary host accepts new sessions.

21. Perform three login and reconnect tests to the canary host using a test user account.
Expected result: Desktop loads each time without black screen or disconnect loop.

22. On the canary host, run PowerShell command Get-WinEvent -FilterHashtable @{LogName='Application'; Id=1000; StartTime=(Get-Date).AddMinutes(-30)} | Where-Object { $_.Message -match 'dwm.exe|igdumd64.dll' }.
Expected result: Command returns no new matching crash events after remediation.

23. On the canary host, run PowerShell command Get-WinEvent -FilterHashtable @{LogName='Microsoft-Windows-Desktop Window Manager/Operational'; Id=9009; StartTime=(Get-Date).AddMinutes(-30)}.
Expected result: Command returns no new 9009 events after remediation.

24. On the canary host, run PowerShell command Get-WinEvent -FilterHashtable @{LogName='Microsoft-Windows-TerminalServices-LocalSessionManager/Operational'; Id=40; StartTime=(Get-Date).AddMinutes(-30)}.
Expected result: Command shows no post-logon disconnect burst linked to test logons.

25. Re-enable remaining POOL-FIN-01 hosts in batches of up to 20 percent by setting Allow new sessions to Yes. [ELEVATED]
Expected result: Capacity returns gradually while risk remains controlled.

26. After each batch, repeat steps 22 through 24 on one host from that batch.
Expected result: No recurrence signals are detected before next batch proceeds.

27. Update incident ticket with evidence screenshots or exported events from affected host and control host.
Expected result: Ticket contains auditable technical evidence for closure.

28. Close the incident only after verification criteria in section 3 are fully met.
Expected result: Incident is closed with validated fix and recovery timestamp.

## 3) Verification
1. Open Azure Portal -> Azure Virtual Desktop -> Host pools -> POOL-FIN-01 -> Session hosts.
Expected result: Session-host list is visible with current status.

2. Confirm at least one validated host shows Available and Allow new sessions set to Yes.
Expected result: A remediated host is open for user sessions.

3. Open Azure Portal -> Azure Virtual Desktop -> Host pools -> POOL-FIN-01 -> User sessions.
Expected result: User session list for POOL-FIN-01 is visible.

4. Confirm a test or pilot user session is Active on a remediated POOL-FIN-01 host.
Expected result: Active session confirms successful user sign-in path.

5. Connect to the validated POOL-FIN-01 host and open Event Viewer (eventvwr.msc).
Expected result: Event Viewer opens on the validated host.

6. Open Windows Logs -> Application and filter Event ID 1000 for the last 30 minutes.
Expected result: No new entries containing dwm.exe and igdumd64.dll after remediation.

7. Open Applications and Services Logs -> Microsoft -> Windows -> Desktop Window Manager -> Operational and filter Event ID 9009 for the last 30 minutes.
Expected result: No new DWM exit events after remediation.

8. Open Applications and Services Logs -> Microsoft -> Windows -> TerminalServices-LocalSessionManager -> Operational and filter Event ID 40 for the last 30 minutes.
Expected result: No disconnect burst linked to post-login sessions.

9. On one control host in POOL-FIN-02, open Desktop Window Manager -> Operational and confirm Event ID 9011 appears in the same observation window.
Expected result: Control pool still shows expected stable DWM startup behavior.

10. Record the verification evidence in the incident ticket with screenshot or exported events from steps 6 to 9.
Expected result: Closure evidence is complete and auditable.

## 4) Rollback
Target: Execute containment rollback in under 3 minutes.

1. Open Azure Portal -> Azure Virtual Desktop -> Host pools -> POOL-FIN-01 -> Session hosts. [ELEVATED]
Expected result: All POOL-FIN-01 session hosts are listed for immediate action.

2. Multi-select all POOL-FIN-01 hosts and set Allow new sessions to No. [ELEVATED]
Expected result: New user logons to POOL-FIN-01 stop immediately.

3. Open Azure Portal -> Azure Virtual Desktop -> Host pools -> POOL-FIN-02 -> Session hosts and confirm at least one host is Available with Allow new sessions set to Yes. [ELEVATED]
Expected result: Known-good pool is ready to receive redirected users.

4. Open Azure Portal -> Azure Virtual Desktop -> Host pools -> POOL-FIN-01 -> User sessions and identify active affected sessions. [ELEVATED]
Expected result: List of impacted sessions is visible for operator comms and reconnect guidance.

5. Send user broadcast in the incident channel instructing reconnect to the AVD workspace to land on POOL-FIN-02.
Expected result: Users reconnect away from unstable pool without waiting for deeper remediation.

6. On one affected POOL-FIN-01 host, open Event Viewer -> Windows Logs -> Application and filter Event ID 1000 for last 10 minutes.
Expected result: Fresh dwm.exe/igdumd64.dll crashes confirm rollback trigger validity.

7. On the same host, open Desktop Window Manager -> Operational and filter Event ID 9009 for last 10 minutes.
Expected result: Fresh DWM exits confirm active recurrence.

8. On the same host, open TerminalServices-LocalSessionManager -> Operational and filter Event ID 40 for last 10 minutes.
Expected result: Disconnect burst confirms user-impacting instability.

9. Keep POOL-FIN-01 in drain mode until image rollback and canary validation are completed under change control. [ELEVATED]
Expected result: Service remains stable on POOL-FIN-02 while corrective rollback is prepared.

## 5) Notes
- This incident signature is specific: Event 21 logon success followed by Event 1000 (dwm.exe -> igdumd64.dll, 0xc0000005), then Event 40 disconnect and Event 9009 DWM exit.
- Do not treat this as primary GPO/FSLogix issue when the crash chain above is present; RCA evidence contradicted those paths.
- Use POOL-FIN-02 as control evidence early; unchanged control pool sharply reduces diagnosis time.
- Related incident records: AVD black-screen hypothesis and RCA artifacts in day4 for POOL-FIN-01.