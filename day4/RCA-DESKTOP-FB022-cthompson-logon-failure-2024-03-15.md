# Root Cause Analysis (RCA)

## Incident Summary
- Incident: User FINBRIDGE\cthompson unable to log in.
- Affected endpoint context: DESKTOP-FB022 (interactive sign-in path).
- Incident window reviewed: 08:44-09:12 on 2024-03-15.
- Resolution time: 09:09 AM.
- Current status: Resolved. User login to host verified and no further issues reported.

## Business Impact
- Impact scope was a single user (cthompson).
- User could not complete login during the incident period until remediation was applied.

## Scope and Change Correlation
- Who was affected: FINBRIDGE\cthompson only.
- Reported start: approximately 08:40.
- Reported change: none.

## Supporting Evidence

### 1) Failure chain on DESKTOP-FB022
- 08:44:01 - Event 4776 (Security, Audit Failure)
  - FINBRIDGE\cthompson credential validation failed.
  - Error code: 0xC000006A (wrong password).
  - Source workstation: DESKTOP-FB022.

- 08:44:03 - Event 4625 (Security, Audit Failure)
  - Failure reason: Unknown user name or bad password.
  - Logon type: 2 (Interactive).
  - Source: DESKTOP-FB022.

- 08:44:28 - Event 4625 (Security, Audit Failure)
  - Failure reason: Unknown user name or bad password.
  - Logon type: 2 (Interactive).
  - Source: DESKTOP-FB022.

- 08:44:55 - Event 4625 (Security, Audit Failure)
  - Failure reason: Unknown user name or bad password.
  - Logon type: 2 (Interactive).
  - Source: DESKTOP-FB022.

- 08:44:56 - Event 4740 (Security, Audit Failure)
  - User account locked out.
  - Account: FINBRIDGE\cthompson.
  - Caller computer: DESKTOP-FB022.

- 08:45:10 - Event 4625 (Security, Audit Failure)
  - Failure reason: Account locked out.
  - Logon type: 7 (Unlock attempt).
  - Source: DESKTOP-FB022.

Interpretation:
- Initial wrong-password attempts on DESKTOP-FB022 triggered account lockout.

### 2) Secondary bad-password source after lockout
- 08:45:44 - Event 4771 (Security, Audit Failure)
  - Kerberos pre-authentication failed.
  - Failure code: 0x18 (wrong password).
  - Source IP: 10.10.8.112.

- 08:46:01 - Event 4771 (Security, Audit Failure)
  - Kerberos pre-authentication failed.
  - Failure code: 0x18 (wrong password).
  - Source IP: 10.10.8.112.

- 08:46:33 - Event 4771 (Security, Audit Failure)
  - Kerberos pre-authentication failed.
  - Failure code: 0x18 (wrong password).
  - Source IP: 10.10.8.112.

Observed difference:
- Secondary source IP 10.10.8.112 differs from DESKTOP-FB022 (10.10.1.88).

Interpretation:
- A secondary source continued submitting wrong credentials for the same account after lockout.

### 3) Resolution and recovery evidence
- 09:08:14 - Event 4722 (Security, Audit Success)
  - User account enabled.
  - Account: FINBRIDGE\cthompson.
  - Done by: FINBRIDGE\helpdesk-admin.

- 09:09:01 - Event 4624 (Security, Audit Success)
  - Successful logon.
  - Account: FINBRIDGE\cthompson.
  - Logon type: 2 (Interactive).
  - Source: DESKTOP-FB022.

Interpretation:
- Administrative recovery action was followed by successful interactive login and service restoration.

