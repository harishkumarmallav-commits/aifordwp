#Requires -Version 5.1

<#
.SYNOPSIS
    Safely removes temporary files from Windows endpoints with rollback support.

.DESCRIPTION
    Targets common Windows temporary directories, moves qualifying files to a
    timestamped backup location (enabling rollback), and logs every action to a
    date-stamped log file. Safe to run repeatedly (idempotent).

.PARAMETER DryRun
    Lists files that would be removed without making any changes to the system.

.PARAMETER OlderThanDays
    Only process files whose LastWriteTime is older than this many days.
    Default: 0 (targets all files regardless of age).

.PARAMETER Rollback
    Restores files removed by a previous run. Combine with -RunId to target a
    specific run, or omit RunId to roll back the most recent run.

.PARAMETER RunId
    The run identifier (e.g. 20260805_143022) of the backup set to restore.
    Only meaningful when used with -Rollback.

.PARAMETER LogDirectory
    Directory where log files are stored. Default: <script folder>\Logs

.PARAMETER BackupDirectory
    Directory where removed files are staged for potential rollback.
    Default: <script folder>\Backup

.EXAMPLE
    .\cleanup-temp.ps1 -DryRun
    Preview what would be removed without changing anything.

.EXAMPLE
    .\cleanup-temp.ps1 -OlderThanDays 7
    Remove temp files not modified in the last 7 days.

.EXAMPLE
    .\cleanup-temp.ps1
    Remove all qualifying temp files and stage them for rollback.

.EXAMPLE
    .\cleanup-temp.ps1 -Rollback
    Restore files from the most recent cleanup run.

.EXAMPLE
    .\cleanup-temp.ps1 -Rollback -RunId 20260805_143022
    Restore files from a specific run.

.NOTES
    - Run in an elevated (Administrator) session for full access to system temp directories.
    - Files are moved (not permanently deleted) to the backup directory, preserving rollback capability.
    - Locked files are skipped and logged; the script continues without stopping.
    - Each run produces a unique RunId (timestamp) used for log files and backup sets.
#>

[CmdletBinding()]
param(
    [switch]$DryRun,

    [ValidateRange(0, 3650)]
    [int]$OlderThanDays = 0,

    [switch]$Rollback,

    [string]$RunId,

    [string]$LogDirectory    = (Join-Path $PSScriptRoot 'Logs'),

    [string]$BackupDirectory = (Join-Path $PSScriptRoot 'Backup')
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Continue'

# --- Run identifier ---
# Unique timestamp-based ID for this execution; groups logs and backup files.
$currentRunId = Get-Date -Format 'yyyyMMdd_HHmmss'

# --- Log directory setup ---
# Ensure the log directory exists before the first Write-Log call (idempotent).
if (-not (Test-Path -LiteralPath $LogDirectory)) {
    New-Item -ItemType Directory -Path $LogDirectory -Force | Out-Null
}

$logFile = Join-Path $LogDirectory ("cleanup-{0}.log" -f $currentRunId)

# --- Write-Log helper ---
# Appends a timestamped, levelled entry to the log file and writes to the console.
function Write-Log {
    param(
        [Parameter(Mandatory)]
        [string]$Message,

        [ValidateSet('INFO', 'WARN', 'ERROR', 'DRY-RUN')]
        [string]$Level = 'INFO'
    )

    $entry = '[{0}] [{1}] {2}' -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), $Level, $Message
    Add-Content -LiteralPath $logFile -Value $entry -Encoding UTF8

    switch ($Level) {
        'ERROR'   { Write-Host $entry -ForegroundColor Red }
        'WARN'    { Write-Host $entry -ForegroundColor Yellow }
        'DRY-RUN' { Write-Host $entry -ForegroundColor Cyan }
        default   { Write-Host $entry }
    }
}

# --- Test-FileLocked helper ---
# Returns $true if the file cannot be opened exclusively, indicating it is in use.
function Test-FileLocked {
    param(
        [Parameter(Mandatory)]
        [string]$FilePath
    )

    try {
        $stream = [System.IO.File]::Open($FilePath, 'Open', 'ReadWrite', 'None')
        $stream.Close()
        $stream.Dispose()
        return $false
    }
    catch {
        return $true
    }
}

