# Incident Analysis — Outlook Crash: KERNELBASE.dll Access Violation
## Event Log Analysis, Sequence Reconstruction, and Root Cause Determination

| Field              | Detail                                              |
|--------------------|-----------------------------------------------------|
| **Incident date**  | 2024-03-15                                          |
| **Affected app**   | OUTLOOK.EXE version 16.0.17126.20132                |
| **Faulting module**| KERNELBASE.dll version 10.0.22621.3155              |
| **Exception code** | 0xc0000005 (Access Violation)                       |
| **Impact window**  | 09:13:44 – 09:18:05                                 |
| **Authored by**    | DWP Analyst                                         |

---

## 1. Raw Event Log Entries

### Event 1 — First Outlook crash
```
Log Name:   Application
Source:     Application Error
Event ID:   1000
Level:      Error
Date:       2024-03-15 09:14:22

Faulting application name:    OUTLOOK.EXE, version: 16.0.17126.20132
Faulting module name:         KERNELBASE.dll, version: 10.0.22621.3155
Exception code:               0xc0000005
Fault offset:                 0x000000000003a4b2
Faulting process ID:          0x1f4c
Faulting application start time: 2024-03-15 09:13:44
Faulting application path:    C:\Program Files\Microsoft Office\root\Office16\OUTLOOK.EXE
Faulting module path:         C:\Windows\System32\KERNELBASE.dll
Report ID:                    a3c2f1d4-89bb-4e21-91d7-f2c3a1b09e44
```

### Event 2 — Second Outlook crash
```
Log Name:   Application
Source:     Application Error
Event ID:   1000
Level:      Error
Date:       2024-03-15 09:17:45

Faulting application name:    OUTLOOK.EXE, version: 16.0.17126.20132
Faulting module name:         KERNELBASE.dll, version: 10.0.22621.3155
Exception code:               0xc0000005
Fault offset:                 0x000000000003a4b2
```

### Event 3 — Windows Error Reporting
```
Log Name:   Application
Source:     Windows Error Reporting
Event ID:   1001
Level:      Information
Date:       2024-03-15 09:18:01

Description: Fault bucket 1847362910, type 4
Event Name:  APPCRASH
Response:    Not available
Cab Id:      0
```

### Event 4 — .NET Runtime termination
```
Log Name:   Application
Source:     .NET Runtime
Event ID:   1026
Level:      Error
Date:       2024-03-15 09:18:05

Application:       OUTLOOK.EXE
Framework Version: v4.0.30319
Description:       The process was terminated due to an unhandled exception.
Exception Info:    System.AccessViolationException
```

---

## 2. Event ID Explanations

| Event ID | Source | What it records |
|----------|--------|----------------|
| **1000** | Application Error | An application crashed. Records the faulting executable, its version, the DLL where the crash occurred, the exception code (type of fault), the exact fault offset (instruction address within the DLL), the process ID, the executable start time, and full file paths. This is the primary crash record. |
| **1001** | Windows Error Reporting | WER has processed the crash report. Assigns a **fault bucket ID** used to group identical or similar crash signatures for telemetry and pattern matching. `Response: Not available` means no automated fix or KB article was returned from Microsoft's WER service. |
| **1026** | .NET Runtime | A .NET managed process was killed by an unhandled exception that propagated to the CLR boundary. Records the framework version and the managed exception type. Confirms the crash also manifested at the managed (.NET) layer, not just the native layer. |

---

## 3. Critical Evidence Decoded

### Exception code: 0xc0000005 — Access Violation
An access violation means the process attempted to read from or write to a memory address that it does not have permission to access — either a null pointer, a freed/corrupted heap block, or a pointer that was never initialised. This is the native Windows equivalent of a `NullReferenceException` or `System.AccessViolationException` in managed code.

### Fault offset: 0x000000000003a4b2 in KERNELBASE.dll — **identical in both crashes**
The fault offset is the instruction address *within* the faulting module where execution failed. The fact that both crashes share the exact same offset is the most diagnostic piece of evidence in this log set:

