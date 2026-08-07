# Incident Analysis — Print Spooler Service Failure
## Event Log Analysis, Sequence Reconstruction, and Root Cause Determination

| Field              | Detail                                              |
|--------------------|-----------------------------------------------------|
| **Incident date**  | 2024-03-15                                          |
| **Affected service** | Print Spooler (spoolsv.exe)                       |
| **Impact**         | Complete printing outage — service unable to start  |
| **Impact window**  | 10:01:14 onwards (unresolved in log window)         |
| **Authored by**    | DWP Analyst                                         |

---

## 1. Raw Event Log Entries

```
10:01:14  System  7034  Error  SCM
          The Print Spooler service terminated unexpectedly. It has done this 1 time(s).

10:01:45  System  7034  Error  SCM
          The Print Spooler service terminated unexpectedly. It has done this 2 time(s).

10:02:16  System  7034  Error  SCM
          The Print Spooler service terminated unexpectedly. It has done this 3 time(s).

10:02:47  System  7031  Error  SCM
          The Print Spooler service terminated unexpectedly. It has done this 4 time(s).
          The following corrective action will be taken in 60000 milliseconds: Restart the service.

10:03:49  System  7023  Error  SCM
          The Print Spooler service terminated with the following error:
          The specified module could not be found.

10:03:50  System  7038  Error  SCM
          The Print Spooler service was unable to log on as NT AUTHORITY\SYSTEM with the
          currently configured password due to the following error:
          Logon failure: the user has not been granted the requested logon type at this computer.
```

---

## 2. Event ID Explanations

| Event ID | Source | What it records |
|----------|--------|----------------|
| **7034** | Service Control Manager | The named service crashed or exited without being stopped by the SCM. Records a running count of unexpected terminations. **No recovery action is fired** — either no action is configured for this failure count, or the failure-count threshold for a recovery action has not yet been reached. |
| **7031** | Service Control Manager | Same as 7034, but the failure count has now reached the threshold where a **configured recovery action applies**. Records what action will be taken and the delay before it is executed. Here: restart in 60 seconds. |
| **7023** | Service Control Manager | The service terminated with a specific Windows error code rather than a clean exit. "The specified module could not be found" is Win32 error **126 (ERROR\_MOD\_NOT\_FOUND)** — the service's executable or a DLL it depends on cannot be located on disk. |
| **7038** | Service Control Manager | The service failed to authenticate its configured service account against the local security policy. Records the account and the logon failure reason. **NT AUTHORITY\SYSTEM failing a logon type check is highly abnormal** — SYSTEM should always have service logon rights unless a Group Policy has explicitly restricted it. |

---

## 3. Critical Evidence Decoded

### 7034 fires three times before 7031 fires once
Service recovery in Windows is configured per-failure tier: "First failure", "Second failure", "Subsequent failures". The pattern here — three bare crashes (7034) followed by one recovery-action crash (7031) — indicates the recovery policy is configured to act only on the **4th failure or later** (or "Subsequent failures" after a reset interval). The first three crashes burned through the no-action tiers before the restart action engaged.

### Event 7023 — "The specified module could not be found" (Error 126)
This error fires when the SCM attempts the 60-second restart and the spooler **immediately fails to start**. Error 126 means a required DLL cannot be found on disk. For the Print Spooler, this points to one of:

