<#
Purpose:
     Collect and display quick endpoint health signals:
     - Computer name and total memory
     - Free space on C:
     - Top 5 processes by memory usage
     - Recent error events from System log
     - Count of stale (unused) user profiles older than 90 days

Author:
     DWP Training (refactored for readability)

How to run:
     1) Open PowerShell
     2) Navigate to the script folder
     3) Run: .\inherited.ps1

Notes:
     - This script is read-only and does not change system configuration.
     - It writes results to the console.
#>

# Get basic computer system details (for example, machine name and total RAM).
$computerSystem = Get-CimInstance Win32_ComputerSystem

# Get free space in bytes from the C: drive.
$freeBytesOnC = Get-PSDrive C | Select-Object -ExpandProperty Free

# Get the top 5 running processes sorted by working set memory (highest first).
$topMemoryProcesses = Get-Process | Sort-Object WS -Descending | Select-Object -First 5

# Get the latest 10 System log events and keep only error-level entries (Level 2).
$recentSystemErrors = Get-WinEvent -LogName System -MaxEvents 10 | Where-Object { $_.Level -eq 2 }

# Get local user profiles and keep only non-special profiles not used in the last 90 days.
$staleUserProfiles = Get-CimInstance Win32_UserProfile | Where-Object {
     # Exclude special profiles and include profiles with LastUseTime older than 90 days.
     -not $_.Special -and $_.LastUseTime -lt (Get-Date).AddDays(-90)
}

# Print computer name and total physical memory.
Write-Host $computerSystem.Name $computerSystem.TotalPhysicalMemory

# Convert free bytes on C: to GB, round to 2 decimals, and print the value.
Write-Host ([math]::Round($freeBytesOnC / 1GB, 2)) 'GB free'

# Print each top process name and its working set memory usage.
$topMemoryProcesses | ForEach-Object { Write-Host $_.Name $_.WS }

# Print time and message for each recent System error event.
$recentSystemErrors | ForEach-Object { Write-Host $_.TimeCreated $_.Message }

# If stale profiles exist, print their total count.
if ($staleUserProfiles.Count -gt 0) { Write-Host 'Stale profiles:' $staleUserProfiles.Count }
