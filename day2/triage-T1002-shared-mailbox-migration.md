# Triage Summary – Shared Mailbox Inaccessible After Migration

**Ticket ref:** T-1002  
**Date:** 2026-08-04  
**Analyst:** [to confirm]

---

## Summary
Finance user is unable to open a shared mailbox following a migration event.

## Impact
- **Who:** Single Finance team user (identity to confirm)
- **How many:** 1 user confirmed; other Finance users may be affected (to confirm)
- **Business urgency:** MEDIUM-HIGH — Finance staff losing access to shared mailboxes can block team workflows, approvals, or correspondence handling

## Known Facts
- The user is a member of the Finance team
- A migration has recently taken place (type and date of migration to confirm — e.g. Exchange on-premises to Exchange Online, tenant-to-tenant)
- The shared mailbox was presumably accessible before the migration
- The user cannot open the shared mailbox now

## Missing Information to Gather
- Name/identifier of the shared mailbox (use placeholder e.g. MAILBOX_01 if sharing with AI tools)
- Type of migration performed and when it completed
- Email client in use — Outlook desktop, Outlook on the Web (OWA), or both
- Exact error message displayed when attempting to open the mailbox
- Whether the user's own primary mailbox is working correctly
- Whether other users can access the same shared mailbox (to confirm scope)
- Whether the user's account permissions on the shared mailbox were re-applied post-migration
- Whether Outlook profile has been recreated since migration
- Whether Autodiscover is correctly resolving post-migration (to confirm)

## Likely Category
- **Primary:** Email / Shared Mailbox Access
- **Sub-category (to confirm):** Permissions not migrated or re-applied, or Outlook profile pointing to old mailbox location

## First Diagnostic Step
Confirm the user's mailbox permissions on the shared mailbox are correctly assigned in the post-migration environment (check via admin portal or Exchange admin tools — do not share real mailbox names or user details with AI). Then ask the user to remove and re-add the shared mailbox in Outlook, or try accessing it via Outlook on the Web to isolate whether the issue is client-side or permission-based.
