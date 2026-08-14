v 1.1, 14/08/2026, status : Draft

# JAMF Pro macOS Configuration Profile - Security Baseline Translation

## Scope
- Platform: macOS managed by JAMF Pro
- Fleet: Design team, 25 devices
- Objective: Translate the six baseline controls into enforceable JAMF profile settings with implementation and validation guidance
- Baseline model: Security settings should be deployed via configuration profiles, with Smart Group monitoring and remediation policies for drift

## Verify UI Labels In Your Tenant

JAMF Pro payload names, menu labels, and option wording can vary by version and tenant configuration.

Do not rely on exact labels from this document without checking live in your own JAMF instance first. Use the same discipline as the Intune Day 6 labs: verify every path and field name before production rollout.

Where this document uses language like "may appear as" or "can be under," treat that as a mandatory verification flag.

---

## Baseline Summary Table

| # | Requirement | Payload type | Value | Effect | False-positive risk |
|---|---|---|---|---|---|
| 1 | FileVault disk encryption must be enabled | Security & Privacy (FileVault payload) | Enable FileVault; escrow personal recovery key to JAMF; enforce at next logout if immediate enablement is not possible | Encrypts data at rest and reduces data exposure if a device is lost or stolen | Device appears non-compliant during enablement window; key escrow not yet reported; inventory not refreshed |
| 2 | Gatekeeper must be enabled (identified developers only) | Security & Privacy (Gatekeeper payload) | Allow apps from App Store and identified developers only | Blocks unsigned or untrusted app execution | Notarized or newly approved tools can be blocked until trust state updates; packaging/quarantine metadata inconsistencies |
| 3 | Minimum macOS version: current stable minus one point release | Software Update payload and/or Smart Group compliance criteria | Minimum allowed version set to stable minus one point release (N-1) | Prevents devices from remaining on unsupported or higher-risk versions | Version telemetry lag after updates; reboot pending; Rapid Security Response suffix parsing differences |
| 4 | Firewall must be enabled | Security & Privacy (Firewall payload) | Enable macOS Application Firewall (consider Stealth Mode if baseline requires) | Reduces exposure to unsolicited inbound network traffic | Third-party tools managing network filtering can create status mismatches; stale inventory |
| 5 | Login password required after sleep/screen saver | Security & Privacy, Login Window, or Restrictions area depending on JAMF version | Require password immediately after sleep or screen saver (0-second grace) | Prevents unattended access to a previously signed-in session | Conflicting user-level settings/profiles; delayed lock-state reporting |
| 6 | Automatic security updates enabled | Software Update payload | Enable automatic checking, download, and install of security updates/system data files | Reduces vulnerability window by accelerating patch adoption | Deferred updates due to power/network constraints; pending restart; conflicting update deferral policies |

---

## Validation After Assignment

### 1) Verify profile delivery and status

1. In JAMF Pro, open the configuration profile used for this baseline.
2. Confirm scope includes only the intended 25 Design devices.
3. Review device-level installation status for the profile and identify failures/pending states.

Verification note: profile status view labels differ between JAMF versions. Validate the exact page/tab names in your tenant.

### 2) Verify each control on a sample device

Use a representative sample of at least 5 devices (different hardware generations and use patterns).

Recommended local checks:
- FileVault: `fdesetup status`
- Gatekeeper policy state: `spctl --status`
- macOS version: `sw_vers -productVersion`
- Firewall: `sudo /usr/libexec/ApplicationFirewall/socketfilterfw --getglobalstate`
- Password after sleep: `sysadminctl -screenLock status` (or JAMF inventory extension method if this command is unavailable on your version)
- Update settings: `softwareupdate --schedule` plus relevant managed preference checks

### 3) What to do when JAMF and local state disagree

1. Trigger an inventory update (recon) from JAMF policy/self service.
2. Recheck device record after inventory refresh.
3. If still mismatched, inspect for conflicting profiles, local admin overrides, or delayed escrow/telemetry.

---

## Requirement 1 - FileVault Disk Encryption Must Be Enabled

| Field | Detail |
|---|---|
| Payload type | Security & Privacy (FileVault payload) |
| Value | Enable FileVault, escrow personal recovery key to JAMF, enforce on next logout if required |

Effect:
FileVault encrypts the startup volume so data is protected at rest. A stolen or offline device cannot expose user data without valid unlock credentials or approved recovery workflow.

False-positive risk:
- Enablement is pending user logout/restart, so JAMF reports a temporary non-compliant state.
- Recovery key escrow upload is delayed, causing compliance checks tied to key presence to fail.
- Inventory has not updated after enablement, so record still shows old encryption state.

Recommendation:
1. Use a staged enforcement window for the first deployment wave.
2. Require key escrow validation before declaring control complete.
3. Add a Smart Group for "FileVault pending enablement" to separate true failures from in-progress devices.

UI drift flag:
Exact FileVault payload names and escrow options can differ by JAMF version. Verify each label in your tenant before rollout.

---

## Requirement 2 - Gatekeeper Must Be Enabled (Identified Developers Only)

| Field | Detail |
|---|---|
| Payload type | Security & Privacy (Gatekeeper payload) |
| Value | Allow apps from App Store and identified developers only |

Effect:
Gatekeeper enforces code-signing and notarization trust decisions, reducing risk from unsigned or tampered software.

False-positive risk:
- Approved creative tools distributed outside normal channels may be quarantined and appear blocked.
- Newly notarized or repackaged binaries may require trust metadata refresh before appearing compliant.
- Local exception workflows can cause temporary drift between expected and observed state.

Recommendation:
1. Maintain a documented exception process for legitimate creative tooling.
2. Validate critical Design apps in pilot before broad enforcement.
3. Track blocked app events during first 14 days and tune allowlisting workflow.

