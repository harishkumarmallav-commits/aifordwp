# Phased Intune Deployment Plan: FinBridge Connect v3.1 (10,000 Win11 Endpoints)

Date: 2026-08-12  
Owner: DWP Endpoint Engineering (Intune)

## 1. RING STRUCTURE

Ring design assumes FinBridge Connect v3.1 is already uploaded in Intune as a Windows app (Win32) from the existing .intunewin package.

Ring 1 (Pilot)
- Size: 300 devices/users total (3% of fleet)
- Duration: 3 calendar days deployment + 2 calendar days monitoring (5 days total)
- Who to include:
  - IT support power users and service desk champions (about 80)
  - Cross-business pilot users (about 180)
  - Explicit at-risk hardware sample: 40 devices with 4GB RAM
- Purpose:
  - Validate install behavior, detection rule reliability (registry version string), and immediate stability under controlled scale
  - Surface packaging/detection failures before business-critical groups
- Intune assignment group type:
  - Static Microsoft Entra ID security group (manually curated for controlled membership)

Ring 2 (Early)
- Size: 2,200 devices/users total (22% of fleet), including Finance 500 by end of week 1 under recommended path in section 4
- Duration: 4 calendar days deployment + 3 calendar days monitoring (7 days total)
- Who to include:
  - Finance business unit (500 users)
  - Remaining early adopters from operations, HR, and selected regional offices
  - Additional at-risk hardware sample: at least 120 devices with 4GB RAM
- Purpose:
  - Validate performance and support volume at meaningful business scale
  - Confirm no business-process blockers before broad release
- Intune assignment group type:
  - Dynamic Entra ID device groups by department and readiness tags (plus one static exception group for named Finance users)

Ring 3 (Broad)
- Size: Remaining 7,500 devices/users (75% of fleet)
- Duration: 5 calendar days deployment + 4 calendar days monitoring (9 days total), finishing within 3 weeks
- Who to include:
  - All remaining production Win11 endpoints not in Rings 1-2
  - 4GB RAM devices only after hardware-specific thresholds are green
- Purpose:
  - Complete tenant-wide adoption while preserving rollback/isolation control by subgroup
- Intune assignment group type:
  - Dynamic Entra ID device groups by production scope (region/site/business unit), split into sub-waves for throttling

## 2. ADVANCE CRITERIA

All criteria are measured from Intune app install status, device status, and service desk ticket queue tagged "FinBridge v3.1". A ring can advance only if every criterion is met.

Ring 1 to Ring 2 advance gate
- Install success rate (minimum): 97.0% or higher
  - Formula: successful installs / targeted devices in Ring 1
  - Observation source: Intune Win32 app install status report
- Error rate threshold (maximum): 2.0% or lower
  - Formula: failed installs / targeted devices
  - Observation source: Intune failure status and error code breakdown
- User-reported issue rate (maximum): 1.5 tickets per 100 users per 24 hours (1.5%)
  - Observation source: Service desk incidents with app tag
- Monitoring period (minimum): 48 continuous hours after 90% of Ring 1 devices report install state
- Time-bound decision point: Change Advisory review at end of monitoring window; go/no-go within 4 business hours

Ring 2 to Ring 3 advance gate
- Install success rate (minimum): 98.0% or higher
  - Formula: successful installs / targeted devices in Ring 2
  - Observation source: Intune Win32 app install status report
- Error rate threshold (maximum): 1.2% or lower
  - Formula: failed installs / targeted devices
  - Observation source: Intune error report by code, tenant and subgroup
- User-reported issue rate (maximum): 1.0 ticket per 100 users per 24 hours (1.0%)
  - Observation source: Service desk incidents with app tag
- Monitoring period (minimum): 72 continuous hours after 90% of Ring 2 devices report install state
- Time-bound decision point: CAB + Finance product owner sign-off in 1 business day

Hold condition (pause without full rollback)
- Trigger: any single recurring install error code exceeds 0.8% of targeted devices in an active ring over a rolling 12-hour window, while aggregate success still meets threshold
- Action: pause expansion to next subgroup for 24 hours, keep current successful installs in place, run remediation package for that error class
- Specific example: error 0x87D300C9 appears on 22 of 2,200 Ring 2 devices (1.0%) in 12 hours; rollout is paused and remediation starts, but no immediate tenant-wide rollback

