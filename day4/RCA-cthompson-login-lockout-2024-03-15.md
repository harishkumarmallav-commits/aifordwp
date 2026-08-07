# Root Cause Analysis (RCA)

## Incident Summary
- Incident: User FINBRIDGE\cthompson unable to log in.
- Date of incident: 2024-03-15.
- User impact window: approximately 08:40 to 09:09.
- Resolution confirmed: 09:09.
- Current status: Resolved. User login to host verified with no issues reported.

## Business Impact
- Single-user impact: FINBRIDGE\cthompson could not access interactive desktop login during the incident window.
- No broader multi-user impact was provided in the incident evidence.

## Scope and Change Correlation
- Affected user: FINBRIDGE\cthompson only.
- Affected endpoint in evidence: DESKTOP-FB022.
- Reported change context: Nil.

## Supporting Evidence

### 1) Security log sequence on DESKTOP-FB022 (08:44-09:12)
- 08:44:01 - Event 4776 (Audit Failure)
  - Domain credential validation failed for FINBRIDGE\cthompson.
  - Error code 0xC000006A (wrong password).
  - Source workstation: DESKTOP-FB022.

- 08:44:03 - Event 4625 (Audit Failure)
  - FINBRIDGE\cthompson failed interactive logon type 2.
  - Failure reason: Unknown user name or bad password.
  - Source: DESKTOP-FB022.

- 08:44:28 - Event 4625 (Audit Failure)
  - Repeat interactive logon type 2 failure.
  - Failure reason: Unknown user name or bad password.
  - Source: DESKTOP-FB022.

- 08:44:55 - Event 4625 (Audit Failure)
  - Repeat interactive logon type 2 failure.
  - Failure reason: Unknown user name or bad password.
  - Source: DESKTOP-FB022.

- 08:44:56 - Event 4740 (Audit Failure)
  - Account FINBRIDGE\cthompson locked out.
  - Caller computer: DESKTOP-FB022.

- 08:45:10 - Event 4625 (Audit Failure)
  - Unlock attempt logon type 7 failed.
  - Failure reason: Account locked out.
  - Source: DESKTOP-FB022.

### 2) Additional authentication-failure source
- 08:45:44 - Event 4771 (Audit Failure)
  - Kerberos pre-authentication failed for FINBRIDGE\cthompson.
  - Failure code 0x18 (wrong password).
  - Source IP: 10.10.8.112.

- 08:46:01 - Event 4771 (Audit Failure)
  - Kerberos pre-authentication failed.
  - Failure code 0x18 (wrong password).
  - Source IP: 10.10.8.112.

- 08:46:33 - Event 4771 (Audit Failure)
  - Kerberos pre-authentication failed.
  - Failure code 0x18 (wrong password).
  - Source IP: 10.10.8.112.

### 3) Resolution confirmation events
- 09:08:14 - Event 4722 (Audit Success)
  - User account FINBRIDGE\cthompson enabled by FINBRIDGE\helpdesk-admin.

- 09:09:01 - Event 4624 (Audit Success)
  - FINBRIDGE\cthompson interactive logon type 2 succeeded.
  - Source: DESKTOP-FB022.

## Timeline (Detailed)
- ~08:40 - User-reported login issue begins.
- 08:44:01 - First captured wrong-password validation failure (Event 4776, 0xC000006A).
- 08:44:03 - First captured interactive logon failure (Event 4625, type 2).
- 08:44:28 - Second interactive failure (Event 4625, type 2).
- 08:44:55 - Third interactive failure (Event 4625, type 2).
- 08:44:56 - Account lockout recorded (Event 4740).
- 08:45:10 - Post-lockout unlock attempt fails (Event 4625, type 7, account locked out).
- 08:45:44, 08:46:01, 08:46:33 - Repeated Kerberos wrong-password failures from source IP 10.10.8.112 (Event 4771, 0x18).
- 09:08:14 - Account enabled by helpdesk admin (Event 4722).
- 09:09:01 - Successful interactive login to DESKTOP-FB022 (Event 4624, type 2).
- 09:09 - Incident marked resolved; user login verified and no further issues reported.

