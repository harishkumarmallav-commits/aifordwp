# Microsoft 365 Copilot Readiness Checklist — Finance Department
**Department:** Finance | **Users:** ~200 | **Date:** 2026-08-12  
**Prepared by:** DWP Engineering  
**Data sensitivity:** HIGH — payroll, board packs, M&A documents, client financial data

---

> **Risk note:** SharePoint permissions on this tenant were inherited from a 2019 migration and have never been fully audited. Until the permissions and oversharing checks in Section 3 are fully resolved and signed off, Copilot licences **must not** be assigned. Copilot surfaces content the user has permission to access — misconfigured permissions will cause sensitive financial data to be exposed through AI-generated responses.

---

## Section 1 — Licensing Prerequisites

| # | Check | Owner | Done |
|---|-------|-------|------|
| 1.1 | Confirm all ~200 Finance users hold a valid **M365 E5** base licence | IT Licensing | ☐ |
| 1.2 | Confirm **Microsoft 365 Copilot add-on** licences have been procured for the intended rollout scope | IT Licensing | ☐ |
| 1.3 | Identify any users on E3 or lower — these require upgrade before Copilot can be assigned | IT Licensing | ☐ |
| 1.4 | Do **not** assign Copilot add-on licences until Section 3 (Permissions & Oversharing) is fully signed off | IT Licensing / Security | ☐ |

---

## Section 2 — Microsoft 365 Apps Client Version

| # | Check | Owner | Done |
|---|-------|-------|------|
| 2.1 | Verify all Finance endpoints are running **Microsoft 365 Apps for Enterprise** (not Office 2019/2021 perpetual) | Endpoint | ☐ |
| 2.2 | Confirm build is on **Current Channel** or **Monthly Enterprise Channel** — Copilot features are not available on Semi-Annual Channel without a minimum build | Endpoint | ☐ |
| 2.3 | Minimum required build: **Version 2302 (Build 16130.20306)** or later — validate via M365 Apps Admin Centre or Intune device compliance report | Endpoint | ☐ |
| 2.4 | Confirm **Microsoft Teams** desktop client is up to date (new Teams preferred — classic Teams support for Copilot is limited) | Endpoint | ☐ |
| 2.5 | Verify **WebView2 Runtime** is installed and current on all endpoints (required for Copilot UI components) | Endpoint | ☐ |

---

## Section 3 — Permissions & Oversharing Audit ⚠️ HIGHEST PRIORITY

> This section must be completed and signed off by the Security/Data Owner **before** Copilot licences are assigned. Copilot does not create new permissions — it respects existing ones. Overly permissive permissions inherited from 2019 will be exploited by Copilot queries, surfacing content to users who should not see it.

### 3a — SharePoint Permissions Baseline

| # | Check | Owner | Done |
|---|-------|-------|------|
| 3.1 | Run a full **SharePoint permissions report** across all Finance-owned site collections using SharePoint Admin Centre or PnP PowerShell (`Get-PnPSiteCollectionAdmin`, `Get-PnPGroupMembers`) | SharePoint Admin | ☐ |
| 3.2 | Identify all sites/libraries still carrying **inherited permissions from the 2019 migration** — list and triage each | SharePoint Admin | ☐ |
| 3.3 | Remove or break inheritance on any site where the inherited permissions grant broader access than currently required | SharePoint Admin | ☐ |
| 3.4 | Identify and remediate any **"Everyone"**, **"Everyone except external users"**, or **"All authenticated users"** permissions on Finance sites, libraries, or folders | SharePoint Admin / Security | ☐ |
| 3.5 | Audit and clean up **direct user permissions** (non-group) — these are invisible in normal group reviews and common post-migration | SharePoint Admin | ☐ |
| 3.6 | Confirm all Finance site collections have a **named, active Site Owner** with a current business justification on record | SharePoint Admin / Data Owner | ☐ |

### 3b — Oversharing & Sensitive Content Exposure

