v 1.0, 11/08/2026, status : Draft

# Windows 11 Intune Compliance Policy — Security Baseline Translation

## Scope
- Platform: Windows 10 and later (targets Windows 11 endpoints)
- Policy type: Compliance policy
- Grace period: 7 days applied to all settings below
- Admin centre path: Endpoint security > Device compliance > Policies > + Create policy > Windows 10 and later > Basics > Name policy > Compliance settings
- Profile type (confirmed August 2026): Windows 10/11 compliance policy
- Wizard steps: 1 Basics → 2 Compliance settings → 3 Actions for noncompliance → 4 Assignments → 5 Review + create
- Alternative path: Devices > Manage devices > Compliance > Create policy > Windows 10 and later > Compliance settings
- Custom compliance section is present in Step 2 Compliance settings; leave it Not configured for this baseline unless using a custom discovery script and JSON settings package.
- Targeting: use Assignment filters to scope policy to DESKTOP-FB* devices — Microsoft Intune admin centre > Devices > Organize devices > Assignment filters
- Update ring management: Microsoft Intune admin centre > Devices > Manage updates > Windows updates
- Conditional access enforcement (block non-compliant devices): Microsoft Intune admin centre > Devices > Manage devices > Conditional access OR Endpoint security > Conditional access

> **Grace period and notification configuration paths (confirmed August 2026):**
> - Per-policy actions: Endpoint security > Device compliance > Policies > [Policy name] > Properties > Actions for noncompliance
> - Notification templates: Endpoint security > Device compliance > Notifications
> - Global compliance settings: Endpoint security > Device compliance > Compliance policy settings
> - Compliance scripts: Endpoint security > Device compliance > Scripts
> Action: Mark device noncompliant | Schedule: 7 days after noncompliance

---

## Validation after assignment

### 1) Where to see this device's status for this specific policy
- Open **Endpoint security > Device compliance > Policies > [Policy name]**.
- Use the **Device status** view/tab to find the test device and confirm whether this policy reports **Compliant**, **Not compliant**, or **In grace period**.
- Open **Per-setting status** for the same policy if you need to see which rule is failing, such as BitLocker, Secure Boot, or Defender.

### 2) What the status means for Conditional Access

| Policy status | Meaning for access when CA requires a compliant device |
|---|---|
| **Compliant** | Access is allowed, assuming no other CA condition blocks it. |
| **Not compliant** | Access is blocked by Conditional Access if the policy is in scope. |
| **In grace period** | The device has already failed a rule, but Intune is still allowing the remediation window to run; treat it as at risk and verify whether your tenant is already blocking access via CA. |

### 3) BitLocker false-positive checks

If BitLocker is enabled on the device but this policy still shows BitLocker as non-compliant, check these three causes first:

| Common cause | Fastest check |
|---|---|
| **Compliance/attestation lag after sync or enrolment** | On the device, run `manage-bde -status C:` and confirm **Protection Status: On**; then re-check **Endpoint security > Device compliance > Policies > [Policy name] > Device status** after the next sync cycle. |
| **BitLocker is suspended or pending reboot after a servicing change** | Run `manage-bde -status C:` and look for **Protection Status: Suspended** or **Off**; if so, complete the reboot and recheck compliance. |
| **TPM / Secure Boot / attestation mismatch** | Run `Get-Tpm` and open `msinfo32` to confirm the device has a ready TPM and **Secure Boot State = On**; if either is missing, fix firmware/TPM state or move the device to a supported platform. |

---

## Requirement 1 — BitLocker must be enabled on the OS drive

| Field | Detail |
|---|---|
| **Setting name** | BitLocker |
| **Section in Intune UI** | Device Health > Windows 10 and 11 |
| **Value** | Require |

**Effect:**
Intune queries Windows Health Attestation Service (HAS) to confirm BitLocker is protecting the OS drive. A device is only marked compliant when the OS volume is encrypted and the BitLocker status is reported as active by the HAS measurement.

**False-positive risk:**
- Device has BitLocker enabled but HAS report has not yet been retrieved or cached (typically on first enrolment or after a reset).
- BitLocker is suspended during a pending Windows Update reboot — device reports as not encrypted until the update completes and BitLocker resumes.
- Software-layer encryption tools that are not BitLocker will not satisfy this check even if the drive is encrypted.
- Virtual machines (Hyper-V, AVD) using software-only encryption without TPM binding may fail attestation.

