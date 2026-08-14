# RCA: Citrix VDI Session Launch Failure (FinBridge-VDI-Pool-02)

Date: 2026-08-14  
Prepared by: DWP Analyst  
Incident type: VDI launch failure (pool-scoped degradation)

## 1) Executive Summary

On 2026-08-14, FinBridge-VDI-Pool-02 experienced major launch degradation affecting 22 of 30 users. Evidence shows a high unregistered VDA count (22 of 25 provisioned machines) in Pool-02 and inability of sample VDAs to connect to dc-vdi-02 on port 80 due to connection refusal. The Delivery Controller dc-vdi-02 had Citrix Broker Service stopped, while dc-vdi-01 remained healthy and Pool-01 remained largely registered. The failure pattern is consistent with controller service outage driving registration collapse and launch failures in Pool-02.

## 2) Scope and Impact

- Affected service: Citrix VDI launches in FinBridge-VDI-Pool-02
- User impact: 22 of 30 users affected
- Non-impacted comparator: FinBridge-VDI-Pool-01 (same site) remained mostly healthy

## 3) Supporting Evidence

### 3.1 Broker Evidence

- [08:58:34] Timeout waiting for machine registration response (30000ms exceeded)
- [08:58:34] Session launch failed: error 1030, No machines available in the desktop group

Note:

- This RCA uses the exact message logged with error 1030 and does not rely on inferred external semantics.

### 3.2 Catalog Registration Evidence

- Pool-02: 25 provisioned, 3 registered, 22 unregistered
- Pool-01: 20 provisioned, 19 registered, 1 unregistered

Interpretation:

- Degradation is concentrated in Pool-02 and is not site-wide universal failure.

### 3.3 VDA Registration Failure Samples

- VDI-P02-014 and VDI-P02-017 failed registration with:
  - Unable to contact Delivery Controller
  - dc-vdi-02.finbridge.local:80 connection refused

Interpretation:

- Endpoint-level refusal is consistent with unavailable broker endpoint/service path on dc-vdi-02.

### 3.4 Delivery Controller Health

- dc-vdi-02
  - Citrix Broker Service: STOPPED
  - Last known running: yesterday 23:40
  - Windows Update installed today 00:15, reboot required flag set, host not rebooted
- dc-vdi-01
  - Citrix Broker Service: RUNNING
  - Uptime: 14 days

Interpretation:

- Asymmetric controller health aligns with asymmetric pool impact.

## 4) Timeline (Known Facts)

- Yesterday 23:40: dc-vdi-02 Broker Service last known running
- Today 00:15: Windows Update installed on dc-vdi-02; reboot required flag set, host not rebooted
- 06:15 to 06:16: Sample Pool-02 VDAs failed registration attempts to dc-vdi-02:80 (connection refused)
- 08:58: Session launch in Pool-02 timed out on registration response and failed with error 1030 / No machines available

## 5) 5 Whys Analysis

1. Why did users fail to launch sessions in Pool-02?
- Broker could not allocate available registered machines in that desktop group.

2. Why could Broker not allocate machines?
- Most Pool-02 machines were unregistered (22 unregistered, only 3 registered).

3. Why were Pool-02 machines unregistered?
- Sample VDAs failed contacting Delivery Controller endpoint dc-vdi-02:80 with connection refused.

4. Why was controller endpoint unavailable/refusing connections?
- dc-vdi-02 had Citrix Broker Service stopped.

5. Why was Broker Service stopped and not recovered?
- Strong temporal association with post-update state: update installed, reboot required, host not rebooted. Service recovery likely incomplete after maintenance event.

RCA statement:

- Most likely root cause chain is dc-vdi-02 Broker Service outage (in post-update pending reboot context) causing VDA registration failures in Pool-02 and resulting launch failures.

## 6) Remediation Plan (Exact Steps)

1. Open controlled change window and notify stakeholders.
2. Capture evidence snapshot on dc-vdi-02:
- Service state and startup type
- System/Application/Service Control Manager events
3. Attempt to start Citrix Broker Service on dc-vdi-02.
4. If unsuccessful or unstable, reboot dc-vdi-02 (reboot required already flagged).
5. After reboot, verify:
- Citrix Broker Service running
- Startup type set for expected auto-start
- No immediate recurrent service faults
6. From sample Pool-02 VDAs, verify connectivity to dc-vdi-02:80.
7. Monitor Pool-02 registration recovery until counts normalize.
8. Execute controlled user launch tests in Pool-02.
9. Confirm incident recovery and close communications.

## 7) Correct Order of Operations

1. Evidence preservation
2. Service recovery attempt
3. Reboot path if required
4. Post-boot controller health validation
5. VDA connectivity checks
6. Registration trend confirmation
7. User launch validation
8. Closure and problem-management follow-up

## 8) Verification of Resolution

Mandatory checks:

- Controller check:
  - dc-vdi-02 Broker Service is RUNNING and stable
- Registration check:
  - Pool-02 registered count increases materially from 3 and unregistered count drops from 22
- Functional check:
  - Multiple Pool-02 users can launch sessions successfully
- Error check:
  - No fresh broker timeout or no machines available events in observation period

## 9) Preventive Actions

1. Post-patching controller standard:
- Enforce reboot completion when reboot-required is set
- Include mandatory Broker Service health check before ending maintenance

2. Monitoring and alerting:
- Alert on Broker Service stopped state for any Delivery Controller
- Alert on abnormal unregistered ratio per pool threshold

3. Resilience assurance:
- Validate Pool-02 controller assignment/failover to healthy secondary controller
- Quarterly failover drill for controller outage scenario

4. Operational readiness:
- Add controller service recovery runbook with explicit rollback/escalation triggers

## 10) Residual Risk and Follow-up

- If registration does not recover after controller restoration, secondary issues may exist (network path, controller assignment policy, or VDA-side service/dependency).
- Follow-up action: retain 24-hour enhanced monitoring after restoration for early relapse detection.
