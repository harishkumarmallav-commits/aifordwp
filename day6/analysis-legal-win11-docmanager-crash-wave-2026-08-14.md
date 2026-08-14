# Analysis: Legal-Win11 App Crash Wave Linked to Document Manager v2.1 Deployment

Date: 2026-08-14  
Incident window: 2024-03-25 08:00-11:00  
Device group: Legal-Win11 (45 devices)

## 1) Scope Facts (From Both Sources)

### Nexthink DEX facts
- Population monitored: 45 devices in `Legal-Win11`.
- Baseline period:
  - 08:00: DEX 91, app crash rate 0.1%, disk I/O Normal
  - 09:00: DEX 90, app crash rate 0.2%, disk I/O Normal
- Degradation period:
  - 10:00: DEX 58, app crash rate 6.2%, disk I/O High
  - 11:00: DEX 55, app crash rate 6.8%, disk I/O High
- Top crashing process during 10:00-11:00: `DocManager.exe` (74% of all crashes in that window).

### SCCM deployment facts
- 09:38:20: Deployment started: `Legal Document Manager v2.1` to `Legal-Win11` (45 devices).
- 09:44:07: Install completed on 45/45 devices.
- 09:44:07: Install result: Success (0 failures).
- Previous stable version: `Document Manager v2.0` (stable for 6 weeks).

### Vendor release note facts
- v2.1 introduces auto-save.
- Known limitation: devices with under 8GB RAM may experience high disk I/O and intermittent crashes during first few hours while initial index builds.

### Hardware distribution facts
- Fleet composition (45 devices):
  - 8GB RAM: 60% (27 devices)
  - 4GB RAM: 40% (18 devices)

## 2) Correlated Timeline (Joined Evidence)

| Time | Event | Source | Correlated Meaning |
|---|---|---|---|
| 08:00-09:00 | Environment stable (DEX ~90, crash <=0.2%, disk I/O Normal) | Nexthink | Pre-change baseline shows no active crash wave before deployment. |
| 09:38:20 | v2.1 deployment starts to all 45 devices | SCCM | Single change event introduced across full legal fleet. |
| 09:44:07 | Deployment completes successfully on 45/45 | SCCM | Confirms broad and near-simultaneous exposure to v2.1. |
| 10:00 | DEX drops to 58, crashes jump to 6.2%, disk I/O High | Nexthink | Major degradation begins ~16 minutes after install completion. |
| 10:00-11:00 | `DocManager.exe` = 74% of crashes | Nexthink | Crash concentration points to deployed app, not random multi-app instability. |
| 11:00 | DEX falls further to 55, crash rate 6.8%, disk I/O remains High | Nexthink | Pattern persists through early post-install period, matching vendor warning window. |

## 3) Correlation Assessment

The two data sources are consistent and complementary:
- SCCM proves the exact change, audience, and completion time.
- Nexthink proves immediate user-experience degradation and process-level crash concentration.
- Vendor notes provide a matching mechanism (auto-save indexing on low-memory devices -> high disk I/O + intermittent crashes).

This is not just temporal coincidence:
- There is a clean before/after difference within the same morning.
- The dominant crashing process is the exact app that was updated.
- The degradation signal (High disk I/O) matches the known v2.1 limitation.

## 4) Impact Quantification (Best-Evidence Estimate)

Known facts:
- Exposed devices: 45/45.
- Lower-memory risk cohort (<8GB): 18/45 devices.
- Crash signal at group level increased from <=0.2% baseline to 6.2%-6.8% after rollout.
- 74% of crash events in the degraded window came from `DocManager.exe`.

Interpretation:
- Immediate incident scope: Legal floor fleet-wide user experience degradation was observable at telemetry level.
- Most likely severe-impact subset: 4GB cohort (18 devices), based on vendor limitation.
- Residual/minor impact likely also affected parts of 8GB cohort due to full-fleet rollout and first-hours indexing load.

## 5) Confirmed Findings

1. A major crash wave began in the first telemetry interval after successful v2.1 deployment.
2. `DocManager.exe` became the dominant crash source (74%) in the degradation window.
3. High disk I/O emerged concurrently with the crash spike and DEX decline.
4. The observed pattern aligns with the vendor-documented v2.1 known limitation for low-memory devices.

## 6) Confidence Statement

Confidence in causal link: High.

Reason:
- Strong temporal alignment (install complete 09:44, degradation visible by 10:00).
- Process specificity (`DocManager.exe` dominates crashes).
- Mechanism match (high disk I/O + first-hours window + low-RAM susceptibility).
- No contradicting evidence in provided sources.

## 7) Immediate Operational Actions (Recommended)

1. Pause further v2.1 rollout to other collections pending mitigation.
2. Prioritize containment on the 4GB cohort (18 devices): temporary rollback to v2.0 or disable/limit auto-save indexing if vendor supports switch.
3. Keep v2.1 on selected 8GB pilot subset only while monitoring crash rate and disk I/O.
4. Request vendor hotfix/config guidance for indexing behavior on <=4GB endpoints.
5. Define go/no-go threshold for re-release (for example: crash rate <=0.5% and DEX recovery to normal band for 24 hours).

## 8) Resolution Direction

Primary resolution path is application-focused (v2.1 behavior under memory pressure), not SCCM delivery-focused.
SCCM delivery was successful; post-install runtime behavior is the failure domain.
