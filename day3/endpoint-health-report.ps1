<#
.SYNOPSIS
Read-only endpoint health report for DWP desktop/endpoint engineering checks (PowerShell 5.1).

.DESCRIPTION
Collects endpoint health data without modifying system state.

VERIFY BEFORE RUNNING
1) Run in an elevated PowerShell session if you need complete visibility of all processes/event logs.
2) Confirm outbound web access to the speed test URL is allowed by your environment/policy.
3) Confirm `quser` is available on the endpoint for logged-in user session counting.
4) This script reads local registry and event logs only; it does not write files, services, registry, or settings.

NOTE
- Internet speed is an approximate download estimate based on a small HTTPS download test.
- CPU values from Get-Process are total processor time (seconds) since process start, not instantaneous CPU percent.
#>

[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'

# This section stores report values in-memory only and does not write to system state.
$report = [ordered]@{}

Write-Host '=== Endpoint Health Report (Read-Only) ===' -ForegroundColor Cyan
Write-Host ('Generated: {0}' -f (Get-Date)) -ForegroundColor Gray
Write-Host ''

# 1) System uptime: reads OS last boot time and calculates elapsed uptime.
try {
    $os = Get-CimInstance -ClassName Win32_OperatingSystem
    $lastBoot = $os.LastBootUpTime
    $uptime = (Get-Date) - $lastBoot
    $report.SystemUptime = [pscustomobject]@{
        LastBootTime = $lastBoot
        Uptime       = ('{0} days {1} hours {2} minutes' -f $uptime.Days, $uptime.Hours, $uptime.Minutes)
    }
}
catch {
    $report.SystemUptime = "Unable to retrieve uptime: $($_.Exception.Message)"
}

# 2) Free disk space: reads logical disk info for fixed drives only.
try {
    $report.FreeDiskSpace = Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DriveType=3" |
        Select-Object DeviceID,
            @{Name='SizeGB';Expression={[math]::Round($_.Size / 1GB, 2)}},
            @{Name='FreeGB';Expression={[math]::Round($_.FreeSpace / 1GB, 2)}},
            @{Name='FreePercent';Expression={ if ($_.Size -gt 0) { [math]::Round(($_.FreeSpace / $_.Size) * 100, 2) } else { $null } }}
}
catch {
    $report.FreeDiskSpace = "Unable to retrieve disk information: $($_.Exception.Message)"
}

# 3) Pending reboot check: reads known registry indicators only.
try {
    $pendingRebootFlags = [ordered]@{
        CBSRebootPending = Test-Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending'
        WURebootRequired = Test-Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired'
        PendingFileRenameOperations = $false
    }

    $sessionMgrPath = 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager'
    $sessionMgr = Get-ItemProperty -Path $sessionMgrPath -Name 'PendingFileRenameOperations' -ErrorAction SilentlyContinue
    if ($null -ne $sessionMgr -and $null -ne $sessionMgr.PendingFileRenameOperations) {
        $pendingRebootFlags.PendingFileRenameOperations = $true
    }

    $pendingReboot = $pendingRebootFlags.Values -contains $true

    $report.PendingReboot = [pscustomobject]@{
        IsPending = $pendingReboot
        Flags     = $pendingRebootFlags
    }
}
catch {
    $report.PendingReboot = "Unable to determine pending reboot status: $($_.Exception.Message)"
}

# 4) Top 5 processes by memory: reads process working set and sorts descending.
try {
    $report.Top5Memory = Get-Process |
        Sort-Object -Property WorkingSet64 -Descending |
        Select-Object -First 5 ProcessName, Id,
            @{Name='WorkingSetMB';Expression={[math]::Round($_.WorkingSet64 / 1MB, 2)}}
}
catch {
    $report.Top5Memory = "Unable to retrieve process memory data: $($_.Exception.Message)"
}

# 5) Top 5 processes by CPU: reads cumulative CPU seconds and sorts descending.
try {
    $report.Top5CPU = Get-Process |
        Where-Object { $null -ne $_.CPU } |
        Sort-Object -Property CPU -Descending |
        Select-Object -First 5 ProcessName, Id,
            @{Name='CPUSeconds';Expression={[math]::Round($_.CPU, 2)}}
}
catch {
    $report.Top5CPU = "Unable to retrieve process CPU data: $($_.Exception.Message)"
}

# 6) Last 5 system log errors: reads recent Error-level events from the System log.
try {
    $report.Last5SystemErrors = Get-WinEvent -FilterHashtable @{ LogName = 'System'; Level = 2 } -MaxEvents 5 |
        Select-Object TimeCreated, Id, ProviderName, Message
}
catch {
    $report.Last5SystemErrors = "Unable to retrieve System log errors: $($_.Exception.Message)"
}

# 7) Internet speed: performs a read-only, approximate download test over HTTPS.
try {
    $testUrl = 'https://speed.hetzner.de/1MB.bin'
    $webClient = New-Object System.Net.WebClient
    $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
    [byte[]]$payload = $webClient.DownloadData($testUrl)
    $stopwatch.Stop()

    $bytes = $payload.Length
    $seconds = [math]::Max($stopwatch.Elapsed.TotalSeconds, 0.001)
    $mbps = [math]::Round((($bytes * 8) / 1MB) / $seconds, 2)

    $report.InternetSpeed = [pscustomobject]@{
        TestUrl            = $testUrl
        BytesDownloaded    = $bytes
        ElapsedSeconds     = [math]::Round($seconds, 3)
        ApproxDownloadMbps = $mbps
    }
}
catch {
    $report.InternetSpeed = "Unable to run internet speed test: $($_.Exception.Message)"
}

# 8) Defender service status: reads Microsoft Defender Antivirus service state.
try {
    $defender = Get-Service -Name 'WinDefend' -ErrorAction Stop
    $report.DefenderService = [pscustomobject]@{
        ServiceName = $defender.Name
        DisplayName = $defender.DisplayName
        Status      = $defender.Status
        IsRunning   = ($defender.Status -eq 'Running')
    }
}
catch {
    $report.DefenderService = "Unable to retrieve Defender service status: $($_.Exception.Message)"
}

# 9) Logged-in users count: reads current user sessions from quser output.
try {
    $quserOutput = & quser 2>$null
    if ($LASTEXITCODE -eq 0 -and $quserOutput) {
        $sessionLines = $quserOutput | Select-Object -Skip 1 | Where-Object { $_.Trim() -ne '' }
        $report.LoggedInUsers = [pscustomobject]@{
            SessionCount = $sessionLines.Count
            Source       = 'quser'
        }
    }
    else {
        $currentUser = (Get-CimInstance -ClassName Win32_ComputerSystem).UserName
        $report.LoggedInUsers = [pscustomobject]@{
            SessionCount = if ($currentUser) { 1 } else { 0 }
            Source       = 'Win32_ComputerSystem fallback'
        }
    }
}
catch {
    $report.LoggedInUsers = "Unable to determine logged-in users: $($_.Exception.Message)"
}

# 10) Last Windows Update time: reads installed hotfix records and returns most recent install date.
try {
    $updates = Get-CimInstance -ClassName Win32_QuickFixEngineering |
        Where-Object { $_.InstalledOn }

    $parsedUpdates = foreach ($u in $updates) {
        $parsedDate = $null
        if ([datetime]::TryParse($u.InstalledOn, [ref]$parsedDate)) {
            [pscustomobject]@{
                HotFixID    = $u.HotFixID
                Description = $u.Description
                InstalledOn = $parsedDate
            }
        }
    }

    $latestUpdate = $parsedUpdates | Sort-Object InstalledOn -Descending | Select-Object -First 1

    if ($latestUpdate) {
        $report.LastWindowsUpdate = $latestUpdate
    }
    else {
        $report.LastWindowsUpdate = 'No installed update date found from Win32_QuickFixEngineering.'
    }
}
catch {
    $report.LastWindowsUpdate = "Unable to retrieve last Windows Update details: $($_.Exception.Message)"
}

# This section prints all collected read-only results to the console.
Write-Host '1) System Uptime' -ForegroundColor Yellow
$report.SystemUptime | Format-List
Write-Host ''

Write-Host '2) Free Disk Space' -ForegroundColor Yellow
$report.FreeDiskSpace | Format-Table -AutoSize
Write-Host ''

Write-Host '3) Pending Reboot' -ForegroundColor Yellow
$report.PendingReboot | Format-List
Write-Host ''

Write-Host '4) Top 5 Processes by Memory (Working Set)' -ForegroundColor Yellow
$report.Top5Memory | Format-Table -AutoSize
Write-Host ''

Write-Host '5) Top 5 Processes by CPU' -ForegroundColor Yellow
$report.Top5CPU | Format-Table -AutoSize
Write-Host ''

Write-Host '6) Last 5 System Log Errors' -ForegroundColor Yellow
$report.Last5SystemErrors | Format-Table -AutoSize -Wrap
Write-Host ''

Write-Host '7) Internet Speed (Approximate)' -ForegroundColor Yellow
$report.InternetSpeed | Format-List
Write-Host ''

Write-Host '8) Microsoft Defender Service' -ForegroundColor Yellow
$report.DefenderService | Format-List
Write-Host ''

Write-Host '9) Logged-In Users Count' -ForegroundColor Yellow
$report.LoggedInUsers | Format-List
Write-Host ''

Write-Host '10) Last Windows Update' -ForegroundColor Yellow
$report.LastWindowsUpdate | Format-List
Write-Host ''

Write-Host 'Report complete. Script performed read-only checks only.' -ForegroundColor Green
