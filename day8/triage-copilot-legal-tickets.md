# Triage Assessment – Copilot Legal Team Tickets

**Date:** 2026-08-12  
**Analyst:** [to-verify]

---

## Ticket CL-001 – Paralegal: Copilot cannot summarise NDA in SharePoint

### Summary
Paralegal asked Copilot to summarise a client NDA stored in SharePoint and received "I don't have access to that content." The paralegal has never opened or navigated to the folder directly; she became aware of it verbally during a meeting.

### Impact
- **Who:** Single paralegal user
- **How many:** 1 user affected
- **Business urgency:** MEDIUM – work is blocked; urgency increases if the NDA review has a deadline (to-verify)

### Known Facts
- File is a client NDA stored in SharePoint
- Copilot returned an explicit access denial message
- User has never directly opened or navigated to the folder containing the file
- User's only awareness of the file came from a verbal meeting reference

### Missing Information to Gather
- Whether the user has ever been formally granted permissions to the SharePoint site, folder, or file (to-verify)
- Whether the user can manually open the file by navigating to it in SharePoint
- Whether the folder uses unique permissions or inherits from a parent site
- Whether the document carries a sensitivity label that restricts Copilot grounding
- Whether the SharePoint library requires explicit site membership (e.g., a restricted site or private channel)

### Likely Category
1. **Permissions/access boundary** – user may have assumed access based on secondhand knowledge; she may never have been granted it
2. Sensitivity label restriction – client NDAs may carry a label that blocks Copilot grounding even with read access
3. Data indexing lag – if access was only recently granted, the file may not yet be indexed
4. Genuine Copilot fault (last resort)

### First Diagnostic Step
Ask the paralegal to navigate directly to the SharePoint folder and attempt to open the NDA manually. If she receives an access error, the issue is a permissions gap — not Copilot. If she can open the file, check whether it carries a sensitivity label (visible in the document info panel or via the compliance portal) and review the SharePoint folder's permission inheritance. Resolve access first, then re-test Copilot.

---

## Ticket CL-002 – New Associate: Copilot in Outlook cannot find case emails

### Summary
A new associate who started this week reports that Copilot in Outlook cannot find or provide context on case emails they need. No error message is specified.

### Impact
- **Who:** Single new associate
- **How many:** 1 user
- **Business urgency:** MEDIUM – new starter productivity impact, but likely to self-resolve with indexing; escalate if no improvement within 72 hours

### Known Facts
- User started this week
- Issue is specific to Copilot in Outlook
- User wants Copilot to surface context from case-related emails
- Mailbox is presumably working (email is being received) — to-verify

### Missing Information to Gather
- Exact date the mailbox and Copilot licence were provisioned
- Whether Copilot returns no results, an error, or generic responses
- Whether standard Outlook search finds the same emails (isolates Copilot from general search)
- Whether the case emails are in the user's own primary mailbox or a shared/team mailbox
- Whether the user is fully onboarded into the matter management or email filing system (to-verify)

### Likely Category
1. **Data indexing lag** – new user; mailbox content not yet indexed for Copilot grounding (most probable)
2. Licence/provisioning incomplete – Copilot entitlement may not be fully active for a day-one account
3. Permissions/access boundary – if case emails reside in a shared mailbox the user has not been added to
4. Genuine Copilot fault (last resort)

### First Diagnostic Step
Check when the user's mailbox was created and when the Copilot licence was assigned. Confirm whether standard Outlook search returns the emails in question. If standard search works and Copilot does not, this is most likely normal indexing delay (typically 24–72 hours for new accounts). If neither Copilot nor standard search finds the emails, the issue may be that the case emails are stored in a shared mailbox or location the user has not yet been given access to.

---

## Ticket CL-003 – Partner: Copilot surfaced draft settlement from unassigned matter

### Summary
A partner reports that Copilot found and summarised a draft settlement document from a legal matter they are not assigned to. The partner was unaware they had access to that folder.

### Impact
- **Who:** The reporting partner and the matter whose documents were exposed
- **How many:** Potentially wider — if the folder inherits broad permissions, other unassigned users may have the same unintended access (to-verify urgently)
- **Business urgency:** HIGH – potential confidentiality and data governance risk; treat as a compliance finding

### Known Facts
- Copilot surfaced and summarised the document, confirming the partner has read-access to it
- The partner is not assigned to the matter the document relates to
- The partner was not aware they could see that folder
- **This is not a Copilot fault** — Copilot only surfaces content a user already has permission to access; the finding exposes a permissions misconfiguration

### Missing Information to Gather
- Whether the matter folder uses unique permissions or inherits from a parent site/library with broader access
- Who was intended to have access to this matter folder (check with matter owner or legal ops — to-verify)
- Whether other unassigned staff have the same access (scope of exposure — to-verify)
- Whether the document carries a sensitivity label that should restrict access but has not been applied
- Whether a matter management system or SharePoint group controls access, and whether it was correctly configured at matter creation

### Likely Category
1. **Permissions misconfiguration** – folder likely inherits overly broad access from a parent site
2. Security group or matter management system misconfiguration – user may have been added to a group that grants unintended access
3. Sensitivity label gap – document may lack the label that would restrict access to assigned-matter personnel only
4. **Not a Copilot fault** – Copilot behaved correctly; it is the underlying permissions that need remediation

