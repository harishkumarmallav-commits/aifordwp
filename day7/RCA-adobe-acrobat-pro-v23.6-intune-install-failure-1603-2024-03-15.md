# Root Cause Analysis (RCA)

## Incident Summary
- Incident: Intune Win32 deployment failure for Adobe Acrobat Pro v23.6
- Package: AdobeAcrobatPro.intunewin
- Failure date: 2024-03-15
- RCA date: 2026-08-12
- Environment: Windows 11 endpoint(s), Intune app install context SYSTEM

## Executive Conclusion
Adobe Acrobat Pro v23.6 installation repeatedly failed with MSI exit code 1603, and post-install detection used a Reader-oriented registry key (`HKLM\SOFTWARE\Adobe\Acrobat Reader\23.0`) that did not match expected Pro detection artifacts. The deployment therefore remained in failed/not-detected state and entered hourly retry loops.

## Scope and Impact
- Affected service: Endpoint software deployment via Intune Win32 apps.
- User impact: Targeted users did not receive usable Adobe Acrobat Pro v23.6.
- Operational impact: Repeated Intune retries increased noise and delayed completion.

## Supporting Evidence

### Primary facts from the provided log
- `10:01:00` Start app install for Adobe Acrobat Pro v23.6.
- `10:01:01` Install context: SYSTEM.
- `10:01:03` Install command: `msiexec /i AcrobatPro.msi /quiet`.
- `10:01:44` Return code: `1603`; install failed.
- `10:01:45` Detection rule path: `HKLM\SOFTWARE\Adobe\Acrobat Reader\23.0`; value not found.
- `10:01:46` Detection result: Not detected.
- `10:01:47` Retry scheduled in 60 minutes.
- `11:01:47` Retry attempt 1 starts.
- `11:02:31` Retry attempt 1 returns `1603`.

### Evidence interpretation (fact-based)
- Repeated 1603 across attempts indicates persistent install failure, not transient delivery issue.
- Detection target references Reader path while app is Pro, indicating likely detection-rule mismatch.
- Retry cadence confirms endpoint remains in unresolved fail state.

## Timeline

| Time | Event | Evidence |
|---|---|---|
| 2024-03-15 10:01:00 | Installation initiated | AgentExecutor start event |
| 2024-03-15 10:01:44 | Installer returned fatal error | MSI return code 1603 |
| 2024-03-15 10:01:45 | Detection evaluated as not installed | Reader registry key not found |
| 2024-03-15 10:01:47 | Retry scheduled | 60-minute retry set |
| 2024-03-15 11:01:47 | Retry attempt started | Retry attempt 1 event |
| 2024-03-15 11:02:31 | Retry failed again | MSI return code 1603 |
| 2026-08-12 | RCA documented | Current analysis date |

## 5 Whys Analysis
1. Why did deployment fail?
- Because the installer returned MSI 1603.

2. Why did Intune still mark app as not installed?
- Because detection evaluated to Not detected.

3. Why did detection fail even in this Pro deployment context?
- Because detection checked a Reader-specific registry path, likely not the correct Pro install artifact.

4. Why did issue persist across retries?
- Because retries used unchanged install command and unchanged detection rule.

5. Why was this not prevented before broader deployment?
- Because validation gate did not fully verify both install completion and product-correct detection mapping before assignment scale-up.

## Confirmed Root Cause
Combined failure condition:
1. Persistent installer failure (MSI 1603) under SYSTEM context.
2. Detection-rule mismatch (Reader registry path used for Pro deployment), causing Not detected outcomes and repeated retry behavior.

## Contributing Factors
- Lack of verbose MSI logging in initial install command reduced immediate diagnosability.
- Detection rule quality check did not confirm product-accurate artifact before rollout.

## Corrective Actions
1. Replace detection rule with Pro-specific file/version or registry artifact validated on known-good install.
2. Add verbose MSI logging to install command (`/L*v`) and collect logs on pilot devices.
3. Validate command execution in SYSTEM context on representative endpoints.
4. Resolve discovered 1603 blocker (conflict/prerequisite/reboot/path) from log evidence.
5. Resume rollout only after validation ring meets success thresholds.

## Verification of Resolution
Resolution is confirmed when all are true:
- Validation ring install success meets target threshold and remains stable for monitoring window.
- Failed installs no longer dominated by 1603.
- Detection reports installed for successfully installed Pro endpoints.
- Hourly retry loop pattern is no longer observed on remediated devices.

## Preventive Actions
1. Add pre-release checklist item: detection artifact must match exact product edition (Pro vs Reader).
2. Standardize Win32 install commands to include verbose logging for all pilot-phase deployments.
3. Add rollout gate requiring successful install + successful detection on pilot sample before expansion.
4. Create known-error mapping for MSI 1603 with triage decision tree and fast containment actions.

## Ownership and Follow-up
- Endpoint Engineering: package and detection correction.
- Intune Operations: assignment containment and controlled redeployment.
- Service Desk: incident tagging and volume monitoring during re-release.

## Closure Criteria
RCA can be closed when:
- Pro deployment succeeds in pilot with corrected detection and no recurring 1603 trend.
- Rollout resumes without repeat retry-loop failure pattern.
- Preventive checklist controls are published and adopted for future Win32 app releases.
