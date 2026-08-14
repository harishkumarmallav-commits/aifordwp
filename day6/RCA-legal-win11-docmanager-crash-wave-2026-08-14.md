# Root Cause Analysis (RCA)

## Incident Summary
- Incident: App crash wave in Legal (Floor 6)
- Affected group: `Legal-Win11`
- Total devices in scope: 45
- Incident date: 2024-03-25 (morning)
- RCA date: 2026-08-14
- Related change: `Legal Document Manager v2.1` deployment via SCCM

## Executive Conclusion
The crash wave was triggered by deployment of `Document Manager v2.1` at 09:38-09:44 to all 45 Legal devices. The new v2.1 auto-save indexing behavior caused high disk I/O and intermittent application crashes during initial indexing, with strongest impact expected on sub-8GB devices (notably the 4GB cohort).

## Scope and Impact
- Service impact: Legal users experienced degraded endpoint experience and app instability.
- Telemetry impact:
  - DEX score dropped from ~90 baseline (08:00-09:00) to 58 at 10:00 and 55 at 11:00.
  - App crash rate rose from <=0.2% baseline to 6.2%-6.8%.
  - Disk I/O shifted from Normal to High during degradation window.
- Crash attribution: `DocManager.exe` produced 74% of all crashes between 10:00 and 11:00.
- At-risk hardware segment: 18 of 45 devices (40%) have 4GB RAM and match vendor risk condition (<8GB).

## Supporting Evidence

### Source 1: Nexthink DEX export
- Clear baseline before change (08:00-09:00).
- Sharp deterioration beginning at 10:00.
- Process concentration on `DocManager.exe` (74%).
- High disk I/O concurrent with crash spike.

### Source 2: SCCM deployment log
- 09:38:20 deployment start for v2.1 to all 45 devices.
- 09:44:07 deployment complete with 45/45 success and 0 failures.

### Vendor release notes
- v2.1 known limitation explicitly describes:
  - high disk I/O
  - intermittent crashes
  - first few hours post-install
  - elevated risk on devices with <8GB RAM

## Correlated Timeline

| Time | Event | Evidence | Interpretation |
|---|---|---|---|
| 08:00 | DEX 91, crashes 0.1%, disk I/O Normal | Nexthink | Healthy baseline. |
| 09:00 | DEX 90, crashes 0.2%, disk I/O Normal | Nexthink | Still stable before software change. |
| 09:38:20 | v2.1 deployment starts to 45 devices | SCCM | Controlled, fleet-wide change begins. |
| 09:44:07 | v2.1 deployment completes 45/45 success | SCCM | Entire fleet exposed to new runtime behavior. |
| 10:00 | DEX 58, crashes 6.2%, disk I/O High | Nexthink | Degradation starts shortly after change completion. |
| 10:00-11:00 | `DocManager.exe` = 74% of crashes | Nexthink | Fault localized to updated application. |
| 11:00 | DEX 55, crashes 6.8%, disk I/O High | Nexthink | Ongoing post-install instability. |

## 5 Whys
1. Why did users experience a crash wave?
- App crashes increased abruptly and substantially in Legal-Win11 after 10:00.

2. Why did crashes spike at that time?
- `Document Manager v2.1` was deployed to all 45 devices and completed at 09:44, just before the spike.

3. Why is v2.1 implicated instead of general endpoint instability?
- `DocManager.exe` accounted for 74% of crash events, concentrating failure in the updated app.

4. Why did disk I/O become high concurrently?
- Vendor indicates v2.1 auto-save indexing can drive high disk I/O during initial index build.

5. Why was Legal particularly vulnerable?
- 40% of fleet has 4GB RAM, meeting vendor risk condition (<8GB) for crash-prone indexing behavior.

## Confirmed Root Cause
`Document Manager v2.1` introduced an auto-save indexing behavior that, during first-hours post-installation, caused high disk I/O and intermittent crashes, producing a measurable crash wave in the Legal-Win11 fleet.

## Contributing Factors
1. Full-fleet simultaneous deployment (45/45) increased blast radius.
2. No memory-tiered ring deployment to isolate low-RAM devices first.
3. Known vendor limitation was present before broad production rollout.

## What Is Not the Root Cause
- SCCM deployment execution failure (not supported; deployment succeeded 45/45 with 0 failures).
- Pre-existing baseline instability (not supported; 08:00-09:00 was stable).

## Corrective Actions
1. Stop additional v2.1 expansion outside Legal until mitigations are in place.
2. Contain Legal impact for 4GB devices (18 endpoints): rollback to v2.0 or apply vendor-approved switch to suppress/limit indexing.
3. Keep only controlled pilot usage on 8GB devices while tracking telemetry.
4. Engage vendor for hotfix or configuration guidance for low-memory endpoints.
5. Re-issue rollout using rings by hardware class (4GB deferred, 8GB pilot, then wider release).

## Preventive Actions
1. Add pre-deployment compatibility gate: block broad rollout when release notes include known hardware limitations affecting >10% of target fleet.
2. Add mandatory ring strategy in SCCM: pilot by RAM tier, then phased expansion.
3. Add telemetry guardrails for automatic hold:
- If crash rate increases above threshold (for example >1%) or DEX drops below threshold within 60-120 minutes, pause rollout.
4. Require release-readiness checklist to include vendor known limitations and explicit mitigation plan.
5. Publish service desk advisory playbook for post-deployment crash waves tied to known app behaviors.

## Validation Criteria for Closure
RCA can be closed when:
- Crash rate in Legal-Win11 returns to normal band (near pre-change baseline).
- DEX recovers from 55-58 range back to normal operating range.
- Disk I/O trend returns to Normal during business hours.
- `DocManager.exe` no longer dominates crash telemetry.
- Deployment process updated with memory-tiered ring control and telemetry auto-hold.

## Ownership
- Endpoint Engineering: deployment ring design and telemetry guardrails.
- Application Packaging: release readiness and vendor limitation assessment.
- Service Operations: monitoring, incident response, and communication playbook.
- Problem Management: recurrence tracking and control effectiveness review.
