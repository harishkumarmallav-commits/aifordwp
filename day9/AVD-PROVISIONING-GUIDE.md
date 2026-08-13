# Azure Virtual Desktop (AVD) Provisioning Guide

**Version:** 1.0  
**Date:** 2026-08-13  
**Environment:** Azure Cloud  
**Target Setup:** Windows 11 multi-user session host pool with Microsoft Entra ID integration

---

## Executive Summary

This guide documents the complete provisioning workflow for an Azure Virtual Desktop (AVD) environment, including hostpool creation, session host deployment, agent registration, and security configuration. The process involves Azure CLI commands and PowerShell scripts for automation and validation.

---

## Prerequisites

- Azure subscription with appropriate RBAC roles
- Azure CLI 2.0+ installed
- PowerShell 5.1 or later
- Access to Microsoft Entra ID (formerly Azure AD)
- Resource group created in Azure

---

## Provisioning Workflow

### Phase 1: Initial Configuration & Validation

#### 1.1 Verify Azure Connectivity
- **Command:** `az account show`
- **Purpose:** Confirm Azure CLI authentication and current subscription
- **Output:** Validates account, subscription ID, and tenant details

#### 1.2 List Available SKUs
- **Script:** List Windows 11 multi-user images with specific versions (22H2, 23H2, 24H2)
- **Commands:**
  - `az vm image list --publisher MicrosoftWindowsDesktop --all`
  - Filter by offer: `Windows-11`
  - Filter by SKU: `win11-21h2`, `win11-22h2`, `win11-23h2`, `win11-24h2`
- **Purpose:** Identify compatible VM images for session hosts

---

### Phase 2: Hostpool & Application Group Setup

#### 2.1 Create Hostpool
**Command Template:**
```powershell
az desktopvirtualization hostpool create `
  -g <resource-group> `
  -n <hostpool-name> `
  --host-pool-type Pooled `
  --load-balancer-type BreadthFirst `
  --personal-desktop-assignment-type Persistent `
  --maximum-sessions-allowed 5 `
  --preferred-app-group-type Desktop
```

**Parameters:**
- `--host-pool-type`: Pooled or Personal
- `--load-balancer-type`: BreadthFirst (recommended for cost optimization)
- `--maximum-sessions-allowed`: Max concurrent sessions per host
- `--preferred-app-group-type`: Desktop (for full desktop) or RailApplications (for RemoteApp)

**Example:**
```
az desktopvirtualization hostpool create -g dwpai-lab-rg -n POOL-FIN-01 \
  --host-pool-type Pooled \
  --load-balancer-type BreadthFirst \
  --maximum-sessions-allowed 5 \
  --preferred-app-group-type Desktop
```

#### 2.2 Create Application Group (Desktop Application Group)
**Command Template:**
```powershell
az desktopvirtualization applicationgroup create `
  -g <resource-group> `
  -n <appgroup-name> `
  --host-pool-name <hostpool-name> `
  --application-group-type Desktop
```

**Example:**
```
az desktopvirtualization applicationgroup create -g dwpai-lab-rg \
  -n DAG-FIN-01 \
  --host-pool-name POOL-FIN-01 \
  --application-group-type Desktop
```

#### 2.3 Create Workspace
**Command Template:**
```powershell
az desktopvirtualization workspace create `
  -g <resource-group> `
  -n <workspace-name> `
  --application-group-ids <appgroup-resource-id>
```

**Example:**
```
az desktopvirtualization workspace create -g dwpai-lab-rg \
  -n WS-FIN-01 \
  --application-group-ids <full-resource-id-of-appgroup>
```

---

### Phase 3: Session Host Deployment

#### 3.1 Create Session Host VMs
**Command Template:**
```powershell
az vm create `
  -g <resource-group> `
  -n <vm-name> `
  --image <image-urn> `
  --size <vm-size> `
  --nics <nic-id> `
  --os-disk-size-gb 128 `
  --admin-username azureuser