| # | Check | Owner | Done |
|---|-------|-------|------|
| 3.7 | Use **Microsoft Purview Content Explorer** (requires E5 compliance) to locate payroll files, board packs, and M&A documents — confirm they are held in appropriately restricted locations | Security / Compliance | ☐ |
| 3.8 | Run **SharePoint Advanced Management (SAM) — Oversharing Reports** or equivalent to identify broadly shared files and folders | SharePoint Admin | ☐ |
| 3.9 | Identify any Finance documents shared via **anonymous/public links** — revoke all unless explicitly business-justified and approved | SharePoint Admin / Security | ☐ |
| 3.10 | Confirm **site sharing settings** for all Finance sites are set to "Only people in your organisation" or more restrictive — block external sharing where not required | SharePoint Admin | ☐ |
| 3.11 | Review **OneDrive for Business** sharing settings for Finance users — confirm "Anyone" links are disabled at tenant or at user level via policy | SharePoint Admin | ☐ |
| 3.12 | Produce and retain a **written sign-off record** confirming permissions have been reviewed and are fit for Copilot enablement — required before proceeding to Section 5 | Security Lead / Data Owner | ☐ |

---

## Section 4 — Identity & MFA Readiness

| # | Check | Owner | Done |
|---|-------|-------|------|
| 4.1 | Confirm all 200 Finance users are **Azure AD / Entra ID** accounts (no on-premises-only or hybrid sync issues) | Identity | ☐ |
| 4.2 | Verify **MFA is enforced** for all Finance users — either via Conditional Access policy or per-user MFA (Conditional Access preferred) | Identity / Security | ☐ |
| 4.3 | Confirm no Finance accounts are excluded from MFA-enforcing Conditional Access policies (check named exclusions and break-glass accounts) | Identity / Security | ☐ |
| 4.4 | Confirm **sign-in risk policies** (Entra ID Protection) are active for Finance users — M365 E5 includes this | Identity / Security | ☐ |
| 4.5 | Validate that service accounts and shared mailboxes used by Finance are excluded from Copilot licence assignment | Identity | ☐ |

---

## Section 5 — Sensitivity Labelling

| # | Check | Owner | Done |
|---|-------|-------|------|
| 5.1 | Confirm **Microsoft Purview sensitivity labels** are published and applied to Finance users via label policy | Compliance | ☐ |
| 5.2 | Confirm labels relevant to Finance data exist and are in use — minimum expected: `Confidential`, `Highly Confidential`, `Internal Only` or equivalent | Compliance / Data Owner | ☐ |
| 5.3 | Verify payroll files, board packs, and M&A documents are labelled `Highly Confidential` (or equivalent) and that the label applies encryption and restricts sharing | Compliance | ☐ |
| 5.4 | Enable **auto-labelling policies** in Purview for Finance-specific content types (payroll, financial statements) where manual labelling coverage is incomplete | Compliance | ☐ |
| 5.5 | Confirm **Copilot in Teams** and **Copilot in Word/Excel** will respect label-applied encryption — validate with a test document | Security / Compliance | ☐ |
| 5.6 | Confirm DLP policies in Purview are in place for Finance-classified content and that Copilot interactions are within policy scope | Compliance | ☐ |

---

## Section 6 — End-User Comms & Enablement

| # | Check | Owner | Done |
|---|-------|-------|------|
| 6.1 | Deliver a **Finance-specific pre-launch briefing** covering: what Copilot can access, what it cannot do, and the team's responsibility not to use it to query content outside their role | Change / L&D | ☐ |
| 6.2 | Communicate clearly that Copilot **will surface documents they have access to** — reinforce that this is why permissions have been cleaned up | Change / L&D | ☐ |
| 6.3 | Provide written guidance on **what not to put in a Copilot prompt** — e.g. do not paste raw payroll data, M&A terms, or client data into Copilot chat | Change / L&D / Security | ☐ |
| 6.4 | Share the **DWP Personal AI Usage Charter** with all Finance users before go-live and obtain acknowledgement | Change | ☐ |
| 6.5 | Confirm a **named Finance business champion** is identified to support adoption and act as first escalation for misuse queries | Change / Finance Lead | ☐ |
| 6.6 | Schedule a **30-day post-go-live review** — check Copilot usage logs in M365 Admin Centre, review any data exposure queries raised, revisit permissions if issues found | IT / Security | ☐ |

---

## Sign-Off

| Stage | Approver | Date | Signature |
|-------|----------|------|-----------|
| Section 3 — Permissions signed off | Security Lead | | |
| Section 5 — Labelling signed off | Compliance Lead | | |
| Copilot licence assignment approved | IT Director / CISO | | |
| Go-live confirmed | Finance Head / Change Lead | | |

---

*This checklist should be stored alongside the Finance SharePoint audit evidence and retained for audit purposes. Do not delete or archive until the 30-day post-go-live review is complete.*
