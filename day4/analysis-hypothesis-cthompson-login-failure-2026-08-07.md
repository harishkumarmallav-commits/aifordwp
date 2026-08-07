# User Logon Incident Analysis and Hypothesis

Date: 2026-08-07
Incident: User cthompson unable to log in

## Scope Facts Used
- Symptom: cthompson not able to login.
- Who: cthompson only (single-user impact).
- Since: ~08:40 this morning.
- Change: Nil.

## Ranked Likely Causes (Most Probable First)

### 1) User credential mismatch (incorrect or outdated password at sign-in)
Why this fits the scope facts:
- The impact is isolated to one user, which is consistent with a user-specific credential issue.
- No reported environmental change reduces the likelihood of a broad platform fault.

Single fastest check:
- Check Security log/domain auth events for cthompson around 08:40 for failed logon reason indicating bad password/unknown username (for example, failed-auth events and failure reason text).

### 2) Account lockout triggered by failed attempts
Why this fits the scope facts:
- Single-user lockouts are common and align with the one-user-only scope.
- Onset at a specific time (~08:40) matches a threshold-based lockout trigger point.

Single fastest check:
- Check directory/security events for an account lockout event for cthompson and confirm lockout state in the identity directory.

### 3) Account disabled/expired/restricted at account level
Why this fits the scope facts:
- A user-level account status problem would affect only cthompson while other users continue normally.
- No environment change is required for this to occur if account lifecycle conditions were reached.

Single fastest check:
- Inspect cthompson account properties (enabled/disabled, expiry, logon-hour/workstation restrictions) in the identity directory.

### 4) Corrupt or failing local user profile path for cthompson on target endpoint/session host
Why this fits the scope facts:
- A profile issue can present as "cannot log in" for one user only, with no wider user impact.
- No global change is needed for a single profile to become unusable.

Single fastest check:
- Review endpoint/session-host Application and User Profile Service logs for cthompson at first failure time for profile load failure events.

### 5) Stale cached credentials or mapped/secondary auth target using old secret for cthompson
Why this fits the scope facts:
- This can affect one user only and present as repeated login failure without any infrastructure change.
- Time-bounded start at ~08:40 is consistent with first sign-in attempt after credential drift.

Single fastest check:
- Verify whether failures originate from one endpoint and clear stored credentials for cthompson on that device, then retry once and compare auth event outcome.

## Current Position
No single root cause is confirmed yet. Keep all five hypotheses active until event evidence and account-state checks eliminate four paths.

---

## Event Evidence Addendum (Security Log)

Source: DESKTOP-FB022 security events during 2024-03-15 08:44-09:12.

- 08:44:01 - Event 4776 (Audit Failure): credential validation failed for FINBRIDGE\cthompson, error 0xC000006A (wrong password), source workstation DESKTOP-FB022.
- 08:44:03 - Event 4625 (Audit Failure): unknown user name or bad password, logon type 2 (interactive), source DESKTOP-FB022.
- 08:44:28 - Event 4625 (Audit Failure): unknown user name or bad password, logon type 2 (interactive), source DESKTOP-FB022.
- 08:44:55 - Event 4625 (Audit Failure): unknown user name or bad password, logon type 2 (interactive), source DESKTOP-FB022.
- 08:44:56 - Event 4740 (Audit Failure): account FINBRIDGE\cthompson locked out, caller computer DESKTOP-FB022.
- 08:45:10 - Event 4625 (Audit Failure): failure reason account locked out, logon type 7 (unlock attempt), source DESKTOP-FB022.
- 08:45:44 - Event 4771 (Audit Failure): Kerberos pre-auth failed, failure code 0x18 (wrong password), source IP 10.10.8.112.
- 08:46:01 - Event 4771 (Audit Failure): Kerberos pre-auth failed, failure code 0x18 (wrong password), source IP 10.10.8.112.
- 08:46:33 - Event 4771 (Audit Failure): Kerberos pre-auth failed, failure code 0x18 (wrong password), source IP 10.10.8.112.

Note: 10.10.8.112 differs from DESKTOP-FB022 (10.10.1.88).

## Hypothesis Elimination Update

1) User credential mismatch (incorrect or outdated password at sign-in)
- Judgement: Supports.
- Determining evidence: Event 4776 at 08:44:01 (0xC000006A wrong password) and Event 4625 at 08:44:03, 08:44:28, and 08:44:55 (unknown user name or bad password).

2) Account lockout triggered by failed attempts
- Judgement: Supports.
- Determining evidence: Event 4740 at 08:44:56 (account locked out) and Event 4625 at 08:45:10 (failure reason account locked out).