- It means Outlook is **deterministically** hitting the same code path with a bad pointer.
- A random heap corruption would typically produce varying offsets across crashes.
- A consistent offset points to a **specific code path** — most likely a Windows API call (e.g., `RaiseException`, `HeapFree`, `VirtualAlloc`, or similar KERNELBASE-exported functions) being called with an invalid argument.

### Crash timing: 38 seconds after start
Outlook started at **09:13:44** and crashed at **09:14:22** — only 38 seconds into the session. This timing places the crash squarely in Outlook's **startup and initialisation phase**, which includes:
- Profile loading
- OST/PST data file attachment
- MAPI subsystem initialisation
- COM add-in loading
- Exchange/AutoDiscover connection establishment

### Two crashes, 3 minutes apart, same signature
Outlook crashed at 09:14:22 and again at 09:17:45 with an identical signature. This indicates the user (or an automated restart mechanism) launched Outlook a second time, and the same crash reproduced identically — confirming the fault is **persistent and deterministic**, not a transient race condition.

### Event 1026 — System.AccessViolationException from .NET Runtime
Outlook hosts managed (.NET) add-ins and components alongside native code. The .NET Runtime event confirms that the access violation was not fully caught in native code — it propagated through to the CLR, which terminated the process. This pattern is strongly associated with a **COM add-in or managed Outlook extension** triggering a memory corruption that crosses the native/managed boundary.

---

## 4. Sequence of Events (Plain English)

1. **09:13:44** — The user launches Outlook (OUTLOOK.EXE, process 0x1f4c). Startup begins: profile loads, add-ins initialise, data files attach.

2. **09:14:22** — 38 seconds into startup, Outlook crashes. The crash occurs inside `KERNELBASE.dll` at offset `0x3a4b2` with a memory access violation (0xc0000005). The process terminates.

3. **Shortly after 09:14** — The user or an automated recovery mechanism relaunches Outlook.

4. **09:17:45** — Outlook crashes a second time with an **identical** event signature — same module, same fault offset, same exception code. The fault is fully reproducible.

5. **09:18:01** — Windows Error Reporting processes the crash, assigns it to fault bucket `1847362910`, and queries Microsoft for a known fix. No response is returned (`Response: Not available`).

6. **09:18:05** — The .NET Runtime logs the final process termination, confirming the access violation reached managed code and was reported as `System.AccessViolationException`. Outlook is dead.

---

## 5. Root Cause Analysis

### Most Likely Cause: Corrupt Outlook profile or OST data file — or a faulty COM add-in — triggering a deterministic access violation via a Windows API call in KERNELBASE.dll

**Evidence supporting this conclusion:**

| Evidence | Interpretation |
|----------|---------------|
| Same fault offset (0x3a4b2) in both crashes | Deterministic crash — not random heap corruption; something specific is passing a bad pointer to a Windows API |
| Crash at 38 seconds (startup phase) | The fault is triggered during profile/OST load or add-in initialisation, not during normal user operation |
| KERNELBASE.dll as faulting module | Outlook is calling a core Windows API (heap, exception, or memory management) with an invalid argument — the real corruption likely occurs in Outlook or an add-in before the API call |
| System.AccessViolationException from .NET Runtime (Event 1026) | Managed code (an Outlook add-in or .NET component) is involved; the AV crossed the native-to-managed boundary |
| Crash reproduces on second launch with identical signature | The corrupting condition persists across process restarts — pointing to on-disk corruption (OST, profile registry keys) or a persistently loaded add-in, not a transient runtime state |
| WER Response: Not available | No Microsoft-published fix for this exact fault bucket — suggests a local environment-specific cause rather than a widely known Outlook build bug |

### Alternative causes (lower probability)

| Cause | Assessment |
|-------|-----------|
| Known Outlook build bug in 16.0.17126.20132 | Possible but WER returned no KB — less likely to be a widespread build defect |
| Corrupt Windows system file (KERNELBASE.dll itself) | Very unlikely — KERNELBASE.dll corruption would cause wider system instability beyond just Outlook |
| Antivirus/security product injecting into Outlook | Can cause access violations in KERNELBASE; worth checking if AV hooks are present, especially after a recent AV update |

