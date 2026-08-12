# FinBridge Support Feedback Theme Clustering and Priority Actions

Date: 2026-08-12  
Analyst: DWP

## Clustered Themes

- Theme name: Shared credentials vault inaccessible
  Count: 3
  Ticket refs: 5, 8, 14
  Representative quotes: "Shared credentials vault is completely inaccessible, whole team blocked." / "Third day now I can't access the credentials vault, this is urgent."
  Severity: Blocker

- Theme name: Test VM remote access failures
  Count: 2
  Ticket refs: 1, 12
  Representative quotes: "Can't remote into any of my test VMs since the update, blocking my whole day." / "My test VM access is still down, can't do my job today either."
  Severity: Blocker

- Theme name: Admin console lockouts
  Count: 2
  Ticket refs: 3, 10
  Representative quotes: "Second engineer this week locked out of the admin console entirely." / "Admin console lockouts happening across the whole team now, not just one person."
  Severity: Blocker

- Theme name: Dashboard/UI positive feedback
  Count: 4
  Ticket refs: 2, 6, 11, 15
  Representative quotes: "New ticketing system dashboard is a nicer colour scheme, small win." / "Overall the rollout felt smoother than last time, appreciate it."
  Severity: Positive

- Theme name: Minor usability and performance friction
  Count: 3
  Ticket refs: 4, 7, 9
  Representative quotes: "Font in the new portal is slightly smaller, hard to read for some of us." / "Dashboard refresh is a bit slower than before, barely noticeable."
  Severity: Friction

- Theme name: No issues reported
  Count: 1
  Ticket refs: 13
  Representative quote: "No issues at all for me, everything's working fine."
  Severity: Positive

## Top 2 Themes to Act On Today (Ranked)

1. Shared credentials vault inaccessible (Count: 3)
- Why this rank: Team-wide dependency, repeated over 3 days, management escalation already in motion, and explicit statement that the whole team is blocked.
- Immediate action focus: Incident bridge, owner assignment, hourly updates, manual credential retrieval fallback.

2. Admin console lockouts (Count: 2)
- Why this rank: Impact appears to be spreading from individuals to the whole team and directly blocks privileged operational tasks.
- Immediate action focus: Confirm scope, isolate auth policy/conditional access changes, apply temporary access workaround.

## Proactive Notification (For Theme 1)

Subject: Ongoing issue: Shared credentials vault access

We are aware of an ongoing issue where some colleagues cannot access the shared credentials vault. We know this is blocking critical work and we are treating it as a high-priority incident.

What we are doing now:
- Incident team is actively investigating platform access and authentication paths.
- We are validating a temporary fallback process for urgent credential needs.
- We are coordinating with service owners and will share progress updates every 60 minutes.

What to do if you are affected:
- Do not retry continuously, as repeated attempts can trigger additional access controls.
- Log one service ticket with your username, time of failure, and exact error message.
- Mark urgent business impact in the ticket so requests can be prioritized.

Next update: within 60 minutes, or sooner if service is restored.

Thank you for your patience while we work to restore access.
