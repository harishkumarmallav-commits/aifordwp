# Incident Analysis — AVD Black Screen: POOL-FIN-01
## Hypothesis Evaluation and Root Cause Determination

| Field              | Detail                                               |
|--------------------|------------------------------------------------------|
| **Incident date**  | 2024-03-15                                           |
| **Affected pool**  | POOL-FIN-01                                          |
| **Unaffected pool**| POOL-FIN-02                                          |
| **Impact window**  | ~07:00 – 10:00                                       |
| **Users affected** | ~40% of POOL-FIN-01 assigned users                  |
| **Authored by**    | DWP Analyst                                          |
| **Source documents**| avd-black-screen-analysis-hypothesis.md; RCA-POOL-FIN-01-black-screen-2024-03-15.md |

---

## 1. Incident Description

Users assigned to Azure Virtual Desktop pool POOL-FIN-01 reported black screens immediately after login beginning at approximately 07:00. For some users the black screen cleared after around 30 seconds; for others, sessions repeatedly disconnected or failed entirely. Users on POOL-FIN-02 were completely unaffected throughout the same window. The incident was resolved at 10:00.

---

## 2. Critical Scope Constraint

The single most diagnostic fact established at the outset:

> **POOL-FIN-01 received an overnight image update at 02:00. POOL-FIN-02 did not.**

This A/B difference immediately scoped the investigation to image-introduced regressions and allowed all tenant-wide or external platform causes to be deprioritised without requiring further evidence. Every hypothesis was evaluated against this constraint first.

---

## 3. Initial Hypotheses (Ranked)

Five candidate root causes were identified and ranked by probability at the start of triage:

| Rank | Hypothesis | Initial Confidence |
|------|-----------|-------------------|
| 1 | Post-image shell/logon pipeline regression (Explorer, AppReadiness, Winlogon startup) | High |
| 2 | Subset of POOL-FIN-01 hosts in a bad post-update state (partial rollout drift) | High |
| 3 | FSLogix/profile container attach delay or failure introduced by updated image | Medium |
| 4 | GPO/logon script/logon task delay from new image baseline | Medium |
| 5 | Graphics/rendering stack regression in updated image | Lower (least likely at outset) |

**Ranking rationale at triage time:** The 30-second recovery pattern favoured shell startup timing delays (Hypothesis 1). The 40%-not-100% impact pattern supported host-concentration drift (Hypothesis 2). The graphics regression (Hypothesis 5) was ranked lowest because delayed-then-clearing black screens were considered more consistent with startup timing issues than with rendering crashes.

---

## 4. Evidence Collected

### 4.1 Affected host: SHFIN-01-A (POOL-FIN-01)

Events captured during incident window 07:00–07:30:

| Time     | Event ID | Source                              | Detail |
|----------|----------|-------------------------------------|--------|
| 07:02:10 | 21       | TerminalServices-LocalSessionManager | Session logon succeeded — FINBRIDGE\mlopez (Session 3) |
| 07:02:14 | 1        | Kernel-General                       | Boot time: 02:03:11 — confirms host restarted after 02:00 image update |
| 07:02:16 | **1000** | Application Error                    | **dwm.exe crashed in igdumd64.dll — exception 0xc0000005 (access violation)** |
| 07:02:17 | 40       | TerminalServices-LocalSessionManager | Session disconnected (Reason code 0) |
| 07:02:18 | **9009** | Desktop Window Manager               | **DWM exited with error code 0x40010004** |
| 07:02:44 | 21       | TerminalServices-LocalSessionManager | Reconnect logon succeeded (same user/session) |
| 07:02:46 | 1000     | Application Error                    | Repeat dwm.exe crash in igdumd64.dll |
| 07:02:47 | 40       | TerminalServices-LocalSessionManager | Session disconnected again |
| 07:03:01 | 9009     | Desktop Window Manager               | DWM exited again |
| 07:03:10 | 21       | TerminalServices-LocalSessionManager | Subsequent reconnect succeeded |
| 07:08:22 | 21       | TerminalServices-LocalSessionManager | Second user logon succeeded — FINBRIDGE\akapoor |
| 07:08:24 | 1000     | Application Error                    | Repeat dwm.exe crash in igdumd64.dll |

