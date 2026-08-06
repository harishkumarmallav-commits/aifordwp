#Requires -Version 5.1

<#
.SYNOPSIS
    Audits Windows startup programs and optionally disables one by name.

.DESCRIPTION
    Lists startup entries from common registry Run keys and Startup folders.
    Supports disabling a startup entry by program name using -Disable and
    -ProgramName.

.PARAMETER Disable
    Enables disable mode. Requires -ProgramName.

.PARAMETER ProgramName
    Startup program name to disable. Match is case-insensitive and supports
    partial matches.

.PARAMETER IncludeCommonStartup
    Include common startup locations (all users) in addition to current user.
    Default is enabled.

.PARAMETER DryRun
    Compatibility switch. In audit mode (default), the script is already
    read-only, so -DryRun does not change behavior.

.EXAMPLE
    .\startup-program-auditor.ps1
    Lists startup entries from registry and startup folders.

.EXAMPLE
    .\startup-program-auditor.ps1 -DryRun
    Runs the same read-only audit. -DryRun is accepted for consistency.

.EXAMPLE
    .\startup-program-auditor.ps1 -Disable -ProgramName Teams
    Disables startup entries that match "Teams".

.EXAMPLE
    .\startup-program-auditor.ps1 -Disable -ProgramName OneDrive -WhatIf
    Shows what would be disabled without making changes.

.NOTES
    - Run elevated for full visibility/modification of HKLM and Common Startup.
    - Registry disable behavior: moves matched Run value(s) to a sibling
      "Run-DisabledByAudit" key and removes them from the active Run key.
    - Startup folder disable behavior: renames matching .lnk files to
      "<name>.disabled".
#>

[CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
param(
    [switch]$Disable,

    [string]$ProgramName,

    [switch]$IncludeCommonStartup = $true,

    [switch]$DryRun
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if ($Disable -and [string]::IsNullOrWhiteSpace($ProgramName)) {
    throw 'ProgramName is required when using -Disable.'
}

function Get-RegistryStartupEntries {
    [CmdletBinding()]
    param()

    $runKeyPaths = @(
        'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run',
        'HKLM:\Software\Microsoft\Windows\CurrentVersion\Run',
        'HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Run'
    )

    foreach ($keyPath in $runKeyPaths) {
        if (-not (Test-Path -LiteralPath $keyPath)) {
            continue
        }

        try {
            $item = Get-Item -LiteralPath $keyPath -ErrorAction Stop
            $props = Get-ItemProperty -LiteralPath $keyPath -ErrorAction Stop

            foreach ($prop in $item.Property) {
                $value = $props.$prop
                [pscustomobject]@{
                    Source     = 'Registry'
                    Name       = $prop
                    Command    = [string]$value
                    Location   = $keyPath
                    Path       = $null
                    Enabled    = $true
                }
            }
        }
        catch {
            Write-Warning ("Unable to read startup registry key '{0}': {1}" -f $keyPath, $_.Exception.Message)
        }
    }
}

function Get-StartupFolderEntries {
    [CmdletBinding()]
    param(
        [switch]$IncludeCommon
    )

    $startupDirs = @()

    if ($env:APPDATA) {
        $startupDirs += (Join-Path $env:APPDATA 'Microsoft\Windows\Start Menu\Programs\Startup')
    }

    if ($IncludeCommon -and $env:ProgramData) {
        $startupDirs += (Join-Path $env:ProgramData 'Microsoft\Windows\Start Menu\Programs\Startup')
    }

    foreach ($dir in $startupDirs | Select-Object -Unique) {
        if (-not (Test-Path -LiteralPath $dir)) {
            continue
        }

        try {
            Get-ChildItem -LiteralPath $dir -File -ErrorAction Stop | ForEach-Object {
                [pscustomobject]@{
                    Source     = 'StartupFolder'
                    Name       = $_.BaseName
                    Command    = $_.Name
                    Location   = $dir
                    Path       = $_.FullName
                    Enabled    = -not $_.Extension.Equals('.disabled', [System.StringComparison]::OrdinalIgnoreCase)
                }
            }
        }
        catch {
            Write-Warning ("Unable to read startup folder '{0}': {1}" -f $dir, $_.Exception.Message)
        }
    }
}

function Disable-RegistryEntry {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [pscustomobject]$Entry
    )

    $runKeyPath = $Entry.Location
    $disabledKeyPath = $runKeyPath.Replace('\Run', '\Run-DisabledByAudit')

    if (-not (Test-Path -LiteralPath $disabledKeyPath)) {
        New-Item -Path $disabledKeyPath -Force | Out-Null
    }

    $currentValue = (Get-ItemProperty -LiteralPath $runKeyPath -Name $Entry.Name -ErrorAction Stop).$($Entry.Name)
    $disabledValueName = '{0}__disabled_{1}' -f $Entry.Name, (Get-Date -Format 'yyyyMMdd_HHmmss')

    Set-ItemProperty -LiteralPath $disabledKeyPath -Name $disabledValueName -Value $currentValue -Type String
    Remove-ItemProperty -LiteralPath $runKeyPath -Name $Entry.Name -ErrorAction Stop
}

function Disable-StartupFolderEntry {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [pscustomobject]$Entry
    )

    $currentPath = $Entry.Path
    if (-not (Test-Path -LiteralPath $currentPath)) {
        throw "File no longer exists: $currentPath"
    }

    if ([System.IO.Path]::GetExtension($currentPath).Equals('.disabled', [System.StringComparison]::OrdinalIgnoreCase)) {
        return
    }

    $disabledPath = '{0}.disabled' -f $currentPath
    Rename-Item -LiteralPath $currentPath -NewName ([System.IO.Path]::GetFileName($disabledPath)) -ErrorAction Stop
}

