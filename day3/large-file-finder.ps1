#Requires -Version 5.1

<#
.SYNOPSIS
    Read-only large file finder for Windows endpoints.

.DESCRIPTION
    Recursively scans a target path and reports files whose size is greater
    than or equal to a configurable threshold in MB.

.PARAMETER Path
    Root path to scan recursively.
    Default: current directory.

.PARAMETER ThresholdMB
    File size threshold in MB. Files at or above this value are reported.
    Default: 100 MB.

.PARAMETER Top
    Maximum number of largest matching files to display.
    Default: 100.

.EXAMPLE
    .\large-file-finder.ps1
    Scans the current directory and reports files >= 100 MB.

.EXAMPLE
    .\large-file-finder.ps1 -Path C:\Users -ThresholdMB 250
    Scans C:\Users and reports files >= 250 MB.

.EXAMPLE
    .\large-file-finder.ps1 -Path D:\Data -ThresholdMB 50 -Top 25
    Reports the top 25 largest files >= 50 MB under D:\Data.

.NOTES
    - Read-only script: no changes are made to files or system settings.
    - Access-denied folders are skipped; the scan continues.
#>

[CmdletBinding()]
param(
    [ValidateNotNullOrEmpty()]
    [string]$Path = (Get-Location).Path,

    [ValidateRange(1, 1048576)]
    [int]$ThresholdMB = 100,

    [ValidateRange(1, 10000)]
    [int]$Top = 100
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if (-not (Test-Path -LiteralPath $Path)) {
    throw ("Path not found: {0}" -f $Path)
}

$thresholdBytes = $ThresholdMB * 1MB

Write-Host '=== Large File Finder (Read-Only) ===' -ForegroundColor Cyan
Write-Host ("Scan path      : {0}" -f $Path)
Write-Host ("Threshold      : {0} MB" -f $ThresholdMB)
Write-Host ("Top results    : {0}" -f $Top)
Write-Host ''

$allFiles = @(Get-ChildItem -LiteralPath $Path -File -Recurse -Force -ErrorAction SilentlyContinue)

$matches = @(
    $allFiles |
        Where-Object { $_.Length -ge $thresholdBytes } |
        Sort-Object Length -Descending |
        Select-Object -First $Top |
        Select-Object @{Name='SizeMB';Expression={[math]::Round($_.Length / 1MB, 2)}}, LastWriteTime, FullName
)

Write-Host ("Files scanned   : {0}" -f $allFiles.Count)
Write-Host ("Matches found   : {0}" -f $matches.Count)
Write-Host ''

if ($matches.Count -eq 0) {
    Write-Host 'No files met or exceeded the threshold.' -ForegroundColor Yellow
    exit 0
}

$matches | Format-Table -AutoSize -Wrap

Write-Host ''
Write-Host 'Report complete. Script performed read-only checks only.' -ForegroundColor Green
