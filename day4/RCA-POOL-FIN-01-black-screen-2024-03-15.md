# Root Cause Analysis (RCA)

## Incident Summary
- Incident: Black screen after login on AVD hosts in POOL-FIN-01.
- Date of incident: 2024-03-15.
- User impact window: Approximately 07:00 to 10:00.
- Resolution confirmed: 10:00.
- Current status: Resolved. Verified users can log in to POOL-FIN-01 hosts with no further issues reported.

## Business Impact
- Approximately 40% of users assigned to POOL-FIN-01 experienced post-login black screen behavior.
- For some users, the black screen cleared after around 30 seconds.
- For others, sessions disconnected or repeatedly failed before successful access.
- POOL-FIN-02 users were unaffected.

## Scope and Change Correlation
- Affected pool: POOL-FIN-01.
- Unaffected pool: POOL-FIN-02.
- Material change: Overnight image update applied at 02:00 to POOL-FIN-01 only.
- No equivalent image update was applied to POOL-FIN-02.

This A/B difference was the strongest early indicator that the fault was introduced by the new POOL-FIN-01 image path.

## Supporting Evidence

### 1) Affected host evidence (SHFIN-01-A)
From incident window 07:00-07:30:

- 07:02:10 - Event 21 (TerminalServices-LocalSessionManager)
  - Session logon succeeded for FINBRIDGE\\mlopez (Session ID 3).

- 07:02:14 - Event 1 (Kernel-General)
  - Boot time logged as 02:03:11.
  - Confirms host restart after overnight image update.

- 07:02:16 - Event 1000 (Application Error)
  - Faulting app: dwm.exe
  - Faulting module: igdumd64.dll
  - Exception: 0xc0000005

- 07:02:17 - Event 40 (TerminalServices-LocalSessionManager)
  - Session disconnected (Reason code 0).

- 07:02:18 - Event 9009 (Desktop Window Manager)
  - DWM exited with error code 0x40010004.

- 07:02:44 - Event 21
  - Reconnect logon succeeded (same user/session flow).

- 07:02:46 - Event 1000
  - Repeat dwm.exe crash in igdumd64.dll.

- 07:02:47 - Event 40
  - Session disconnected again.

- 07:03:01 - Event 9009
  - DWM exited again.

- 07:03:10 - Event 21
  - Subsequent reconnect succeeded.

- 07:08:22 - Event 21
  - Another user logon succeeded (FINBRIDGE\\akapoor).

- 07:08:24 - Event 1000
  - Repeat dwm.exe crash in igdumd64.dll.

Interpretation:
- The repeated sequence of logon success followed by DWM crash in Intel graphics module and disconnect indicates a rendering stack instability immediately after interactive session initialization.

### 2) Unaffected comparison host evidence (SHFIN-02-A, POOL-FIN-02)
- Image version: 10.0.22621.2861-build-20240313 (pre-update).
- 07:01:44 - Event 21
  - Session logon succeeded.
- 07:01:46 - Event 9011 (Desktop Window Manager)
  - DWM started successfully.
- No Application Error Event 1000 entries in same window.

Interpretation:
- Stable DWM startup and absence of crashes on the non-updated pool host strongly supports image-linked regression in POOL-FIN-01.

## Timeline (Detailed)
- 02:00 - Overnight image update initiated for POOL-FIN-01.
- 02:03:11 - Affected host SHFIN-01-A booted post-update (confirmed by Event 1 at 07:02:14).
- ~07:00 - User-visible incident begins as morning logons increase.
- 07:02:10 - First captured affected session logon succeeds (Event 21).
- 07:02:16 - First captured dwm.exe crash in igdumd64.dll (Event 1000).
- 07:02:17 - Session disconnect occurs (Event 40).
- 07:02:18 - DWM exits with error (Event 9009).
- 07:02:44 to 07:03:10 - Reconnect cycle repeats with same crash/disconnect pattern.
- 07:08:24 - Similar crash pattern observed for additional user, confirming repeatability.
- Incident triage phase - Initial hypothesis set built from pool-specific blast radius and timing.
- Evidence analysis phase - Event logs used to eliminate non-matching hypotheses and isolate graphics stack regression.
- Mitigation/remediation phase - Proposed rendering/driver-focused fix path applied to POOL-FIN-01.
- 10:00 - Service validation complete; issue resolved and users successfully logging in without reports of recurrence.

