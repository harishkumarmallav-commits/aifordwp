v 1.0, 07/08/2026, status : Draft

# KB: AVD Black Screen After Login (POOL-FIN-01) - L2/L3 Diagnostic and Recovery Guide

## Background: what the system does and why it matters
Azure Virtual Desktop (AVD) host pools POOL-FIN-01 and POOL-FIN-02 deliver virtual desktops to Finance users. After user authentication, Windows session initialization depends on Desktop Window Manager (dwm.exe) to render the interactive desktop. If DWM fails during this stage, users can authenticate successfully but still receive a black screen or disconnect.

Why this matters:
- This failure mode creates high user impact while identity and network checks may still appear healthy.
- It can be mis-triaged as profile, policy, or generic logon issues unless event-chain evidence is collected.
- Fast pool-level comparison (POOL-FIN-01 vs POOL-FIN-02) materially reduces time to correct root cause.

## Symptom: what the engineer observes and what the user reports
Engineer-observed pattern:
- Incident localized to POOL-FIN-01 hosts.
- POOL-FIN-02 remains stable in same time window.
- Session hosts show successful logons followed immediately by disconnects on affected pool.

User-reported pattern:
- Black screen directly after sign-in.
- Some sessions recover after about 30 seconds.
- Other sessions disconnect or loop through reconnect attempts.

Impact profile from reference incident:
- Approximately 40% of users assigned to POOL-FIN-01 impacted.
- User impact window observed around 07:00 to 10:00.

## Root cause: the specific technical cause with the evidence that confirms it
Specific technical cause:
- A graphics/rendering regression introduced by the overnight image update applied to POOL-FIN-01.
- On affected hosts, dwm.exe crashes in igdumd64.dll with exception code 0xc0000005 during post-login session initialization.

Evidence confirming root cause:
- Affected host sequence (SHFIN-01-A, incident window):
  - Event ID 21 (TerminalServices-LocalSessionManager): logon success.
  - Event ID 1000 (Application Error): Faulting application dwm.exe, Faulting module igdumd64.dll, Exception 0xc0000005.
  - Event ID 40 (TerminalServices-LocalSessionManager): session disconnect.
  - Event ID 9009 (Desktop Window Manager): DWM exited (error 0x40010004).
  - Sequence repeats on reconnect attempts.
- Supporting host-state evidence:
  - Event ID 1 (Kernel-General) confirms post-update boot timing alignment.
- Control comparison (SHFIN-02-A, same period):
  - Event ID 21 logon success.
  - Event ID 9011 (Desktop Window Manager) successful DWM start.
  - No Event ID 1000 entries for dwm.exe/igdumd64.dll.

Conclusion:
- Fault is image-linked rendering stack regression in POOL-FIN-01, not a primary FSLogix or GPO/logon-script issue.

## Detection: exactly how to confirm this is the issue before acting
Target: confirm or rule out this incident signature in under 3 minutes.

### A. Fast pool comparison by command (Azure CLI)
Run from admin workstation with Azure CLI and desktopvirtualization extension.

1. Check POOL-FIN-01 session-host state.
Command:
```powershell
az desktopvirtualization session-host list --resource-group <RG_NAME> --host-pool-name POOL-FIN-01 --query "[].{sessionHost:name,status:status,allowNewSession:allowNewSession,sessions:sessions}" -o table
```
Expected result:
- Unstable hosts/sessions are visible in POOL-FIN-01 during incident window.

2. Check POOL-FIN-02 session-host state (control pool).
Command:
```powershell
az desktopvirtualization session-host list --resource-group <RG_NAME> --host-pool-name POOL-FIN-02 --query "[].{sessionHost:name,status:status,allowNewSession:allowNewSession,sessions:sessions}" -o table
```
Expected result:
- POOL-FIN-02 appears stable and usable as unaffected baseline.