- A **printer driver DLL** in `C:\Windows\System32\spool\drivers\` that has been deleted, quarantined by antivirus, or corrupted
- A **spooler plug-in or monitor DLL** registered in the registry but no longer present on disk
- A **PrintNightmare (CVE-2021-34527) remediation** that removed a driver DLL without cleaning up its registry entry

The spooler loads all registered printer driver DLLs at startup — a single missing DLL causes the entire service to fail to initialise.

### Event 7038 — NT AUTHORITY\SYSTEM denied logon type — **extremely abnormal**
`NT AUTHORITY\SYSTEM` is the most privileged built-in Windows account. It is hardcoded to have "Log on as a service" rights on every Windows installation. The only mechanisms that can revoke this are:

1. A **Group Policy Object** that populates `Deny log on as a service` (SeServiceLogonRight denied) with SYSTEM or removes SYSTEM from `Log on as a service`
2. A **local security policy** misconfiguration (less likely on a domain-joined machine)
3. A **security hardening script** that incorrectly overwrote the default user rights assignments

The presence of this event alongside 7023 indicates **two compounding faults**, not one. Even if the missing DLL were fixed, the service would still fail to start due to the logon rights issue.

---

## 4. Sequence of Events (Plain English)

1. **10:01:14** — The Print Spooler crashes for the first time. The SCM logs it but takes no recovery action (first failure tier — no action configured).

2. **10:01:45** — The spooler crashes a second time, approximately 31 seconds later. Same behaviour — no recovery action. The consistent ~31-second interval suggests the SCM is auto-restarting it on tiers 1–3 despite 7034 not recording a configured action, or the service is crashing during a rapid restart cycle.

3. **10:02:16** — Third crash, again ~31 seconds later. No recovery action.

4. **10:02:47** — Fourth crash. This time the failure count triggers the configured recovery action: **restart the service in 60 seconds**.

5. **10:03:49** — The 60-second delay expires and the SCM attempts to start the Print Spooler. The service **immediately fails with error 126** — a required DLL cannot be found. The service cannot initialise.

6. **10:03:50** — One second later, the SCM records a second failure: **NT AUTHORITY\SYSTEM is denied the requested logon type**. A Group Policy has stripped SYSTEM's service logon rights. Even without the missing DLL, the service account cannot authenticate to start.

7. **Result** — The Print Spooler is completely dead. Both a missing DLL and a GPO logon rights misconfiguration are blocking recovery. Printing is unavailable.

---

## 5. Root Cause Analysis

### Two compounding root causes are present simultaneously

#### Root Cause 1 — Missing or quarantined printer driver DLL (Event 7023)
A registered printer driver DLL has been removed from disk — most likely quarantined by an antivirus or endpoint protection product responding to a threat (potentially PrintNightmare-related), or deleted as part of a driver cleanup — without its registry entry being removed. The Print Spooler loads all registered driver DLLs at startup; a single missing module causes Error 126 and immediate service failure.

**Evidence:** Event 7023 fires at the exact moment the recovery restart is attempted, confirming the service cannot load — not that it crashes after loading.

#### Root Cause 2 — GPO has removed NT AUTHORITY\SYSTEM's service logon rights (Event 7038)
A Group Policy change has incorrectly modified the `Log on as a service` or `Deny log on as a service` user rights assignment, revoking SYSTEM's ability to start services. This is a misconfiguration — SYSTEM should never require this right to be explicitly granted because it is a default; removing it is an abnormal hardening action.

**Evidence:** Event 7038 fires one second after 7023, confirming the logon rights failure is independent of and compounding the DLL issue.

**Combined effect:** Even if the missing DLL were restored, the service would still fail. Even if the logon rights were fixed, the service would still crash on the missing DLL. Both must be resolved simultaneously.

---

## 6. 5 Whys Analysis

| Why | Question | Answer |
|-----|----------|--------|
| 1 | Why is printing unavailable? | The Print Spooler service has crashed repeatedly and cannot restart. |
| 2 | Why can the Print Spooler not restart? | Two blocking faults: (a) a required driver DLL is missing from disk (Error 126), and (b) NT AUTHORITY\SYSTEM has been denied the service logon type by Group Policy. |
| 3 | Why is a driver DLL missing? | An antivirus or endpoint protection product quarantined or deleted a printer driver DLL — likely as a response to a PrintNightmare-pattern detection — without cleaning up the corresponding registry registration in the spooler driver store. |
| 4 | Why were SYSTEM's service logon rights revoked? | A Group Policy Object was deployed that incorrectly modified the `Log on as a service` or `Deny log on as a service` user rights assignment, removing the implicit SYSTEM right. |
| 5 | Why were these changes not caught before impact? | The antivirus remediation lacked a post-quarantine service-health check; and the GPO change was not tested against baseline service logon rights before being applied to production systems. |

---

## 7. Recommended Resolution Steps

Perform in order — both issues must be resolved:

### Step 1 — Fix the GPO logon rights (Event 7038) first
This must be fixed before the service can start, regardless of the DLL issue.

1. Run `gpresult /h gpresult.html` and review applied GPOs for user rights assignments.
2. Identify any policy setting `Deny log on as a service` that includes `NT AUTHORITY\SYSTEM`, or any `Log on as a service` policy that omits SYSTEM.
3. Correct the offending GPO and run `gpupdate /force`.
4. Alternatively, temporarily override via Local Security Policy (`secpol.msc` → Local Policies → User Rights Assignment → Log on as a service → ensure SYSTEM is listed).

### Step 2 — Identify and resolve the missing DLL (Event 7023)

1. Check the antivirus quarantine log for any DLL quarantined from `C:\Windows\System32\spool\drivers\` around 10:01–10:03.
2. If quarantined in error: restore the file and verify its digital signature. If it is a legitimate Microsoft-signed driver DLL, add the path to the AV exclusion list.
3. If the DLL was legitimately malicious: remove its registry entry from the spooler driver store.
   - Open `regedit` and navigate to `HKLM\SYSTEM\CurrentControlSet\Control\Print\Environments\Windows x64\Drivers\`
   - Locate the driver entry referencing the missing DLL and delete it.
4. Run `sc start spooler` after both fixes are in place.

### Step 3 — Validate

```powershell
# Confirm service is running
Get-Service -Name Spooler | Select-Object Status, StartType