## Hypothesis Elimination Record
Initial ranked hypotheses were:
1. User credential mismatch (incorrect/outdated password at sign-in).
2. Account lockout triggered by failed attempts.
3. Account disabled/expired/restricted at account level.
4. Corrupt/failing local user profile path.
5. Stale cached credentials or secondary auth target using old secret.

Evidence-based disposition:
- User credential mismatch: Supported.
  - Event 4776 (08:44:01, 0xC000006A) and Event 4625 (08:44:03/08:44:28/08:44:55) show wrong-password failures.
- Account lockout: Supported.
  - Event 4740 (08:44:56) and Event 4625 (08:45:10, account locked out) confirm lockout state.
- Account disabled/expired/restricted: Contradicted by available evidence.
  - Provided events show wrong-password and lockout path, not disabled/expired status errors.
- Local profile failure: Contradicted by available evidence.
  - Failures occurred at authentication stage before successful sign-in.
- Stale cached credentials or secondary auth source: Supported and surviving hypothesis.
  - Repeated Event 4771 failures from 10.10.8.112 after lockout indicate a separate source continuing wrong-password submissions.

## Root Cause Statement
The incident was driven by repeated wrong-password authentication attempts for FINBRIDGE\cthompson that triggered account lockout, with continued wrong-password Kerberos pre-authentication failures from secondary source IP 10.10.8.112 during the same window. This aligns with stale cached credentials or a secondary authentication source using an outdated secret for the same account.

## Resolution Actions Implemented
- Applied the recommended resolution steps for lockout and stale-credential path.
- FINBRIDGE\helpdesk-admin enabled the account at 09:08:14 (Event 4722).
- Verified successful interactive user login at 09:09:01 from DESKTOP-FB022 (Event 4624 type 2).

## Validation and Exit Criteria
Resolution considered complete when:
- Account re-enabled event was recorded (Event 4722).
- Successful interactive login was recorded for FINBRIDGE\cthompson (Event 4624 type 2).
- User confirmed working and no further issues were reported.

## 5 Whys Analysis
1. Why could FINBRIDGE\cthompson not log in?
- Because authentication attempts failed and the account entered locked-out state.

2. Why did authentication attempts fail?
- Because wrong-password submissions were recorded (Event 4776 0xC000006A and Event 4771 0x18).

3. Why did the account become locked out?
- Because multiple failed interactive attempts on DESKTOP-FB022 preceded Event 4740 lockout.

4. Why did failures continue after lockout was reached?
- Because Kerberos pre-authentication failures continued from source IP 10.10.8.112.

5. Why was a second source still submitting wrong credentials?
- Evidence indicates a secondary source path using outdated credentials for the same account during the incident window.

## Preventive and Corrective Actions (CAPA)

### Immediate hardening
- Add a lockout triage step to identify all active failure sources for the affected account (workstation and source IPs) before unlock.
- On lockout incidents with multi-source failures, require credential cache/secret cleanup on each identified source before closure.

### Process improvements
- Standardize evidence capture for Event 4776/4625/4740/4771/4722/4624 in user lockout incidents.
- Add a mandatory verification checkpoint that confirms successful login event and user confirmation before ticket closure.

### Monitoring controls
- Implement targeted alerting for repeated Event 4771 wrong-password failures from a source different from the primary user workstation during lockout windows.
- Track recurring lockouts for the same user account and recurring offending source IPs for early intervention.

## Ownership and Follow-ups
- Incident owner: DWP Engineering.
- Follow-up 1: Add lockout runbook update covering secondary-source credential checks.
- Follow-up 2: Add event-correlation view for 4776/4625/4740/4771 -> 4722/4624 sequence.
- Follow-up 3: Review whether source IP 10.10.8.112 retains stale credentials for FINBRIDGE\cthompson.