3. Capture host-pool property snapshot for change correlation.
Commands:
```powershell
az desktopvirtualization hostpool show --resource-group <RG_NAME> --host-pool-name POOL-FIN-01 -o json
az desktopvirtualization hostpool show --resource-group <RG_NAME> --host-pool-name POOL-FIN-02 -o json
```
Field to capture:
- Host-pool configuration delta used by your tenant change process (plus image metadata from image pipeline/release record if image version is external to host-pool object).

### B. Fast event confirmation on one affected host (PowerShell)
Run on an affected POOL-FIN-01 host (example SHFIN-01-A).

1. Set time window.
Command:
```powershell
$Start = (Get-Date).AddMinutes(-30)
```

2. Confirm Event ID 1000 in exact Application log with required fault signature.
Exact log location:
- Event Viewer path: Windows Logs > Application
- PowerShell LogName: Application
Command:
```powershell
Get-WinEvent -FilterHashtable @{ LogName='Application'; Id=1000; StartTime=$Start } |
Where-Object {
    $_.Message -match 'Faulting application name:\s*dwm\.exe' -and
    $_.Message -match 'Faulting module name:\s*igdumd64\.dll' -and
    $_.Message -match 'Exception code:\s*0xc0000005'
} |
Select-Object TimeCreated, Id, ProviderName, Message | Format-List
```
What to look for:
- Event ID 1000 exists.
- Faulting module name is exactly igdumd64.dll.

3. Confirm Event ID 9009 in exact DWM Operational log.
Exact log location:
- Event Viewer path: Applications and Services Logs > Microsoft > Windows > Desktop Window Manager > Operational
- PowerShell LogName: Microsoft-Windows-Desktop Window Manager/Operational
Command:
```powershell
Get-WinEvent -FilterHashtable @{ LogName='Microsoft-Windows-Desktop Window Manager/Operational'; Id=9009; StartTime=$Start } |
Select-Object TimeCreated, Id, Message | Format-Table -AutoSize
```
What to look for:
- Event ID 9009 entries aligned with user complaint time.

4. Confirm session chain around the same timestamp.
Exact log location:
- Event Viewer path: Applications and Services Logs > Microsoft > Windows > TerminalServices-LocalSessionManager > Operational
- PowerShell LogName: Microsoft-Windows-TerminalServices-LocalSessionManager/Operational
Command:
```powershell
Get-WinEvent -FilterHashtable @{ LogName='Microsoft-Windows-TerminalServices-LocalSessionManager/Operational'; Id=21,40; StartTime=$Start } |
Sort-Object TimeCreated |
Select-Object TimeCreated, Id, Message | Format-Table -Wrap
```
What to look for:
- Event 21 logon success, followed by Event 40 disconnect within seconds.

### C. Healthy baseline comparison on POOL-FIN-02 control host
Run on an unaffected POOL-FIN-02 host (example SHFIN-02-A).

1. Confirm Event ID 9011 baseline in DWM Operational log.
Exact log location:
- Event Viewer path: Applications and Services Logs > Microsoft > Windows > Desktop Window Manager > Operational
- PowerShell LogName: Microsoft-Windows-Desktop Window Manager/Operational
Command:
```powershell
Get-WinEvent -FilterHashtable @{ LogName='Microsoft-Windows-Desktop Window Manager/Operational'; Id=9011; StartTime=$Start } |
Select-Object TimeCreated, Id, Message | Format-Table -AutoSize
```
What to look for:
- Event ID 9011 present during same observation window.

2. Confirm no matching Event ID 1000 crash signature in Application log.
Exact log location:
- Event Viewer path: Windows Logs > Application
- PowerShell LogName: Application
Command:
```powershell
Get-WinEvent -FilterHashtable @{ LogName='Application'; Id=1000; StartTime=$Start } |
Where-Object { $_.Message -match 'dwm\.exe|igdumd64\.dll|0xc0000005' } |
Select-Object TimeCreated, Id, Message | Format-Table -Wrap
```
What to look for:
- No rows returned for dwm.exe/igdumd64.dll crash signature.

