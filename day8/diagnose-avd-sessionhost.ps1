$ErrorActionPreference = 'Continue'

Write-Output '=== Services ==='
Get-Service -Name 'RdAgent', 'RDAgentBootLoader' -ErrorAction SilentlyContinue |
    Select-Object Name, Status, StartType |
    Format-Table -AutoSize

Write-Output '=== RDInfra Logs ==='
$logRoot = 'C:\ProgramData\Microsoft\RDInfra'
if (Test-Path $logRoot) {
    $logs = Get-ChildItem -Path $logRoot -Recurse -File -Filter '*.log' -ErrorAction SilentlyContinue |
        Sort-Object LastWriteTime -Descending |
        Select-Object -First 5

    if ($logs) {
        $logs | Select-Object FullName, LastWriteTime | Format-Table -AutoSize
        foreach ($log in $logs) {
            Write-Output "--- Tail: $($log.FullName) ---"
            Get-Content -Path $log.FullName -Tail 30 -ErrorAction SilentlyContinue
        }
    } else {
        Write-Output 'No .log files found under RDInfra.'
    }
} else {
    Write-Output 'RDInfra folder not found.'
}
