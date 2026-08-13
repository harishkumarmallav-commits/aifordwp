$ErrorActionPreference = 'Continue'

Write-Output '=== HKLM:SOFTWARE\\Microsoft\\RDInfraAgent ==='
if (Test-Path 'HKLM:\SOFTWARE\Microsoft\RDInfraAgent') {
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

Write-Output '=== MSI Product Keys ==='
Get-ChildItem 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall' -ErrorAction SilentlyContinue |
    ForEach-Object { Get-ItemProperty $_.PSPath } |
    Where-Object { $_.DisplayName -match 'Remote Desktop|RDInfra|Boot Loader' } |
    Select-Object DisplayName, DisplayVersion |
    Format-Table -AutoSize
