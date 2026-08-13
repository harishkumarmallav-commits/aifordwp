param(
    [Parameter(Mandatory = $true)]
    [string]$registrationToken
)

$ErrorActionPreference = 'Stop'

$agentUrl = 'https://query.prod.cms.rt.microsoft.com/cms/api/am/binary/RWrmXv'
$bootUrl = 'https://query.prod.cms.rt.microsoft.com/cms/api/am/binary/RWrxrH'
$agentMsi = Join-Path $env:TEMP 'AVD-Agent.msi'
$bootMsi = Join-Path $env:TEMP 'AVD-Bootloader.msi'

Invoke-WebRequest -Uri $bootUrl -OutFile $bootMsi
Invoke-WebRequest -Uri $agentUrl -OutFile $agentMsi

Start-Process -FilePath 'msiexec.exe' -ArgumentList "/i `"$bootMsi`" /qn /norestart" -Wait -NoNewWindow
Start-Process -FilePath 'msiexec.exe' -ArgumentList "/i `"$agentMsi`" REGISTRATIONTOKEN=$registrationToken /qn /norestart" -Wait -NoNewWindow

Start-Sleep -Seconds 20
Get-Service -Name 'RDAgentBootLoader', 'RDAgent' -ErrorAction SilentlyContinue |
    Select-Object Name, Status, StartType |
    Format-Table -AutoSize |
    Out-String
