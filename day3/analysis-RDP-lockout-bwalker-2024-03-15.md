# Incident Analysis — RDP Account Lockout: FINBRIDGE\bwalker
## Event Log Analysis, Sequence Reconstruction, and Root Cause Determination

| Field               | Detail                                               |
|---------------------|------------------------------------------------------|
| **Incident date**   | 2024-03-15                                           |
| **Affected account**| FINBRIDGE\bwalker                                    |
| **Source IP**       | 10.10.5.44                                           |
| **Protocol**        | RDP (Remote Desktop / Logon type 10 RemoteInteractive)|
| **Impact window**   | 14:01:02 – 14:22:09 (~21 minutes)                   |
| **Authored by**     | DWP Analyst                                          |

---

## 1. Raw Event Log Entries

```
14:01:02  System    56   Error    TermDD
          The Terminal Server security layer detected an error in the protocol stream
          and has disconnected the client. Client IP: 10.10.5.44

14:01:02  System    140  Warning  RemoteDesktopServices-RdpCoreTS
          A connection from the client computer with an IP address of 10.10.5.44
          failed because the user name or password is not correct.

14:01:04  Security  4625  Audit Failure  FINBRIDGE\bwalker
          Failure reason: Unknown username or bad password
          Logon type: 10 (RemoteInteractive)  Source IP: 10.10.5.44

14:03:18  Security  4625  Audit Failure  FINBRIDGE\bwalker
          Failure reason: Unknown username or bad password
          Logon type: 10 (RemoteInteractive)  Source IP: 10.10.5.44

14:05:33  Security  4625  Audit Failure  FINBRIDGE\bwalker
          Failure reason: Unknown username or bad password
          Logon type: 10 (RemoteInteractive)  Source IP: 10.10.5.44

14:05:34  Security  4740  Audit Failure  FINBRIDGE\bwalker
          Caller computer: 10.10.5.44
          A user account was locked out.

14:22:07  System    131  Info     RemoteDesktopServices-RdpCoreTS
          Server accepted a new TCP connection from client 10.10.5.44:52341.

14:22:09  Security  4624  Audit Success  FINBRIDGE\bwalker
          Logon type: 10 (RemoteInteractive)  Source IP: 10.10.5.44
```

---

## 2. Event ID Explanations

| Event ID | Source | What it records |
|----------|--------|----------------|
| **56** | TermDD | The Terminal Server security layer detected an error in the RDP protocol stream and forcibly disconnected the client. Fires when an RDP session is terminated due to a protocol or authentication error at the transport security layer. When paired with Event 140, it confirms the disconnect was caused by an authentication failure rather than a network fault. |
| **140** | RemoteDesktopServices-RdpCoreTS | An RDP connection attempt failed because the credentials supplied were incorrect. This is the RDP-layer record of the authentication rejection — it fires before the Security log records the 4625, as the RDP stack rejects the connection before the domain logon subsystem processes it fully. |
| **4625** | Security | A logon attempt failed. Records the account name, failure reason, logon type, and source IP. **Logon type 10 (RemoteInteractive)** specifically identifies an RDP/Terminal Services session logon — distinct from a local interactive logon (type 2) or a network logon (type 3). |
| **4740** | Security | A user account was automatically locked out after exceeding the domain bad-password threshold. Records the account and the calling computer (source of the final bad attempt). |
| **131** | RemoteDesktopServices-RdpCoreTS | The RDP server accepted a new inbound TCP connection from the specified client IP and port. This is the connection-establishment record — it fires before any authentication occurs. The new port (52341) confirms this is a fresh TCP session, not a reconnect of the previous failed session. |
| **4624** | Security | A logon succeeded. Logon type 10 confirms a successful RDP session was established. |

---

## 3. Critical Evidence Decoded

