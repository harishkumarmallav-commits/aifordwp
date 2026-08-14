# Hypothesis Analysis - FLR6-AUTH-002 Login Failures

**Incident:** FLR6-AUTH-002  
**Date:** 2026-08-14  
**Weighting Rule:** Friday deployment timing is heavily weighted in ranking.

---

## Scope Facts
- 12+ Floor 6 users reported failed or very slow logins Monday morning.
- Symptoms emerged after Friday afternoon document management app deployment (~36-hour correlation window).
- Impact appears localized to the Floor 6 target scope in initial triage.
- Failure mode includes both hard failures and severe delay (>60s), suggesting startup or dependency contention.

Reasoning baseline:
- A time-bound, floor-bound incident after targeted deployment increases prior probability of deployment-linked causes over unrelated platform-wide outages.

---

## Top 5 Hypotheses (Ranked)

## Hypothesis 1 (Most Likely)
### App added to login/startup path and blocking authentication completion

Why this fits:
- Explains mixed symptom pattern (timeouts for some, long delays for others).
- Matches targeted Floor 6 deployment scope and timing.
- Startup-path bottlenecks commonly present as "auth issue" even when identity platform is healthy.

Fastest validation check:
1. Inspect startup entries/services/tasks created by Friday deployment.
2. Test one affected device in Safe Mode or with app startup disabled.
3. Compare login duration before/after disabling app startup.

Evidence supporting:
- Strong temporal linkage to Friday rollout.
- Localized scope consistent with deployment targeting.
- Existing ranked differential already places startup integration highest.

Evidence contradicting:
- No startup/task/service changes from deployment.
- Login delay persists after disabling app startup.
- Same problem appears on unaffected non-deployed devices.

---

## Hypothesis 2
### Group Policy change deployed Friday introduced logon script/policy delay

Why this fits:
- GPO can slow sign-in and alter user environment quickly at next logon.
- Could affect many users in same OU/security group simultaneously.

Fastest validation check:
1. Review Friday AD/GPO change logs (Event ID 5136 and GPO version deltas).
2. Run gpresult on affected and unaffected devices.
3. Measure policy processing time in logon events.

Evidence supporting:
- Same-floor user-group clustering.
- Timing fits next-login policy application behavior.

Evidence contradicting:
- No Friday GPO changes for target OU/group.
- Policy processing times normal.
- Problems persist when suspect policy is unlinked/rolled back.

---

## Hypothesis 3
### Roaming profile or profile service synchronization delay

Why this fits:
- Profile load failures can look like auth failure and increase login time dramatically.
- Could be amplified by deployment increasing profile data or profile hooks.

Fastest validation check:
1. Confirm roaming/folder-redirection usage.
2. Review profile-service and file-server logs during incident window.
3. Compare login behavior with local profile test.

Evidence supporting:
- Co-occurring user-profile symptoms in related stream (missing shortcuts).
- Delay behavior consistent with profile mount/sync bottleneck.

Evidence contradicting:
- Local-profile users show same issue.
- No profile server latency/errors.
- No profile-related events during failed logins.

---

## Hypothesis 4
### Network/firewall change linked to deployment disrupted auth traffic from Floor 6

Why this fits:
- Segment-specific filtering can delay Kerberos/LDAP and produce timeouts.
- Could align with floor-localized impact if only one segment changed.

Fastest validation check:
1. Diff firewall/proxy changes from Friday change window.
2. Validate connectivity/latency to DC/Entra endpoints from Floor 6 devices.
3. Check deny logs for auth-related ports/endpoints.

Evidence supporting:
- Floor-local scope suggests segment-specific configuration possibility.
- Deployment may have included network prerequisites.

Evidence contradicting:
- No relevant network changes Friday.
- Normal latency and no denies on auth paths.
- Issues reproduce off Floor 6 network.

---

## Hypothesis 5
### Authentication platform incident (AD/Entra outage) coincidental to deployment

Why this fits:
- Can produce failures and delays broadly.
- Always must be checked early despite lower prior probability here.

Fastest validation check:
1. Check AD replication/DC health and Entra service health.
2. Compare sign-ins from other floors during same window.
3. Review auth failure event distribution by location.

Evidence supporting:
- Broad multi-floor or org-wide sign-in failures.
- Platform health alerts in same time window.

Evidence contradicting:
- Impact appears constrained to deployment cohort/Floor 6.
- No platform health alarms or replication failures.
- Recovery follows app rollback instead of platform remediation.

---

## Most Likely Hypothesis
**Hypothesis 1: deployment-introduced startup/login-path interference.**

Why:
- Best explains timing, scope, and symptom shape with least assumptions.
- Directly testable quickly and actionable (disable/rollback startup integration).
- Consistent with evidence pattern across triage and differential analysis.

---

## Why Other Hypotheses Were Deprioritized
- **Hypothesis 2:** plausible but secondary until change logs confirm GPO edits aligned to affected cohort.
- **Hypothesis 3:** credible contributor, especially with profile symptoms, but less direct than startup-path interference.
- **Hypothesis 4:** possible for floor-local impact, but currently lacks direct evidence of Friday network rule changes.
- **Hypothesis 5:** essential to rule out quickly, but least consistent with floor-targeted post-deployment pattern.

---

## Rapid Validation Sequence
1. Disable/remove app startup hook on one affected device and retest.
2. Validate AD/Entra health and cross-floor sign-in behavior.
3. Pull Friday GPO/network change diffs.
4. Check profile-service events for corroborating delays.