### D. 3-minute go/no-go rule
Confirm this incident only when all are true:
- Affected host Application log has Event ID 1000 with dwm.exe and igdumd64.dll and exception 0xc0000005.
- Affected host DWM Operational log has Event ID 9009 in same timeframe.
- Affected host TerminalServices-LocalSessionManager Operational log shows Event 21 then Event 40 sequence.
- Unaffected POOL-FIN-02 control host shows Event ID 9011 and no matching Event ID 1000 signature.

If any one condition is missing, stop and investigate alternate causes before applying this KB resolution.

## Resolution: step-by-step fix with expected result after each step
Target time: 5 to 10 minutes for containment plus canary recovery.

1. List FIN01 and FIN02 session hosts and capture current state.
Azure portal path and options:
- Azure Portal > Azure Virtual Desktop > Host pools > POOL-FIN-01 > Session hosts
- Azure Portal > Azure Virtual Desktop > Host pools > POOL-FIN-02 > Session hosts
- Option to check on each host row: Status, Allow new sessions, Sessions
Azure CLI:
```powershell
az desktopvirtualization session-host list --resource-group <RG_NAME> --host-pool-name POOL-FIN-01 --query "[].{name:name,status:status,allowNewSession:allowNewSession,sessions:sessions}" -o table
az desktopvirtualization session-host list --resource-group <RG_NAME> --host-pool-name POOL-FIN-02 --query "[].{name:name,status:status,allowNewSession:allowNewSession,sessions:sessions}" -o table
```
Expected result:
- You have the exact host list and current Allow new sessions state before action.

2. Drain all FIN01 hosts immediately.
Azure portal path and options:
- Azure Portal > Azure Virtual Desktop > Host pools > POOL-FIN-01 > Session hosts
- Select all affected hosts > Set Allow new sessions = No
PowerShell (Az.DesktopVirtualization):
```powershell
$rg = "<RG_NAME>"
$pool = "POOL-FIN-01"
Get-AzWvdSessionHost -ResourceGroupName $rg -HostPoolName $pool |
ForEach-Object { Update-AzWvdSessionHost -ResourceGroupName $rg -HostPoolName $pool -Name $_.Name -AllowNewSession:$false }
```
Expected result:
- New logons stop landing on POOL-FIN-01.

3. Keep FIN02 available as the live service pool.
Azure portal path and options:
- Azure Portal > Azure Virtual Desktop > Host pools > POOL-FIN-02 > Session hosts
- Confirm Allow new sessions = Yes on at least one healthy host
PowerShell (Az.DesktopVirtualization):
```powershell
$rg = "<RG_NAME>"
$pool = "POOL-FIN-02"
Get-AzWvdSessionHost -ResourceGroupName $rg -HostPoolName $pool |
Select-Object Name, Status, AllowNewSession
```
Expected result:
- Users can reconnect to a healthy pool while FIN01 is remediated.

4. Apply image or graphics stack fix for FIN01 hosts.
Azure portal path and options (image-managed environment):
- Azure Portal > Resource groups > <RG_NAME> > Virtual machine scale sets > <FIN01_VMSS_NAME> > Settings > Disks
- Option to verify/update: Image reference (publisher/offer/sku/version) or Gallery image ID
Azure CLI (if using VMSS image pin/rollback path):
```powershell
az vmss show --resource-group <RG_NAME> --name <FIN01_VMSS_NAME> --query "virtualMachineProfile.storageProfile.imageReference" -o json
az vmss update --resource-group <RG_NAME> --name <FIN01_VMSS_NAME> --set virtualMachineProfile.storageProfile.imageReference.id="<KNOWN_GOOD_IMAGE_ID>"
```
Expected result:
- FIN01 compute image points to approved known-good image baseline.

5. Restart FIN01 hosts after fix.
Azure portal path and options:
- Azure Portal > Azure Virtual Desktop > Host pools > POOL-FIN-01 > Session hosts > select host > Restart
Azure CLI (VM-level restart):
```powershell
az vm restart --resource-group <RG_NAME> --name <FIN01_VM_NAME>
```
Expected result:
- Host returns to Available after restart.

