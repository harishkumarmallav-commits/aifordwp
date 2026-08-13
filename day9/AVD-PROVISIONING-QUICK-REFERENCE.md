# AVD Provisioning Quick Reference

## Quick Start (TL;DR)

```powershell
# Phase 1: Create Infrastructure (5 min)
az desktopvirtualization hostpool create -g dwpai-lab-rg -n POOL-FIN-01 \
  --host-pool-type Pooled --load-balancer-type BreadthFirst --maximum-sessions-allowed 5

az desktopvirtualization applicationgroup create -g dwpai-lab-rg -n DAG-FIN-01 \
  --host-pool-name POOL-FIN-01 --application-group-type Desktop

az desktopvirtualization workspace create -g dwpai-lab-rg -n WS-FIN-01 \
  --application-group-ids <appgroup-resource-id>

# Phase 2: Deploy Session Host VM (10-15 min)
az vm create -g dwpai-lab-rg -n shfin0101 \
  --image MicrosoftWindowsDesktop:Windows-11:win11-24h2:latest \
  --size Standard_D4s_v5 --admin-username azureuser

# Phase 3: Install Extension & Register Agent (15-20 min)
az vm extension set -g dwpai-lab-rg -n shfin0101 \
  --publisher Microsoft.Azure.ActiveDirectory \
  --name AADLoginForWindows --version 2.0

# Generate token
TOKEN_RESPONSE=$(az desktopvirtualization hostpool update -g dwpai-lab-rg -n POOL-FIN-01 \
  --registration-info registration-token-operation=Update -o json)

# Register agent (see register-avd-sessionhost.ps1 in ../day8)
az vm run-command invoke -g dwpai-lab-rg -n shfin0101 \
  --command-id RunPowerShellScript --scripts @../day8/register-avd-sessionhost.ps1

# Phase 4: Configure RDP Properties (2 min)
az desktopvirtualization hostpool update -g dwpai-lab-rg -n POOL-FIN-01 \
  --custom-rdp-property 'targetisaadjoined:i:1;enablerdsaadauth:i:1'

# Phase 5: Assign User Access (2 min)
az role assignment create \
  --role "Desktop Virtualization User" \
  --assignee user@domain.com \
  --scope <appgroup-resource-id>
```

---

## Key Scripts Used

Located in [../day8/](../day8/):

### Critical Path Scripts
1. **register-avd-sessionhost.ps1** → Download and install RDInfra agent
2. **set-hostpool-rdp-props.ps1** → Configure Entra ID authentication
3. **refresh-hostpool-token.ps1** → Generate new registration token when expired

### Validation & Diagnostics
- **check-rdinfra-reg.ps1** → Verify registry configuration
- **check-rdinfra-services-and-reg.ps1** → Full health check
- **diagnose-avd-events.ps1** → Event log analysis
- **join-entra-device.ps1** → Force Entra ID join (if needed)

### Helper Commands
- `run-register-avd.cmd` → Quick registration wrapper
- `show-hostpool-token.cmd` → Display current token
- `list-sessionhosts.cmd` → List all session hosts in pool

---

## Common Errors & Fixes

| Error | Solution |
|-------|----------|
| "Session Host Not Available" | Run: `check-rdinfra-services-and-reg.ps1` and refresh token |
| "Cannot Connect" | Verify RBAC roles and Entra ID join status |
| "Authentication Failed" | Run: `set-hostpool-rdp-props.ps1` or `join-entra-device.ps1` |
| "Token Expired" | Run: `refresh-hostpool-token.ps1` then re-register |

---

## Validation Checklist

- [ ] Hostpool created and accessible
- [ ] Application group linked to hostpool
- [ ] Workspace linked to application group
- [ ] VM provisioned and running
- [ ] AAD Login extension installed
- [ ] RDInfraAgent registered (check registry)
- [ ] RDP properties configured for Entra ID
- [ ] User RBAC roles assigned
- [ ] Entra ID join status verified
- [ ] Session host appears in hostpool

---

## Time Estimates

- **Automation Time:** 50-65 minutes total
- **Manual Steps:** ~10 minutes for role assignments
- **Troubleshooting:** Variable (see diagnostics section)
