# Floor 6 Incident Triage Report – STREAM 2
**Issue Name:** Floor 6 Login Failures and Authentication Delays (FLR6-AUTH-002)  
**Date:** 2026-08-14 | **Time Reported:** 09:14 | **Reporter:** IT Ops Lead | **Floor:** 6  
**Incident:** Login Failures / Slow Authentication  
**Status:** TRIAGE IN PROGRESS

---

## EXECUTIVE SUMMARY
Minimum 12 users on Floor 6 unable to log in or experiencing extreme login delays this morning. Issue discovered at 09:14, timing correlates directly with Friday afternoon deployment of new document management app. **Business impact: HIGH.** Users blocked from accessing all systems. Immediate diagnostics required to determine if new app deployment caused authentication bottleneck or if infrastructure issue is coincidental.

---

## INCIDENT DETAILS

### LOGIN FAILURES / SLOW AUTHENTICATION
**Priority:** HIGH (P2)  
**Reported by:** IT Ops Lead (bulk report)  
**Incident Time:** This morning (~09:00-09:14 estimated)  
**Affected User Count:** "At least a dozen people" (12+ estimated, exact count TBD)

#### Business Impact
- **Severity Indicator:** HIGH
  - Users unable to access workstations (complete loss of productivity)
  - Slow login creates cascading work delays even for users who eventually authenticate
  - Paralegal and finance staff likely affected; high-cost user population ($75+/hour)
  - Cascading effect: File access, email, applications all blocked at authentication layer
  - **Business cost:** 12+ users × $75/hr = $900/hour minimum downtime cost
- **Scope:** Minimally 12+ users on Floor 6; may extend to other floors if shared infrastructure
- **Affected Asset:** Authentication infrastructure (AD/Entra ID), network, or new app interfering with auth flow

#### Known Facts
- Minimum 12 users unable to authenticate or experiencing very slow login
- Issue manifests as both complete login failure AND extreme slowness (two different failure modes)
- Timeframe: Discovered at 09:14, unclear when symptoms began (could be from 08:00 onward)
- Correlation: Follows Friday afternoon document management app deployment
- Floor-specific report: Only Floor 6 mentioned in initial report
- Deployment timing: Approximately 36 hours before discovery

#### Missing Critical Information
- **Exact number of affected users?** (12+ is range; need precise count from Help Desk tickets)
- **When did login issues begin?** (Friday evening, overnight, this morning before 09:00?)
- **Is failure affecting all users or only some accounts?** (Accounts vs. devices vs. user segments)
- **Is failure at domain authentication layer or application layer?** (AD/Entra ID vs. third-party app)
- **Are login attempts failing silently or generating error messages?** (Type of failure affects investigation)
- **What is typical login time for Floor 6 users?** (Baseline to define "slow")
- **Are affected users on same physical network segment?** (Localized network issue vs. infrastructure-wide)
- **Is new document management app part of or launched during login process?** (Direct path vs. indirect)
- **Have other floors experienced login issues?** (Containment assessment – is this Floor 6 only?)
- **Did Friday deployment change network, firewall, or proxy settings?** (Infrastructure changes vs. app-only)

#### First Investigation Checks (ORDER OF PRIORITY)
1. **Immediate:** Get exact count of affected users from Help Desk ticket system
   - How many users reported login issues since 08:00?
   - Are there patterns (department, user group, device type)?
2. **Immediate:** Confirm: Is this Floor 6 only or wider impact?
   - Request Help Desk to test login from another floor
   - Check if login issues reported from other floors
3. **Immediate:** Check authentication service health
   - Active Directory replication status
   - Entra ID service status (if using hybrid auth)
   - Domain controller availability and health
4. **High:** Review Friday deployment change log
   - What services were modified or installed?
   - Were any authentication-related services touched?
   - Were network, firewall, or proxy rules changed?
   - What was the change window and duration?
5. **High:** Test if new document management app impacts login flow
   - Is app launched during startup or login phase?
   - Does app require separate authentication before login completes?
   - Are there hanging processes or service dependencies during login?
6. **High:** Pull authentication logs from affected user devices (last 12 hours)
   - Event ID 4768/4769/4771 (Kerberos authentication events)
   - Event ID 4625 (Failed login attempts)
   - Event ID 4776 (NTLM authentication failures)
   - Check for patterns (timeout vs. access denied vs. service unavailable)
7. **Medium:** Measure actual login times for affected vs. unaffected users
   - Baseline login time without new app
   - Current login time with new app
   - Identify bottleneck (authentication, network, disk, CPU)
