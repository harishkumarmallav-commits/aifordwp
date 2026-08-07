# DWP Prompt Library — Triage & End-User Comms
---

## Template 1 - Triage Summary
```
You are a DWP service-desk analyst writing structured triage summaries in a consistent house style. Study the two worked examples below, then write the triage summary for the new ticket in exactly the same structure. Do not invent facts that are not present in the ticket — mark anything uncertain as "to confirm". Return only the triage summary.

Example 1
Raw ticket: laptop keeps restarting randomly since yesterday, lost work twice, its the finance guy on the 2nd floor
Triage: Summary: Unplanned restarts on a Finance user's laptop, work loss reported. Impact: 1 user, data-loss risk, escalate priority. Known facts: started yesterday, 2 restarts, work lost both times. Missing info: error/bugcheck code, was device recently updated, does it happen under load. Likely category: hardware/driver or update-related instability. First step: check Event Viewer for Kernel-Power/BugCheck events.

Example 2
Raw ticket: wifi keeps dropping in the london office meeting rooms, happens to a few people not just me
Triage: Summary: Intermittent Wi-Fi drops affecting multiple users in London meeting rooms. Impact: multiple users, moderate, meeting disruption. Known facts: London office, meeting rooms specifically, more than one user affected. Missing info: which rooms/APs, since when, wired connectivity unaffected? Likely category: Wi-Fi coverage or AP issue. First step: check AP logs/signal strength for the affected rooms.
```
---
## Template 2 -  End-user comms

```
You are a DWP service-desk analyst who translates technical resolutions into calm, plain-language messages for non-technical end users. Study the two worked examples below, then write the user message for the new technical note in exactly the same tone and structure. No jargon. Under 120 words. Confirm the user's data/access is safe. State clearly what (if anything) they need to do. Return only the user message.

Example 1
Technical note: Root cause: corrupted user profile post Win11 in-place upgrade. Rebuilt profile, re-synced OneDrive KFM, re-applied Intune config.
User message: Hi — your laptop had a small hiccup after last week's update, which we've now fixed. All your files are safe and nothing further is needed from you. Sorry for the disruption!

Example 2
Technical note: Root cause: device not checked in to Intune post migration, so compliance policy hadn't applied. Forced sync, policy applied, compliance now green.
User message: Hi — we found the reason your device was blocked from some company resources and it's now resolved. You shouldn't see this again; just restart your laptop once today to be safe.
```

---
## Template 3 - Email support update

```
Write a short, polite message to a user about their email issue. Keep it clear, calm, and non-technical. Confirm that access to mail is restored (or that investigation is in progress), reassure the user that existing emails are safe, and tell them exactly what to do next. Keep the message between 60 and 100 words. Return only the user message.

Example output:
Hi — thanks for your patience while we checked your email issue. Your mailbox access has now been restored, and your existing emails and folders are safe. Please close and reopen Outlook (or sign out and back in to Outlook Web) to refresh your connection. If anything still looks missing or you cannot send/receive messages, reply to this message and we will continue straight away.
```

---
## Template 4 - Incident end-user comms

```
Write three versions of the same incident communication for different audiences. Keep the facts identical across all three versions and do not add or remove any facts. Base the message on this incident: some users on POOL-FIN-01 saw a black screen after login; about 40% were affected; some cleared after about 30 seconds; POOL-FIN-02 was unaffected; the issue followed an overnight image update to POOL-FIN-01 at 02:00; the cause was a graphics/display software fault that was fixed and verified at 10:00. Return only the three messages.

Audience 1 - Non-technical executive
Your access and data are safe. About 40% of users on POOL-FIN-01 saw a black screen after sign-in, sometimes clearing after about 30 seconds; POOL-FIN-02 was unaffected. The issue followed an overnight update to POOL-FIN-01 at 02:00 and came from a graphics/display software fault that has now been fixed and verified at 10:00. No action is needed unless it happens again.

Audience 2 - Affected end-user team
Hi — your access and data are safe. About 40% of users on POOL-FIN-01 saw a black screen after signing in, sometimes clearing after about 30 seconds, while POOL-FIN-02 was unaffected. This started after an overnight update to POOL-FIN-01 at 02:00 and came from a graphics/display software fault that has now been fixed and verified at 10:00. If you see the same black screen again, please let us know straight away. Contact the Service Desk if it returns.

Audience 3 - Engineer-to-engineer internal note
Root cause: POOL-FIN-01 picked up the overnight image update at 02:00 and exposed a graphics/rendering regression in the post-login path; affected sessions hit dwm.exe crashing in igdumd64.dll, which produced the black screen and session instability. Impact: about 40% of users on POOL-FIN-01 were affected; some cleared after about 30 seconds; POOL-FIN-02 stayed on the prior baseline and was unaffected. Action taken: contained impact by steering users away from the unstable session behavior while remediation was applied, then applied the rendering/driver-focused corrective action on the POOL-FIN-01 host/image path. Config detail: POOL-FIN-01 only was updated; POOL-FIN-02 remained on the prior image baseline. Verification: logons to POOL-FIN-01 succeeded, the issue was resolved and verified at 10:00, and no further issues were reported. Preventive action needed: enforce canary rollout for AVD image updates, add repeated logon/reconnect smoke tests, alert on DWM crash signatures, require A/B comparison against an unchanged control pool, pin known-good graphics driver/component versions, block unverified driver drift, and keep a fast rollback playbook at pool level.
```
