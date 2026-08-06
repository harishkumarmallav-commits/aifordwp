# Triage Summary – Teams Audio Not Working on Three Meeting Room Machines

**Ticket ref:** T-1005  
**Date:** 2026-08-04  
**Analyst:** [to confirm]

---

## Summary
Microsoft Teams audio is non-functional on three machines located in the same meeting room.

## Impact
- **Who:** All users of the affected meeting room
- **How many:** Three devices affected; number of users impacted depends on meeting room usage (to confirm)
- **Business urgency:** HIGH — a meeting room with no audio makes it unusable for Teams calls and collaboration; business impact increases if meetings are scheduled imminently

## Known Facts
- Three machines in the same meeting room are affected
- The issue is with Teams audio specifically
- All three devices are in the same physical location, which suggests a shared factor (network, hardware, policy, or room audio device)

## Missing Information to Gather
- Whether the machines are using a shared room audio device (speakerphone, conference unit, HDMI audio) or individual headsets/built-in audio
- Whether audio works outside of Teams on the same devices (e.g. system sounds, media playback)
- Whether the audio device appears in Teams audio settings on the affected machines
- Whether Teams has been updated recently on these devices
- Whether any Windows updates were applied recently that may have affected audio drivers
- Whether the room audio device (if shared) shows as connected and powered on
- Whether the issue is input (microphone), output (speaker), or both
- Whether other rooms or individual devices have the same Teams audio issue (to confirm scope)
- Whether the devices are running Teams classic or the new Teams client (to confirm)
- Whether Group Policy or Intune policy restricts audio device access on these machines (to confirm)

## Likely Category
- **Primary:** Unified Communications / Microsoft Teams Audio
- **Sub-category (to confirm):** Shared room audio device not being detected by Teams, audio driver issue, or Teams audio policy/permissions misconfiguration

## First Diagnostic Step
On one of the affected machines, open Teams Settings → Devices and confirm whether an audio input and output device is listed and selected. Then test audio outside of Teams (e.g. system sounds or a media file) to determine whether the fault is Teams-specific or affects the whole device. If the room uses a shared peripheral audio device, check its physical connections and power state first, as all three machines sharing the same symptom in the same room strongly suggests a shared hardware or peripheral root cause.
