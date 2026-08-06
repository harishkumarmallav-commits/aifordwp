# Triage Summary – AVD Session Disconnecting After ~10 Minutes

**Ticket ref:** T-1003  
**Date:** 2026-08-04  
**Analyst:** [to confirm]

---

## Summary
Azure Virtual Desktop session drops after approximately 10 minutes then reconnects automatically, disrupting the user's work.

## Impact
- **Who:** Single user (identity to confirm)
- **How many:** 1 user confirmed; wider AVD pool affected status unknown (to confirm)
- **Business urgency:** MEDIUM — repeated disconnections cause workflow disruption and potential data loss if unsaved work is affected; not a full outage

## Known Facts
- The user is connecting via Azure Virtual Desktop (AVD)
- Sessions disconnect after approximately 10 minutes
- The session reconnects after the disconnection (suggesting the AVD host and network are partially functional)
- The pattern is consistent (to confirm — every session or intermittent)

## Missing Information to Gather
- Whether the issue occurs on one specific AVD host pool or across multiple (to confirm)
- Whether other users on the same host pool are experiencing the same behaviour (to confirm)
- Client device type and OS the user is connecting from
- Network connection type — office LAN, home Wi-Fi, VPN (to confirm)
- Whether the disconnection time of ~10 minutes is consistent or variable
- Whether the AVD session timeout/idle disconnect policies have been changed recently (to confirm with AVD admin — do not share policy details with AI)
- Whether any AVD or Windows updates were applied to the host pool recently
- Whether event logs on the host or client show a specific disconnect reason (to confirm — do not paste raw logs containing user or device data into AI tools)
- Whether the user loses session state (running apps, unsaved work) on disconnect

## Likely Category
- **Primary:** Remote Access / Azure Virtual Desktop
- **Sub-category (to confirm):** AVD session timeout policy misconfiguration, network instability causing keep-alive failure, or idle disconnect policy applied incorrectly

## First Diagnostic Step
Check the AVD host pool session timeout and idle disconnection policy settings in the Azure portal to confirm whether a short timeout value has been set or recently changed. Compare against the ~10-minute window reported. If policy appears correct, ask the user to note the exact time of disconnection on next occurrence and cross-reference with AVD diagnostic logs in Azure Monitor — without sharing raw log output containing user data with AI tools.