```

**Parameters:**
- `--image`: Windows 11 multi-session image URN (e.g., `MicrosoftWindowsDesktop:Windows-11:win11-24h2:latest`)
- `--size`: Recommended VM sizes: Standard_D2s_v5, Standard_D4s_v5 (for multi-session)
- `--nics`: Network interface to attach
- `--os-disk-size-gb`: Storage capacity (minimum 128GB for Windows 11)

**Example:**
```
az vm create -g dwpai-lab-rg -n shfin0101 \
  --image MicrosoftWindowsDesktop:Windows-11:win11-24h2:latest \
  --size Standard_D4s_v5 \
  --admin-username azureuser
```

#### 3.2 Wait for VM Creation
- **Purpose:** Ensure VM is in running state before installing extensions
- **Polling:** Check VM state every 30 seconds until `provisioningState` = "Succeeded"

---

### Phase 4: Agent Installation & Registration

#### 4.1 Install Microsoft Entra ID Login Extension
**Command:**
```
az vm extension set \
  -g dwpai-lab-rg \
  -n shfin0101 \
  --publisher Microsoft.Azure.ActiveDirectory \
  --name AADLoginForWindows \
  --version 2.0
```

**Purpose:** Enable Microsoft Entra ID join and passwordless sign-in capabilities

#### 4.2 Generate Hostpool Registration Token
**Command:**
```
az desktopvirtualization hostpool update \
  -g dwpai-lab-rg \
  -n POOL-FIN-01 \
  --registration-info expiration-time=2024-03-20T00:00:00Z registration-token-operation=Update
```

**Output:** Capture the registration token from the response (valid for specified duration)

#### 4.3 Register Session Host to Hostpool
**Script:** [register-avd-sessionhost.ps1](../day8/register-avd-sessionhost.ps1)

**Steps:**
1. Download RDInfra agent installer
2. Execute installer with token and hostpool name
3. Validate registration in hostpool

**Command Reference:**
```
az vm run-command invoke \
  -g dwpai-lab-rg \
  -n shfin0101 \
  --command-id RunPowerShellScript \
  --scripts @register-avd-sessionhost.ps1
```

---

### Phase 5: Configuration & Security

#### 5.1 Set Hostpool RDP Properties
**Script:** [set-hostpool-rdp-props.ps1](../day8/set-hostpool-rdp-props.ps1)

**Configuration:**
```
targetisaadjoined:i:1
enablerdsaadauth:i:1
```

**Command:**
```
az desktopvirtualization hostpool update \
  -g dwpai-lab-rg \
  -n POOL-FIN-01 \
  --custom-rdp-property 'targetisaadjoined:i:1;enablerdsaadauth:i:1'
```

**Purpose:** 
- Enable Microsoft Entra ID authentication
- Configure session host for Entra-joined devices

#### 5.2 Configure RBAC Roles

Assign the following roles to end users:
- **Desktop Virtualization User** - Access published resources
- **Virtual Machine User Login** - RDP sign-in capability

**Commands:**
```
az role assignment create \
  --role "Desktop Virtualization User" \
  --assignee <user-principal-name> \
  --scope <appgroup-resource-id>

az role assignment create \
  --role "Virtual Machine User Login" \
  --assignee <user-principal-name> \
  --scope <vm-resource-id>