6. Re-enable only one FIN01 canary host.
Azure portal path and options:
- Azure Portal > Azure Virtual Desktop > Host pools > POOL-FIN-01 > Session hosts > select canary host
- Option: Allow new sessions = Yes
PowerShell:
```powershell
Update-AzWvdSessionHost -ResourceGroupName <RG_NAME> -HostPoolName POOL-FIN-01 -Name <CANARY_SESSION_HOST_NAME> -AllowNewSession:$true
```
Expected result:
- Only canary host accepts new sign-ins.

7. Run 3 test logons/reconnects, then re-enable remaining FIN01 hosts in batches.
Azure portal path and options:
- Azure Portal > Azure Virtual Desktop > Host pools > POOL-FIN-01 > User sessions
- Azure Portal > Azure Virtual Desktop > Host pools > POOL-FIN-01 > Session hosts > Allow new sessions
PowerShell (batch enable after pass):
```powershell
Get-AzWvdSessionHost -ResourceGroupName <RG_NAME> -HostPoolName POOL-FIN-01 |
Where-Object { $_.Name -ne "<CANARY_SESSION_HOST_NAME>" } |
ForEach-Object { Update-AzWvdSessionHost -ResourceGroupName <RG_NAME> -HostPoolName POOL-FIN-01 -Name $_.Name -AllowNewSession:$true }
```
Expected result:
- No recurrence on canary, then controlled restoration of FIN01 capacity.

## Verification: how to confirm the fix worked
1. Confirm host-pool operational state in AVD.
Azure portal path and options:
- Azure Portal > Azure Virtual Desktop > Host pools > POOL-FIN-01 > Session hosts
- Verify columns: Status = Available, Allow new sessions = Yes on intended hosts
- Azure Portal > Azure Virtual Desktop > Host pools > POOL-FIN-01 > User sessions
- Verify: Active sessions with no repeated disconnect/reconnect churn
Azure CLI:
```powershell
az desktopvirtualization session-host list --resource-group <RG_NAME> --host-pool-name POOL-FIN-01 --query "[].{name:name,status:status,allowNewSession:allowNewSession,sessions:sessions}" -o table
```
Pass condition:
- FIN01 hosts intended for service are Available and receiving stable sessions.

2. Confirm no recurrence signature on remediated FIN01 host (last 30 minutes).
PowerShell:
```powershell
$Start = (Get-Date).AddMinutes(-30)

# Application log exact path: Windows Logs > Application
Get-WinEvent -FilterHashtable @{ LogName='Application'; Id=1000; StartTime=$Start } |
Where-Object { $_.Message -match 'dwm\.exe|igdumd64\.dll|0xc0000005' } |
Select-Object TimeCreated, Id, Message

# DWM Operational exact path: Microsoft > Windows > Desktop Window Manager > Operational
Get-WinEvent -FilterHashtable @{ LogName='Microsoft-Windows-Desktop Window Manager/Operational'; Id=9009; StartTime=$Start } |
Select-Object TimeCreated, Id, Message

# LSM Operational exact path: Microsoft > Windows > TerminalServices-LocalSessionManager > Operational
Get-WinEvent -FilterHashtable @{ LogName='Microsoft-Windows-TerminalServices-LocalSessionManager/Operational'; Id=40; StartTime=$Start } |
Select-Object TimeCreated, Id, Message
```
Pass condition:
- No new matching Event 1000 signature, no Event 9009 recurrence, no disconnect burst Event 40.

3. Confirm healthy control baseline remains intact on FIN02.
PowerShell:
```powershell
$Start = (Get-Date).AddMinutes(-30)
Get-WinEvent -FilterHashtable @{ LogName='Microsoft-Windows-Desktop Window Manager/Operational'; Id=9011; StartTime=$Start } |
Select-Object TimeCreated, Id, Message
```
Pass condition:
- Event 9011 continues on POOL-FIN-02 control host in same observation window.

4. Service exit criteria.
Pass only when all are true:
- No black-screen user reports in observation window.
- No recurrence of 21 -> 1000 -> 40 -> 9009 sequence on FIN01.
- FIN02 baseline remains healthy with Event 9011.