**Recommendation:**
- Keep grace period at 7 days to absorb HAS report latency on enrolment.
- Exclude dedicated AVD session-host device objects from this rule if those VMs use a non-TPM encryption path; apply a separate compliance policy for AVD hosts.
- Pair with a remediation script that forces `manage-bde -on C:` and triggers a fresh HAS report on non-compliant endpoints.
- To manage BitLocker policy directly: Endpoint security > Manage > Disk encryption.
- Note: a complementary setting **Require encryption of data storage on device** exists at System Security > Encryption — consider enabling this alongside BitLocker for defence in depth.

> ✅ **UI note (confirmed August 2026):** Section heading is **Device Health**, powered by Microsoft Attestation Service evaluation settings. Setting label is **BitLocker** with toggle options: Require / Not configured. Path: Step 2 Compliance settings > Device Health > Windows 10 and 11 > BitLocker.

---

## Requirement 2 — Secure Boot must be enabled

| Field | Detail |
|---|---|
| **Setting name** | Secure Boot |
| **Section in Intune UI** | Device Health > Windows 10 and 11 |
| **Value** | Require |

**Effect:**
Intune checks the HAS report to confirm firmware-level Secure Boot is active. Only devices that boot with a signed boot chain (no tampered bootloader or kernel) are marked compliant.

**False-positive risk:**
- Generation 1 Hyper-V VMs do not support Secure Boot; they will always fail this check.
- Legacy BIOS devices without UEFI Secure Boot support cannot satisfy this regardless of OS version.
- Some OEM images ship with Secure Boot disabled by default and require manual BIOS enablement.
- HAS report latency on first enrolment can cause a transient non-compliant state.

**Recommendation:**
- Audit UEFI Secure Boot support across the device estate before enforcing this policy; exclude confirmed Generation 1 or BIOS-only devices into a separate compliance policy with a compensating control.
- For AVD session hosts, use Generation 2 VMs (which support Secure Boot) to avoid blanket exclusions.

> ✅ **UI note (confirmed August 2026):** Setting label is **Secure Boot** with toggle options: Require / Not configured. Path: Step 2 Compliance settings > Device Health > Windows 10 and 11 > Secure Boot.

---

## Requirement 3 — Minimum OS build: 10.0.22621.2861 (N-1 from latest 22621.3155)

| Field | Detail |
|---|---|
| **Setting name** | Minimum OS version |
| **Section in Intune UI** | Device Properties |
| **Value** | 10.0.22621.2861 |

**Effect:**
Devices running a build lower than 10.0.22621.2861 are flagged non-compliant. This enforces that all endpoints are on at most one cumulative update behind the current known-good release.

**False-positive risk:**
- Devices that received the update but have not yet rebooted to apply it will still report the old build number until the reboot completes.
- Intune compliance evaluation runs on a schedule (default approximately every 8 hours); a device that updated minutes ago may not show compliant until the next check-in.
- Devices with Windows Update for Business deferral rings set beyond the N-1 threshold will fail until they receive the deferred update.

**Recommendation:**
- Align Windows Update for Business deferral policy to a maximum of the N-1 grace window so compliant devices naturally stay within range. Configure deferral rings at: Devices > Manage updates > Windows updates.
- Set the value to the N-1 build (22621.2861) rather than current (22621.3155) to avoid flagging devices that are one patch behind but still within acceptable risk tolerance.
- Review and update this value each Patch Tuesday as part of change management.

---

## Requirement 4 — Windows Defender real-time protection must be on

| Field | Detail |
|---|---|
| **Setting name** | Real-time protection |
| **Section in Intune UI** | System Security > Defender |
| **Value** | Require |

**Effect:**
Intune checks that the Microsoft Defender Antivirus real-time protection component is active and not disabled. Devices with Defender turned off or paused are marked non-compliant.

**False-positive risk:**
- Devices running a third-party antivirus (for example Sophos, CrowdStrike, or Trend Micro) that co-installs and causes Defender to enter passive mode will fail this check, even though the device is protected by the third-party product.
- Defender updates that require a service restart can briefly show protection as inactive.
- Tampered or corrupt Defender installations may report unexpected states.

**Recommendation:**
- If a third-party AV is the standard for the estate, switch to evaluating the third-party product's compliance state through a partner connector (for example Microsoft Defender for Endpoint or Jamf) rather than enforcing this Defender-specific toggle.
- If Defender is the sole AV, pair this with a remediation script that runs `Set-MpPreference -DisableRealtimeMonitoring $false` on non-compliant endpoints.
- To manage Defender AV policy directly: Endpoint security > Manage > Antivirus.