UI drift flag:
Gatekeeper labels and placement have changed across macOS/JAMF cycles. Confirm exact option names in your tenant.

---

## Requirement 3 - Minimum macOS Version Must Be Stable Minus One Point Release

| Field | Detail |
|---|---|
| Payload type | Software Update payload and/or Smart Group compliance logic |
| Value | Set minimum accepted version to N-1 point release from current stable |

Effect:
Prevents devices from falling behind patch levels where known vulnerabilities remain unaddressed.

False-positive risk:
- Device updated but not rebooted, still reporting old build.
- Inventory delay after successful update.
- Version string handling differences (for example Rapid Security Response suffixes).

Recommendation:
1. Define a monthly version-review process tied to patch release cadence.
2. Use Smart Group logic that normalizes version comparison to avoid suffix-related misclassification.
3. Pair enforcement with user messaging and controlled deferral windows for design-critical production deadlines.

UI drift flag:
Minimum version enforcement can be implemented in different JAMF areas depending on edition/version. Verify the exact implementation pattern in your tenant.

---

## Requirement 4 - Firewall Must Be Enabled

| Field | Detail |
|---|---|
| Payload type | Security & Privacy (Firewall payload) |
| Value | Enable macOS Application Firewall; optionally enable Stealth Mode if required by baseline |

Effect:
Reduces unauthorized inbound connectivity and limits exposure of listening services on user endpoints.

False-positive risk:
- Third-party endpoint/network security tooling may influence reported firewall state.
- JAMF inventory may be stale relative to local machine state.
- Overlapping profiles can present as conflicting control status.

Recommendation:
1. Confirm whether any third-party tooling co-manages firewall behavior.
2. Keep one authoritative profile for firewall settings to avoid configuration collisions.
3. Re-run inventory before triaging as non-compliant.

UI drift flag:
Firewall settings can appear under different payload groupings in different UI revisions. Verify the final labels in your tenant.

---

## Requirement 5 - Login Password Required After Sleep or Screen Saver

| Field | Detail |
|---|---|
| Payload type | Security & Privacy, Login Window, or Restrictions (location varies) |
| Value | Require password immediately after sleep or screen saver begins (0-second grace) |

Effect:
Ensures unattended devices cannot be accessed by another user without authentication when a session locks.

False-positive risk:
- Settings enforced in a different payload can make a healthy device appear out of policy in one check.
- User-level preference remnants on previously unmanaged devices can cause temporary reporting mismatch.
- Lock-state telemetry may not immediately reflect profile application.

Recommendation:
1. Enforce this control through one profile path only.
2. Remove or supersede older conflicting profiles.
3. Validate with both local command evidence and JAMF inventory state.

UI drift flag:
This is one of the highest drift controls for naming and placement. Verify exact payload and field names in your tenant before deployment.

---

## Requirement 6 - Automatic Security Updates Enabled

| Field | Detail |
|---|---|
| Payload type | Software Update payload |
| Value | Enable automatic checks, download, and install for security updates/system data files |

Effect:
Reduces time-to-patch and lowers exposure to known vulnerabilities between release and full deployment.

False-positive risk:
- Device is offline, asleep, or on restricted network so updates are deferred.
- Update is downloaded but awaiting restart to complete.
- Another policy introduces update deferral settings that conflict with baseline intent.

Recommendation:
1. Align update deferral policy with security SLA for Design devices.
2. Track restart compliance separately from download/install status.
3. Add user communications for required restart windows after security updates.

UI drift flag:
Software update toggle names frequently change across macOS and JAMF versions. Verify each label in your tenant.

---

## False-Positive Triage Checklist

When a device appears non-compliant but is likely healthy:

1. Confirm the baseline profile is installed and not conflicting with another profile.
2. Collect local evidence (commands listed above) before taking remediation action.
3. Trigger JAMF inventory update and re-evaluate after recon.
4. Check for pending reboot/logout requirements.
5. Confirm key escrow status for FileVault-specific alerts.
6. Review whether temporary business-approved exceptions apply.

---

## UI Path And Label Verification Flags (Mandatory Review)

| Setting area | Drift risk | Verification action |
|---|---|---|
| FileVault payload labels and escrow fields | Medium | Confirm payload field names and key escrow options in your tenant |
| Gatekeeper payload labels | Medium | Confirm App Store/identified developer wording is unchanged |
| Minimum macOS version enforcement path | High | Confirm whether implemented via profile, compliance logic, or Smart Group criteria |
| Firewall payload placement | Medium | Confirm exact category location and toggle labels |
| Password after sleep/screen saver | High | Confirm whether this appears under Security & Privacy, Login Window, or Restrictions |
| Automatic security update toggles | High | Confirm each update toggle name against current JAMF/macOS release |

---

## Deployment Plan For 25-Device Design Fleet

1. Pilot wave: 5 devices (mixed hardware and high-value app users).
2. Validation wave: 10 devices after pilot passes for 3 business days.
3. Full deployment: remaining 10 devices with support coverage window.
4. Post-deploy review: compare JAMF compliance state vs local evidence for at least 3 sample endpoints per wave.

Operational notes:
- Keep a documented exception register for Design tooling constraints.
- Avoid overlapping profiles for the same control domain.
- Capture rollback steps before tightening enforcement.

---

## Audit Evidence To Retain

1. Export of baseline profile settings and scope at deployment time.
2. Device-level profile installation status for all 25 devices.
3. Smart Group compliance snapshots per requirement.
4. Evidence samples (command output/screenshots) for each control.
5. Versioned record of verified JAMF UI labels used during implementation.

---

## Related Documents

- Intune reference model used for detail depth: day6/intune-compliance-policy-win11-security-baseline.md
- Prompt and process references: prompt-library.md
