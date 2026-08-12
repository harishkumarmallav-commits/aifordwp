# Analysis — DEX Startup Performance Drop: Finance-Win11

**Date:** 2026-08-12  
**Analyst:** DWP Service Desk  
**Affected group:** Finance-Win11 (215 devices)  
**Trigger event:** Security baseline configuration profile deployed 2026-08-04 02:00  
**Observed drop:** Score 82–84 → 59–61 (−23 points); median startup 18 s → 42 s (+24 s)  
**Comparison group:** IT-Win11 (40 devices) — no config change, no degradation

---

## Ranked Causes — Most Probable First

---

### 1. Startup compliance-logging script executing synchronously at login

**Why it fits the evidence**

The config change explicitly added a startup script for compliance logging. Windows startup scripts assigned via Intune or Group Policy run synchronously during the login phase by default — the desktop is held until the script completes. A 24-second increase is consistent with a script that performs file I/O, registry reads, or network calls before exiting. The degradation appeared on the exact day and cohort of deployment, and IT-Win11, which received no script, shows zero change across the same window. The effect is also stable day-on-day (41–44 s), which matches a script with a consistent execution path rather than a transient background process.

**Fastest check to confirm or eliminate**

On an affected Finance-Win11 device, open Event Viewer → **Applications and Services Logs → Microsoft → Windows → GroupPolicy → Operational**. Look for script execution events timestamped within the login window. Alternatively, run `gpresult /h report.html` and inspect the startup scripts section for assigned scripts and their reported execution times. If the script appears and its duration accounts for ~24 s, this is the primary cause.

---

### 2. Additional Defender scan policy triggering a scan at every startup

**Why it fits the evidence**

The config change also added an additional Defender scan policy. If this policy schedules or forces a scan to begin at device startup (e.g. a quick scan triggered on login or a scheduled task set to "run at startup"), it would saturate disk and CPU during the login-to-usable-desktop window, delaying shell responsiveness. The timing is exact — first occurrence on 2026-08-04, Finance-Win11 only. IT-Win11 retained its baseline, consistent with having no new Defender policy. The magnitude (24 s) is plausible for a quick scan on a modern endpoint; a full scan would typically be larger.

**Fastest check to confirm or eliminate**

On an affected device, check Task Manager (or Resource Monitor) immediately after login and observe whether **MsMpEng.exe** (Windows Defender Antivirus Service) is consuming high CPU or disk I/O during the startup window. Then review **Event Viewer → Windows Logs → Application** for Windows Defender scan-start events (Event ID 1000 or 2000) timestamped at or just after login. Also inspect the Intune Endpoint Security policy applied to Finance-Win11 to confirm whether scan timing is set to "At startup" or "On login".

---

### 3. Compliance-logging script making a network call that times out or waits

**Why it fits the evidence**

If the compliance-logging script contacts a logging endpoint, domain controller, or cloud service during execution, and that connection either takes time to establish or waits for a retry on partial failure, the delay would be consistent and reproducible — matching the flat 41–44 s pattern across all three post-change days. The 24-second delta is characteristic of a network timeout with a fixed retry interval rather than a fixed computation. This is a sub-variant of cause 1 but with a distinct failure mode: the script itself may be working as designed, but the network dependency is the bottleneck. IT-Win11 is unaffected because it has no such script.

**Fastest check to confirm or eliminate**

While logged in to an affected device, open **Process Monitor** (Sysinternals), filter on the script process name, and observe whether any network operations show "TIMEOUT" or long-wait results during login. Alternatively, capture a **Windows Performance Recorder (WPR)** boot trace (`wpr -start GeneralProfile`) and review the login phase in **Windows Performance Analyzer** for network wait time attributed to the script process. A simpler proxy: temporarily disconnect the device from the network before login and measure startup time — if it returns to baseline, a network dependency in the script is confirmed.

---

## Summary Table

| Rank | Cause | Key evidence fit | Fastest check |
|---|---|---|---|
| 1 | Startup script running synchronously | Direct mechanism for login delay; exact timing; comparison group clean | Event Viewer GroupPolicy Operational log + `gpresult` |
| 2 | Defender scan policy at startup | High disk/CPU during login window; same deployment timing; exact cohort | Task Manager / MsMpEng.exe at login + Defender Event IDs 1000/2000 |
| 3 | Script network call timing out | Explains flat 24 s delta (fixed timeout); same deployment timing | Process Monitor network ops during login; offline login test |