---

## 6. 5 Whys Analysis

| Why | Question | Answer |
|-----|----------|--------|
| 1 | Why did Outlook crash? | Because the process encountered a memory access violation (0xc0000005) during startup that was not handled. |
| 2 | Why did an access violation occur? | Because a bad or null pointer was passed to a Windows API call in KERNELBASE.dll at a specific, repeatable code path (offset 0x3a4b2). |
| 3 | Why was a bad pointer being generated? | Because a corrupt Outlook profile, OST data file, or a faulty COM/managed add-in introduced memory corruption during the startup initialisation sequence. |
| 4 | Why was the corrupting data or add-in present on this machine? | Either the OST file was corrupted during a previous abnormal Outlook shutdown, a profile setting became invalid, or an add-in was installed/updated in a broken state. |
| 5 | Why did the issue persist across restarts without self-healing? | Because the corrupt data is on disk (OST or registry profile keys) or the add-in continues to load — no automated remediation (OST rebuild, profile repair, or add-in rollback) was triggered. |

---

## 7. Recommended Diagnostic Steps

Perform in order — stop when the fault is identified:

1. **Disable all COM add-ins**
   - Start Outlook in safe mode: `outlook.exe /safe`
   - If Outlook starts successfully, a COM add-in is the cause.
   - Re-enable add-ins one at a time to identify the offender.

2. **Rebuild the OST file**
   - Close Outlook.
   - Navigate to `%LOCALAPPDATA%\Microsoft\Outlook\` and rename the `.ost` file (e.g., append `.old`).
   - Relaunch Outlook — it will rebuild the OST from the Exchange mailbox.
   - If Outlook starts cleanly, the OST was corrupted.

3. **Create a new Outlook profile**
   - Open Control Panel → Mail → Show Profiles → Add.
   - Configure a new profile and set it as default.
   - If this resolves the crash, the original profile's registry keys were corrupt.

4. **Run Office repair**
   - Settings → Apps → Microsoft 365 → Modify → Quick Repair.
   - If Quick Repair fails to resolve, run Online Repair.
   - This will replace any corrupt Office binaries including Outlook components.

5. **Check antivirus exclusions**
   - Verify the AV product excludes `%LOCALAPPDATA%\Microsoft\Outlook\` and the Office installation directory.
   - Check for a recent AV definition or engine update on 2024-03-15 that may have changed injection behaviour.

---

## 8. Preventive and Corrective Actions

| Priority | Action | Owner |
|----------|--------|-------|
| High | Implement Outlook safe-mode test as first-line step in all Outlook crash tickets to immediately determine add-in vs. data file cause | Service Desk |
| High | Add OST file integrity check to endpoint health scripts — flag OST files over 25 GB or with recent abnormal growth | Endpoint Engineering |
| Medium | Review COM add-in inventory across the estate; remove or update add-ins not verified against the current Outlook build version | Desktop Engineering |
| Medium | Ensure Office Online Repair is included in the standard break-fix runbook for Event ID 1000 OUTLOOK.EXE crashes | Service Desk |
| Low | Configure WER to collect full crash dumps for OUTLOOK.EXE to enable deeper analysis of the specific API call at offset 0x3a4b2 if the issue recurs | Endpoint Engineering |

---

## 9. Key Diagnostic Indicators (for Future Reference)

An Outlook crash with these characteristics strongly suggests **add-in or data file corruption** rather than an OS or network issue:

- Event 1000: `OUTLOOK.EXE` faulting in `KERNELBASE.dll`
- Exception code `0xc0000005`
- **Same fault offset across multiple crashes** (deterministic)
- Crash within 60 seconds of Outlook start (startup phase)
- Event 1026 `System.AccessViolationException` present alongside Event 1000

The safe-mode test (`outlook.exe /safe`) is the fastest triage step and should be performed before any other investigation.

---

*Analysis authored by: DWP Analyst | Incident date: 2024-03-15 | Stored: day3*
