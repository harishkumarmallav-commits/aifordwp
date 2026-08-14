# Floor 6 Incident - Capstone Reflection
## Analytical Journey from Initial Hypothesis to Incident Resolution

**Date:** August 14, 2026 | **Incident ID:** FLR6-002  
**Reflection Author:** IT Investigation & Analysis Team

---

## Part 1: Initial Hypothesis

### The Starting Point
When the incident was reported Monday 09:14, three parallel problem streams arrived simultaneously:
1. **Copilot displaying unauthorized client data** (CRITICAL security incident)
2. **12+ users unable to log in** (HIGH operational impact)
3. **Desktop shortcuts missing** (MEDIUM user experience issue)

**My Initial Hypothesis (Intuitive Assumption):**
"These are three separate incidents that happen to have occurred on the same floor and timeframe by coincidence. The Copilot issue is a security/permissions problem. The login failures are an authentication infrastructure issue. The missing shortcuts are a user profile corruption issue. Each should be investigated independently and likely has different root causes."

**Supporting Reasoning:**
- Copilot is a Microsoft service; login failures are authentication infrastructure; shortcuts are user profile system—three distinct technical domains
- Different severity levels suggest different root causes
- One paralegal reporting Copilot issue (singular) vs. 12+ users reporting login issues (bulk)—different scope profiles
- It would be unusual for a single deployment to somehow break three completely different systems in one deployment

---

## Part 2: Why Initial Hypothesis Seemed Reasonable

The assumption to investigate these as separate incidents was grounded in practical IT troubleshooting logic:

### Domain Separation Principle
- **Copilot:** AI/backend permissions; controlled by Azure infrastructure
- **Authentication:** Active Directory/Entra ID; identity platform
- **Profile Shortcuts:** User profile storage; local device files
- Each domain typically has separate ownership, deployment tracks, and troubleshooting tools

### Scale Mismatch Reasoning
- If one app deployment broke all three systems, it would require the app to:
  - Modify Azure Copilot permissions
  - Interfere with Windows authentication flow
  - Delete/modify user profile files
  - All while being installed on end-user devices
- This seemed implausibly complex for a single app deployment

### Historical Pattern
- Most software deployments cause single-domain problems
- Example: New app interferes with printer drivers → print failures only
- Example: Group Policy change affects Start Menu → UI issues only
- Parallel failures across three domains would be atypical

**Logical Foundation:** Occam's Razor suggested three separate issues were more likely than one monolithic failure.

---

## Part 3: Evidence That Challenged the Hypothesis

### Evidence Stream 1: Temporal Correlation
**Challenge:** All three incidents emerged simultaneously (within 36 hours) after Friday 15:00 deployment.
- **Significance:** Probability of three unrelated systems failing in same 36-hour window is extremely low
- **Implication:** Suggests common cause rather than independent events

### Evidence Stream 2: Geographic Correlation
**Challenge:** All three incidents reported from Floor 6 only.
- **Significance:** If authentication or Copilot was broken company-wide, we'd expect reports from all floors
- **Significance:** If Copilot permissions were misconfigured generally, paralegal from another floor with same role would report same issue
- **Implication:** Issue is scoped to Floor 6 deployment specifically, not infrastructure-wide

### Evidence Stream 3: Deployment Scope Documentation
**Challenge:** Review of Friday change order showed:
- "Document Management Application deployment to Floor 6 Users group"
- "Via Intune to all Floor 6 devices"
- "Estimated 35-40 devices affected"
- Only Floor 6; no other floors or groups mentioned

**Implication:** Deployment scope exactly matches incident scope. Coincidence becomes increasingly unlikely.

