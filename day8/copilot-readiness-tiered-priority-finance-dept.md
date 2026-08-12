# Microsoft 365 Copilot Readiness — Tiered Priority Ranking
**Department:** Finance | **Users:** ~200 | **Date:** 2026-08-12  
**Prepared by:** DWP Engineering  
**Source checklist:** `copilot-readiness-checklist-finance-dept.md`

---

## Why this document exists

Not all checklist items carry equal risk. This document re-ranks every item from the readiness checklist into three tiers so the team can sequence work correctly and make an informed go/no-go decision. Tier 1 items are hard blockers — Copilot must not go live until every one of them is resolved. Tier 2 items represent serious risk if skipped but do not break the technical rollout. Tier 3 items can run in parallel with or after go-live without materially increasing exposure.

---

## Tier 1 — MUST complete before rollout (blocking)

These items either prevent Copilot from functioning at all, or create a direct, unacceptable data exposure risk if skipped. Rollout must not proceed until every Tier 1 item has a named owner, documented evidence of completion, and a written sign-off.

| Ref | Item | Why it is blocking |
|-----|------|--------------------|
| 1.1 | Confirm all ~200 users hold a valid M365 E5 base licence | Copilot add-on cannot be assigned without the base licence — technical hard stop |
| 1.2 | Copilot add-on licences procured for rollout scope | Cannot assign what has not been purchased |
| 1.4 | Do not assign Copilot licences until Section 3 is signed off | Gate item — enforces the correct sequencing of the entire rollout |
| 2.1 | All endpoints running M365 Apps for Enterprise (not perpetual Office) | Copilot in Word/Excel/Outlook does not function on perpetual Office builds |
| 2.3 | Minimum build Version 2302 (Build 16130.20306) or later confirmed | Copilot UI and backend integration will not load on older builds |
| **3.1** | **Full SharePoint permissions report run across all Finance site collections** | **Foundation step for the entire permissions audit — nothing downstream is possible without it** |
| **3.2** | **Sites carrying inherited permissions from 2019 migration identified and triaged** | **The specific inherited state of this tenant is the primary risk driver for this rollout** |
| **3.3** | **Broken inheritance applied where current permissions are broader than required** | **Directly prevents Copilot from surfacing over-permissioned content to Finance users** |
| **3.4** | **"Everyone" / "Everyone except external users" permissions removed from Finance sites** | **Broadest possible oversharing vector — any Finance user querying Copilot would be able to surface content intended for nobody in particular** |
| **3.5** | **Direct user permissions (non-group) audited and cleaned up** | **Post-migration tenants commonly carry orphaned direct permissions invisible to group-level reviews — a silent data exposure path** |
| **3.7** | **Purview Content Explorer used to locate payroll, board packs, M&A docs and confirm they are in restricted locations** | **Confirms that the most sensitive Finance assets are not sitting in broadly accessible libraries before Copilot can index and surface them** |
| **3.9** | **Anonymous/public sharing links on Finance documents revoked** | **Copilot respects permissions — but an anonymous link means the content is effectively public; any summarisation or retrieval compounds the exposure** |
| **3.12** | **Written sign-off obtained confirming permissions are fit for Copilot enablement** | **Audit and accountability requirement — without this, there is no documented basis for the go-live decision** |
| 4.1 | All Finance users on Entra ID accounts with no sync issues | Copilot identity binding requires a functioning Entra ID account |
| 4.2 | MFA enforced for all Finance users | A Copilot-enabled account without MFA is a high-value target for account takeover; an attacker gains Copilot access to all indexed Finance content |
| 4.3 | No Finance accounts excluded from MFA Conditional Access | Exclusions silently undermine 4.2 — must be verified explicitly |
| 5.1 | Sensitivity labels published and applied to Finance users | Without labels, Copilot has no signal to restrict or warn on sensitive content; DLP policies also depend on label state |
| 5.3 | Payroll, board packs, and M&A documents labelled Highly Confidential with encryption applied | Encryption at the document level is the last line of defence if permissions are misconfigured; must be in place before Copilot is live |
| 6.4 | DWP Personal AI Usage Charter shared with all Finance users and acknowledgement obtained | Legal and policy compliance requirement — establishes the basis for enforcement if misuse occurs |

---

## Tier 2 — SHOULD complete before rollout (high risk if skipped)

These items do not technically block Copilot from being assigned or functioning, but skipping them leaves meaningful gaps in security posture, compliance, or user safety that are very likely to cause problems in a high-sensitivity Finance environment.

