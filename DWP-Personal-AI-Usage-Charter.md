# Personal AI Usage Charter (DWP Desktop/Endpoint Engineer)

**Version:** 1.0  
**Date:** 2026-08-03

## Purpose
I use public AI assistants to improve speed and quality for low-risk engineering work, while protecting DWP data, systems, and users. AI output is advisory only. I remain accountable for all actions taken.

## Scope
This charter applies to day-to-day desktop, endpoint, and workstation engineering tasks when using public AI tools (web/chat/code assistants not hosted in a DWP-approved private environment).

## 1) DWP Tasks Appropriate for Public LLM Help
I will use public AI only where no sensitive DWP data is required, including:

- Drafting or improving generic PowerShell/Bash snippets using placeholder values only.
- Explaining technical concepts (Group Policy behavior, Intune policy types, SCCM workflows, Windows event log interpretation patterns).
- Building troubleshooting checklists for common endpoint issues (slow boot, profile corruption symptoms, update failures, printer mapping logic).
- Translating notes into clearer incident updates, handover notes, and user-friendly communications.
- Creating template documentation (runbooks, SOP outlines, post-incident review headings).
- Summarizing publicly available vendor guidance (for example Microsoft and OEM documentation).
- Generating test plans for desktop changes (pilot ring strategy, rollback criteria, success metrics).
- Reviewing script structure for readability, error handling, and idempotency using redacted examples.

**Rule:** If the task can be done with invented/sample data and still be useful, it is usually appropriate.

## 2) Tasks That Are Not Appropriate for Public LLM Help
I will not use public AI for work involving protected information, internal-only material, or direct production decision-making, including:

- Pasting tickets, logs, screenshots, emails, or exports containing real user, device, or case data.
- Sharing internal architecture details, network layouts, hostnames, domain structure, security controls, or vulnerability details.
- Sharing internal policy content that is not already public.
- Asking AI to make final security decisions, risk acceptances, access approvals, or production change approvals.
- Uploading scripts/configuration containing real tenant identifiers, device names, certificate material, tokens, or secrets.
- Using AI output as sole evidence for root cause, compliance, or audit statements.
- Executing AI-generated commands directly on live endpoints without validation.

**Rule:** If disclosure could aid misuse, identify a person, expose credentials, or reveal internal operations, it is not appropriate.

## 3) Data-Handling Rule for End-User PII and Credentials
**Non-negotiable rule:** Never enter end-user PII or credentials into a public AI assistant.

- Prohibited data includes: names linked to cases, National Insurance numbers, addresses, phone numbers, personal emails, dates of birth, claim details, health indicators, device-user mappings, usernames, passwords, PINs, MFA codes, API keys, access tokens, certificates, private keys, and session cookies.
- Before using AI, sanitize all inputs and replace real values with placeholders (for example `USER_A`, `DEVICE_01`, `TENANT_X`).
- If sanitization removes essential meaning, do not use public AI for that task.
- If sensitive data is disclosed by mistake, immediately report through the DWP security incident process and rotate/revoke exposed secrets.

**Rule:** No real person data, no real credentials, no exceptions.

## 4) Personal "Generate Then Verify" Rule for Scripts and System Changes
I treat AI as a draft generator, never as an execution authority.

### Generate
- Request first drafts with explicit constraints: least privilege, idempotent behavior, logging, safe error handling, and rollback steps.
- Require comments and a dry-run mode where possible.

### Verify
- Manually review every command for side effects, target scope, and privilege level.
- Validate against official documentation and DWP standards.
- Test in an isolated lab or non-production pilot group first.
- Use peer review for medium/high-impact scripts and endpoint changes.
- Confirm rollback works before broad deployment.
- Record what was AI-generated, what was edited, and final test evidence in change records.

### Deploy
- Release in controlled rings, monitor outcomes, and stop on unexpected behavior.
- Never run AI-generated code unchanged in production.

## Final Accountability Statement
I am responsible for safeguarding data, validating technical accuracy, and ensuring safe change outcomes. Public AI may accelerate my work, but it does not replace professional judgment, DWP policy, or formal approval controls.