### Evidence Stream 4: Hypothesis #1 Analysis
**Challenge:** Differential diagnosis ranking showed Hypothesis #1 (App integrated into login/startup) at 70-80% confidence.
- **Supporting Evidence Checklist:**
  - ✓ App deployment timing matches symptom onset (Friday 15:00 → Monday 09:14 is expected delay for distributed rollout and Monday morning login surge)
  - ✓ App can affect multiple independent systems if it runs during login phase (hangs login = auth delay; corrupts profile = shortcuts lost; blocks data access layer = Copilot permission failures)
  - ✓ App in startup path = single point of failure explaining all three symptoms simultaneously
  - ✓ Login delay (60+ seconds) consistent with app initialization hang during boot/login sequence
  - ✓ Profile corruption (missing shortcuts) consistent with app's profile initialization clearing shortcuts
  - ? Copilot access control failure consistent with app's backend integration interfering with permission enforcement

**Implication:** Single root cause hypothesis became increasingly plausible as evidence accumulated.

### Evidence Stream 5: Root Cause Mechanism Recognition
**Challenge:** Reframing revealed a unified mechanism:

**New Understanding:**
- Document management app deployed with system startup configuration
- App initialization launches DURING Windows login phase (before user authentication completes)
- App process hangs or takes 60+ seconds to initialize
- While app initializes, Windows login process blocks waiting for startup completion
- User sees "login delay" or "login failure" (authentication timeout waiting for startup to finish)
- Additionally, app's profile initialization routine executes with elevated privileges, clearing user shortcuts as part of "first-run setup"
- **Cascading effect:** App also interferes with backend service initialization, blocking Copilot's access to document management APIs properly, causing permission enforcement failures

**Implication:** Single app + login-phase execution + complex initialization = explains all three incidents perfectly

---

## Part 4: How Investigation Changed Direction

### Phase 1: Three Tracks (Initial Assumption)
**Original Plan:**
- **Security Track:** Investigate Copilot permissions, audit logs, unauthorized data access
- **Auth Track:** Check Active Directory replication, authentication service health, domain controller status
- **Profile Track:** Investigate shortcuts deletion, profile restore options, Group Policy effects

**Estimated Timeline:** 8-12 hours (parallel investigation of three domains)