8. **Medium:** Check for resource contention during login
   - CPU usage spike during login attempts
   - Disk I/O wait during authentication
   - Network packet loss or latency on Floor 6 segment

#### Evidence Required
- [ ] List of all affected user account names and device names
- [ ] Help Desk ticket log (all login-related tickets since Friday deployment)
- [ ] Friday deployment change documentation (change request, approval, scope)
- [ ] Document management app installation/deployment plan and execution log
- [ ] Active Directory event logs (all domain controllers, last 24 hours)
- [ ] Entra ID sign-in logs and diagnostic logs
- [ ] Domain controller replication status and errors
- [ ] Network/firewall logs (Floor 6 segment, last 12 hours)
- [ ] Device event logs (System, Security, Application) from 3-5 affected machines
- [ ] New app startup configuration, dependencies, service accounts, and required ports
- [ ] Process monitor trace during failed/slow login attempt (if reproducible)
- [ ] Network packet capture during slow login (if reproducible, shows latency points)
- [ ] Deployment rollback plan and estimated time to revert (for decision-making)

#### Reason for HIGH Priority
- **Blocks core business operations:** Users cannot access any systems when unable to log in
- **High-impact user population:** Finance/legal staff with high hourly cost
- **Probable cause identified:** Deployment timing strongly correlates with issue onset
- **Limited workaround:** Cannot bypass authentication to restore service quickly
- **Scope expansion risk:** If root cause is infrastructure-wide, other floors may become affected
- **Duration unknown:** Could continue affecting users throughout business day
- **Economic impact:** 12+ users × ~$75/hr = $900/hour minimum cost of downtime
- **Not a security/legal risk:** No regulatory or compliance implications (unlike Stream 1)
- **Likely reversible:** If deployment caused it, rollback is possible solution

---

## CRITICAL DECISION GATES

### Gate 1: Scope Confirmation
**Decision:** Is this Floor 6 only or infrastructure-wide?
- **If Floor 6 only:** Likely deployment-specific or network segment-specific
- **If wider:** Indicates infrastructure or domain-level issue, escalate to platform team

### Gate 2: Root Cause Location
**Decision:** Is failure at authentication layer or application layer?
- **If authentication layer:** Domain, Entra ID, or network issue
- **If application layer:** New app or dependency issue
- **If both:** Complex interaction between systems

### Gate 3: Rollback vs. Fix
**Decision:** Can we fix faster than rollback?
- **If new app is root cause:** Estimate rollback time vs. configuration fix time
- **Choose fastest path to restore service:** Rollback, configuration change, or infrastructure fix

---

## INVESTIGATION ROADMAP

### Phase 1: Immediate (Next 15 minutes)
1. Get exact count of affected users from Help Desk
2. Confirm: Other floors affected or Floor 6 only? (Help Desk test login)
3. Check authentication service health dashboard
4. Brief IT Ops lead on findings

### Phase 2: Parallel Investigation (30-90 minutes)
**Auth Track:**
- Pull AD/Entra ID logs for this timeframe
- Check domain controller replication
- Identify error patterns in authentication logs

**App Track:**
- Review deployment change log
- Check if new app modifies login process
- Test app startup during login simulation

**Network Track:**
- Run diagnostics on Floor 6 network segment
- Check for latency, packet loss, or saturation
- Verify firewall rules for new app

### Phase 3: Root Cause Determination (90-180 minutes)
1. Correlate evidence to identify root cause (app, auth service, network, or other)
2. Decide: Rollback vs. configuration fix vs. infrastructure change
3. Execute fix and verify login restoration
4. Measure login times post-fix vs. baseline

---

## NEXT STEPS

**Immediate (Next 30 minutes):**
- Dispatch Level 2 technical support to Floor 6
- Pull affected user count and notification list
- Begin reviewing deployment documentation
- Coordinate with authentication infrastructure team

**Follow-up Triage Meeting:** 10:30 AM
- Expected to have: Exact user count, auth logs, deployment details, root cause hypothesis
- Decision point: Rollback decision and ETA for service restoration

**Communication to Users:**
- "We're aware of login issues on Floor 6. Investigation underway. Estimated resolution within 2-3 hours."
- "We will update you every 30 minutes with progress."

**Communication to Management:**
- Risk level: HIGH – 12+ users unable to work
- Estimated cost: $900+/hour per hour of downtime
- Timeline: Investigating root cause; rollback available if needed
- Status: Updates every 30 minutes
