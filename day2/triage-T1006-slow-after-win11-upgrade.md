# Triage Summary – General Performance Degradation After Win11 Upgrade

**Ticket ref:** T-1006  
**Date:** 2026-08-04  
**Analyst:** [to confirm]

---

## Summary
User reports that everything is slow following a Windows 11 upgrade carried out two days ago.

## Impact
- **Who:** Single end user (identity and team to confirm)
- **How many:** 1 user confirmed; if the upgrade was part of a batch rollout, other users may be affected (to confirm)
- **Business urgency:** MEDIUM — user productivity is significantly impaired but the device remains operational

## Known Facts
- The device was upgraded to Windows 11 two days ago (approximately 2026-08-02)
- The user reports general slowness across the device (specific apps or actions not detailed)
- Slowness began after the upgrade (direct causation not confirmed, but timing is strongly correlated)

## Missing Information to Gather
- Device make, model, and hardware specification — particularly RAM and storage type (SSD vs HDD), as Win11 has higher baseline requirements (to confirm)
- Whether the device meets Microsoft's minimum hardware requirements for Windows 11
- Whether the upgrade was in-place or a clean install
- Whether specific applications are slow or the entire system is affected
- Whether disk usage, CPU, or memory is consistently high (Task Manager or Resource Monitor data — do not share outputs containing usernames or device identifiers with AI tools)
- Whether Windows 11 post-upgrade tasks (indexing, background optimisation, driver updates) are still running
- Whether any drivers were not updated as part of the upgrade (particularly display, storage, or chipset drivers)
- Whether the issue has improved, stayed the same, or worsened since the upgrade
- Whether a rollback to Windows 10 is within the 10-day rollback window (to confirm — deadline would be approximately 2026-08-12)

## Likely Category
- **Primary:** Endpoint Performance / OS Upgrade
- **Sub-category (to confirm):** Post-upgrade background processing still running, hardware below Win11 optimal spec, or driver compatibility issue

## First Diagnostic Step
Check Task Manager (Ctrl+Shift+Esc) on the device and review the CPU, Memory, and Disk columns to identify which resource is under pressure and which process is consuming it. Pay particular attention to high disk usage, which is common in the first few days after an in-place upgrade due to background indexing and optimisation tasks. If a specific process is responsible, note the process name before taking further action. Do not share raw Task Manager output containing real usernames or device names with AI tools.
