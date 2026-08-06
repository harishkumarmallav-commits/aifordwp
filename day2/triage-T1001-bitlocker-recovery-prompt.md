# Triage Summary – BitLocker Recovery Key Prompt on Every Boot

**Ticket ref:** T-1001  
**Date:** 2026-08-04  
**Analyst:** [to-verify]

---

## Summary
New Windows 11 laptop is prompting for a BitLocker recovery key on every boot, preventing normal access.

## Impact
- **Who:** Single end user assigned to the new laptop (identity to-verify)
- **How many:** 1 device affected; may indicate a wider provisioning issue if other new laptops are being deployed from the same image (to-verify)
- **Business urgency:** HIGH — device is unusable without the recovery key at every boot; user cannot work normally

## Known Facts
- Device is a new Windows 11 laptop
- BitLocker is enabled on the device
- The recovery key prompt appears on every boot, not just once
- The issue is present from the point of provisioning/first use (to-verify — may have started after a specific event)

## Missing Information to Gather
- Device asset tag / serial number (use placeholder e.g. DEVICE_01 if sharing with AI tools)
- How the device was provisioned — Autopilot, manual build, SCCM/MDM image (to-verify)
- Whether the device is joined to Azure AD, on-premises AD, or hybrid joined (to-verify)
- Whether a recovery key is stored in Azure AD or AD and can be retrieved by the service desk
- Whether Secure Boot or TPM settings have been changed or are correctly configured (to-verify)
- TPM chip presence and status (to-verify)
- Whether any BIOS/UEFI updates were applied during or after provisioning
- Whether the user has been able to enter the recovery key and boot successfully, or is fully locked out
- Whether other new laptops from the same batch are exhibiting the same behaviour (to-verify)
- Whether any Group Policy or Intune BitLocker policy was applied that may have changed PCR (Platform Configuration Register) settings (to-verify)

## Likely Category
- **Primary:** Endpoint Security / BitLocker
- **Sub-category (to-verify):** TPM measurement mismatch causing BitLocker to distrust the boot state, or BitLocker policy misconfiguration during provisioning

## First Diagnostic Step
Retrieve the BitLocker recovery key for the device from Azure AD (Entra ID) or Active Directory — do not ask the user to share it verbally or in writing. Confirm the device can boot successfully using the key. Then check the TPM status in Windows Security settings or via tpm.msc (availability to-verify on the build) and confirm whether Secure Boot is enabled and correctly configured in BIOS/UEFI. If TPM appears healthy, review the Intune or Group Policy BitLocker configuration applied to new devices to identify whether a policy change is forcing repeated key prompts.
