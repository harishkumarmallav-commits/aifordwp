$ErrorActionPreference = 'Stop'

$mdm = Get-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\CloudDomainJoin\JoinInfo\*' -ErrorAction SilentlyContinue
Write-Output '=== JoinInfo ==='
$mdm | Select-Object * | ConvertTo-Json -Depth 6
Write-Output '=== dsregcmd /status ==='
dsregcmd /status