**Pattern observed:** Every logon (Event 21) is immediately followed by a DWM crash in the Intel graphics module (Event 1000) → session disconnect (Event 40) → DWM exit (Event 9009). This sequence repeated across multiple users and reconnect attempts, confirming it is deterministic and not transient.

### 4.2 Unaffected comparison host: SHFIN-02-A (POOL-FIN-02)

Image version: `10.0.22621.2861-build-20240313` (pre-update baseline)

| Time     | Event ID | Source                    | Detail |
|----------|----------|---------------------------|--------|
| 07:01:44 | 21       | TerminalServices-LSM      | Session logon succeeded |
| 07:01:46 | **9011** | Desktop Window Manager    | **DWM started successfully** |
| — | No 1000 events | Application Error | Zero dwm.exe crashes in this window |

**Pattern observed:** Clean DWM startup (Event 9011), no crash chain. Directly contrasts with POOL-FIN-01 behaviour in the same time window.

---

## 5. Hypothesis Evaluation

### Hypothesis 1 — Shell/logon pipeline regression
**Disposition: Contradicted as primary cause.**

The crash evidence points to a hard rendering fault, not a startup timing delay. Event 1000 records a memory access violation (0xc0000005) in a graphics DLL — this is a code-level crash, not a slow initialisation path. If shell startup were the cause, we would expect Event 1000 to be absent and would instead see delays in Winlogon/AppReadiness/Explorer startup events. No such delays appear in the log; the session crashes immediately due to DWM failure, not because the shell was slow to start.

### Hypothesis 2 — Subset of hosts in bad post-update state
**Disposition: Neutral-to-supporting context only.**

The 40% user impact could partially reflect host assignment distribution — if only some POOL-FIN-01 hosts were in the worst crash state, users assigned to those hosts would be disproportionately affected. However, this does not explain the root cause; it describes the blast radius. The DWM crash chain was reproduced on the specific host examined (SHFIN-01-A) across multiple users, so the regression is at minimum host-level, possibly pool-wide. Hypothesis 2 can coexist with the confirmed root cause but is not an independent causal explanation.

### Hypothesis 3 — FSLogix/profile attach failure
**Disposition: Contradicted by available evidence.**

FSLogix failures produce profile attach errors that are logged in the FSLogix operational logs and typically manifest as profile-related Event IDs, not graphics crashes. The crash chain observed — dwm.exe → igdumd64.dll → 0xc0000005 — is entirely within the graphics rendering stack and has no connection to profile container operations. No profile attach failure events appear in the provided dataset.

### Hypothesis 4 — GPO/logon script/logon task delay
**Disposition: Contradicted by available evidence.**

GPO or logon script delays present as extended dark/black screens during synchronous policy processing, eventually resolving when policy completes. The evidence shows immediate crash-and-disconnect cycles beginning at 07:02:16 — just 6 seconds after logon success at 07:02:10. This is not consistent with a policy processing window; it is consistent with a rendering stack crash triggered at session initialisation. Crash signatures eliminate synchronous policy delay as the primary trigger.

### Hypothesis 5 — Graphics/rendering stack regression
**Disposition: Confirmed as root cause.**

This hypothesis was ranked least likely at triage but is the only one fully supported by the evidence:

- **Event 1000** (dwm.exe faulting in `igdumd64.dll` with 0xc0000005) is a direct, repeatable crash in the Intel graphics user-mode driver.
- **Event 9009** (DWM exit with 0x40010004) is the downstream consequence of the DWM process being killed by the crash.
- **Event 40** (session disconnect) is the user-visible result — DWM exiting causes the session composition stack to collapse, producing the black screen and disconnect.
- The crash reproduced deterministically across multiple users (mlopez, akapoor) and multiple reconnect attempts.
- **Event 9011** on the unaffected POOL-FIN-02 host shows clean DWM startup on the prior image version, directly contrasting with the crash chain on the updated image.
- The affected image was updated overnight; the unaffected image was not. No other variable differs between the two pools.

