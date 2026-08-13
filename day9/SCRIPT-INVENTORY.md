# AVD Provisioning Script Inventory

**Location:** All scripts located in [../day8/](../day8/) folder

## Registration & Configuration Scripts

### Core Registration Workflow
```
register-avd-sessionhost.ps1
  │
  ├─ Purpose: Download RDInfra agent from Microsoft servers and install with token
  ├─ When to use: Initial session host agent installation
  ├─ Execution: az vm run-command invoke with this script
  └─ Required: Valid hostpool registration token (from refresh-hostpool-token.ps1)
```

### Registration Variants
```
register-avd-sessionhost-direct.ps1
  └─ Purpose: Direct registration without requiring token refresh
  └─ When to use: Alternative method if standard registration fails
```

### Token Management
```
refresh-hostpool-token.ps1
  ├─ Purpose: Generate new registration token (expiration-based)
  ├─ When to use: Every ~24 hours or before registering new session hosts
  └─ Output: Valid token string to use in register scripts
```

### Configuration
```
set-hostpool-rdp-props.ps1
  ├─ Purpose: Configure Entra ID authentication in hostpool RDP properties
  ├─ When to use: After hostpool creation, before users connect
  ├─ Sets: targetisaadjoined:i:1 and enablerdsaadauth:i:1
  └─ Critical: Enables passwordless Entra ID sign-in
```

---

## Validation & Diagnostics Scripts

### Quick Health Checks
```
check-rdinfra-reg.ps1
  ├─ Purpose: Verify RDInfraAgent registry configuration
  ├─ When to use: Troubleshooting registration issues
  └─ Checks: Registry path HKLM:\SOFTWARE\Microsoft\RDInfraAgent

check-rdinfra-services-and-reg.ps1
  ├─ Purpose: Comprehensive hostpool and registry validation
  ├─ When to use: Session host health verification
  └─ Checks: Services, registry, connection status
```

### Event & Diagnostics
```
diagnose-avd-events.ps1
  ├─ Purpose: Extract and analyze event logs for errors
  ├─ Event channels: System, Application, TerminalServices
  └─ When to use: Troubleshooting session host issues

diagnose-avd-sessionhost.ps1
  ├─ Purpose: Full diagnostic report on session host
  └─ When to use: Comprehensive health assessment

diagnose-avd-products.ps1
  └─ Purpose: Check AVD product-level diagnostics

get-rdinfra-events.ps1
  └─ Purpose: Extract RDInfra-specific event log entries
```

### Device & Identity
```
check-vm-identity.cmd
  ├─ Purpose: Verify VM identity configuration
  └─ When to use: Troubleshooting identity issues

join-entra-device.ps1
  ├─ Purpose: Manually join device to Microsoft Entra ID
  ├─ When to use: If device is not Entra-joined after AAD Login extension install
  └─ Prerequisite: Device must be callable from Azure

check-hostpool-rdp.cmd
  └─ Purpose: Verify RDP properties are correctly configured
```

---

## Batch File Wrappers

Quick execution wrappers for common operations:

```
run-register-avd.cmd
  └─ Executes: register-avd-sessionhost.ps1

run-set-hostpool-rdp.cmd
  └─ Executes: set-hostpool-rdp-props.ps1

run-refresh-hostpool-token.cmd
  └─ Executes: refresh-hostpool-token.ps1

run-check-rdinfra-reg.cmd
  └─ Executes: check-rdinfra-reg.ps1

show-hostpool-token.cmd
  └─ Display current hostpool token

list-sessionhosts.cmd
  └─ List all session hosts in current hostpool
```

---

## Usage Flow Diagram

```
Provisioning Workflow:
├─ Phase 1: Infrastructure Setup
│  └─ Azure CLI commands (no scripts needed)
│
├─ Phase 2: VM Deployment  
│  └─ Azure CLI commands (no scripts needed)
│
├─ Phase 3: Extension Installation
│  └─ Azure CLI commands (no scripts needed)
│
├─ Phase 4: Agent Registration ⭐ CRITICAL
│  ├─ run-refresh-hostpool-token.cmd (or refresh-hostpool-token.ps1)
│  └─ run-register-avd.cmd (or register-avd-sessionhost.ps1)
│
├─ Phase 5: RDP Configuration ⭐ CRITICAL
│  └─ run-set-hostpool-rdp.cmd (or set-hostpool-rdp-props.ps1)
│
└─ Phase 6: Validation ⭐ FOR TROUBLESHOOTING
   ├─ check-rdinfra-services-and-reg.ps1
   ├─ diagnose-avd-events.ps1
   └─ join-entra-device.ps1 (if needed)
```

---

## Script Dependencies

```
Execution Order (for new deployment):
1. refresh-hostpool-token.ps1 (First! Get token)
   └─ Input: Hostpool name, resource group
   └─ Output: Registration token

2. register-avd-sessionhost.ps1 (Run on each VM)
   └─ Input: Token from step 1
   └─ Installs: RDInfra agent and RDAgentBootLoader services

3. set-hostpool-rdp-props.ps1 (Configure hostpool once)
   └─ Enables: Entra ID authentication properties
   └─ Applies to: All current and future session hosts

4. Validation scripts (Run as needed for troubleshooting)
   └─ check-rdinfra-services-and-reg.ps1
   └─ diagnose-avd-events.ps1
```

---

## Critical Parameters & Environment Variables

### Required for Registration
```powershell
$HostPoolName = "POOL-FIN-01"
$ResourceGroupName = "dwpai-lab-rg"
$TenantName = "dwpai.onmicrosoft.com" (or your Entra ID tenant)
$RegistrationToken = "<from refresh-hostpool-token.ps1>"
```

### VM-Specific
```powershell
$VMName = "shfin0101"
$ImageUrn = "MicrosoftWindowsDesktop:Windows-11:win11-24h2:latest"
$VMSize = "Standard_D4s_v5"
```

### RDP Properties
```
targetisaadjoined:i:1          (Enable Entra ID)
enablerdsaadauth:i:1           (Enable Entra ID Auth)
```

---

## Troubleshooting Quick Reference

### Script: Diagnose Session Host Not Available
```powershell
# Run this diagnostic
./check-rdinfra-services-and-reg.ps1

# If failed:
# 1. Verify token is still valid: ./show-hostpool-token.cmd
# 2. If expired, refresh: ./refresh-hostpool-token.ps1
# 3. Re-register: ./run-register-avd.cmd
```

### Script: Cannot Connect / Authentication Fails
```powershell
# Step 1: Verify Entra ID join
./check-vm-identity.cmd

# Step 2: Verify RDP properties
./check-hostpool-rdp.cmd

# Step 3: If RDP properties not set
./set-hostpool-rdp-props.ps1

# Step 4: If device not Entra-joined
./join-entra-device.ps1
```

### Script: Event Log Analysis
```powershell
# Extract and review errors
./get-rdinfra-events.ps1 | Where-Object { $_.LevelDisplayName -eq "Error" }

# Full diagnostics
./diagnose-avd-events.ps1
./diagnose-avd-sessionhost.ps1
./diagnose-avd-products.ps1
```

---

## Notes

- All `.cmd` batch files are wrappers for easier execution from Command Prompt
- All `.ps1` scripts require PowerShell execution and may need execution policy adjustment
- Scripts that run via `az vm run-command invoke` execute with SYSTEM privileges on the VM
- Token expiration is typically 24 hours from generation
- Registry checks require SYSTEM-level access (run as Administrator)

---

**Last Updated:** 2026-08-13  
**All scripts verified:** Day 8 provisioning exercises