## Rollback: what to do if the fix makes things worse
Trigger rollback immediately if any of these occur after canary enablement:
- New Event ID 1000 (dwm.exe in igdumd64.dll, 0xc0000005).
- New Event ID 9009 spike.
- New post-logon disconnect burst (Event ID 40) with user impact.

Rollback procedure:
1. Immediately re-drain FIN01.
Azure portal path and options:
- Azure Portal > Azure Virtual Desktop > Host pools > POOL-FIN-01 > Session hosts
- Select all hosts > Set Allow new sessions = No
PowerShell:
```powershell
Get-AzWvdSessionHost -ResourceGroupName <RG_NAME> -HostPoolName POOL-FIN-01 |
ForEach-Object { Update-AzWvdSessionHost -ResourceGroupName <RG_NAME> -HostPoolName POOL-FIN-01 -Name $_.Name -AllowNewSession:$false }
```
Expected result:
- New impacted sessions on FIN01 stop immediately.

2. Keep FIN02 open for continuity.
Azure portal path and options:
- Azure Portal > Azure Virtual Desktop > Host pools > POOL-FIN-02 > Session hosts
- Confirm Allow new sessions = Yes on healthy hosts
Expected result:
- Users reconnect on stable pool while rollback executes.

3. Validate rollback trigger quickly (last 10 minutes).
PowerShell:
```powershell
$Start = (Get-Date).AddMinutes(-10)
Get-WinEvent -FilterHashtable @{ LogName='Application'; Id=1000; StartTime=$Start } |
Where-Object { $_.Message -match 'dwm\.exe|igdumd64\.dll|0xc0000005' } |
Select-Object TimeCreated, Id, Message
Get-WinEvent -FilterHashtable @{ LogName='Microsoft-Windows-Desktop Window Manager/Operational'; Id=9009; StartTime=$Start } |
Select-Object TimeCreated, Id, Message
Get-WinEvent -FilterHashtable @{ LogName='Microsoft-Windows-TerminalServices-LocalSessionManager/Operational'; Id=40; StartTime=$Start } |
Select-Object TimeCreated, Id, Message
```
Expected result:
- Active recurrence evidence confirms rollback is required.

4. Roll back FIN01 image to known-good baseline.
Azure portal path and options (image-managed environment):
- Azure Portal > Resource groups > <RG_NAME> > Virtual machine scale sets > <FIN01_VMSS_NAME> > Settings > Disks
- Option: Image reference set to last known-good image ID/version
Azure CLI:
```powershell
az vmss update --resource-group <RG_NAME> --name <FIN01_VMSS_NAME> --set virtualMachineProfile.storageProfile.imageReference.id="<KNOWN_GOOD_IMAGE_ID>"
az vmss rolling-upgrade start --resource-group <RG_NAME> --name <FIN01_VMSS_NAME>
```
Expected result:
- FIN01 hosts return on known-good image and no longer reproduce DWM crash signature.

5. Restart and canary re-open only one FIN01 host post-rollback.
Azure portal path and options:
- Azure Portal > Azure Virtual Desktop > Host pools > POOL-FIN-01 > Session hosts > [one host] > Restart
- Then set Allow new sessions = Yes only on that canary host
PowerShell:
```powershell
Update-AzWvdSessionHost -ResourceGroupName <RG_NAME> -HostPoolName POOL-FIN-01 -Name <CANARY_SESSION_HOST_NAME> -AllowNewSession:$true
```
Expected result:
- Canary validates cleanly before any broader re-enable action.

## Preventive: specific changes to process or tooling to stop recurrence
1. Add mandatory graphics stability gate to image release process.
- Owner/Timing/Mode: release engineer, before deployment, automated [REQUIRES: canary test runner + event collector].
- Pass/Fail signal: pass only if 60-minute canary soak has Event 1000 count where message contains dwm.exe and igdumd64.dll = 0, and Event 9009 count = 0.
- If fail: change manager blocks promotion; image owner opens defect and rollback-to-last-good image is mandatory.

