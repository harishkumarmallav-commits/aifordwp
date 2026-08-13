$ErrorActionPreference = 'Continue'

if (Test-Path 'HKLM:\SOFTWARE\Microsoft\RDInfraAgent') {
    Write-Output '=== HKLM:SOFTWARE\Microsoft\RDInfraAgent ==='
    Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\RDInfraAgent' |
        Select-Object * |
        ConvertTo-Json -Depth 6
} else {
    Write-Output 'RDInfraAgent key missing'
}

Write-Output '=== Services ==='
Get-Service -Name 'RdAgent', 'RDAgentBootLoader' -ErrorAction SilentlyContinue |
    Select-Object Name, Status, StartType |
    Format-Table -AutoSize
