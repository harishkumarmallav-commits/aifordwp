$ErrorActionPreference = 'Continue'

$patterns = @('RDAgent', 'RDInfra', 'RemoteDesktop', 'WVD')
$allLogs = Get-WinEvent -ListLog * -ErrorAction SilentlyContinue

Write-Output '=== Candidate Event Logs ==='
$matched = $allLogs | Where-Object {
    $ln = $_.LogName
    foreach ($p in $patterns) {
        if ($ln -like "*$p*") { return $true }
    }
    return $false
} | Select-Object -ExpandProperty LogName | Sort-Object -Unique

if (-not $matched) {
    Write-Output 'No matching logs found.'
    exit 0
}

$matched | ForEach-Object { Write-Output $_ }

Write-Output '=== Recent Errors/Warnings ==='
foreach ($logName in $matched) {
    Write-Output "--- $logName ---"
    try {
        Get-WinEvent -LogName $logName -MaxEvents 50 -ErrorAction Stop |
            Where-Object { $_.LevelDisplayName -in @('Error', 'Warning') } |
            Select-Object -First 10 TimeCreated, Id, LevelDisplayName, Message |
            Format-List
    } catch {
        Write-Output "Unable to read $logName : $($_.Exception.Message)"
    }
}