```

---

### Phase 6: Validation & Diagnostics

#### 6.1 Verify Session Host Status
**Script:** [check-rdinfra-services-and-reg.ps1](../day8/check-rdinfra-services-and-reg.ps1)

**Checks:**
- Hostpool connection status
- RDInfraAgent registry configuration
- Service health (RDAgentBootLoader, RDInfraAgent)

#### 6.2 Check RDInfra Registry
**Script:** [check-rdinfra-reg.ps1](../day8/check-rdinfra-reg.ps1)

**Registry Path:** `HKLM:\SOFTWARE\Microsoft\RDInfraAgent`

**Key Values to Verify:**
- `PoolName`
- `TenantName`
- `IsRegistered`
- `LastStatusReport`
- `RegistrationToken`

#### 6.3 Diagnose AVD Events
**Script:** [diagnose-avd-events.ps1](../day8/diagnose-avd-events.ps1)

**Event Log Channels:**
- System
- Application
- Microsoft-Windows-TerminalServices-LocalSessionManager/Operational
- Microsoft-Windows-RemoteDesktopServices-RdpCoreTS/Operational

**Error Patterns to Search:**
- "Agent Registration Failed"
- "Token Expired"
- "Connection Failed"

#### 6.4 Check Entra Join Status
**Command:**
```
dsregcmd /status
```

**Expected Output:**
```
Device Name: shfin0101
Join Type: Azure AD joined
```

---

## Supporting Scripts

All scripts are located in [day8 folder](../day8/):

| Script | Purpose |
|--------|---------|
| `register-avd-sessionhost.ps1` | Download and install RDInfra agent |
| `register-avd-sessionhost-direct.ps1` | Direct registration without token refresh |
| `set-hostpool-rdp-props.ps1` | Configure Entra ID authentication properties |
| `refresh-hostpool-token.ps1` | Generate new registration token |
| `check-rdinfra-reg.ps1` | Validate RDInfraAgent registry configuration |
| `check-rdinfra-services-and-reg.ps1` | Comprehensive health check |
| `diagnose-avd-events.ps1` | Event log analysis for errors |
| `diagnose-avd-sessionhost.ps1` | Full session host diagnostics |
| `join-entra-device.ps1` | Manual Entra ID join (if needed) |
| `get-rdinfra-events.ps1` | Extract RDInfra-related events |

### Helper Batch Files
- `run-register-avd.cmd` - Wrapper for registration script
- `run-set-hostpool-rdp.cmd` - Wrapper for RDP property configuration
- `run-refresh-hostpool-token.cmd` - Wrapper for token refresh
- `show-hostpool-token.cmd` - Display current token
- `list-sessionhosts.cmd` - List hostpool session hosts
- `check-hostpool-rdp.cmd` - Check RDP property settings
- `check-rdinfra-services-and-reg.cmd` - Service and registry check

---

## Troubleshooting

### Issue: Session Host Shows "Not Available"
1. Run: `check-rdinfra-services-and-reg.ps1`
2. Verify registration token is still valid
3. Check Event Viewer for errors (see Phase 6.3)
4. Redeploy agent if needed: `register-avd-sessionhost.ps1`

### Issue: Users Cannot Connect
1. Verify RBAC role assignments (Phase 5.2)
2. Check Entra ID join status on VM
3. Validate RDP properties are configured (Phase 5.1)
4. Review security group membership

### Issue: Entra ID Authentication Fails
1. Confirm AAD Login extension is installed (Phase 4.1)
2. Run: `join-entra-device.ps1` if device is not Entra-joined
3. Verify `targetisaadjoined:i:1` in hostpool properties
4. Check Microsoft Entra ID device registration status

### Issue: Token Expiration
1. Generate new token: `refresh-hostpool-token.ps1`
2. Re-register agents with new token
3. Verify token expiration time in hostpool settings

---

## Performance Tuning

### Recommended VM Sizes (Multi-Session)
- **Light Workload:** Standard_D2s_v5 (2 vCPU, 8 GB RAM)
- **Medium Workload:** Standard_D4s_v5 (4 vCPU, 16 GB RAM)
- **Heavy Workload:** Standard_D8s_v5 (8 vCPU, 32 GB RAM)

### Load Balancing
- **BreadthFirst:** Distributes sessions across hosts (recommended for cost optimization)
- **DepthFirst:** Fills one host before using another (for resource consolidation)

### Maximum Sessions
- Windows 11 multi-session: 1-10 users per host (adjust based on workload)

---

## Security Best Practices

1. **Network Security:** Place AVD in VNet with NSGs
2. **RDP Port:** Use custom RDP ports (not 3389)
3. **Firewall:** Restrict access to authorized users only
4. **MFA:** Enable MFA in Microsoft Entra ID
5. **Device Compliance:** Require compliant devices if using Conditional Access
6. **Image Patching:** Apply latest Windows updates before provisioning

---

## Rollback Procedures

### Delete Session Host
```
az vm delete -g dwpai-lab-rg -n shfin0101 --yes
```

### Delete Hostpool
```
az desktopvirtualization hostpool delete -g dwpai-lab-rg -n POOL-FIN-01
```

### Delete Workspace
```
az desktopvirtualization workspace delete -g dwpai-lab-rg -n WS-FIN-01
```

**Note:** Deleting workspace automatically removes associated application groups.

---

## Commands Reference Card

```bash
# List all Azure SDKs and tools
which az