2. Implement automated event-correlation checks after each image rollout.
- Owner/Timing/Mode: DWP engineer, during deployment, automated [REQUIRES: correlation job or SIEM rule].
- Pass/Fail signal: fail if sequence 21 -> 1000 -> 40 -> 9009 occurs 2 or more times on any canary host within 15 minutes.
- If fail: auto-create P1 incident, set FIN01 hosts Allow new sessions = No, and hold rollout at current ring.

3. Enforce A/B comparison checkpoint before full production enablement.
- Owner/Timing/Mode: change manager, during deployment, manual.
- Pass/Fail signal: POOL-FIN-01 must show zero matching Event 1000 dwm.exe/igdumd64.dll and POOL-FIN-02 must show Event 9011 in same 30-minute window.
- If fail: no additional FIN01 hosts are enabled; continue on control pool and escalate to image owner. Automation note: convert to release gate script using `Get-WinEvent` outputs.

4. Pin and verify graphics stack in image pipeline.
- Owner/Timing/Mode: image owner, before deployment, automated [REQUIRES: image SBOM or driver manifest check].
- Pass/Fail signal: pass only when approved graphics driver/version hash list exactly matches baseline; any drift count > 0 is fail.
- If fail: build artifact is rejected, release engineer cannot tag image as deployable, and remediation ticket is required.

5. Add first-login-wave alerting.
- Owner/Timing/Mode: service desk lead, after deployment, automated [REQUIRES: alert rule in Log Analytics/Azure Monitor].
- Pass/Fail signal: alert threshold is Event 1000 (dwm.exe+igdumd64.dll) >= 3 on any host or Event 9009 >= 5 per host in first 60 minutes.
- If fail: service desk lead pages DWP engineer and change manager; freeze rollout and invoke rollback trigger check.

6. Pre-deployment smoke test gate (missing layer coverage).
- Owner/Timing/Mode: release engineer, before deployment, automated [REQUIRES: synthetic AVD login test account/workload].
- Pass/Fail signal: 3 login + reconnect cycles on canary image with zero Event 1000 matching igdumd64.dll and zero Event 9009.
- If fail: deployment does not start; image owner must fix and rerun smoke test.

7. Post-deployment validation before change closure (missing layer coverage).
- Owner/Timing/Mode: change manager, after deployment, manual.
- Pass/Fail signal: 30-minute validation window shows no FIN01 recurrence chain (21 -> 1000 -> 40 -> 9009) and FIN02 still shows Event 9011.
- If fail: change remains open, FIN01 stays constrained, and corrective action is required before closure. Automation note: publish a one-click validation script for approvers.

8. Rollback trigger threshold control (missing layer coverage).
- Owner/Timing/Mode: DWP engineer, during deployment, automated preferred; manual fallback [REQUIRES: host drain automation runbook].
- Pass/Fail signal: trigger rollback when canary shows Event 1000 signature >= 1 or Event 9009 >= 2 within 10 minutes.
- If fail threshold hit: auto-drain FIN01 (Allow new sessions = No) and switch user load to FIN02 immediately.

9. Knowledge update and checklist control (missing layer coverage).
- Owner/Timing/Mode: image owner, after deployment, manual.
- Pass/Fail signal: runbook, release checklist, and known-error entry updated within 2 business days with event IDs 1000/9009/9011 and thresholds used.
- If fail: change manager marks CAPA incomplete and blocks next image promotion until documentation is updated. Automation note: add change-close task template enforcing document links.

## Related: other incidents or KB articles this connects to
- Runbook source: Runbook - AVD Black Screen After Login (POOL-FIN-01), day5.
- Root cause record: RCA-POOL-FIN-01-black-screen-2024-03-15, day4.
- Known error summary: known-error-POOL-FIN-01-black-screen-2024-03-15, day4.
- Closure record: closure-POOL-FIN-01-black-screen-2024-03-15, day4.
- End-user communication template: end-user-comms-POOL-FIN-01-black-screen-2024-03-15, day4.
- L1 user self-service companion: L1-self-service-sign-in-black-screen, day5.