| Ref | Item | Risk if skipped |
|-----|------|-----------------|
| 1.3 | Identify users on E3 or lower requiring upgrade | Any overlooked users will silently not receive the add-on; creates inconsistent coverage and support confusion |
| 2.2 | Confirm endpoints on Current Channel or Monthly Enterprise Channel | Users on Semi-Annual Channel may have degraded or missing Copilot features without warning |
| 2.4 | Teams desktop client up to date (new Teams preferred) | Copilot in Teams meetings and chat has reduced functionality on classic Teams; known support-lifecycle issues |
| 3.6 | All Finance site collections have a named, active Site Owner on record | Without ownership, permissions drift cannot be governed post-rollout; no accountable party if a data incident occurs |
| 3.8 | SharePoint Advanced Management oversharing reports run | SAM provides automated, ongoing oversharing detection — skipping this means the manual audit in 3.1–3.5 has no ongoing complement |
| 3.10 | Finance site sharing settings restricted to "Only people in your organisation" or tighter | External sharing of Finance content enabled at site level is an active oversharing risk even without Copilot |
| 3.11 | OneDrive "Anyone" links disabled via policy for Finance users | Same risk as 3.10 applied to personal OneDrive storage — Finance users routinely stage payroll and board material here |
| 4.4 | Entra ID Protection sign-in risk policies active for Finance users | E5 includes this capability; not activating it leaves account compromise risk undetected |
| 5.2 | Labels covering Confidential, Highly Confidential, and Internal Only exist and are in use | Incomplete label taxonomy means some sensitive Finance content has no protection signal at all |
| 5.5 | Copilot in Teams and Word/Excel validated to respect label-applied encryption | Functional validation — confirms that the protection chain holds end-to-end before users go live |
| 5.6 | DLP policies in Purview active and scoped to include Copilot interactions | Without this, Copilot interactions involving sensitive content fall outside DLP enforcement; creates a compliance gap |
| 6.1 | Finance-specific pre-launch briefing delivered | Users without a briefing will misuse Copilot through ignorance, not intent — most preventable misuse vector |
| 6.3 | Written guidance on what not to put in a Copilot prompt distributed | Payroll figures and M&A terms pasted into Copilot chat are not protected by permissions or labels — user behaviour is the control here |

---

## Tier 3 — CAN complete during or after rollout (lower risk)

These items improve the quality and sustainability of the rollout but do not materially increase data exposure risk if addressed in the first 30–60 days after go-live.

| Ref | Item | Rationale |
|-----|------|-----------|
| 2.5 | WebView2 Runtime installed and current on all endpoints | Copilot will typically prompt for or install WebView2 if missing; operational nuisance rather than a security or blocking issue |
| 4.5 | Service accounts and shared mailboxes excluded from Copilot licence assignment | Low risk of accidental assignment if the licence roll-out is controlled; worth confirming but not a blocker |
| 5.4 | Auto-labelling policies enabled in Purview for Finance content types | Improves label coverage over time; the manual label requirement in 5.3 covers the critical assets at go-live |
| 6.2 | Communication to users confirming what Copilot can access and why permissions were cleaned up | Useful for trust and transparency; can follow shortly after go-live once the permissions story is settled |
| 6.5 | Named Finance business champion identified | Supports adoption quality; does not affect security posture |
| 6.6 | 30-day post-go-live review scheduled | By definition post-rollout — but must be scheduled before go-live, not treated as optional |

---

## Why the permissions and oversharing audit is Tier 1 — not just another checklist item

Licensing and client version checks are simpler to complete, but they are not higher risk. Here is why the permissions audit belongs at the top of Tier 1 for this specific Finance context:

**1. Copilot's threat model is permissions-as-trust.**
Copilot does not independently classify or restrict content. It indexes and surfaces everything a user has permission to read. Licensing and client version checks determine whether Copilot works. Permissions determine what it exposes. In a Finance department, those are not equivalent risks.

**2. The 2019 migration created a known, unresolved permissions debt.**
This is not a hypothetical risk. SharePoint permissions on this tenant were inherited from a migration that happened seven years ago and have never been audited. Post-migration tenants routinely carry orphaned permissions, over-broad group memberships, and direct user grants that were never intended to be permanent. That debt exists today and Copilot will immediately make it visible and exploitable.

**3. The data in scope is the most sensitive a UK public sector finance team handles.**
Payroll data, board packs, M&A documents, and client financial data each carry distinct legal and regulatory exposure: UK GDPR for personal payroll data, market abuse considerations for M&A, fiduciary obligations for board materials. A misconfigured permission causing a Finance analyst to Copilot-query a colleague's salary or an unreleased acquisition document is not a configuration error — it is a reportable data incident.

**4. Licensing errors are self-contained and correctable after the fact.**
If a user's M365 Apps build is too old, their Copilot experience degrades or fails silently for that user. The error is contained to that endpoint. A permissions error, by contrast, is immediately systemic: Copilot queries the entire content graph the user can see, which means a single misconfigured "Everyone" permission on a payroll library is exploitable by every one of the 200 licensed users from the moment go-live occurs.

**5. The permissions audit cannot be done after the fact.**
Unlike client version remediation, there is no clean rollback for a data exposure event. Once a user has retrieved content they should not have seen through a Copilot interaction, the exposure has occurred. The permissions audit must be complete, evidenced, and signed off before any licence assignment takes place — not as a best practice, but as the only approach consistent with the data sensitivity of this department.

---

*This document should be read alongside `copilot-readiness-checklist-finance-dept.md`. Both documents should be retained with the permissions audit evidence and the go-live sign-off record.*
