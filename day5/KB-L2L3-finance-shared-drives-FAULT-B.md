v 1.0, 10/08/2026, status : Draft

# KB: Finance Team Cannot Access Shared Drives (FAULT-B) - L2/L3 Diagnosis and Recovery

## Background: what the system does and why it matters
Finance users access shared data through mapped drive S:, which points to \\finbridge-fs01\Finance. The mapping workflow was migrated from a GPO logon script (USER context) to an Intune PowerShell script (SYSTEM context). If context, startup timing, or retry behavior is wrong, users can sign in successfully but still lose S: access.

Why this matters:
- Loss of S: blocks core Finance workflows.
- Impact can spread quickly across OU=Finance devices.
- The issue can look like server outage, but root cause may be endpoint script context and timing.

## Symptom: what engineer observes and what users report
Engineer-observed:
- Affected devices follow pattern DESKTOP-FB* in OU=Finance.
- S: drive missing or not assigned after sign-in.
- Intune script execution shows SYSTEM context with script failure and no retry.

User-reported:
- S: drive missing in This PC.
- Shared drive path opens intermittently only after delay or manual retry.
- Some users see access failures immediately after logon.

## Root cause: specific technical cause with confirming evidence
Root cause:
- Mapping migration changed execution from USER to SYSTEM context, and script attempted UNC access too early in startup.
- Mapping failed before Workstation service readiness and exited with no retry.

Confirming evidence from incident:
- Intune log sequence:
  - 08:00:02: script running as SYSTEM.
  - 08:00:03: \\finbridge-fs01\Finance inaccessible from SYSTEM context, exit code 1 (network name cannot be found).
  - 08:00:04: no retry configured.
- System log sequence on DESKTOP-FB041:
  - 08:00:05 Event ID 7036: Workstation service entered running state.
  - 08:00:07 Event ID 98 (Ntfs): S: could not be assigned.
- Change correlation:
  - 2024-03-14 23:30 migration from GPO USER-context mapping to Intune SYSTEM-context script without readiness/retry updates.

## Detection: confirm this exact issue before acting
### A. Pull direct evidence from affected endpoint (PowerShell)
1. Intune script context and failure signature.
Command:
```powershell
Get-Content "C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\IntuneManagementExtension.log" |
Select-String "Map-FinBridgeDrives|SYSTEM|network name cannot be found|exit code 1|No retry configured"
```
Pass condition:
- Output includes SYSTEM context plus UNC/network failure and exit code 1.

2. System timing and mapping-failure events.
Command:
```powershell
$Start = (Get-Date).AddHours(-4)
Get-WinEvent -FilterHashtable @{LogName='System'; Id=7036,98; StartTime=$Start} |
Select-Object TimeCreated, Id, ProviderName, Message | Sort-Object TimeCreated
```
Pass condition:
- Event 7036 (Workstation running) appears after mapping attempt and Event 98 confirms S: assignment failure.

3. Validate user-context reachability.
Command:
```powershell
Test-Path "\\finbridge-fs01\Finance"
```
Pass condition:
- Returns True in user session, indicating this is not a persistent share outage.

### B. Confirm change context in Intune
Path:
- Intune admin center > Devices > Scripts and remediations > Platform scripts > Map-FinBridgeDrives.ps1 > Properties
Check:
- Run this script using logged on credentials: No (SYSTEM)
- Assignment scope includes Finance devices
Pass condition:
- SYSTEM context setting matches incident regression pattern.

## Resolution: step-by-step fix
1. Contain impact by restoring USER-context mapping path.
Path:
- Group Policy Management > Finance OU > User Configuration > Windows Settings > Scripts (Logon)
Action:
- Re-enable known-good logon script for S: mapping.
Expected result:
- Affected users receive mapping during sign-in.

2. Disable problematic Intune script assignment temporarily.
Path:
- Intune admin center > Devices > Scripts and remediations > Platform scripts > Map-FinBridgeDrives.ps1 > Assignments
Action:
- Remove/disable assignment to Finance device group.
Expected result:
- SYSTEM-context failure path is no longer triggered.

