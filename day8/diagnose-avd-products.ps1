$ErrorActionPreference = 'Continue'

Write-Output '=== Installed AVD Products ==='
Get-ChildItem 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall' -ErrorAction SilentlyContinue |
    ForEach-Object { Get-ItemProperty $_.PSPath } |
    Where-Object { $_.DisplayName -match 'Remote Desktop|AVD|WVD|RDAgent|Boot Loader' } |
    Select-Object DisplayName, DisplayVersion, Publisher |
    Format-Table -AutoSize

Write-Output '=== Candidate Log Folders ==='
$paths = @(
    'C:\ProgramData\Microsoft\RDInfra',
    'C:\ProgramData\Microsoft\RDInfraAgent',
    'C:\ProgramData\Microsoft\RDAgent',
    'C:\Windows\Temp',
    'C:\WindowsAzure\Logs\Plugins\Microsoft.CPlat.Core.RunCommandWindows'
)

foreach ($p in $paths) {
    if (Test-Path $p) {
        Write-Output "Found: $p"
        Get-ChildItem -Path $p -Recurse -File -ErrorAction SilentlyContinue |
            Sort-Object LastWriteTime -Descending |
            Select-Object -First 5 FullName, LastWriteTime |
            Format-Table -AutoSize
    } else {
        Write-Output "Missing: $p"
    }
}
