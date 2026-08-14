# Hypothesis Analysis - FLR6-SEC-001 Copilot Breach

**Incident:** FLR6-SEC-001  
**Date:** 2026-08-14  
**Analyst View:** Security-first triage (governance, permissions, oversharing before product-defect theory)

---

## Scope Facts
- A Floor 6 paralegal reported Copilot returned a client matter she states she never had access to.
- Issue was discovered Monday morning after Friday deployment of a new document management app/integration.
- Initial scope is one confirmed user; broader scope is unknown.
- Existing incident materials classify this as an authorization-boundary problem, not a UI glitch.
- Business and legal risk is high because attorney-client privileged data may be exposed.

Reasoning baseline:
- In legal workflows, unauthorized retrieval of real matter content is an access-control event unless evidence proves otherwise.
- Timing and scope strongly suggest a change-linked control failure and justify ranking governance hypotheses first.

---

## Ranked Hypotheses

## Hypothesis 1 (Most Likely)
### Permissions misconfiguration in document management integration (oversharing by backend)

Why this fits:
- The report describes retrieval of real matter data outside expected entitlement, which is classic permissions matrix failure.
- Friday deployment created a high-probability change window for integration role mappings, ACL inheritance, or default-sharing rules.
- Copilot usually reflects upstream entitlements; if backend returns over-broad results, Copilot will surface them.

Fastest validation check:
1. Pull the affected user's Copilot query timestamps.
2. Correlate with document management access logs for the same timestamps.
3. Compare the user's effective permissions against the returned matter ID.

Evidence supporting:
- Explicit user testimony: "never had access".
- Post-deployment onset.
- Security-incident classification in existing analysis artifacts.
- Problem pattern matches governance/authorization defect more than client-side rendering defect.

Evidence contradicting:
- If backend logs show no retrieval for the matter at that time.
- If entitlement matrix proves user already had legitimate access pre-deployment.
- If retrieval cannot be reproduced by same user/session context.

---

## Hypothesis 2
### Service account or API-layer bypass of user-context filtering

Why this fits:
- Integration can fail by querying with elevated service identity and returning unfiltered results to users.
- This explains how one user can see data beyond normal role without direct ACL changes on her account.
- It is common in rushed deployments where authorization checks are assumed upstream.

Fastest validation check:
1. Inspect integration configuration for query identity (user-delegated vs service principal).
2. Verify where filtering is enforced (before result return vs absent/after display).
3. Replay one blocked query in controlled test with non-privileged test account.

Evidence supporting:
- Friday integration rollout timing.
- Scenario of legal matter oversharing aligns with server-side filter omission.
- Potentially systemic blast radius if all users inherit the same bypass path.

Evidence contradicting:
- If traces show delegated user token with correct policy enforcement.
- If denied documents are consistently excluded for similarly scoped users.
- If service principal has least-privilege scoping and no broad read grants.

---

## Hypothesis 3
### Copilot product defect (ranking/response bug) independent of entitlement change

Why this fits:
- Product defects can occasionally produce incorrect result associations or stale context leakage.
- Could explain apparent mismatch if backend evidence is incomplete.

Fastest validation check:
1. Confirm backend returned (or did not return) the same matter for that query.
2. Reproduce in controlled environment with fixed entitlements.
3. Compare Copilot display with raw backend response payload.

Evidence supporting:
- Would be supported only if backend logs do **not** show corresponding authorized retrieval and Copilot output diverges from source.

Evidence contradicting:
- Existing evidence emphasizes real document retrieval from backend.
- Security analyses already frame this as governance failure and provide rationale.
- Change timing aligns better with deployment/configuration than random product defect.

---

## Most Likely Hypothesis
**Hypothesis 1: Permissions misconfiguration in the document management integration.**

Why:
- It explains the observed unauthorized matter exposure with the fewest assumptions.
- It directly aligns with the change window and known architecture (Copilot surfaces backend results).
- It matches legal/security incident characteristics in existing triage and incident-assessment documents.

---

## Why Other Hypotheses Were Deprioritized
- **Hypothesis 2** remains plausible but is secondary because it is a specific technical mechanism under the broader permissions-governance failure category; it is tested after confirming entitlement mismatch.
- **Hypothesis 3** is deprioritized because it requires contrary evidence (backend mismatch) not currently indicated; security-first investigation practice requires exhausting governance and authorization paths before labeling product defect.

---

## Immediate Validation Order (Operational)
1. Copilot query-to-backend log correlation for affected user.
2. Effective permissions diff pre/post Friday deployment.
3. Integration auth mode and filter-enforcement verification.
4. Controlled reproduction with least-privileged test account.