# --- Write-ManifestEntry helper ---
# Appends one CSV row to the manifest; writes the header on the very first call.
function Write-ManifestEntry {
    param(
        [Parameter(Mandatory)][string]$ManifestPath,
        [Parameter(Mandatory)][string]$OriginalPath,
        [Parameter(Mandatory)][string]$BackupPath
    )

    if (-not (Test-Path -LiteralPath $ManifestPath)) {
        '"OriginalPath","BackupPath"' | Set-Content -LiteralPath $ManifestPath -Encoding UTF8
    }
    # Escape embedded double-quotes per RFC 4180.
    $escapedOrig   = $OriginalPath.Replace('"', '""')
    $escapedBackup = $BackupPath.Replace('"', '""')
    '"{0}","{1}"' -f $escapedOrig, $escapedBackup |
        Add-Content -LiteralPath $ManifestPath -Encoding UTF8
}

# --- Rollback mode ---
# Restores files staged by a previous run using that run's manifest CSV.
if ($Rollback) {
    # Resolve which backup run to restore: explicit RunId or the most recent folder.
    if ($RunId) {
        $backupRunPath = Join-Path $BackupDirectory $RunId
    }
    else {
        $latestRun = Get-ChildItem -LiteralPath $BackupDirectory -Directory -ErrorAction SilentlyContinue |
            Sort-Object Name -Descending |
            Select-Object -First 1

        if (-not $latestRun) {
            Write-Log 'No backup runs found to roll back.' -Level WARN
            exit 0
        }
        $RunId         = $latestRun.Name
        $backupRunPath = $latestRun.FullName
    }

    if (-not (Test-Path -LiteralPath $backupRunPath)) {
        Write-Log "Backup run '$RunId' not found: $backupRunPath" -Level ERROR
        exit 1
    }

    $manifestPath = Join-Path $backupRunPath 'manifest.csv'
    if (-not (Test-Path -LiteralPath $manifestPath)) {
        Write-Log "Manifest not found for run '$RunId': $manifestPath" -Level ERROR
        exit 1
    }

    Write-Log "=== Rollback started | Restoring run: $RunId ==="

    $manifest   = Import-Csv -LiteralPath $manifestPath
    $rbRestored = 0
    $rbSkipped  = 0
    $rbFailed   = 0

    foreach ($entry in $manifest) {
        $src  = $entry.BackupPath
        $dest = $entry.OriginalPath

        # Skip if backup file is missing (already restored or manually removed).
        if (-not (Test-Path -LiteralPath $src)) {
            Write-Log "SKIP (backup missing): $src" -Level WARN
            $rbSkipped++
            continue
        }

        # Skip if the file is already present at its original location (idempotent).
        if (Test-Path -LiteralPath $dest) {
            Write-Log "SKIP (already restored): $dest" -Level WARN
            $rbSkipped++
            continue
        }

        try {
            $destDir = Split-Path -Path $dest -Parent
            if (-not (Test-Path -LiteralPath $destDir)) {
                New-Item -ItemType Directory -Path $destDir -Force | Out-Null
            }
            Move-Item -LiteralPath $src -Destination $dest -Force
            Write-Log "RESTORED: $dest"
            $rbRestored++
        }
        catch {
            Write-Log "FAILED to restore '$dest': $($_.Exception.Message)" -Level ERROR
            $rbFailed++
        }
    }

    Write-Log ('=== Rollback complete | Restored: {0} | Skipped: {1} | Failed: {2} ===' -f $rbRestored, $rbSkipped, $rbFailed)
    exit 0
}

# --- Target directories ---
# Common Windows temporary directories targeted by this cleanup script.
$targetDirectories = @(
    $env:TEMP,
    (Join-Path $env:WINDIR 'Temp')
) | Select-Object -Unique | Where-Object { $_ -and (Test-Path -LiteralPath $_) }

if ($targetDirectories.Count -eq 0) {
    Write-Log 'No accessible target directories found. Exiting.' -Level WARN
    exit 0
}