> ✅ **UI note (confirmed August 2026):** Section heading is **Defender** (not Microsoft Defender Antivirus or Windows Defender Antivirus). Setting label is **Real-time protection** with toggle options: Require / Not configured. Additional Defender settings visible in same subsection: Microsoft Defender Antimalware, Microsoft Defender Antimalware minimum version, Microsoft Defender Antimalware security intelligence up-to-date.

---

## Requirement 5 — Firewall must be enabled for all profiles

| Field | Detail |
|---|---|
| **Setting name** | Firewall |
| **Section in Intune UI** | System Security > Device Security |
| **Value** | Require |

**Effect:**
Intune confirms the Windows Firewall service is active for all three network profiles — Domain, Private, and Public. Any device where firewall is disabled on even one profile is marked non-compliant.

**False-positive risk:**
- Devices running a third-party firewall (for example Cisco Secure Endpoint or Symantec) that disables Windows Firewall as part of installation will fail this check even if they have equivalent protection.
- Group Policy firewall settings that override or disable Windows Firewall for certain profiles can cause a mismatch.
- Some enterprise network appliances (for example Zscaler, Global Protect) interact with the Windows Firewall state in ways that can briefly trigger non-compliance.

**Recommendation:**
- If a third-party firewall is authorised, either configure it to leave Windows Firewall enabled in alongside mode, or replace this compliance check with an equivalent check via the partner security product.
- To manage Firewall policy directly: Endpoint security > Manage > Firewall.
- Review Group Policy firewall settings for Finance and VDI OUs to ensure no conflicting policy disables Windows Firewall for Domain profile.

> ✅ **UI note (confirmed August 2026):** Section heading is **Device Security**. Setting label is **Firewall** with toggle options: Require / Not configured. Additional Device Security settings in same subsection: Trusted Platform Module (TPM), Antivirus, Antispyware.

---

## Requirement 6 — A PIN or password must be configured

| Field | Detail |
|---|---|
| **Setting name** | Require a password to unlock mobile devices |
| **Section in Intune UI** | System Security > Password |
| **Value** | Require |
| **Supporting settings (confirmed August 2026)** | Simple passwords: Block / Not configured; Password type: Device default (dropdown); Minimum password length: default 4, recommend setting to 8; Password expiration (days): default 41; Number of previous passwords to prevent reuse: default 5 |

**Effect:**
Intune confirms the device requires credentials to resume from lock. Without this setting, an unattended device with no lock screen provides no access barrier.

**False-positive risk:**
- Shared kiosk devices or devices configured for automatic sign-in will fail this check by design.
- Devices in Windows Autopilot self-deploying mode may report as non-compliant briefly before PIN setup is completed.
- Windows Hello for Business devices that use biometrics may need the underlying PIN to be set as fallback; if the PIN is not set, the compliance check fails.

**Recommendation:**
- Exclude kiosk device groups into a separate compliance policy with appropriate compensating controls (for example physical security controls, network access restriction).
- Ensure Windows Hello for Business policy requires PIN enrolment as a prerequisite so biometric devices are not erroneously marked non-compliant.

---

## Requirement 7 — Device must not be jailbroken or rooted

| Field | Detail |
|---|---|
| **Setting name (primary)** | Require the device to be at or under the machine risk score |
| **Section in Intune UI** | Device Health > Microsoft Defender for Endpoint |
| **Value** | Clean |
| **Setting name (secondary — HAS-based)** | Code integrity |
| **Section in Intune UI** | Device Health > Windows 10 and 11 |
| **Value** | Require |

**Effect:**
For Windows 11, the concept of jailbreaking maps to two controls used together. The MDE risk score set to Clean blocks devices where Defender for Endpoint has detected tampering, rootkits, or integrity violations. Code integrity confirms the kernel and drivers are signed and the boot chain has not been modified.

**False-positive risk:**
- Devices not yet onboarded to Microsoft Defender for Endpoint will show an unknown risk score and can be treated as non-compliant depending on tenant configuration.
- Test or development machines running unsigned drivers (for example lab machines with test-signing enabled) will fail the code integrity check.
- MDE sensor delays or connectivity issues can cause the risk score to be stale or unavailable.

**Recommendation:**
- Set the MDE risk score tolerance to Low rather than Clean if the estate includes approved lab devices with unsigned drivers; document the exception formally.
- Ensure all Finance and corporate endpoints are onboarded to MDE before this policy goes live to avoid mass non-compliance on first evaluation.
- Use the Intune-MDE connector (Tenant administration > Connectors and tokens) to confirm the integration is active before enforcing risk-score compliance.
- To configure MDE integration directly: Endpoint security > Setup > Microsoft Defender for Endpoint.
- To review endpoint detection and response status: Endpoint security > Manage > Endpoint detection and response.

