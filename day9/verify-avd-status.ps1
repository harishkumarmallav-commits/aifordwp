param(
    [string]$SubscriptionId = 'b2f12c89-b8dc-496c-bd77-6c41d7fc0340',
    [string]$ResourceGroup = 'dwpai-lab-rg',
    [string]$HostPoolName = 'POOL-FIN-01',
    [string]$WorkspaceName = 'FinBridge-Workspace',
    [string]$AppGroupName = 'POOL-FIN-01-DAG',
    [string]$UserUpn = 'p45@zippyops.in'
)

$ErrorActionPreference = 'Stop'
$az = 'C:\Program Files\Microsoft SDKs\Azure\CLI2\wbin\az.cmd'

if (-not (Test-Path $az)) {
    throw "Azure CLI not found at $az"
}

& $az account set --subscription $SubscriptionId | Out-Null

Write-Host 'ACCOUNT'
& $az account show --query '{user:user.name,sub:id,tenant:tenantId}' -o json

Write-Host 'HOSTPOOL'
& $az desktopvirtualization hostpool show -g $ResourceGroup -n $HostPoolName --query '{name:name,type:hostPoolType,lb:loadBalancerType,max:maxSessionLimit,validation:validationEnvironment}' -o json

Write-Host 'APPGROUP'
& $az desktopvirtualization applicationgroup show -g $ResourceGroup -n $AppGroupName --query '{name:name,type:applicationGroupType,hostPoolArmPath:hostPoolArmPath}' -o json

Write-Host 'WORKSPACE'
& $az desktopvirtualization workspace show -g $ResourceGroup -n $WorkspaceName --query '{name:name,location:location}' -o json

Write-Host 'WORKSPACE APPGROUP LINK'
& $az desktopvirtualization workspace show -g $ResourceGroup -n $WorkspaceName --query 'applicationGroupReferences' -o json

Write-Host 'SESSIONHOSTS'
& $az resource list -g $ResourceGroup --resource-type 'Microsoft.DesktopVirtualization/hostpools/sessionhosts' --query '[].{name:name,type:type,location:location}' -o table

Write-Host 'VM'
& $az vm list -g $ResourceGroup --query "[?contains(name,'pool-fin-01') || contains(name,'avd') || contains(name,'session')].{name:name,power:powerState,location:location,security:securityProfile.securityType}" -o table

Write-Host 'ROLE ASSIGNMENTS USER'
$userId = & $az ad user show --id $UserUpn --query id -o tsv
& $az role assignment list --all --assignee-object-id $userId --query "[?contains(scope,'$ResourceGroup') || contains(scope,'$SubscriptionId')].{role:roleDefinitionName,scope:scope}" -o table
