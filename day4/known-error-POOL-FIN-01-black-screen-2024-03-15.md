Symptom: Users on POOL-FIN-01 see a black screen immediately after login. For some users it clears after around 30 seconds; for others, sessions disconnect or repeatedly fail before successful access.

Cause: A graphics/rendering regression was introduced with the POOL-FIN-01 overnight image update. Desktop Window Manager (dwm.exe) repeatedly crashed in Intel graphics module igdumd64.dll during post-login session initialization, with access violation 0xc0000005.

Scope: The issue affected AVD hosts in POOL-FIN-01 and approximately 40% of users assigned to that pool during the 07:00 to 10:00 incident window. POOL-FIN-02 was unaffected and remained on the prior image baseline.

Workaround: During mitigation, users were steered away from unstable session behavior while remediation was applied. Service was restored after remediation and validation of successful logins on POOL-FIN-01.

Permanent fix: Rendering/driver-focused corrective actions were applied on the POOL-FIN-01 host/image path, and recovery was confirmed at 10:00 with no new user-reported issues. Lasting controls recorded in CAPA are canary image rollout, repeated logon/reconnect smoke tests, DWM instability alerting, A/B control-pool comparison for promotion, and pinning known-good graphics driver/component versions with unverified drift blocked.

How to spot it: Look for the repeating chain Event 21 (logon success) -> Event 1000 (Application Error: dwm.exe faulting in igdumd64.dll, exception 0xc0000005) -> Event 40 (session disconnect) -> Event 9009 (DWM exited with error 0x40010004). On unaffected hosts, Event 9011 (DWM started successfully) appears and no corresponding Event 1000 dwm.exe crash entries are seen.