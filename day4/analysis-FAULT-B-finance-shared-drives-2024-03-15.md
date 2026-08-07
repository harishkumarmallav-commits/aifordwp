# Incident Analysis - FAULT-B Finance Shared Drive Access

Date: 2024-03-15
Incident: Finance team cannot access shared drives

## Scope Facts
- Impact: 45 users in Finance.
- Device scope: DESKTOP-FB* devices, OU=Finance.
- Symptom: shared drive mapping fails (S: not assigned).

## Evidence Summary

### Intune Management Extension Log
- 08:00:01 - ScriptRunner starts Map-FinBridgeDrives.ps1.
- 08:00:02 - Script context is SYSTEM account.
- 08:00:03 - Warning: \\finbridge-fs01\Finance not accessible from SYSTEM context at execution time.
- 08:00:03 - Error: script failed, exit code 1, network name cannot be found.
- 08:00:04 - No retry configured.

### System Log (DESKTOP-FB041)
- 08:00:05 - Event 7036: Workstation service entered running state.
- 08:00:06 - Event 1500: Group Policy processed successfully.
- 08:00:07 - Event 98 (Ntfs): could not map drive letter S:, drive letter not assigned.

### Prior Change Correlation
- 2024-03-14 23:30 - Drive mapping migrated from GPO logon script (runs as USER) to Intune PowerShell script (runs as SYSTEM).
- Change note states script was not updated for SYSTEM context, and UNC path access depended on user-mapped credentials not available to SYSTEM at login time.

## Causal Analysis
The failure is consistent with an execution-context regression introduced by the migration from USER context to SYSTEM context. The script attempted UNC access at 08:00:03 and failed before the Workstation service reached running state at 08:00:05, then did not retry. Because the script stayed in SYSTEM context without user credential context and without retry logic, drive S: remained unassigned for affected users.

## Hypothesis Disposition
1. Group Policy failure: Contradicted by Event 1500 at 08:00:06 showing successful GP processing.
2. File server path typo or permanent share outage: Not supported by provided evidence; failure is explicitly context and timing-linked in logs and change note.
3. Script logic regression due to migration to SYSTEM context: Supported by script-context log line at 08:00:02, UNC failure at 08:00:03, and migration note.
4. Service readiness race condition with no retry: Supported by failure at 08:00:03 preceding Workstation running at 08:00:05 and explicit No retry configured at 08:00:04.

## Most Likely Cause
Drive mapping failed because the migrated Intune script executed as SYSTEM and attempted UNC mapping before required network/session readiness, then exited with no retry.

## Immediate Recovery Actions
1. Restore user access quickly by reverting mapping execution to USER context (previous GPO behavior) or running equivalent user-context mapping at sign-in.
2. If Intune must be retained, add retry/backoff and readiness checks so mapping runs only after Workstation service is running and network path is reachable.
3. Re-run mapping workflow for affected Finance endpoints and verify S: assignment.

## Preventive Actions
1. Add pre-deployment validation for script security context changes (USER vs SYSTEM) in change review.
2. Require readiness gates in drive-mapping automation: Workstation running, UNC reachable, and retry policy configured.
3. Add monitoring for script exit code 1 and Event 98 spikes after mapping jobs.