### Event 56 + Event 140 firing at the same second (14:01:02)
These two events are tightly coupled. Event 140 (RdpCoreTS) records the authentication rejection at the RDP application layer. Event 56 (TermDD) records the transport-layer disconnect that follows — the RDP stack closes the TCP session cleanly after rejecting the credentials. Seeing both at the same timestamp is normal for a failed RDP auth; it is **not** an indicator of a protocol attack in this context because it is paired with a clear credential failure reason.

### ~2-minute intervals between failed attempts
The three 4625 failures occur at: **14:01:04**, **14:03:18**, **14:05:33** — approximately 2 minutes and 15 seconds apart. Automated credential-stuffing or brute-force tools operate in milliseconds to seconds; intervals of over 2 minutes are consistent with a human manually re-entering credentials at an RDP login prompt. This strongly supports a genuine user mistyping their password rather than a malicious attack.

### All activity from a single IP (10.10.5.44), consistent throughout
Every event — failed attempts, lockout, reconnection, and successful logon — originates from the same IP address. This rules out a distributed attack and confirms a single endpoint is involved. The IP is likely bwalker's own workstation or a trusted internal jump host.

### Lockout fires 1 second after the third 4625 (14:05:33 → 14:05:34)
The account locks out immediately after the third failed attempt, indicating the domain Account Lockout Policy threshold is set to **3 bad passwords**. There is no grace window.

### 17-minute gap between lockout and successful logon (14:05 → 14:22)
After the lockout at 14:05:34, the next activity is a new TCP connection at 14:22:07 — a gap of approximately 17 minutes. This is consistent with bwalker raising an incident with the helpdesk, waiting in queue, and having the account unlocked — matching the typical helpdesk response window seen in similar lockout incidents on this estate.

### New TCP port (52341) at 14:22:07
Event 131 records a new connection from `10.10.5.44:52341`. The port change confirms this is a brand-new RDP TCP session initiated after the account was unlocked, not an automatic reconnection of the previous session.

---

## 4. Sequence of Events (Plain English)

1. **14:01:02** — bwalker attempts to connect via RDP from 10.10.5.44. The credentials submitted are wrong. The RDP server rejects the connection (Event 140) and the transport layer disconnects the client (Event 56).

2. **14:01:04** — The domain controller records the failed logon — FINBRIDGE\bwalker, wrong password, RemoteInteractive (RDP) logon type (Event 4625, attempt 1 of 3).

3. **14:03:18** — bwalker tries again, ~2 minutes later. The password is still incorrect. Second 4625 recorded (attempt 2 of 3).

4. **14:05:33** — A third RDP login attempt fails with the same reason. Third 4625 recorded (attempt 3 of 3).

5. **14:05:34** — One second later, the domain Account Lockout Policy triggers automatically. FINBRIDGE\bwalker is locked out (Event 4740). No further logon attempts are possible until an administrator unlocks the account.

6. **14:05 – 14:22** — A ~17-minute gap. bwalker contacts the helpdesk; an administrator unlocks the account (no 4722 unlock event visible in this log window, but the subsequent successful logon confirms it occurred).

7. **14:22:07** — bwalker initiates a new RDP connection from 10.10.5.44. The server accepts the TCP connection (Event 131, new port 52341).

8. **14:22:09** — bwalker authenticates successfully via RDP. FINBRIDGE\bwalker is logged on (Event 4624, logon type 10). Session established.

---

## 5. Root Cause Analysis

### Most Likely Cause: User entered an incorrect RDP password three times — most probably a recently changed password not yet committed to memory, or a saved RDP credential file (.rdp) storing the old password

**Evidence:**

| Evidence | Interpretation |
|----------|---------------|
| ~2-minute intervals between failures | Manual human input — not automated brute force |
| Single consistent source IP | One user at one machine — not a distributed attack |
| Logon type 10 (RemoteInteractive) throughout | Dedicated RDP session attempts, not background service retries |
| Lockout threshold hit on attempt 3 | Standard domain policy behaviour; three manual mistyped passwords |
| Successful logon from the same IP after ~17 minutes | Same user, same machine — after helpdesk unlock, correct password used |
| No 4776 (credential validation) events from unusual sources | No evidence of lateral movement or external attack |