3) Account disabled/expired/restricted at account level
- Judgement: Contradicts.
- Determining evidence: Failure sequence is wrong-password then lockout (Event 4776 08:44:01, Event 4625 08:44:03/08:44:28/08:44:55, Event 4740 08:44:56) rather than disabled/expired status in the provided window.

4) Corrupt or failing local user profile path on target endpoint/session host
- Judgement: Contradicts.
- Determining evidence: Authentication-layer failures are recorded before sign-in completion (Event 4776 at 08:44:01 and Event 4625 at 08:44:03/08:44:28/08:44:55), with lockout at 08:44:56 (Event 4740).

5) Stale cached credentials or mapped/secondary auth target using old secret
- Judgement: Supports.
- Determining evidence: Repeated Event 4771 at 08:45:44, 08:46:01, and 08:46:33 from source IP 10.10.8.112, which differs from DESKTOP-FB022.

## Surviving Hypothesis

Stale cached credentials or a secondary authentication source is repeatedly submitting an old password for FINBRIDGE\cthompson (notably from 10.10.8.112), driving lockout recurrence after the initial bad-password sequence.

## Resolution Steps

1. Unlock FINBRIDGE\cthompson and temporarily stop new authentication attempts from 10.10.8.112 while cleanup is performed.
2. Confirm the pattern in logs: initial wrong-password and lockout from DESKTOP-FB022, then continued wrong-password Kerberos pre-auth failures from 10.10.8.112.
3. On DESKTOP-FB022, clear saved credentials related to FINBRIDGE resources, remove or refresh saved connections, then sign out/in.
4. On 10.10.8.112, remove saved credentials and update or stop any scheduled task, service, script, or background process using FINBRIDGE\cthompson old credentials.
5. If needed, reset cthompson password once and ensure the new password is entered only on trusted endpoints.
6. Validate by testing cthompson interactive login and monitoring for no new Event 4771 (0x18) from 10.10.8.112, no new Event 4776 wrong-password failures, and no new Event 4740 lockout for cthompson.

## Event Evidence Review (Incident Window 2024-03-15 08:44-09:12)
- 08:44:01 - Event 4776 (Audit Failure): FINBRIDGE\cthompson wrong password (0xC000006A) from DESKTOP-FB022.
- 08:44:03 - Event 4625 (Audit Failure): Interactive logon type 2 failed, unknown user name or bad password, source DESKTOP-FB022.
- 08:44:28 - Event 4625 (Audit Failure): Interactive logon type 2 failed, unknown user name or bad password, source DESKTOP-FB022.
- 08:44:55 - Event 4625 (Audit Failure): Interactive logon type 2 failed, unknown user name or bad password, source DESKTOP-FB022.
- 08:44:56 - Event 4740 (Audit Failure): FINBRIDGE\cthompson account locked out, caller computer DESKTOP-FB022.
- 08:45:10 - Event 4625 (Audit Failure): Unlock attempt logon type 7 failed, account locked out, source DESKTOP-FB022.
- 08:45:44 - Event 4771 (Audit Failure): Kerberos pre-auth failed (0x18 wrong password), source IP 10.10.8.112.
- 08:46:01 - Event 4771 (Audit Failure): Kerberos pre-auth failed (0x18 wrong password), source IP 10.10.8.112.
- 08:46:33 - Event 4771 (Audit Failure): Kerberos pre-auth failed (0x18 wrong password), source IP 10.10.8.112.

## Hypothesis Elimination Outcome
- Hypothesis 1 (user credential mismatch): Supported by Event 4776 at 08:44:01 and Event 4625 at 08:44:03/08:44:28/08:44:55.
- Hypothesis 2 (account lockout): Supported by Event 4740 at 08:44:56 and locked-out failure at Event 4625, 08:45:10.
- Hypothesis 3 (account disabled/expired/restricted): Contradicted by observed wrong-password and lockout sequence rather than disabled/expired account errors.
- Hypothesis 4 (local profile failure): Contradicted by authentication-layer failures before successful sign-in in the supplied window.
- Hypothesis 5 (stale cached credentials or secondary auth source using old secret): Supported by repeated Event 4771 failures from IP 10.10.8.112 at 08:45:44/08:46:01/08:46:33, distinct from DESKTOP-FB022.

## Surviving Hypothesis
The surviving hypothesis is stale cached credentials or a secondary authentication source repeatedly submitting an old password for FINBRIDGE\cthompson.

## Resolution and Verification Update
- 09:08:14 - Event 4722 (Audit Success): FINBRIDGE\helpdesk-admin enabled FINBRIDGE\cthompson.
- 09:09:01 - Event 4624 (Audit Success): FINBRIDGE\cthompson interactive logon type 2 succeeded from DESKTOP-FB022.
- Reported outcome: Suggested resolution steps were applied; issue resolved at 09:09 AM, user login verified on host, and no further issues reported.