# --- Age cut-off ---
# Only files with a LastWriteTime before this date qualify for removal.
$cutoffDate = (Get-Date).AddDays(-$OlderThanDays)

# --- Backup run directory ---
# Staged files for this run land here; directory is created on first file removal.
$runBackupPath = Join-Path $BackupDirectory $currentRunId
$manifestPath  = Join-Path $runBackupPath 'manifest.csv'

# --- Summary counters ---
$totalScanned       = 0
$totalRemoved       = 0
$totalSkippedAge    = 0
$totalSkippedLocked = 0
$totalFailed        = 0

Write-Log ('=== Cleanup started | RunId: {0} | DryRun: {1} | OlderThanDays: {2} ===' -f $currentRunId, $DryRun.IsPresent, $OlderThanDays)

# --- Main cleanup loop ---
# Enumerates each target directory recursively and processes qualifying files.
foreach ($dir in $targetDirectories) {
    Write-Log "Scanning directory: $dir"

    $files = Get-ChildItem -LiteralPath $dir -Recurse -Force -File -ErrorAction SilentlyContinue

    foreach ($file in $files) {
        $totalScanned++

        # Age filter: skip files that are newer than the configured cut-off date.
        if ($file.LastWriteTime -gt $cutoffDate) {
            $totalSkippedAge++
            continue
        }

        # Locked-file check: log the warning and move on; never abort the run.
        if (Test-FileLocked -FilePath $file.FullName) {
            Write-Log "LOCKED (skipping): $($file.FullName)" -Level WARN
            $totalSkippedLocked++
            continue
        }

        if ($DryRun) {
            Write-Log "DRY-RUN - would remove: $($file.FullName)" -Level 'DRY-RUN'
            $totalRemoved++   # counted as "would remove" in the dry-run summary
            continue
        }

        # Per-file try/catch ensures one failure never halts the entire run.
        try {
            # Mirror the original path structure inside the run backup directory.
            $root          = [System.IO.Path]::GetPathRoot($file.FullName)
            $relativePath  = $file.FullName.Substring($root.Length)
            $backupDest    = Join-Path $runBackupPath $relativePath
            $backupDestDir = Split-Path -Path $backupDest -Parent

            if (-not (Test-Path -LiteralPath $backupDestDir)) {
                New-Item -ItemType Directory -Path $backupDestDir -Force | Out-Null
            }

            Move-Item -LiteralPath $file.FullName -Destination $backupDest -Force

            # Record original->backup mapping so rollback can locate this file.
            Write-ManifestEntry -ManifestPath $manifestPath `
                                -OriginalPath $file.FullName `
                                -BackupPath   $backupDest

            Write-Log "REMOVED: $($file.FullName)"
            $totalRemoved++
        }
        catch {
            Write-Log "FAILED '$($file.FullName)': $($_.Exception.Message)" -Level ERROR
            $totalFailed++
        }
    }
}

# --- Summary report ---
# Prints a concise results table to both the console and the log file.
$modeLabel    = if ($DryRun) { 'DRY-RUN (no changes made)' } else { 'LIVE' }
$removedLabel = if ($DryRun) { 'Would remove    ' } else { 'Files removed   ' }

$summaryLines = @(
    '=== Cleanup Summary ==='
    ('Run ID          : {0}' -f $currentRunId)
    ('Mode            : {0}' -f $modeLabel)
    ('Older than days : {0}' -f $OlderThanDays)
    ('Files scanned   : {0}' -f $totalScanned)
    ('{0}: {1}' -f $removedLabel, $totalRemoved)
    ('Skipped (age)   : {0}' -f $totalSkippedAge)
    ('Skipped (locked): {0}' -f $totalSkippedLocked)
    ('Errors          : {0}' -f $totalFailed)
    ('Log file        : {0}' -f $logFile)
)

if (-not $DryRun -and $totalRemoved -gt 0) {
    $summaryLines += ('Backup location : {0}' -f $runBackupPath)
    $summaryLines += ('To roll back    : .\cleanup-temp.ps1 -Rollback -RunId {0}' -f $currentRunId)
}

$summaryLines += '======================='

foreach ($line in $summaryLines) {
    Write-Log $line
}