## 3. ROLLBACK TRIGGERS

Trigger 1: Install failure rate automatic halt
- Condition: install failure rate exceeds 6.0% in any active ring for 6 continuous hours
- Decision owner: DWP Endpoint Incident Manager (on-call) with Intune Platform Lead
- Decision window: immediate halt within 30 minutes of threshold breach
- Exact Intune action:
  - Remove required assignment of FinBridge Connect v3.1 from current ring deployment group
  - Add required assignment of FinBridge Connect v3.0 to that same deployment group
  - Keep v3.1 only on a small technical validation group (max 25 devices) for root cause testing

Trigger 2: Application crash rate rollback consideration
- Condition: app crash rate >= 3 crashes per 100 active installs per 24 hours for 2 consecutive days in the same ring
- Decision owner: Endpoint Engineering Manager + Business Service Owner
- Decision window: 4 business hours after second-day confirmation
- Exact Intune action:
  - Freeze all pending v3.1 assignments (do not expand to next subgroup)
  - If confirmed severe user impact, switch affected ring from required v3.1 to required v3.0
  - Retain unaffected prior rings only if their crash telemetry is below threshold

Trigger 3: Business-critical failure immediate rollback
- Condition: Finance users cannot complete payment authorization workflow in FinBridge Connect due to v3.1 defect (reproducible on >= 3 distinct Finance devices)
- Decision owner: Finance Product Owner can invoke emergency rollback; execution by Intune Platform Lead
- Decision window: 60 minutes from validated incident bridge declaration
- Exact Intune action:
  - Immediately unassign required v3.1 from Finance group
  - Assign required v3.0 to Finance group
  - Block Ring 2/3 expansion until validated hotfix or vendor mitigation is approved

Trigger 4: 4GB RAM at-risk group ring isolation
- Condition: failure rate on 4GB RAM devices exceeds 10% in any 24-hour period in active ring
- Decision owner: Endpoint Engineering Duty Lead
- Decision window: 2 hours from threshold breach
- Exact Intune action:
  - Exclude "Win11-4GB-RAM" dynamic group from v3.1 required assignment in all active rings
  - Assign v3.0 required deployment to that excluded hardware group
  - Continue v3.1 rollout for non-4GB devices only if global criteria remain green

## 4. FINANCE DEADLINE RESOLUTION

Option A: Compress pilot so Finance enters Ring 2 by end of week 1
- Minimum safe pilot duration: 72 hours total (48 hours deployment + 24 hours monitoring)
- Risk introduced:
  - Lower chance of detecting medium-latency defects (for example, second-day profile/cache issues)
  - Higher chance of discovering business-impact issues inside Finance instead of before Finance
- Compensating control:
  - Increase pilot sample quality rather than duration: enforce inclusion of 40 at-risk 4GB devices and 20 heavy-use transaction users
  - Add twice-daily telemetry review checkpoints and pre-approved emergency rollback runbook

Option B: Create separate Finance Ring 0 before main pilot
- Ring 0 structure:
  - Size: 500 Finance users
  - Start: day 1
  - Wave split: 150 users (day 1), 150 users (day 2), 200 users (day 3)
  - Assignment type: static Entra group for exact user control
- Ring 0 advance conditions:
  - Wave-to-wave advance if prior wave has >= 97.5% install success, <= 1.5% failures, <= 1.0 ticket per 100 users over 24 hours
  - Hold wave for 24 hours if any single error code exceeds 1.0%
- Ring 0 rollback plan:
  - If failure rate > 5% in any wave over 6 hours, revert the full Finance Ring 0 group to required v3.0 within 60 minutes
  - Freeze all additional non-Finance rollout until root cause is closed

Recommendation: Option B (Finance Ring 0)
- Justification:
  - Meets hard business deadline with controlled, wave-based risk for the exact critical audience
  - Protects main rollout integrity by decoupling Finance urgency from pilot quality for the other 9,500 endpoints
  - Provides cleaner governance: Finance has explicit entry/exit criteria and dedicated rollback authority without forcing an unsafe compression of global pilot validation
- Execution outcome:
  - Finance completes by end of week 1 under Ring 0 wave plan
  - Main Ring 1 pilot for broader population still runs at full 5-day quality gate, reducing probability of tenant-wide disruption