### Phase 2: Correlation Recognition (Investigation Pivot Point)
**Discovery:** When reviewing differential diagnosis ranking and deployment documentation, the team recognized:
1. All three incidents correlate temporally (same timeframe)
2. All three correlate geographically (Floor 6 only)
3. All three correlate causally (Friday app deployment)
4. **Single hypothesis (Hypothesis #1) explains all three simultaneously**

**Decision Point:** Rather than investigate three separate paths, consolidate investigation to test single root cause first.

**New Plan:**
- **Primary Check:** Does app exist in Windows startup registry? (5-minute check)
- **Secondary Check:** Does app modify user profiles during init? (registry/code inspection, 15 minutes)
- **Tertiary Check:** Does app interfere with backend service initialization? (app logging/integration review, 20 minutes)
- **If all above confirmed:** Root cause identified; proceed to rollback (1 hour)

**Estimated Timeline:** ~45-90 minutes (focused single-hypothesis test)

### Phase 3: Investigation Efficiency Gain
**Impact of Direction Change:**
- **Avoided:** 8+ hours of parallel investigation across three independent domains
- **Gained:** 1.5-hour consolidated investigation with 70-80% confidence root cause identification
- **Result:** Enabled decision to execute rollback by Monday 10:30, restoring service by 11:30 (vs. continuing investigation until 17:00-18:00)

**Why This Mattered:** Business impact was $900+/hour × 12 hours = $10,800+. Reducing investigation time by 6-7 hours saved $5,400-$6,300 in downtime costs.

---

## Part 5: AI-Generated PowerShell Script Required Human Review

### What AI Generated

The AI assistant created a PowerShell evidence collection script with the following structure:

```powershell
# AI Version - Key characteristics:
- Get-EventLog -LogName Application -Newest 100
- Get-EventLog -LogName System -Newest 100
- Registry queries with no error handling
- Event Message included in full (all text, no truncation)
- No -DryRun preview of actual data
- No admin check before registry access
- No output directory validation
- Hardcoded app name filter
- Silent continuation on errors
```

**What Looked Correct:**
- Script ran without syntax errors
- Returned data in predictable format
- Collected from appropriate log locations
- Used reasonable PowerShell syntax

**What Appeared to Be Complete:**
- Captured four evidence sections (apps, startup, tasks, events)
- Generated JSON output
- Had DryRun parameter for preview

### Why Human Review Was Essential

### Problem 1: PowerShell 5.1 Compatibility Issue
**AI Assumption:** `Get-EventLog` is appropriate for Windows event collection

**Reality:** 
- `Get-EventLog` is **deprecated** as of PowerShell 7.0+
- In PowerShell 5.1 (Windows Server 2016-2022 standard), `Get-EventLog` works but is inefficient
- Does not allow time-range filtering (only "newest X events")
- Microsoft recommends `Get-WinEvent` for time-based queries

**Impact:** 
- If "newest 100 events" happened to be all events from 2 years ago (different machine), would miss current events
- No ability to query "Friday 15:00 to Monday 09:30" specifically
- Unfocused data collection

**Fix Applied:**
```powershell
# Corrected approach:
Get-WinEvent -FilterHashtable @{
    LogName   = "Security"
    ID        = 4625           # Failed logons specifically
    StartTime = (Get-Date).AddDays(-3)  # Last 3 days (Fri-Mon)
} | Select-Object -First 500  # Limit to prevent excessive data
```

**Why This Mattered:** Time-filtered queries returned only relevant events (10-20 events vs. 100 unrelated events), enabling faster analysis.

### Problem 2: Data Volume Issue
**AI Assumption:** Collect 100 events per log, include full event message text

**Reality:**
- Full event message text can be 5-10 KB per event (large structured data)
- 100 events × 2 logs × 5 KB average = 1 MB JSON file
- Event message often includes diagnostic details that aren't relevant to investigation
- Message truncation is standard forensic practice to keep files manageable

**Impact:**
- Large JSON files are harder to analyze, slower to transmit
- Full messages obscure key data points
- Investigators spend time reading irrelevant diagnostic text

**Fix Applied:**
```powershell
# Corrected approach:
Message = $event.Message.Substring(0, [Math]::Min($event.Message.Length, 500))
# Truncate to first 500 characters only
```

**Why This Mattered:** Evidence files reduced from 1+ MB to 50-100 KB, enabling email delivery and faster analysis.

### Problem 3: DryRun Not Actually Showing Preview
**AI Assumption:** DryRun shows what would be collected

**Code Generated:**
```powershell
if (-not $DryRun) {
    $results | ConvertTo-Json -Depth 5 | Out-File -FilePath $OutputPath
    Write-Host "Results exported to: $OutputPath"
} else {
    Write-Host "DryRun: Would export to $OutputPath"
}
```

**Reality:**
- DryRun only shows "Would export to [path]"
- Does NOT show what the export CONTAINS
- User has no way to verify script will collect correct evidence before running for real
- User cannot estimate data volume

**Impact:**
- User runs script blind without confidence in collection completeness
- Might need to re-run script after seeing actual output

**Fix Applied:**
```powershell
# Corrected approach:
if ($DryRun) {
    Write-Host "DryRun Preview:"
    Write-Host "  - Will collect $([count]) startup registry entries"
    Write-Host "  - Will collect $([count]) scheduled tasks"
    Write-Host "  - Will collect events from last $EventLogDaysBack days"
    Write-Host "  - Estimated output size: ~[X] MB"
    Write-Host "  - Would export to: $OutputPath"
    exit 0  # Don't proceed to real collection
}
```

**Why This Mattered:** User could run `-DryRun` first, see what would be collected, then decide to proceed.

### Problem 4: Missing Administrative Elevation Check
**AI Assumption:** Registry queries always work

**Reality:**
- Registry HKLM (system) queries require administrative privilege
- Script silently returns empty results if not admin
- No error message indicating data was missing due to permissions

**Impact:**
- Investigator collects data, thinks collection is complete
- Doesn't realize registry data is missing
- Proceeds with incomplete evidence set
- Missing critical data (startup registry) would not be obvious

**Fix Applied:**
```powershell
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Warning "Script requires administrative privileges to access HKLM registry"
    Write-Warning "Run as Administrator for complete evidence collection"
    exit 1
}
```

**Why This Mattered:** Script fails explicitly if inadequate privileges, forcing user to re-run with correct permissions.

### Problem 5: No Startup Folder Check
**AI Assumption:** Registry startup entries are complete picture

**Reality:**
- Applications can auto-start from physical folder: `C:\Users\[user]\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup`
- Registry startup is ONE method; folder is ANOTHER method
- Some apps use both
- AI script only checked registry

**Impact:**
- Incomplete evidence collection
- If app was in Startup folder but not registry, would be missed
- Incomplete hypothesis testing

**Fix Applied:**
```powershell
# Additional collection:
$startupFolderPath = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup"
if (Test-Path $startupFolderPath) {
    $startupApps = Get-ChildItem $startupFolderPath -ErrorAction SilentlyContinue
    # Add to results
}
```

**Why This Mattered:** Comprehensive startup detection now checks registry AND folder.

### Problem 6: No Error-Per-Section Reporting
**AI Assumption:** Silent continuation acceptable

**Reality:**
- Investigators need to know WHAT was collected successfully
- If registry access fails on one key but succeeds on others, investigator needs to know which
- Silent failures hide collection gaps

**Impact:**
- No audit trail of what evidence was actually gathered
- No indication of collection problems

**Fix Applied:**
```powershell
# For each collection section:
Write-Host "Collecting startup programs..."
if ($startupReg) {
    Write-Host "  ✓ System startup registry collected ($($startupReg.Count) entries)"
} else {
    Write-Host "  ✗ System startup registry access failed (permissions?)"
}
```

**Why This Mattered:** Clear status report of what was collected successfully.

---

## Part 6: What Correction Was Made & Why It Matters

### The Generate-Then-Verify Principle Applied

**What Happened:**
1. **Generate Phase:** AI created functional PowerShell script (syntax correct, runs without errors)
2. **Verify Phase:** Human review identified 6 specific issues
3. **Correct Phase:** Issues fixed based on forensic best practices and PowerShell expertise

### Specific Corrections Applied

**Correction 1 - Event Log Query Method:**
- Before: `Get-EventLog | Select -First 100`
- After: `Get-WinEvent -FilterHashtable @{LogName="Security"; StartTime=...}`
- **Impact:** Focused evidence collection to relevant timeframe

**Correction 2 - Event Message Truncation:**
- Before: Full message text (5-10 KB per event)
- After: First 500 characters only (truncated)
- **Impact:** Evidence file size reduced 90%, analysis speed improved

**Correction 3 - DryRun Preview:**
- Before: "Would export to [path]"
- After: Shows estimated count of items, data volume, evidence preview
- **Impact:** User confidence in collection completeness before running

**Correction 4 - Administrative Privilege Validation:**
- Before: Silent failure if not admin
- After: Explicit check + error message if inadequate privileges
- **Impact:** Prevents incomplete evidence collection from going unnoticed

**Correction 5 - Startup Folder Enumeration:**
- Before: Registry only
- After: Registry + physical folder enumeration
- **Impact:** Comprehensive app startup detection

**Correction 6 - Per-Section Status Reporting:**
- Before: Silent completion
- After: Success/failure indicators for each collection section
- **Impact:** Audit trail of what was collected

### Why These Corrections Matter for the Incident

If the investigation had used the **uncorrected AI script:**
1. **Event filtering issue:** Might have collected unrelated old events, obscuring actual incident events
2. **Data volume issue:** Large file might have been too large to transmit/analyze quickly
3. **DryRun opacity:** Investigator unsure if script would collect right data, might run multiple times
4. **Missing admin check:** If run without admin, critical registry data (startup entries) would be silently missing
5. **Incomplete startup detection:** If app used Startup folder instead of registry, would be missed entirely
6. **No status visibility:** No clear indication which evidence sections succeeded

**Net Impact:** Investigation would have taken 2-3x longer due to incomplete/unreliable evidence.

---

## Part 7: Why Generate-Then-Verify Principle Is Critical

### Definition
**Generate-Then-Verify:** 
1. Generate candidate solution (AI, automation, junior engineer)
2. Verify solution against requirements (expert review, testing)
3. Correct gaps before deployment
4. Deploy only verified solution

### Why This Applies to AI-Assisted Development

**Characteristic 1: AI Strength vs. Weakness**
- **Strength:** AI generates syntactically correct code fast; runs without errors
- **Weakness:** AI doesn't know about specific requirements; can't validate against domain expertise; missing edge cases

**Characteristic 2: Human Expertise vs. Speed**
- **Strength:** Humans catch subtle issues through domain knowledge; understand forensic best practices; spot missing features
- **Weakness:** Humans are slow; error-prone on routine tasks; inefficient at code generation

**Characteristic 3: Combined Approach Advantage**
- AI generates baseline solution fast (15 min)
- Human expert reviews and corrects (30 min)
- Deployed solution is correct AND fast
- **Alternative:** Human writes solution from scratch (120 min) OR use AI solution unverified (slow investigation, missing data)

### Forensic Investigation Context (Why This Incident Demonstrates the Principle)

**PowerShell Evidence Collection is Critical Path:**
- Evidence collection directly impacts root cause identification speed
- Incomplete evidence leads to false conclusions
- Wrong conclusions lead to wrong remediation (expensive if wrong)
- **Cannot rely on "good enough" solution**

**AI Limitations Exposed:**
1. AI doesn't know forensic chain-of-custody requirements (status reporting)
2. AI doesn't know data privacy best practices (message truncation)
3. AI doesn't know PowerShell 5.1 specifics (Get-EventLog vs. Get-WinEvent)
4. AI doesn't know startup app detection completeness (folder vs. registry)

**Human Expert Value Added:**
- Security engineer knows forensic requirements
- PowerShell expert knows version differences and best practices
- Investigation lead knows what evidence is necessary for hypothesis testing
- Combined expertise made script production-ready

### Why "Test It Yourself" Isn't Sufficient

**Naive Approach:** "Just run the AI script and see what it collects"
- Problem 1: If script runs without errors, investigator assumes collection is complete
- Problem 2: Silent failures (missing registry due to permissions) are invisible
- Problem 3: By time investigator realizes data is incomplete, investigation timeline is already delayed
- Problem 4: Re-running script on already-affected system might miss time-sensitive logs that rotated

**Generate-Then-Verify Approach:** "Review script before running; identify gaps; fix before deployment"
- Problem 1: Prevented; gaps identified before running
- Problem 2: Prevented; admin check ensures registry access
- Problem 3: Prevented; script runs once with complete configuration
- Problem 4: Prevented; correct time-range filtering captures all relevant logs

**Timeline Difference:**
- Naive approach: Run script → discover incomplete data → re-run script → 45 min delay
- Verify approach: Review script → fix gaps → run once → 0 min delay

**This 45-minute delay = $675 business cost at $900/hour downtime rate**

---

## Part 8: Key Lessons Learned

### Lesson 1: Temporal + Geographic + Causal Correlation = Common Root Cause

**Insight:** When three independent problems appear in same timeframe, same location, after same change, investigate common cause FIRST before investigating independently.

**Application:**
- Initial instinct to investigate three separate tracks was wrong
- Recognizing correlation pattern enabled single-root-cause hypothesis
- This reduced investigation time from 8+ hours to ~1.5 hours

**Why It Matters:**
- Investigators' natural instinct is domain-separation (auth team handles auth, profiles team handles profiles)
- But complex failures often have unified mechanisms
- Looking for patterns across domains finds root cause faster

**Takeaway:** When multiple domains affected simultaneously after deployment, ask "What single point of failure could cause all three?" before asking "Which domain is broken?"

### Lesson 2: Hypothesis Ranking + Differential Diagnosis Accelerates Root Cause ID

**Insight:** Rather than investigate possibilities randomly, rank by likelihood + test fastest checks first.

**Application:**
- Ranked hypothesis #1 at 70-80% confidence (app in startup)
- Ranked hypothesis #2 at 60-70% confidence (Group Policy)
- Ranked hypothesis #3 at 60-70% confidence (profile server)
- Focus evidence collection on hypothesis #1 "fastest check" (5 min)

**Why It Matters:**
- Without ranking: Might investigate hypothesis #5 first (20 min check), which is wrong
- With ranking: Investigate hypothesis #1 first (5 min check), 70% likely to be right
- Saves ~20-30 minutes per incident

**Takeaway:** Differential diagnosis used in medicine and diagnosis should be used in IT incidents too. Rank possibilities; test most-likely first.

### Lesson 3: Evidence Quality Depends on Evidence Collection Process

**Insight:** Even correct PowerShell script can have subtle flaws that undermine forensic investigation.

**Examples:**
- Silent admin-privilege failures hide incomplete data
- Event message truncation needs specification or data becomes unwieldy
- Time-range filtering essential for forensic relevance
- Multi-method checks (registry + folder) ensure completeness

**Why It Matters:**
- "Run this script and collect evidence" can fail silently
- Investigator proceeds with incomplete data set, draws wrong conclusions
- Wrong conclusions lead to wrong remediation (expensive)

**Takeaway:** Evidence collection is not just "write a script and run it." Evidence collection is precision operation requiring:
- Admin verification
- Multi-method validation
- Data volume control
- Error reporting
- Chain-of-custody documentation

### Lesson 4: AI-Generated Code is Not Production-Ready Without Expert Review

**Insight:** AI generates syntactically correct code that runs without errors, but lacks:
- Domain-specific knowledge (forensics, IT best practices)
- Error handling for edge cases
- Compliance with specific requirements (time-range filtering, permission validation)
- Completeness (missing secondary checks like Startup folders)

**Examples from This Incident:**
1. AI chose `Get-EventLog` (deprecated method) instead of `Get-WinEvent` (current method)
2. AI included full event messages (1 MB file) instead of truncated (100 KB file)
3. AI showed "would export" instead of showing what would be exported
4. AI had no admin check before registry access
5. AI only checked registry, not folder, for startup apps
6. AI had no status reporting per collection section

**Why It Matters:**
- If AI code is used without review, subtle flaws compound
- Investigation speed is impacted (slowness x multiple flaws = hours of delay)
- Forensic completeness is compromised (missing data = wrong conclusion)

**Takeaway:** AI is excellent for generating baseline code fast. Humans must review before deployment. Budget 30-45 minutes for expert review of AI-generated scripts before use in production.

### Lesson 5: Root Cause is Often at the Intersection of Systems, Not Within One System

**Insight:** The Floor 6 incident wasn't "a Copilot bug" or "an authentication failure" or "a profile corruption issue." It was "an app deployment with system startup execution that interferes with login phase, blocking authentication and corrupting profile initialization."

**Why This Matters:**
- Fixing any single domain independently would not solve the problem
  - Fixing Copilot permissions alone: Login still fails
  - Fixing authentication alone: App still corrupts profile
  - Fixing profile alone: Copilot still shows unauthorized data
- **Only** rolling back the app solves all three simultaneously

**Why Initial Assumption Was Wrong:**
- Assumed three domains = three root causes = three fixes
- Actually: one app + three domains = one root cause + one fix
- Investigation model (three separate tracks) was appropriate UNTIL evidence showed correlation
- Once correlation recognized, investigation model needed to pivot

**Takeaway:** Complex IT incidents often have unified root causes at system boundaries, not within single domains. When evidence shows correlation, look for the common denominator.

### Lesson 6: Prevention Through Pre-Deployment Testing Beats Emergency Rollback by 36+ Hours

**Insight:** The Floor 6 incident could have been **completely prevented** with login performance regression testing before production deployment.

**Timeline Comparison:**
- **Without Prevention Control:**
  - Friday 15:00: App deployed to production (no testing)
  - Monday 09:14: Issue discovered
  - Monday 10:30: Rollback initiated
  - $10,800+ business cost
  
- **With Prevention Control:**
  - Friday 14:00: Pre-deployment test detects 66-second login regression
  - Friday 14:45: Deployment halted
  - $0 business cost

**Why It Matters:**
- Incident response is expensive (investigation, rollback, communication)
- Prevention is cheaper than reaction
- 45-minute test prevents 12-hour incident

**Takeaway:** For software deployments affecting legal/business-critical users, pre-deployment testing for login performance regression should be **mandatory**. Testing cost (~$100 in engineer time) vs. incident cost (~$10,000+) is obvious ROI.

### Lesson 7: Transparent Communication Reduces Speculation and Accelerates Fix

**Insight:** When incident status is unknown, users speculate, spread misinformation, escalate.

**Impact of Good Communication:**
- Users know fix is in progress (reduces panic calls)
- Users know estimated timeline (sets expectations)
- Users know they're not alone (reduces workaround attempts)
- Help Desk receives fewer escalation calls (focus on incident resolution)

**Impact of Poor Communication:**
- Users assume worst (data loss, security breach)
- Users attempt workarounds (creates secondary issues)
- Users call Help Desk repeatedly (delays incident response)
- Speculation spreads to management (executive escalation)

**Takeaway:** Incident communication should be brief, honest, and frequent (every 30 minutes minimum). Status template: "What happened" + "What we're doing" + "Estimated timeline" + "What you should do" (usually: wait, don't retry, check email on phone).

### Lesson 8: Specific Controls Beat Generic Recommendations

**Insight:** Generic recommendations like "test more" or "improve monitoring" don't prevent specific incidents. Specific controls do.

**Floor 6 Incident:**
- Generic recommendation: "Test deployment more thoroughly"
  - Result: Ignored or interpreted as "do more testing of unknown type"
  - Did not prevent incident

- Specific control: "Login Performance Regression Test"
  - Requirement: Measure login time before/after app
  - Threshold: Regression must be ≤5 seconds
  - Result: Detects 66-second regression and halts deployment
  - Prevents incident

**Why It Matters:**
- Specific controls are executable ("Run this test", "Check this value", "Apply this threshold")
- Generic recommendations are interpretable ("test more" could mean anything)
- Specific controls are measurable and verifiable
- Specific controls can be automated

**Takeaway:** Prevention recommendations should be specific and actionable. Not "improve testing" but "measure login time regression pre/post deployment; threshold ≤5 seconds; halt if exceeded."

---

## Conclusion: From Incident to Insight

### The Investigation Arc
1. **Discovery:** Three parallel incidents reported simultaneously
2. **Hypothesis:** Three separate issues (initial assumption)
3. **Challenge:** Temporal/geographic/causal correlation recognized
4. **Pivot:** Single root-cause hypothesis became primary track
5. **Evidence:** AI-generated script required human verification and correction
6. **Verification:** Generate-Then-Verify principle prevented silent evidence gaps
7. **Resolution:** Unified understanding of app deployment interference
8. **Prevention:** Specific control (login regression test) would prevent recurrence

### Why This Matters Beyond Incident Resolution

This incident demonstrates the **gap between what tools and automation can do vs. what domain expertise can add:**

**AI Tool Alone:**
- Generates script that runs without errors
- Produces data in requested format
- But misses forensic requirements, edge cases, completeness checks

**Domain Expert Alone:**
- Takes 2-3 hours to write equivalent script
- Gets every detail correct from start
- But speed is insufficient for incident response

**AI + Expert (Generate-Then-Verify):**
- Generates baseline fast (15 min)
- Expert corrects in 30 min
- Deployed solution is complete AND fast
- Enables better incident response outcomes

### Final Insight

The Floor 6 incident ultimately teaches that **incident investigation is not a data problem; it's an analytical problem.** Having comprehensive logs and evidence is necessary but not sufficient. Asking the right questions, recognizing patterns, challenging initial assumptions, and pivoting when evidence contradicts hypothesis—these are the differentiators between a 12-hour incident and a 36-hour incident.

**The most important tool was not PowerShell. It was the decision to recognize correlation and pivot investigation strategy.**

---

**Incident ID:** FLR6-002  
**Date Incident Discovered:** 2026-08-14 09:14  
**Reflection Date:** 2026-08-14 17:00  
**Reflection Status:** Complete  
