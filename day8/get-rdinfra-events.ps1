$ErrorActionPreference = 'Continue'

$paths = @(
    'Microsoft-RDInfra-Agent/Operational',
    'Microsoft-RDInfra-Agent/Trace',
    'Application'
)

foreach ($logName in $paths) {
    Write-Output "=== $logName ==="
    try {
        if ($logName -eq 'Application') {
            Get-WinEvent -LogName Application -MaxEvents 200 |
                Where-Object { $_.ProviderName -match 'RDAgent|RDInfra|Remote Desktop' -or $_.Message -match 'RDAgent|RDInfra|registration' } |
                Select-Object -First 20 TimeCreated, ProviderName, Id, LevelDisplayName, Message |
                Format-List
        } else {
            Get-WinEvent -LogName $logName -MaxEvents 50 |
                Select-Object -First 20 TimeCreated, ProviderName, Id, LevelDisplayName, Message |
                Format-List
        }
    } catch {
        Write-Output $_.Exception.Message
    }
}
