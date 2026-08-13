param(
    [Parameter(Mandatory = $true)]
    [string]$registrationToken
)

$ErrorActionPreference = 'Stop'
$installer = 'C:\Windows\Temp\AVD-Agent.msi'
if (-not (Test-Path $installer)) {
    throw "AVD agent MSI not found at $installer"
}

Write-Output '=== Existing RDInfraAgent registry ==='
$existing = Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\RDInfraAgent' -ErrorAction SilentlyContinue
if ($existing) {
    $existing | Select-Object * | ConvertTo-Json -Depth 6
} else {
    Write-Output 'RDInfraAgent key missing before repair'
}

Start-Process -FilePath 'msiexec.exe' -ArgumentList "/fa `"$installer`" REGISTRATIONTOKEN=$registrationToken /qn /norestart" -Wait -NoNewWindow
Start-Sleep -Seconds 30

Write-Output '=== Services ==='
Get-Service -Name 'RdAgent', 'RDAgentBootLoader' -ErrorAction SilentlyContinue |
    Select-Object Name, Status, StartType |
    Format-Table -AutoSize |
    Out-String

Write-Output '=== RDInfraAgent registry after repair ==='
if (Test-Path 'HKLM:\SOFTWARE\Microsoft\RDInfraAgent') {
    Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\RDInfraAgent' |
        Select-Object * |
        ConvertTo-Json -Depth 6
} else {
    Write-Output 'RDInfraAgent key missing after repair'
}