3. If Intune script must remain, add readiness + retry controls.
Minimum logic:
- Wait until LanmanWorkstation service status is Running.
- Check `Test-Path \\finbridge-fs01\Finance` before mapping.
- Retry up to 5 times with 15-second delay.
Expected result:
- Script does not fail on early startup race.

4. Force refresh on pilot devices and retest.
Commands (pilot endpoint):
```powershell
gpupdate /force
Start-Process "ms-settings:workplace"
```
Expected result:
- New policy/script behavior applies, S: maps after sign-in.

5. Roll out to remaining Finance endpoints in batches.
Expected result:
- S: mapping stability returns without widespread regression.

## Verification: confirm fix worked
1. On at least 3 previously affected endpoints, verify S: exists.
Command:
```powershell
Get-PSDrive -Name S
```
Pass condition:
- Drive S appears with expected root.

2. Confirm share accessibility.
Command:
```powershell
Test-Path "\\finbridge-fs01\Finance"
```
Pass condition:
- Returns True for pilot and sampled users.

3. Confirm no new script failure signature.
Command:
```powershell
Get-Content "C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\IntuneManagementExtension.log" -Tail 300 |
Select-String "Map-FinBridgeDrives|exit code 1|network name cannot be found"
```
Pass condition:
- No new failure entries after remediation timestamp.

4. Confirm no new mapping failure event.
Command:
```powershell
Get-WinEvent -FilterHashtable @{LogName='System'; Id=98; StartTime=(Get-Date).AddMinutes(-60)}
```
Pass condition:
- No new Event 98 on remediated devices during observation window.

## Rollback: if the fix makes things worse
1. Disable modified Intune script assignment immediately.
Path:
- Intune admin center > Devices > Scripts and remediations > Platform scripts > Map-FinBridgeDrives.ps1 > Assignments
Expected result:
- New failing script executions stop.

2. Revert to known-good GPO USER-context mapping only.
Path:
- Group Policy Management > Finance OU > User Configuration > Windows Settings > Scripts (Logon)
Expected result:
- Stable mapping path restored.

3. Force policy refresh and test on 2 pilot endpoints.
Commands:
```powershell
gpupdate /force
shutdown /l
```
Expected result:
- User signs back in and S: mapping is restored.

4. Hold Intune mapping change until corrected script passes pilot verification.
Expected result:
- Recurrence risk controlled while root fix is hardened.

## Preventive: specific changes to stop recurrence
1. Add context-change release gate.
- Owner: change manager; Timing: before deployment; Mode: manual.
- Pass/Fail: any mapping change USER->SYSTEM requires documented credential, readiness, and retry design review.
- If fail: block release and return to image owner.

2. Add startup readiness and retry standard for all mapping scripts.
- Owner: DWP engineer; Timing: during deployment; Mode: automated.
- Pass/Fail: script must check LanmanWorkstation running plus UNC reachable and include minimum 5 retries.
- If fail: script assignment not approved.

3. Add incident signal alerts.
- Owner: service desk lead; Timing: after deployment; Mode: automated [REQUIRES: SIEM/alert rule].
- Pass/Fail: alert when exit code 1 pattern in IME log or Event 98 count >= 3 on Finance endpoints in 30 minutes.
- If fail: open incident and trigger containment runbook.

4. Add post-change validation checkpoint.
- Owner: release engineer; Timing: after deployment; Mode: manual.
- Pass/Fail: 3 pilot devices confirm `Get-PSDrive -Name S` success and no new Event 98 for 30 minutes.
- If fail: immediate rollback to known-good mapping path.

## Related: linked artifacts
- RCA source: day4 analysis-FAULT-B-finance-shared-drives-2024-03-15.
- Runbook: day5 runbook-finance-shared-drives-FAULT-B.
- L1 guide: day5 L1-self-service-finance-shared-drives.