# Show Azure CLI version and path
az --version

# Verify subscription
az account show

# List available VM images
az vm image list --publisher MicrosoftWindowsDesktop --all

# Create resources
az desktopvirtualization hostpool create ...
az desktopvirtualization applicationgroup create ...
az desktopvirtualization workspace create ...
az vm create ...

# Manage extensions
az vm extension set ... (AAD Login)
az vm extension list -g <rg> -n <vm-name>

# Generate and refresh tokens
az desktopvirtualization hostpool update --registration-info expiration-time=... registration-token-operation=Update

# Run scripts on VM
az vm run-command invoke -g <rg> -n <vm-name> --command-id RunPowerShellScript --scripts @script.ps1

# Update hostpool properties
az desktopvirtualization hostpool update --custom-rdp-property ...

# Assign RBAC roles
az role assignment create --role <role-name> --assignee <upn> --scope <resource-id>
```

---

## Timeline & Duration

| Phase | Duration | Critical Path |
|-------|----------|----------------|
| Phase 1: Validation | 5-10 min | No dependencies |
| Phase 2: Infrastructure | 5 min | Sequential |
| Phase 3: VM Deployment | 10-15 min | Blocking |
| Phase 4: Agent Install | 15-20 min | Requires Phase 3 complete |
| Phase 5: Configuration | 5 min | Requires Phase 4 complete |
| Phase 6: Validation | 10-15 min | Requires Phase 5 complete |
| **Total Estimated Time** | **50-65 min** | |

---

## Appendix: Full Command Examples

### Complete Provisioning Sequence
```powershell
# Set variables
$resourceGroup = "dwpai-lab-rg"
$hostpoolName = "POOL-FIN-01"
$appgroupName = "DAG-FIN-01"
$workspaceName = "WS-FIN-01"
$vmName = "shfin0101"
$vmSize = "Standard_D4s_v5"
$imageUrn = "MicrosoftWindowsDesktop:Windows-11:win11-24h2:latest"

# 1. Create Hostpool
az desktopvirtualization hostpool create -g $resourceGroup -n $hostpoolName `
  --host-pool-type Pooled --load-balancer-type BreadthFirst --maximum-sessions-allowed 5

# 2. Create Application Group
az desktopvirtualization applicationgroup create -g $resourceGroup -n $appgroupName `
  --host-pool-name $hostpoolName --application-group-type Desktop

# 3. Create Workspace
az desktopvirtualization workspace create -g $resourceGroup -n $workspaceName `
  --application-group-ids <appgroup-resource-id>

# 4. Create VM
az vm create -g $resourceGroup -n $vmName --image $imageUrn --size $vmSize `
  --admin-username azureuser

# 5. Install Entra ID Login Extension
az vm extension set -g $resourceGroup -n $vmName `
  --publisher Microsoft.Azure.ActiveDirectory --name AADLoginForWindows --version 2.0

# 6. Generate Token & Register
# (See Phase 4 scripts for registration workflow)

# 7. Configure RDP Properties
az desktopvirtualization hostpool update -g $resourceGroup -n $hostpoolName `
  --custom-rdp-property 'targetisaadjoined:i:1;enablerdsaadauth:i:1'

# 8. Assign RBAC Roles
az role assignment create --role "Desktop Virtualization User" `
  --assignee <user-upn> --scope <appgroup-resource-id>
```

---

## Document History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2026-08-13 | Training Lab | Initial comprehensive provisioning guide |

---

**Last Updated:** 2026-08-13  
**Status:** Production Ready