> ⚠️ **UI note:** The MDE risk score compliance setting requires the Intune-MDE connector to be configured. Without the connector, this setting has no effect. Confirmed paths: Tenant administration > Connectors and tokens (connector toggle) and Endpoint security > Setup > Microsoft Defender for Endpoint (full MDE integration setup).

---

## Grace Period Summary

| Requirement | Grace period | Rationale |
|---|---|---|
| BitLocker | 7 days | HAS report latency on enrolment |
| Secure Boot | 7 days | BIOS remediation may require manual IT intervention |
| Minimum OS build | 7 days | Update deferral rings and reboot scheduling |
| Real-time protection | 7 days | AV update or service restart scenarios |
| Firewall | 7 days | Third-party firewall co-existence |
| PIN or password | 7 days | Windows Hello PIN enrolment completion |
| Not jailbroken | 7 days | MDE onboarding propagation delay |

**Grace period configuration:**
Endpoint security > Device compliance > Policies > [Policy name] > Properties > Actions for noncompliance
- Action: Send email to end user — Day 1 (configure email template at Endpoint security > Device compliance > Notifications)
- Action: Mark device noncompliant — Day 7

---

## UI Path Flags (Review Before Publishing)

| Setting | Status | Path / Action |
|---|---|---|
| Compliance policy creation | **Confirmed August 2026** | Endpoint security > Device compliance > Policies > + Create policy |
| Custom compliance (Step 2 wizard) | **Confirmed August 2026** | Endpoint security > Device compliance > Policies > + Create policy > Windows 10 and later > Compliance settings > Custom compliance |
| Compliance notifications (grace period emails) | **Confirmed August 2026** | Endpoint security > Device compliance > Notifications |
| Global compliance settings | **Confirmed August 2026** | Endpoint security > Device compliance > Compliance policy settings |
| Compliance scripts | **Confirmed August 2026** | Endpoint security > Device compliance > Scripts |
| Retire noncompliant devices | **Confirmed August 2026** | Endpoint security > Device compliance > Retire noncompliant devices |
| Conditional access (enforce non-compliance) | **Confirmed August 2026** | Devices > Manage devices > Conditional access OR Endpoint security > Conditional access |
| Scripts and remediations | **Confirmed August 2026** | Devices > Manage devices > Scripts and remediations |
| Windows update rings (Req 3) | **Confirmed August 2026** | Devices > Manage updates > Windows updates |
| Assignment filters (targeting) | **Confirmed August 2026** | Devices > Organize devices > Assignment filters OR Tenant administration > Assignment filters |
| Device clean-up rules | **Confirmed August 2026** | Devices > Organize devices > Device clean-up rules |
| BitLocker policy (Req 1) | **Confirmed August 2026** | Endpoint security > Manage > Disk encryption |
| Firewall policy (Req 5) | **Confirmed August 2026** | Endpoint security > Manage > Firewall |
| Defender AV policy (Req 4) | **Confirmed August 2026** | Endpoint security > Manage > Antivirus |
| Endpoint detection and response (Req 7) | **Confirmed August 2026** | Endpoint security > Manage > Endpoint detection and response |
| MDE integration setup (Req 7) | **Confirmed August 2026** | Endpoint security > Setup > Microsoft Defender for Endpoint |
| MDE connector toggle (Req 7) | **Confirmed August 2026** | Tenant administration > Connectors and tokens |
| Security baselines | **Confirmed August 2026** | Endpoint security > Overview > Security baselines |
| Compliance policy monitoring | **Confirmed August 2026** | Endpoint security > Monitor > Assignment failures |
| Device Health / BitLocker, Secure Boot, Code integrity | **Confirmed August 2026** | Step 2: Compliance settings > Device Health > Windows 10 and 11 — exact labels: BitLocker, Secure Boot, Code integrity; toggles: Require / Not configured |
| Microsoft Defender Antivirus / Real-time protection (compliance wizard) | **Confirmed August 2026** | System Security > **Defender** > Real-time protection; toggle: Require / Not configured |
| Minimum OS version | Build string format validated on save | Use exactly 10.0.22621.2861 (Major.Minor.Build.Revision); mismatched format causes save error |

---

## Related documents
- Security baseline source: DWP security baseline (apply organisation reference here)
- L2/L3 KB for AVD black screen: day5 KB-L2L3-AVD-black-screen-POOL-FIN-01.md
- Prompt library: prompt-library.md