## Hypothesis Elimination Record
Initial ranked hypotheses were:
1. Post-image shell/logon pipeline regression.
2. Subset of POOL-FIN-01 hosts in bad post-update state.
3. FSLogix/profile attach failure introduced by updated image.
4. GPO/logon script/task delay from new image baseline.
5. Graphics/rendering stack regression from updated image.

Evidence-based disposition:
- Graphics/rendering stack regression: Supported.
  - Driven by repeated Event 1000 (dwm.exe -> igdumd64.dll), paired Event 9009, and unaffected pool comparison Event 9011.
- Shell/logon pipeline delay: Contradicted as primary cause.
  - Crash signatures indicate hard rendering fault, not just shell startup delay.
- FSLogix/profile attach issue: Contradicted by available evidence.
  - No profile attach failures observed in provided dataset; crash chain is graphics-centric.
- GPO/logon script delay: Contradicted by available evidence.
  - Immediate crash/disconnect pattern after successful logon points away from synchronous policy delay as primary trigger.
- Partial host drift subset: Neutral-to-supporting context only.
  - Could coexist operationally, but not required to explain observed failure chain.

## Root Cause Statement
The incident was caused by a graphics/rendering regression introduced with the POOL-FIN-01 overnight image update. On affected POOL-FIN-01 hosts, Desktop Window Manager (dwm.exe) repeatedly crashed in Intel graphics module igdumd64.dll during post-login session initialization, producing black screen symptoms and session instability. POOL-FIN-02 remained unaffected because it was on the prior image baseline and did not include the regressed rendering stack path.

## 5 Whys Analysis
1. Why did users see black screens and disconnects after login?
- Because the desktop composition process (DWM) crashed during session initialization.

2. Why did DWM crash?
- Because dwm.exe faulted in igdumd64.dll with access violation (Event 1000, 0xc0000005).

3. Why was this graphics fault present in POOL-FIN-01 sessions?
- Because the overnight POOL-FIN-01 image update introduced a regressed graphics/rendering stack path.

4. Why was the regressed stack promoted into production?
- Because pre-production validation did not detect DWM stability issues under real AVD multi-user login/reconnect conditions.

5. Why did validation fail to detect it early?
- Because release gating lacked explicit event-based checks for DWM crash signatures and lacked an enforced canary soak before broad pool exposure.

## Resolution Actions Implemented
- Contained impact by steering users away from unstable session behavior while remediation was applied.
- Applied rendering/driver-focused corrective actions on POOL-FIN-01 hosts/image path.
- Validated with user logins on POOL-FIN-01 and monitored for recurrence indicators.
- Confirmed recovery at 10:00 with no new user-reported issues.

## Validation and Exit Criteria
Resolution considered complete when all criteria were met:
- Users successfully log in to POOL-FIN-01 hosts.
- No recurring black screen reports after remediation.
- No repeat crash chain observed in validation window:
  - Event 1000 (dwm.exe fault in igdumd64.dll)
  - Event 9009 (DWM exit)
  - Associated Event 40 disconnect bursts

## Preventive and Corrective Actions (CAPA)

### Immediate hardening
- Enforce canary rollout for AVD image updates (small host ring before full pool).
- Add automatic post-image smoke tests that perform repeated logon and reconnect cycles.
- Add alerting for DWM instability signatures:
  - Event 1000 (dwm.exe + igdumd64.dll)
  - Event 9009 spikes
  - Correlated Event 40 burst after Event 21 logons

### Process improvements
- Introduce release gate requiring zero critical graphics session crashes during soak.
- Require A/B comparison against unchanged control pool for every image promotion.
- Add rollback trigger thresholds tied to early crash-rate signals in first login wave.

### Platform controls
- Pin known-good graphics driver/component versions in image pipeline.
- Block unverified driver drift during post-build customization.
- Document and enforce a fast rollback playbook at pool level.

## Ownership and Follow-ups
- Incident owner: DWWP Engineering.
- Follow-up 1: Update image release checklist with DWM/graphics validation controls.
- Follow-up 2: Implement event correlation dashboard for Event 21/40/1000/9009.
- Follow-up 3: Perform retrospective review of recent image updates for similar hidden regressions.

## Lessons Learned
- A clean unaffected control pool is critical evidence and should be used early in triage.
- Repeated crash signatures can eliminate broad hypotheses quickly and reduce time-to-mitigation.
- For AVD, graphics pipeline stability must be a first-class release criterion, not a post-incident check.
