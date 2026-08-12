# Analysis: Adobe Acrobat Pro v23.6 Intune Install Failure (MSI 1603 + Detection Mismatch)

Date: 2026-08-12  
Application: Adobe Acrobat Pro v23.6  
Package: AdobeAcrobatPro.intunewin  
Deployment context: Intune Win32 app, install as SYSTEM

## 1) Confirmed Failure Pattern
The deployment failed consistently with MSI exit code 1603, then failed detection, and entered retry loop.

Evidence from provided log:
- Install command executed: `msiexec /i AcrobatPro.msi /quiet`
- Install context: `SYSTEM`
- Return code on first attempt: `1603`
- Return code on retry attempt 1: `1603`
- Detection rule checked registry key: `HKLM\SOFTWARE\Adobe\Acrobat Reader\23.0`
- Detection result: `Not detected`
- Intune behavior: retry scheduled every 60 minutes

## 2) Technical Interpretation
1. Installation did not complete successfully.
- MSI 1603 indicates a fatal installer error and is not typically resolved by retry alone.

2. Detection rule is likely mismatched to product.
- Deployment target is Acrobat Pro, but detection checks an Acrobat Reader path.
- Even with a successful Pro install, this Reader key may remain absent, causing false failure status.

3. Current retry behavior will likely repeat failure state.
- Same command + same endpoint state + unchanged detection logic = repeated failed attempts.

## 3) Exact Remediation Steps

### A. Stabilize rollout scope (containment)
1. [Admin Center Only] In Intune admin center, pause additional assignment expansion for this app.
2. [Admin Center Only] Keep deployment limited to a small validation group until detection and installer behavior are corrected.

### B. Correct detection logic
1. [Admin Center Only] Edit Adobe Acrobat Pro v23.6 detection rule in Intune.
2. [Admin Center Only] Replace Reader-based registry check with one of the following Pro-aligned checks:
   - File exists/version check for Acrobat Pro executable (preferred when version pinning is required).
   - Registry key/value path known to be written by Acrobat Pro package variant in your tenant build.
3. [Admin Center Only] Validate detection on a known-good reference device with Pro installed.

### C. Improve installer diagnostics
1. [Admin Center Only] Update install command to generate verbose MSI log output:

```cmd
msiexec /i "AcrobatPro.msi" /qn /norestart /L*v "C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\AcrobatPro-install.log"
```

2. [Device Access Required] Re-run install on one affected test endpoint.
3. [Device Access Required] Review `AcrobatPro-install.log` for concrete 1603 cause (conflict, permissions, prerequisite, reboot pending, path issue).

### D. Validate SYSTEM-context execution
1. [Device Access Required] Execute the same packaged command under SYSTEM context on pilot endpoint.
2. [Device Access Required] Confirm working directory and referenced MSI path are valid from Intune extraction location.
3. [Device Access Required] Confirm no pre-existing conflicting Acrobat product blocks the install.

### E. Return code handling and retry behavior
1. [Admin Center Only] Keep `1603` as hard failure.
2. [Admin Center Only] If installer returns `3010`, classify as soft reboot required (not hard failure).
3. [Admin Center Only] Re-test assignment against validation group before re-expanding.

## 4) Correct Order of Operations
1. Pause broad deployment expansion for Adobe Acrobat Pro v23.6.
2. Fix detection rule to Pro-appropriate artifact.
3. Add verbose MSI logging to install command.
4. Re-test on 3-5 representative endpoints (including one with prior Adobe footprint).
5. Review log-backed root cause for 1603 and apply packaging/config fix.
6. Confirm Intune reports both install success and detected status.
7. Resume rollout in controlled ring.

## 5) Verification Checks (Post-Fix)
1. Intune app status shows successful installs on validation group with no false "Not detected" outcomes.
2. Failed rate remains below defined ring threshold for at least 24 hours.
3. No repeated hourly retry loops for previously failing endpoints.
4. Service desk ticket volume tagged to Acrobat v23.6 remains within acceptance threshold.

Success criteria:
- Install completes without 1603 on validation endpoints.
- Detection returns detected for installed Pro devices.
- Retry-loop failure pattern is eliminated.

## 6) Resolution Statement
Primary failure sequence is MSI 1603 during SYSTEM install, compounded by a likely misaligned detection rule checking an Acrobat Reader registry path for an Acrobat Pro deployment. Corrective action is to fix detection to Pro-specific artifacts, capture verbose MSI diagnostics, remediate the underlying 1603 cause, and only then resume staged rollout.