$startupEntries = @()
$startupEntries += Get-RegistryStartupEntries
$startupEntries += Get-StartupFolderEntries -IncludeCommon:$IncludeCommonStartup

if (-not $startupEntries -or $startupEntries.Count -eq 0) {
    Write-Host 'No startup entries found.' -ForegroundColor Yellow
    exit 0
}

Write-Host '=== Startup Program Auditor ===' -ForegroundColor Cyan
Write-Host ('Total entries found: {0}' -f $startupEntries.Count)
if ($DryRun) {
    Write-Host 'DryRun mode: no-op switch accepted. Audit mode is read-only by default.' -ForegroundColor Gray
}
Write-Host ''

$startupEntries |
    Sort-Object Source, Name |
    Select-Object Source, Name, Enabled, Location, Command |
    Format-Table -AutoSize -Wrap

if (-not $Disable) {
    Write-Host ''
    Write-Host 'Audit complete. No changes were made.' -ForegroundColor Green
    exit 0
}

Write-Host ''
Write-Host ('Disable mode enabled. Matching startup entries for: "{0}"' -f $ProgramName) -ForegroundColor Yellow

$matchPattern = [regex]::Escape($ProgramName)
$matches = @($startupEntries | Where-Object {
    $_.Name -match $matchPattern -or $_.Command -match $matchPattern
})

if (-not $matches -or $matches.Count -eq 0) {
    Write-Warning ('No startup entries matched "{0}". Nothing to disable.' -f $ProgramName)
    exit 0
}

$disabledCount = 0
$skippedCount = 0
$failedCount = 0

foreach ($entry in $matches) {
    $target = '{0} | {1}' -f $entry.Source, $entry.Name

    try {
        if ($entry.Source -eq 'StartupFolder' -and -not $entry.Enabled) {
            Write-Host ("SKIP: already disabled: {0}" -f $target) -ForegroundColor DarkYellow
            $skippedCount++
            continue
        }

        if ($PSCmdlet.ShouldProcess($target, 'Disable startup entry')) {
            if ($entry.Source -eq 'Registry') {
                Disable-RegistryEntry -Entry $entry
            }
            elseif ($entry.Source -eq 'StartupFolder') {
                Disable-StartupFolderEntry -Entry $entry
            }
            else {
                throw "Unsupported source type: $($entry.Source)"
            }

            Write-Host ("DISABLED: {0}" -f $target) -ForegroundColor Green
            $disabledCount++
        }
        else {
            $skippedCount++
        }
    }
    catch {
        Write-Warning ("FAILED: {0} | {1}" -f $target, $_.Exception.Message)
        $failedCount++
    }
}

Write-Host ''
Write-Host ('Disable summary | Disabled: {0} | Skipped: {1} | Failed: {2}' -f $disabledCount, $skippedCount, $failedCount) -ForegroundColor Cyan
