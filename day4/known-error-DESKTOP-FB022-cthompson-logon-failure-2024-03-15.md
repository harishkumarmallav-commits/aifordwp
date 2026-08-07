Symptom: User FINBRIDGE\cthompson cannot complete interactive login on DESKTOP-FB022. In this incident window, login attempts failed and then the account was locked out.

Cause: Repeated bad-password submissions for FINBRIDGE\cthompson caused account lockout on DESKTOP-FB022. Wrong-password attempts then continued from secondary source 10.10.8.112, consistent with stale cached or persisted credentials.

Scope: The incident affected one user only (FINBRIDGE\cthompson). The primary affected sign-in path was DESKTOP-FB022, with additional failed authentication attempts from source IP 10.10.8.112.

Workaround: Re-enable the account and verify successful interactive login on DESKTOP-FB022. Before final retest, identify any secondary failed-auth source and clear persisted credentials on all identified source endpoints for the affected account.

Permanent fix: Add lockout triage correlation between Event 4776/4625/4740 on the user endpoint and Event 4771 from other source IPs for the same account. Add monitoring to alert when Event 4740 is followed by repeated Event 4771 from a different source IP, and include a post-recovery check for recurring bad-password events in closure.

How to spot it: Look for Event 4776 with error 0xC000006A (wrong password), followed by repeated Event 4625 interactive failures and Event 4740 lockout on DESKTOP-FB022. Then check for repeated Event 4771 with failure code 0x18 (wrong password) from a different source IP (10.10.8.112 in this incident), and confirm recovery with Event 4722 (account enabled) followed by Event 4624 type 2 (successful interactive logon).