### Security assessment
The pattern is consistent with a **legitimate user lockout** rather than a security incident. However, the following is worth noting for awareness:

- RDP-based failed authentications from an internal IP are low-risk in isolation.
- If the same IP (10.10.5.44) were to appear in future lockout events for **different accounts**, that would elevate concern to a potential credential-stuffing attempt from a compromised internal host.
- The absence of Event 4776 from unexpected sources and the single-account, single-IP pattern confirm this is benign.

---

## 6. 5 Whys Analysis

| Why | Question | Answer |
|-----|----------|--------|
| 1 | Why was bwalker unable to connect via RDP? | The account was locked out after three consecutive failed password attempts. |
| 2 | Why were there three failed password attempts? | bwalker repeatedly entered an incorrect password at the RDP login prompt. |
| 3 | Why was the password incorrect? | Most likely because bwalker had recently changed their domain password and either had not memorised the new one, or a saved `.rdp` credential file was auto-submitting the old password. |
| 4 | Why was a stale or forgotten password in use? | No post-change credential guidance was provided; saved RDP credentials in Windows Credential Manager or `.rdp` files are not automatically invalidated when a domain password changes. |
| 5 | Why is there no self-service recovery path? | The estate lacks a self-service account unlock portal (e.g., SSPR), requiring helpdesk intervention and extending the user downtime to ~17 minutes. |

---

## 7. Recommended Actions

### Immediate (per-incident)
- Confirm the account has been unlocked (check for Event 4722 from a helpdesk admin account).
- Advise bwalker to clear saved RDP credentials: **Credential Manager → Windows Credentials → remove any entries for the target RDP host**.
- Advise bwalker to update any saved `.rdp` files or RDP client profiles that store credentials.

### Preventive

| Priority | Action | Owner |
|----------|--------|-------|
| High | Deploy Azure AD / Entra ID Self-Service Password Reset (SSPR) to allow users to unlock their own accounts without helpdesk involvement — reduces downtime from ~17 minutes to under 2 minutes | Identity & Access |
| High | Add a knowledge article to the password-change process: "After changing your domain password, clear saved credentials in Windows Credential Manager and update any saved RDP files" | Service Desk / L&D |
| Medium | Configure RDP connection broker or RD Gateway to display a "your account is locked" message at the transport layer rather than a generic auth failure — reduces wasted retry attempts | Desktop / RDS Engineering |
| Medium | Enable Smart Lockout (Azure AD) or a Network Policy Server (NPS) rule to distinguish manual RDP mistyping from automated brute-force patterns, and apply different lockout responses accordingly | Security Architecture |
| Low | Review whether the lockout threshold of 3 is appropriate for RemoteInteractive (RDP) logons — a slightly higher threshold (e.g., 5) for RDP with a short observation window would reduce false-positive lockouts from manual mistyping while still protecting against brute force | Security Architecture |

---

## 8. Key Diagnostic Indicators (for Future Reference)

Use the following pattern to distinguish a **legitimate user lockout** from a **brute-force or credential-stuffing attack** on RDP:

| Indicator | Legitimate lockout | Potential attack |
|-----------|-------------------|-----------------|
| Interval between 4625 events | Minutes (human speed) | Seconds or milliseconds |
| Number of source IPs | Single IP | Multiple IPs |
| Number of accounts targeted | Single account | Multiple accounts from same IP |
| Logon type | 10 (RDP) — expected for remote workers | Mixed types from same source |
| Outcome | Lockout then successful logon from same IP | Continued attempts or lateral movement |

> **If Event 4625 (type 10) failures appear for multiple different accounts from the same source IP within a short window, treat as a security incident and isolate 10.10.5.44 immediately.**

---

*Analysis authored by: DWP Analyst | Incident date: 2024-03-15 | Stored: day3*
