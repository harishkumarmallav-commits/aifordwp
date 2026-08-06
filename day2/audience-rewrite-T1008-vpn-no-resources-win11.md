Executive:
Your access is restored and your data is safe. After the Windows 11 upgrade, the old VPN app was removed and the new one was not reinstalled because of a detection-rule gap. We removed stale VPN entries under HKLM\SOFTWARE\<vendor>, forced an Intune sync, deployed the new client, applied the split-tunnel configuration, and confirmed connectivity to all internal subnets. No action is needed from you.

Team:
Your access is restored and there was no data loss. The Windows 11 upgrade removed the old VPN app, and the new one was not reinstalled because of a detection-rule gap. We removed stale VPN entries under HKLM\SOFTWARE\<vendor>, forced an Intune sync, deployed the new client, applied the split-tunnel configuration, and confirmed connectivity to all internal subnets. If you see the same issue, contact the service desk and mention the Windows 11 VPN client redeployment issue. Please contact the service desk.

Engineer:
Root cause: Win11 upgrade removed the legacy VPN client and did not trigger Intune re-deployment of the new client due to a detection-rule gap. Action taken: manually removed stale VPN registry entries under HKLM\SOFTWARE\<vendor>, force-triggered Intune sync, new client deployed, split-tunnel config applied. Verification: connectivity confirmed to all internal subnets. Impact/data: no data loss.