#Requires -Version 5.1

<#
.SYNOPSIS
    Read-only disk health and optimization status reporter.

.DESCRIPTION
    Collects storage health and optimization-related status from Windows
    without changing any disk settings or running defragmentation.

.PARAMETER ShowRecentDefragEvents
    Include recent defrag/optimization events from the Application log.

.PARAMETER EventCount
    Number of recent optimization events to return when
    -ShowRecentDefragEvents is used.

.PARAMETER DryRun
    Compatibility switch. This script is already read-only by design,
    so using -DryRun does not change behavior.

.EXAMPLE
    .\disk-health-reporter.ps1
    Runs a read-only disk health and optimization status report.

.EXAMPLE
    .\disk-health-reporter.ps1 -DryRun
    Runs the same read-only report. -DryRun is accepted for consistency
    with other scripts.

.EXAMPLE
    .\disk-health-reporter.ps1 -ShowRecentDefragEvents -EventCount 10
    Includes the 10 most recent optimization events from Application log.

.NOTES
    - Strictly read-only: this script does not run defragmentation.
    - No calls are made to Optimize-Volume with optimization actions.
    - Elevated session may provide more complete visibility on some systems.
#>

[CmdletBinding()]
param(
    [switch]$ShowRecentDefragEvents,

    [switch]$DryRun,

    [ValidateRange(1, 100)]
    [int]$EventCount = 5
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$report = [ordered]@{}

Write-Host '=== Disk Health Reporter (Read-Only) ===' -ForegroundColor Cyan
Write-Host ('Generated: {0}' -f (Get-Date)) -ForegroundColor Gray
if ($DryRun) {
    Write-Host 'DryRun mode: no-op switch accepted. Script is read-only by default.' -ForegroundColor Gray
}
Write-Host ''

# 1) Physical disk health and operational status.
try {
    if (Get-Command -Name Get-PhysicalDisk -ErrorAction SilentlyContinue) {
        $report.PhysicalDisks = Get-PhysicalDisk |
            Select-Object FriendlyName, MediaType, HealthStatus, OperationalStatus,
                @{Name = 'SizeGB'; Expression = { [math]::Round($_.Size / 1GB, 2) }}
    }
    else {
        $report.PhysicalDisks = Get-CimInstance -ClassName Win32_DiskDrive |
            Select-Object Model,
                @{Name = 'MediaType'; Expression = { $_.MediaType }},
                @{Name = 'HealthStatus'; Expression = { 'Unknown (Get-PhysicalDisk unavailable)' }},
                @{Name = 'OperationalStatus'; Expression = { 'Unknown' }},
                @{Name = 'SizeGB'; Expression = { [math]::Round($_.Size / 1GB, 2) }}
    }
}
catch {
    $report.PhysicalDisks = "Unable to retrieve physical disk information: $($_.Exception.Message)"
}

# 2) Logical volume health and free space status.
try {
    if (Get-Command -Name Get-Volume -ErrorAction SilentlyContinue) {
        $report.Volumes = Get-Volume |
            Where-Object { $_.DriveLetter -or $_.FileSystemLabel } |
            Select-Object DriveLetter, FileSystemLabel, FileSystem, HealthStatus,
                @{Name = 'SizeGB'; Expression = { if ($_.Size) { [math]::Round($_.Size / 1GB, 2) } else { $null } }},
                @{Name = 'FreeGB'; Expression = { if ($_.SizeRemaining) { [math]::Round($_.SizeRemaining / 1GB, 2) } else { $null } }},
                @{Name = 'FreePercent'; Expression = {
                    if ($_.Size -gt 0 -and $null -ne $_.SizeRemaining) {
                        [math]::Round(($_.SizeRemaining / $_.Size) * 100, 2)
                    }
                    else {
                        $null
                    }
                }}
    }
    else {
        $report.Volumes = Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DriveType=3" |
            Select-Object DeviceID,
                @{Name = 'FileSystem'; Expression = { $_.FileSystem }},
                @{Name = 'HealthStatus'; Expression = { 'Unknown (Get-Volume unavailable)' }},
                @{Name = 'SizeGB'; Expression = { [math]::Round($_.Size / 1GB, 2) }},
                @{Name = 'FreeGB'; Expression = { [math]::Round($_.FreeSpace / 1GB, 2) }},
                @{Name = 'FreePercent'; Expression = {
                    if ($_.Size -gt 0) {
                        [math]::Round(($_.FreeSpace / $_.Size) * 100, 2)
                    }
                    else {
                        $null
                    }
                }}
    }
}
catch {
    $report.Volumes = "Unable to retrieve volume information: $($_.Exception.Message)"
}

# 3) SMART failure prediction indicators (when available).
try {
    $smartData = Get-CimInstance -Namespace root\wmi -ClassName MSStorageDriver_FailurePredictStatus -ErrorAction Stop
    if ($smartData) {
        $report.SmartPredictFailure = $smartData |
            Select-Object InstanceName,
                @{Name = 'PredictFailure'; Expression = { $_.PredictFailure }},
                @{Name = 'Reason'; Expression = { $_.Reason }}
    }
    else {
        $report.SmartPredictFailure = 'SMART prediction data not available on this endpoint.'
    }
}
catch {
    $report.SmartPredictFailure = "Unable to retrieve SMART prediction status: $($_.Exception.Message)"
}

# 4) Optimization schedule status from ScheduledDefrag task.
try {
    $taskPath = '\\Microsoft\\Windows\\Defrag\\'
    $taskName = 'ScheduledDefrag'
    $task = Get-ScheduledTask -TaskPath $taskPath -TaskName $taskName -ErrorAction Stop
    $taskInfo = Get-ScheduledTaskInfo -TaskPath $taskPath -TaskName $taskName -ErrorAction Stop

    $report.OptimizationSchedule = [pscustomobject]@{
        TaskName           = $task.TaskName
        TaskPath           = $task.TaskPath
        State              = $task.State
        Enabled            = $task.Settings.Enabled
        LastRunTime        = $taskInfo.LastRunTime
        LastTaskResult     = $taskInfo.LastTaskResult
        NextRunTime        = $taskInfo.NextRunTime
        NumberOfMissedRuns = $taskInfo.NumberOfMissedRuns
    }
}
catch {
    $report.OptimizationSchedule = "Unable to retrieve ScheduledDefrag task status: $($_.Exception.Message)"
}

# 5) Defrag service status.
try {
    $svc = Get-Service -Name 'defragsvc' -ErrorAction Stop
    $report.DefragService = [pscustomobject]@{
        ServiceName = $svc.Name
        DisplayName = $svc.DisplayName
        Status      = $svc.Status
        StartType   = (Get-CimInstance -ClassName Win32_Service -Filter "Name='defragsvc'").StartMode
    }
}
catch {
    $report.DefragService = "Unable to retrieve defrag service status: $($_.Exception.Message)"
}

# 6) Optional recent optimization events (read-only log query).
if ($ShowRecentDefragEvents) {
    try {
        $report.RecentOptimizationEvents = Get-WinEvent -FilterHashtable @{
                LogName      = 'Application'
                ProviderName = 'defrag'
            } -MaxEvents $EventCount |
            Select-Object TimeCreated, Id, LevelDisplayName, Message
    }
    catch {
        $report.RecentOptimizationEvents = "Unable to retrieve defrag events: $($_.Exception.Message)"
    }
}

Write-Host '1) Physical Disk Health' -ForegroundColor Yellow
$report.PhysicalDisks | Format-Table -AutoSize -Wrap
Write-Host ''

Write-Host '2) Logical Volumes' -ForegroundColor Yellow
$report.Volumes | Format-Table -AutoSize -Wrap
Write-Host ''

Write-Host '3) SMART Failure Prediction' -ForegroundColor Yellow
$report.SmartPredictFailure | Format-Table -AutoSize -Wrap
Write-Host ''

Write-Host '4) Optimization Schedule (ScheduledDefrag)' -ForegroundColor Yellow
$report.OptimizationSchedule | Format-List
Write-Host ''

Write-Host '5) Defrag Service' -ForegroundColor Yellow
$report.DefragService | Format-List
Write-Host ''

if ($ShowRecentDefragEvents) {
    Write-Host ('6) Recent Optimization Events (last {0})' -f $EventCount) -ForegroundColor Yellow
    $report.RecentOptimizationEvents | Format-Table -AutoSize -Wrap
    Write-Host ''
}

Write-Host 'Report complete. Script performed read-only checks only (no defragmentation).' -ForegroundColor Green
