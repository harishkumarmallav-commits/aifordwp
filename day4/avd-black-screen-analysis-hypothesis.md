# AVD Incident Analysis and Hypothesis

Date: 2026-08-06
Incident: Black screen after login in AVD

## Scope Facts
- Symptom: Blank screen post-login; clears after ~30 seconds for some users, persists for others.
- Who: ~40% of users on POOL-FIN-01. POOL-FIN-02 unaffected.
- Since: ~07:00 this morning.
- Change: Overnight image update to POOL-FIN-01 at 02:00. POOL-FIN-02 was not updated.

## Working Hypothesis
The issue is most likely tied to the POOL-FIN-01 image update and specifically affects post-login initialization behavior. The strongest indicator is that POOL-FIN-02, which did not receive the update, is fully unaffected.

## Ranked Likely Causes (Most Probable First)

### 1) Post-image logon pipeline regression (shell/AppReadiness/Explorer startup)
Why this fits:
- Directly aligned with pool-specific image change.
- Symptom timing (black screen immediately after login) matches delayed shell initialization.
- 30-second recovery for some users is consistent with delayed startup path; persistent cases fit timeout/hang variants.

Fastest check:
- Compare AppReadiness/AppX/Winlogon events at logon time on one affected POOL-FIN-01 host versus one unaffected POOL-FIN-02 host.

### 2) Subset of POOL-FIN-01 hosts in bad post-update state (partial rollout drift)
Why this fits:
- ~40% affected suggests host concentration rather than all sessions.
- Explains why behavior differs among users (depends on host assignment).
- Still fully consistent with update isolation to POOL-FIN-01.

Fastest check:
- Correlate incidents by session host name to see whether impacted users cluster on specific hosts.

### 3) FSLogix/profile container attach delay or failure introduced by updated image
Why this fits:
- Produces post-login black screen while profile attach retries happen.
- Can cause transient recovery for some and persistent black screen for others.
- Image update can alter service timing, driver/filter behavior, or profile handling.

Fastest check:
- Review FSLogix logs for affected users during login for attach latency/failure events.

### 4) GPO/logon script/logon task delay introduced by new image baseline
Why this fits:
- Image changes can alter startup tasks and policy processing behavior.
- Synchronous logon processing can present as temporary black screen.
- User-specific policy path differences can explain mixed impact.

Fastest check:
- Compare logon policy processing duration/errors (affected user on POOL-FIN-01 vs unaffected reference user).

### 5) Graphics/rendering stack regression in updated image
Why this fits:
- Can cause black screen during initial session rendering.
- Pool-specific update supports image-linked rendering issue.
- Less likely than logon pipeline/profile timing given the ~30-second clear pattern.

Fastest check:
- Compare graphics/RDP component versions and display-related event logs between affected and unaffected pool hosts.

## Explicit Timing-Clue Weighting
The ranking prioritizes causes that are directly explained by one changed variable: POOL-FIN-01 received a 02:00 image update, while POOL-FIN-02 did not and remains unaffected. This strongly increases confidence in image-linked causes and reduces likelihood of tenant-wide or external platform causes.

## Current Position
No single root cause is confirmed yet. Keep multiple hypotheses active until host/user correlation and log evidence narrow to one path.