## Timeline (Detailed)
- ~08:40 - User-reported inability to log in begins.
- 08:44:01 - First captured wrong-password validation failure (Event 4776) on DESKTOP-FB022.
- 08:44:03 - 08:44:55 - Repeated interactive failures (Event 4625) on DESKTOP-FB022.
- 08:44:56 - Account lockout recorded (Event 4740).
- 08:45:10 - Unlock-attempt failure because account remained locked (Event 4625, type 7).
- 08:45:44 - 08:46:33 - Repeated Kerberos pre-auth wrong-password failures from secondary source 10.10.8.112 (Event 4771).
- 09:08:14 - Account enabled by helpdesk-admin (Event 4722).
- 09:09:01 - Successful interactive user logon on DESKTOP-FB022 (Event 4624).
- 09:09 - Incident marked resolved; user login verified and no issues reported.

## Hypothesis Elimination Record
Initial hypothesis set and evidence-based outcome:

1. User credential mismatch (incorrect/outdated password at sign-in): Supported.
   - Evidence: Event 4776 at 08:44:01 and Event 4625 at 08:44:03/08:44:28/08:44:55.

2. Account lockout triggered by failed attempts: Supported.
   - Evidence: Event 4740 at 08:44:56 and Event 4625 at 08:45:10 (account locked out).

3. Account disabled/expired/restricted at account level: Contradicted.
   - Evidence: Provided events show wrong-password progression to lockout rather than disabled/expired status events.

4. Corrupt/failing local profile path: Contradicted.
   - Evidence: Authentication failed before sign-in completion; failure chain remained auth-focused.

5. Stale cached credentials or secondary source using old secret: Supported and surviving.
   - Evidence: Repeated Event 4771 wrong-password failures from 10.10.8.112 after lockout.

## Root Cause Statement
The incident was caused by repeated bad-password submissions for FINBRIDGE\cthompson, culminating in account lockout on DESKTOP-FB022, with continued wrong-password attempts from a secondary source (10.10.8.112) consistent with stale cached or persisted credentials. This secondary submission path sustained lockout pressure until administrative intervention and credential-path cleanup actions were applied.

## 5 Whys Analysis
1. Why could cthompson not log in?
- Because authentication attempts failed with wrong-password errors and the account became locked out.

2. Why was the account locked out?
- Because multiple failed interactive attempts were recorded on DESKTOP-FB022 before lockout threshold was reached.

3. Why did wrong-password attempts continue after lockout?
- Because additional Kerberos pre-auth failures for the same account continued from source IP 10.10.8.112.

4. Why were additional attempts coming from a different source?
- Because a secondary authentication path retained and submitted incorrect credentials for FINBRIDGE\cthompson.

5. Why did this create user-impacting downtime?
- Because lockout and ongoing bad-password submissions required helpdesk intervention before successful login could be restored.

## Resolution Actions Implemented
- Applied the suggested resolution path for lockout and stale secondary credentials.
- Re-enabled account FINBRIDGE\cthompson (Event 4722 at 09:08:14).
- Verified successful interactive login on DESKTOP-FB022 (Event 4624 at 09:09:01).
- Confirmed user can access host and no further issues were reported.

## Validation and Exit Criteria
Resolution was accepted when:
- Account re-enable action completed successfully.
- User interactive login succeeded on target host.
- No further user-reported issues after 09:09.

## Preventive and Corrective Actions (CAPA)

### Immediate controls
- During lockout incidents, identify whether additional failed-auth events originate from a second source (for example, Event 4771 with different source IP) before unlocking.
- Clear persisted credentials on all identified source endpoints for the affected account before final login retest.

### Process improvements
- Add an explicit triage step to correlate Event 4776/4625/4740 on user endpoint with Event 4771 on other source IPs for the same account.
- Add a closure checklist item requiring a post-recovery check for recurring bad-password events for the affected account.

### Monitoring improvements
- Alert when an account lockout event (4740) is followed by repeated wrong-password Kerberos pre-auth failures (4771) from a different source IP.

## Ownership and Follow-up
- Incident owner: DWP Engineering / Service Desk.
- Follow-up 1: Document the secondary-source credential cleanup procedure in the lockout runbook.
- Follow-up 2: Add event-correlation query for 4776/4625/4740/4771 to expedite future triage.