### First Diagnostic Step
Check the effective permissions on the matter folder and the draft settlement file. Identify whether permissions are inherited from a parent site or library that is more broadly accessible than intended. **Treat this as a data governance incident and escalate to the information security or DLP team before remediating.** Determine the scope — check how many unassigned users have the same effective access to this matter — before closing the permissions gap. Do not silently fix the single instance without confirming the full exposure.

---

## Ticket CL-004 – Legal Ops Manager: All 40 Legal team members lost Copilot access

### Summary
All 40 members of the Legal team lost Copilot access simultaneously this morning. Access was working normally throughout last week. No individual-level explanation fits a whole-team simultaneous failure.

### Impact
- **Who:** Entire Legal team (40 users)
- **How many:** 40 users
- **Business urgency:** HIGH – full team productivity loss; treat as a P1/major incident

### Known Facts
- All 40 Legal team members are affected
- Failure occurred this morning (2026-08-12)
- Access was confirmed working last week
- Simultaneous whole-team failure points to a tenant, licensing, or policy-level change rather than individual user fault

### Missing Information to Gather
- Whether any licence assignments, security group memberships, or Copilot service plan entitlements changed overnight or this morning
- Whether any conditional access policies were added or modified that now apply to the Legal team's group or department
- Whether any IT change requests were scheduled or deployed this morning that touch the Legal team's accounts
- Exact error message users see (e.g., "Copilot is unavailable", licence-related message, access denied)
- Whether any other Microsoft 365 services are affected for the same users
- Microsoft 365 service health status for Copilot at time of failure
- Whether the Legal team's accounts share a security group or OU that could have been modified in bulk

### Likely Category
1. **Licence/service plan change** – Copilot licence removed from or modified within the Legal team's licence group
2. Conditional access or security policy change – a new or modified policy now blocks Copilot for this group
3. Tenant-level admin change – a setting affecting Copilot availability was changed and targeted the Legal team
4. Microsoft 365 service incident – check service health; less likely if no other teams are affected
5. Genuine Copilot fault (last resort, after tenant-level checks are clean)

### First Diagnostic Step
Open the Microsoft 365 admin centre and check the licence assignment status for a sample of affected Legal team accounts. Review the audit log for any changes made overnight or this morning to the group, licence assignments, or conditional access policies. Simultaneously check Microsoft 365 service health for active Copilot incidents. If the admin centre shows clean and service health is healthy, contact the change management team to determine whether a scheduled deployment touched this group.

---

## Ticket CL-005 – Contract Specialist: Copilot gives vague answers about contract template clauses

### Summary
A contract specialist reports that Copilot returns generic, non-specific answers when asked about clauses in the organisation's contract templates library. Copilot does not appear to be grounding its responses in the actual documents.

### Impact
- **Who:** Single contract specialist (may be wider if the templates library has a shared access or indexing issue — to-verify)
- **How many:** 1 user confirmed; scope of library-level issue to-verify
- **Business urgency:** MEDIUM – degraded Copilot quality; user can still work manually but productivity is reduced

### Known Facts
- User has Copilot access (no denial or outage reported)
- Copilot returns answers but they are vague and generic
- Issue is specific to queries about the contract templates library
- Copilot does not appear to be reading the actual documents

### Missing Information to Gather
- Whether the user can manually open and search files in the contract templates library in SharePoint
- Whether the library is indexed in Microsoft 365 Search (check Search & intelligence in the admin centre)
- Whether documents in the library carry sensitivity labels that restrict Copilot grounding
- Whether the user is referencing a specific document in their prompt or asking generically without pointing to a file
- An example prompt and response (to assess whether the issue is grounding, prompt technique, or response quality)
- Whether other users querying the same library get the same generic results

### Likely Category
1. **Sensitivity label restriction** – contract templates may carry labels that block Copilot from reading content even when the user has access
2. Data indexing gap – the library or specific files may not be fully indexed for Copilot grounding
3. Permissions/access boundary – Copilot's grounding path to the library may differ from the user's direct access
4. Prompt technique – user may not be explicitly referencing a specific document, causing Copilot to respond from general knowledge
5. Licence/client prerequisite issue
6. Genuine Copilot fault (last resort)

### First Diagnostic Step
Ask the user to share an example prompt alongside the vague response they received. Check whether the contract templates library is indexed in Microsoft 365 Search via the admin centre. Review whether documents carry sensitivity labels that would prevent Copilot grounding. Also confirm whether the user's prompt explicitly references a specific file — Copilot requires a grounding reference (e.g., "summarise /this document/") or a configured data connector to use specific SharePoint content reliably.

---

## Quick Patterns Across These Tickets
- CL-001 and CL-005 both involve SharePoint document libraries where Copilot cannot ground against content; the root causes differ (likely access vs. labelling/indexing) but both start with confirming whether the user has direct access to the files.
- CL-002 is most efficiently resolved by confirming provisioning date and waiting out normal indexing delay.
- CL-003 is a compliance and data governance finding, not a support issue — escalate to the security/DLP team rather than treating it as a Copilot defect.
- CL-004 is the only ticket requiring P1 treatment; a same-morning whole-team failure must start with tenant and licensing checks.
