# Hypothesis Analysis - FLR6-PROF-003 Missing Shortcuts

**Incident:** FLR6-PROF-003  
**Date:** 2026-08-14  
**Weighting Rule:** Deployment-driven profile changes are weighted heavily.

---

## Scope Facts
- Users reported missing desktop shortcuts after Friday application deployment.
- At least one confirmed Floor 6 user affected; broader scope unknown.
- Incident timing aligns to post-deployment window and coexists with login/performance issues.
- Shortcuts are profile-surface artifacts (.lnk), so profile manipulation is a primary risk path.

Reasoning baseline:
- When shortcut-state changes appear directly after targeted deployment, profile initialization/reset logic is more probable than unrelated user behavior.

---

## Top 5 Hypotheses (Ranked)

## Hypothesis 1 (Most Likely)
### Deployment script/profile initialization removed or reset desktop shortcuts

Why this fits:
- Directly explains post-deployment disappearance.
- Consistent with app first-run scripts that standardize or reset user environment.
- Aligns with same-floor targeted rollout and symptom timing.

Fastest validation check:
1. Review installer/MSI/post-install scripts for Desktop path operations.
2. Compare affected profile Desktop timestamps to deployment window.
3. Reproduce on test VM with same package and observe Desktop delta.

Evidence supporting:
- Temporal link to Friday deployment.
- Potential multi-user blast radius in deployment cohort.
- Co-occurring profile/login anomalies suggest startup/profile-touching behavior.

Evidence contradicting:
- No script or package action touches Desktop/profile data.
- Reproduction test does not alter shortcuts.
- Affected devices never received package.

---

## Hypothesis 2
### Group Policy change hid or removed desktop icons/shortcuts

Why this fits:
- Policy can hide icons, redirect desktop, or enforce baseline shell state.
- Can affect many users at once and appear suddenly at next sign-in.

Fastest validation check:
1. Run gpresult and inspect desktop-related policies.
2. Check Friday policy/version changes in target OU/group.
3. Temporarily unlink or exclude test user and re-evaluate icon state.

Evidence supporting:
- Simultaneous behavior across users in same policy scope.
- Friday change window may include policy adjustments.

Evidence contradicting:
- No desktop-related policy change occurred.
- Icon state unchanged after policy exclusion.
- Hidden-state toggles do not restore icons.

---

## Hypothesis 3
### Shortcuts were hidden (attributes/view settings), not deleted

Why this fits:
- Users perceive disappearance when hidden attributes or desktop icon view toggles change.
- Fast to trigger via script or accidental setting change.

Fastest validation check:
1. Enable hidden items and inspect Desktop folder for .lnk files.
2. Check file attributes for Hidden/System flags.
3. Validate "Show desktop icons" setting.

Evidence supporting:
- .lnk files exist with hidden attributes.
- Toggling visibility restores expected desktop view.

Evidence contradicting:
- .lnk files absent from Desktop and Recycle Bin.
- No display-setting anomalies found.

---

## Hypothesis 4
### Roaming profile sync/replace restored an older profile snapshot without shortcuts

Why this fits:
- Profile rollback/sync conflicts can drop recent customizations.
- Fits post-weekend timing if sync occurred after deployment or restart.

Fastest validation check:
1. Check profile server sync logs and profile version history.
2. Compare Desktop contents between local and roaming copies.
3. Inspect profile event IDs around incident window.

Evidence supporting:
- Profile sync conflicts or rollback entries in logs.
- Discrepancy between local and roaming shortcut sets.

Evidence contradicting:
- No roaming profiles in use.
- No sync errors or profile replacement events.
- Local-only users affected identically.

---

## Hypothesis 5
### User action or local cleanup utility deleted shortcuts (independent of deployment)

Why this fits:
- Always possible for isolated reports.
- Some cleanup tools remove broken/unused shortcuts.

Fastest validation check:
1. Review user action timeline and local cleanup utility logs.
2. Check Recycle Bin and shell history for deletion operations.
3. Compare with other users in same deployment cohort.

Evidence supporting:
- Deletion events map to user action/utility execution.
- No similar reports among comparable users.

Evidence contradicting:
- Multiple users show same post-deployment symptom.
- No deletion/audit evidence tied to user action.
- Reappearance tied to deployment rollback/policy change.

---

## Most Likely Hypothesis
**Hypothesis 1: deployment-driven profile initialization/reset altered Desktop shortcut state.**

Why:
- Strongest alignment with change timing, scope targeting, and profile-surface symptom type.
- Best explanatory power with minimal assumptions.
- Rapidly testable through installer/script review and controlled reproduction.

---

## Why Other Hypotheses Were Deprioritized
- **Hypothesis 2:** still plausible, but requires confirmed desktop-policy delta in Friday changes.
- **Hypothesis 3:** common and quick to check, but does not fully explain cohort-level post-deployment pattern unless script-induced.
- **Hypothesis 4:** plausible contributor where roaming profiles exist; secondary until sync errors are observed.
- **Hypothesis 5:** lowest rank because timing and grouping point to systemic change rather than independent user action.

---

## Rapid Validation Sequence
1. Check hidden-state/display toggles (fast elimination).
2. Inspect installer/scripts for Desktop/profile writes.
3. Review GPO deltas for desktop controls.
4. Validate roaming profile logs and profile versions.
5. Reproduce with package on test endpoint.