# Confirm no new 7023/7034/7038 events in the last 10 minutes
Get-WinEvent -LogName System -MaxEvents 50 |
  Where-Object { $_.Id -in 7023,7031,7034,7038 } |
  Select-Object TimeCreated, Id, Message
```

---

## 8. Preventive and Corrective Actions

| Priority | Action | Owner |
|----------|--------|-------|
| High | When AV quarantines a file in `spool\drivers\`, automatically trigger a spooler health check and alert the endpoint team before the service crashes | Security / Endpoint Engineering |
| High | Add post-quarantine automated test: attempt `sc query spooler` and alert if the service fails to start within 2 minutes of a quarantine event | Security / Endpoint Engineering |
| High | Add GPO change review gate requiring baseline comparison of user rights assignments before any security policy GPO is promoted to production | Desktop Engineering / GPO Admins |
| Medium | Monitor Event IDs 7034, 7031, 7023, 7038 for the Print Spooler in SIEM; alert on any 7023 or 7038 immediately | SOC / Operations |
| Medium | Maintain a documented inventory of all registered printer driver DLLs per host group — enables rapid identification of the missing module during incidents | Desktop Engineering |
| Low | Review PrintNightmare mitigation posture — ensure the remediation approach (driver removal vs. policy restriction) is consistent and does not leave orphaned registry entries | Security Architecture |

---

## 9. Key Diagnostic Indicators (for Future Reference)

A Print Spooler outage with this event combination indicates **two independent compounding faults** — both must be fixed:

| Event | Meaning |
|-------|---------|
| Multiple **7034** → then **7031** | Crash loop exhausting service recovery tiers |
| **7023** "specified module could not be found" | Missing DLL in spooler driver store — check AV quarantine |
| **7038** for NT AUTHORITY\SYSTEM | GPO has broken SYSTEM's service logon rights — check user rights assignment GPO |

> If only 7023 is present without 7038, focus on the missing DLL.
> If only 7038 is present without 7023, focus on the GPO.
> When both appear together, fix the GPO first — otherwise any DLL fix cannot be tested.

---

*Analysis authored by: DWP Analyst | Incident date: 2024-03-15 | Stored: day3*