---

## 6. Root Cause Statement

The POOL-FIN-01 overnight image update introduced a regression in the graphics/rendering stack, specifically in the Intel graphics user-mode driver module `igdumd64.dll`. On POOL-FIN-01 hosts running the updated image, Desktop Window Manager (dwm.exe) crashed with a memory access violation (0xc0000005) at the point of post-login session rendering initialisation. This caused session disconnects and black screen behaviour for affected users. POOL-FIN-02 was unaffected because it retained the prior image baseline and `igdumd64.dll` was stable on that version.

---

## 7. Why the Initial Ranking Was Misleading

The graphics regression (Hypothesis 5) was ranked lowest at triage because:

- The 30-second recovery pattern for some users was interpreted as consistent with a startup timing delay, which is a common and familiar failure mode.
- Graphics regressions are less commonly the first-order cause of AVD black screen incidents versus logon pipeline or profile issues.

However, the event log evidence was unambiguous once examined. The lesson is that **symptom patterns at triage should be treated as probabilistic signals, not deterministic indicators** — the final diagnosis must follow the hard evidence, even when it conflicts with the initial ranking. In this case, Event 1000 with `igdumd64.dll` is a specific, non-ambiguous crash signature that overrides the softer symptom interpretation.

---

## 8. 5 Whys

| Why | Question | Answer |
|-----|----------|--------|
| 1 | Why did users see black screens and disconnects? | Because DWM crashed during session initialisation, collapsing the rendering stack. |
| 2 | Why did DWM crash? | Because dwm.exe faulted in igdumd64.dll with an access violation (0xc0000005). |
| 3 | Why was this fault present on POOL-FIN-01 hosts? | Because the overnight image update introduced a regressed Intel graphics driver component. |
| 4 | Why was the regressed component promoted to production? | Because pre-production image validation did not include DWM stability testing under real AVD multi-user logon and reconnect conditions. |
| 5 | Why did validation not cover this scenario? | Because the image release gate lacked explicit event-based checks for DWM crash signatures and did not enforce a canary soak period before full pool deployment. |

---

## 9. Key Diagnostic Signals (for Future Reference)

The following event combination is a high-confidence indicator of a graphics/rendering regression in an AVD environment:

```
Event 21  (TerminalServices-LSM)   — Session logon succeeded
  → Event 1000 (Application Error) — dwm.exe crashed in a graphics DLL
  → Event 40  (TerminalServices-LSM)— Session disconnected
  → Event 9009 (DWM)               — DWM exited with error
```

When this sequence repeats across multiple users within seconds of login, graphics stack regression should be promoted to the top of the hypothesis list immediately, regardless of initial symptom-based ranking.

Absence of **Event 9011** (DWM started successfully) in the post-logon window, when expected, is an equally strong signal.

---

## 10. Recommended Preventive Actions

| Priority | Action |
|----------|--------|
| High | Enforce canary rollout for all AVD pool image updates — deploy to a small host ring first, validate DWM stability, then promote to full pool. |
| High | Add automated post-image smoke tests that perform repeated logon/reconnect cycles and alert on Event 1000 (dwm.exe) or Event 9009 spikes. |
| Medium | Pin known-good graphics driver versions in the image pipeline; block unverified driver drift during post-build customisation steps. |
| Medium | Require an A/B comparison against an unchanged control pool as part of every image promotion gate. |
| Low | Build an event correlation dashboard monitoring the Event 21 → 1000 → 40 → 9009 crash chain in near real-time for early detection. |

---

*Analysis authored by: DWP Analyst | Based on: POOL-FIN-01 incident 2024-03-15 | Stored: day3*
