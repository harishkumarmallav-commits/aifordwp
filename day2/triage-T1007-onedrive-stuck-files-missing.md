# Triage Summary – OneDrive Stuck on 'Processing Changes' and Local Files Missing

**Ticket ref:** T-1007  
**Date:** 2026-08-04  
**Analyst:** [to confirm]

---

## Summary
OneDrive has been stuck on 'processing changes' since a migration and files are no longer present locally on the device.

## Impact
- **Who:** Single end user (identity to confirm)
- **How many:** 1 user confirmed; if the migration was a batch event, other users may be experiencing the same issue (to confirm)
- **Business urgency:** HIGH — user reports files missing locally; there is a risk of perceived data loss, which must be ruled out urgently even if files remain in the cloud

## Known Facts
- OneDrive has been in a 'processing changes' state since a migration event
- The migration type and date are not specified (to confirm — e.g. SharePoint tenant migration, OneDrive for Business account transfer)
- Files that were previously available locally are no longer present on the device
- The issue has persisted since the migration (duration to confirm)

## Missing Information to Gather
- Type of migration performed and when it completed
- Whether the files are still visible via OneDrive on the web (browser access to confirm cloud-side data integrity — do not share file names or content with AI tools)
- Whether OneDrive is signed in with the correct post-migration account
- Whether OneDrive sync status shows any specific error beyond 'processing changes' (error codes or messages to confirm)
- Whether Known Folder Move (Desktop, Documents, Pictures) was configured and whether those folders are affected
- Whether the user has Files On-Demand enabled, which would mean files may not be physically present locally but are still accessible (to confirm)
- Available local disk space on the device
- Whether other users from the same migration batch are reporting the same issue (to confirm scope)
- Whether IT has a confirmed data integrity check from the migration team

## Likely Category
- **Primary:** Cloud Storage / OneDrive Sync
- **Sub-category (to confirm):** Post-migration account/tenant mismatch causing sync to stall, or Files On-Demand causing confusion over local file availability

## First Diagnostic Step
Ask the user to open OneDrive on the web via a browser and confirm whether their files are visible in the cloud. This immediately distinguishes between a sync/client issue (files exist in cloud, not syncing locally) and a potential data loss event (files not present in cloud either). If files are visible in the cloud, check the OneDrive desktop client is signed in to the correct account post-migration and review any error message or sync error detail shown in the OneDrive system tray icon. Do not share file names, folder paths containing user data, or account details with AI tools.
