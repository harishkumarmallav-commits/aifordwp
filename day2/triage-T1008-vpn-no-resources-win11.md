# Triage Summary – VPN Connects But No Internal Resources Reachable After Win11 Upgrade

**Ticket ref:** T-1008  
**Date:** 2026-08-04  
**Analyst:** [to confirm]

---

## Summary
VPN connects successfully after a Windows 11 upgrade but the user cannot reach any internal resources once connected.

## Impact
- **Who:** Single end user (identity to confirm)
- **How many:** 1 user confirmed; if others were upgraded in the same batch, wider impact is possible (to confirm)
- **Business urgency:** HIGH — user is fully blocked from all internal systems when working remotely; device is effectively unusable for DWP work outside the office

## Known Facts
- The device was upgraded to Windows 11 (upgrade date to confirm)
- The VPN client establishes a connection successfully (authentication is passing)
- Despite a connected VPN state, no internal resources are reachable (e.g. intranet, internal drives, internal applications — specifics to confirm)
- The issue began after the Windows 11 upgrade (direct causation not confirmed, but timing is strongly correlated)

## Missing Information to Gather
- VPN client name and version (to confirm — do not share internal VPN hostnames, server addresses, or configuration with AI tools)
- Whether the VPN client and/or its drivers were updated or reinstalled as part of the Win11 upgrade process
- Whether the issue affects all internal resources or only specific ones
- Whether DNS resolution is working over VPN (e.g. can the user ping an internal hostname by name vs by IP — do not share real hostnames with AI tools)
- Whether split tunnelling is configured on the VPN profile and whether its behaviour may have changed post-upgrade (to confirm)
- Whether the Windows Firewall profile is correctly set to Domain or Private when VPN is connected, rather than Public (to confirm)
- Whether the VPN adapter appears correctly in Network Connections post-upgrade
- Whether other Win11-upgraded devices on the same VPN profile have the same issue (to confirm)
- Whether the device has been rebooted after the upgrade and after the VPN issue was first observed

## Likely Category
- **Primary:** Remote Access / VPN Connectivity
- **Sub-category (to confirm):** Network routing issue post-upgrade (VPN routes not being applied correctly), Windows Firewall profile misclassifying the VPN adapter as Public, or VPN client incompatibility with Windows 11

## First Diagnostic Step
With VPN connected on the affected device, check the Windows Firewall network profile assigned to the VPN adapter — if it is showing as a Public network rather than Domain or Private, this alone would block access to internal resources. This is a known behaviour change that can occur after an in-place OS upgrade. Verify via Windows Security → Firewall → Network type, or via Network and Sharing Centre. Also confirm the VPN client version is supported on Windows 11 and check the vendor's compatibility notes before making any configuration changes.
