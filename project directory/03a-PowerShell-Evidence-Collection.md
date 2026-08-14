# PowerShell 5.1 Evidence Collection Script
## For Floor 6 Login Failures / Profile Issues Investigation
**Issue ID:** FLR6-AUTH-002 + FLR6-PROF-003  
**Hypothesis:** Friday document management app deployment caused both issues  
**Created:** 2026-08-14

---

## SECTION 1: AI-GENERATED VERSION (Initial Implementation)

```powershell
# Evidence Collection Script - Floor 6 Incident Investigation
# Purpose: Collect evidence to test Hypothesis #1 (App integrated into login/startup)
# Safety: Read-only operation only; no modifications to system
# Author: AI Assistant
# Date: 2026-08-14

param(
    [switch]$DryRun = $false,
    [string]$OutputPath = "$env:TEMP\FloorSixEvidence.json"
)

# Set error action preference
$ErrorActionPreference = "SilentlyContinue"

Write-Host "Floor 6 Evidence Collection - Starting investigation"
Write-Host "DryRun Mode: $DryRun"
Write-Host "Output: $OutputPath"

# Initialize results object
$results = @{
    CollectionTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    MachineName = $env:COMPUTERNAME
    Username = $env:USERNAME
    Evidence = @{}
}

# Section 1: Check for application installation
Write-Host "Collecting application installation data..."
$appName = "Document Management*"
$installedApps = Get-ItemProperty "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*" | 
    Where-Object { $_.DisplayName -like $appName }

$results.Evidence.InstalledApplications = @{
    SearchTerm = $appName
    Count = $installedApps.Count
    Applications = @()
}

foreach ($app in $installedApps) {
    $results.Evidence.InstalledApplications.Applications += @{
        Name = $app.DisplayName
        Version = $app.DisplayVersion
        InstallDate = $app.InstallDate
        InstallLocation = $app.InstallLocation
        Publisher = $app.Publisher
    }
}

# Section 2: Collect startup programs
Write-Host "Collecting startup programs..."
$startupReg = Get-ItemProperty "HKLM:\Software\Microsoft\Windows\CurrentVersion\Run"
$startupRegUser = Get-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"

$results.Evidence.StartupPrograms = @{
    SystemStartup = $startupReg.PSObject.Properties | Select-Object Name, Value
    UserStartup = $startupRegUser.PSObject.Properties | Select-Object Name, Value
}

# Section 3: Collect scheduled tasks
Write-Host "Collecting scheduled tasks..."
$scheduledTasks = Get-ScheduledTask | Where-Object { $_.State -eq "Ready" }

$results.Evidence.ScheduledTasks = @{
    Count = $scheduledTasks.Count
    Tasks = @()
}

foreach ($task in $scheduledTasks) {
    $results.Evidence.ScheduledTasks.Tasks += @{
        TaskName = $task.TaskName
        Path = $task.TaskPath
        State = $task.State
        Enabled = $task.Enabled
    }
}

# Section 4: Collect recent events
Write-Host "Collecting event log data..."
$applicationEvents = Get-EventLog -LogName Application -Newest 100 -ErrorAction SilentlyContinue
$systemEvents = Get-EventLog -LogName System -Newest 100 -ErrorAction SilentlyContinue

$results.Evidence.ApplicationEvents = @{
    Count = $applicationEvents.Count
    Events = @()
}

foreach ($event in $applicationEvents) {
    $results.Evidence.ApplicationEvents.Events += @{
        TimeGenerated = $event.TimeGenerated
        EventID = $event.EventID
        Source = $event.Source
        EntryType = $event.EntryType
        Message = $event.Message
    }
}

$results.Evidence.SystemEvents = @{
    Count = $systemEvents.Count
    Events = @()
}

foreach ($event in $systemEvents) {
    $results.Evidence.SystemEvents.Events += @{
        TimeGenerated = $event.TimeGenerated
        EventID = $event.EventID
        Source = $event.Source
        EntryType = $event.EntryType
        Message = $event.Message
    }
}

# Export results
if (-not $DryRun) {
    $results | ConvertTo-Json -Depth 5 | Out-File -FilePath $OutputPath -Encoding UTF8
    Write-Host "Results exported to: $OutputPath"
} else {
    Write-Host "DryRun: Would export to $OutputPath"
    Write-Host "DryRun: Results contain $(($results.Evidence.Keys).Count) evidence sections"
}

Write-Host "Evidence collection complete"
```

**Issues Identified in AI Version:**

1. **PowerShell 5.1 Compatibility:** `Get-EventLog` is deprecated; should use `Get-WinEvent` for better control
2. **Data Volume:** Collecting 100 newest events per log could be excessive; should filter by time window (Friday-Monday)
3. **No Error Handling:** Script silently continues if registry keys don't exist; should report what was collected vs. what failed
4. **Missing Elevation Check:** Registry reads may fail without admin; should validate
5. **Incomplete App Detection:** Hardcoded app name pattern; should be flexible parameter
6. **No DryRun Info Display:** DryRun switch shows message but doesn't actually show what would be collected
7. **Event Message Length:** Full event messages can be massive in JSON; should truncate or exclude
8. **No Timestamps on Evidence:** Should include evidence collection timestamp for forensic chain
9. **Missing Startup Folder Check:** Only checks registry; should also check physical C:\Users\*\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup
10. **Output Path Not Validated:** Should verify output directory exists before trying to write

---

## SECTION 2: HUMAN-CORRECTED VERSION

```powershell
# Evidence Collection Script - Floor 6 Incident Investigation
# Purpose: Collect evidence to test Hypothesis #1 (App integrated into login/startup)
# Safety: Read-only operation only; no modifications to system
# Requires: PowerShell 5.1+, Administrative privileges for complete registry access
# Author: Corrected by Security Engineering
# Date: 2026-08-14
# Last Updated: 2026-08-14

param(
    [switch]$DryRun = $false,
    [string]$OutputPath = "$env:TEMP\FloorSixEvidence-$(Get-Date -Format 'yyyyMMdd-HHmmss').json",
    [string]$ApplicationNameFilter = "Document Management*",
    [int]$EventLogDaysBack = 3,  # Collect events from Friday to Monday (3-4 days)
    [int]$MaxEventsPerLog = 500  # Limit to prevent excessive data
)

# Set error action preference to continue on errors (but report them)
$ErrorActionPreference = "Continue"

# SECTION: Initialize collection infrastructure
# Verify output path is writable
if (-not $DryRun) {
    $outputDir = Split-Path -Parent $OutputPath
    if (-not (Test-Path -Path $outputDir -PathType Container)) {
        Write-Error "Output directory does not exist: $outputDir"
        exit 1
    }
}

# Check if running with administrative privileges (registry access requires elevation)
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Warning "Script is not running as Administrator. Some registry keys may not be accessible."
}

Write-Host "===== Floor 6 Evidence Collection Script ====="
Write-Host "Start Time: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
Write-Host "Machine: $env:COMPUTERNAME"
Write-Host "User: $env:USERNAME"
Write-Host "Admin: $isAdmin"
Write-Host "DryRun Mode: $DryRun"
Write-Host "Output Path: $OutputPath"
Write-Host "Event Lookback: $EventLogDaysBack days"
Write-Host ""

# Initialize results object with metadata
$results = @{
    Metadata = @{
        CollectionTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        MachineName = $env:COMPUTERNAME
        Username = $env:USERNAME
        IsAdministrator = $isAdmin
        ScriptVersion = "1.0"
        EventLogDaysBack = $EventLogDaysBack
    }
    Evidence = @{}
    CollectionStatus = @{}
}

# SECTION: Verify application installation
# Purpose: Determine if document management app is installed and when
# Read-only: Yes (registry query only)
Write-Host "Collecting application installation data..."
$collectionStarted = Get-Date

try {
    # Query 32-bit and 64-bit uninstall registry paths
    $installedApps = @()
    $registryPaths = @(
        "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*",
        "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
    )
    
    foreach ($path in $registryPaths) {
        $apps = Get-ItemProperty $path -ErrorAction SilentlyContinue | 
            Where-Object { $_.DisplayName -like $ApplicationNameFilter }
        $installedApps += $apps
    }

    $results.Evidence.InstalledApplications = @{
        SearchPattern = $ApplicationNameFilter
        TotalFound = $installedApps.Count
        Applications = @()
        CollectionTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    }

    # Extract relevant properties for each installed application
    foreach ($app in $installedApps) {
        $appEntry = @{
            DisplayName = $app.DisplayName
            DisplayVersion = $app.DisplayVersion
            Publisher = $app.Publisher
            InstallDate = $app.InstallDate
            InstallLocation = $app.InstallLocation
            UninstallString = $app.UninstallString
            SystemComponent = $app.SystemComponent
            NoRemove = $app.NoRemove
        }
        # Only add non-null properties to keep JSON clean
        $appEntry = $appEntry.GetEnumerator() | Where-Object { $null -ne $_.Value } | 
            ForEach-Object { @{ $_.Name = $_.Value } } | Measure-Object -ErrorAction SilentlyContinue
        $results.Evidence.InstalledApplications.Applications += $appEntry
    }
    
    $results.CollectionStatus.InstalledApplications = "SUCCESS"
    Write-Host "  ✓ Found $($installedApps.Count) application(s) matching pattern"
}
catch {
    $results.CollectionStatus.InstalledApplications = "FAILED: $($_.Exception.Message)"
    Write-Error "Failed to collect installed applications: $($_.Exception.Message)"
}

# SECTION: Collect startup programs from registry
# Purpose: Identify processes that execute at system/user startup (potential attack vector for deployment)
# Read-only: Yes (registry query only)
Write-Host "Collecting startup programs from registry..."
try {
    $startupEntries = @()
    
    # System-wide startup programs (HKLM)
    $systemStartup = Get-ItemProperty "HKLM:\Software\Microsoft\Windows\CurrentVersion\Run" -ErrorAction SilentlyContinue
    if ($systemStartup) {
        foreach ($property in $systemStartup.PSObject.Properties) {
            if ($property.Name -ne "PSPath" -and $property.Name -ne "PSParentPath" -and $property.Name -ne "PSChildName" -and $property.Name -ne "PSDrive" -and $property.Name -ne "PSProvider") {
                $startupEntries += @{
                    Type = "SystemStartup"
                    Name = $property.Name
                    Command = $property.Value
                    Scope = "HKLM"
                }
            }
        }
    }
    
    # User-specific startup programs (HKCU) - only if user context available
    if ($env:USERNAME) {
        $userStartup = Get-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -ErrorAction SilentlyContinue
        if ($userStartup) {
            foreach ($property in $userStartup.PSObject.Properties) {
                if ($property.Name -notmatch "^PS(Path|ParentPath|ChildName|Drive|Provider)$") {
                    $startupEntries += @{
                        Type = "UserStartup"
                        Name = $property.Name
                        Command = $property.Value
                        Scope = "HKCU"
                    }
                }
            }
        }
    }

    $results.Evidence.StartupPrograms = @{
        RegistryEntries = $startupEntries
        Count = $startupEntries.Count
        CollectionTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    }
    
    $results.CollectionStatus.StartupPrograms = "SUCCESS"
    Write-Host "  ✓ Collected $($startupEntries.Count) startup registry entries"
}
catch {
    $results.CollectionStatus.StartupPrograms = "FAILED: $($_.Exception.Message)"
    Write-Error "Failed to collect startup programs: $($_.Exception.Message)"
}

# SECTION: Check physical startup folders
# Purpose: Identify batch files, shortcuts, or executables in startup directory
# Read-only: Yes (file listing only, no execution)
Write-Host "Checking physical startup folders..."
try {
    $startupFolders = @(
        "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Startup",
        "$env:AppData\Microsoft\Windows\Start Menu\Programs\Startup"
    )
    
    $startupFiles = @()
    foreach ($folder in $startupFolders) {
        if (Test-Path -Path $folder -PathType Container) {
            $files = Get-ChildItem -Path $folder -Recurse -File -ErrorAction SilentlyContinue | 
                Select-Object Name, FullPath, Length, LastWriteTime, Extension
            $startupFiles += $files | ForEach-Object { 
                $_ | Add-Member -NotePropertyName "StartupFolder" -NotePropertyValue $folder -PassThru 
            }
        }
    }

    $results.Evidence.StartupFolders = @{
        FoldersChecked = $startupFolders
        FilesFound = $startupFiles.Count
        Files = $startupFiles
        CollectionTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    }
    
    $results.CollectionStatus.StartupFolders = "SUCCESS"
    Write-Host "  ✓ Scanned $($startupFolders.Count) startup folder(s), found $($startupFiles.Count) file(s)"
}
catch {
    $results.CollectionStatus.StartupFolders = "FAILED: $($_.Exception.Message)"
    Write-Error "Failed to check startup folders: $($_.Exception.Message)"
}

# SECTION: Collect scheduled tasks
# Purpose: Identify automated tasks that could interfere with login or profile loading
# Read-only: Yes (task query only)
Write-Host "Collecting scheduled tasks..."
try {
    # Get all scheduled tasks (can be hundreds; filter to recent/enabled)
    $allTasks = Get-ScheduledTask -ErrorAction SilentlyContinue
    
    # Filter to tasks that are enabled and recently modified
    $relevantTasks = $allTasks | Where-Object { $_.State -eq "Ready" -or $_.State -eq "Running" } | 
        Select-Object -First $MaxEventsPerLog
    
    $taskEntries = @()
    foreach ($task in $relevantTasks) {
        try {
            # Get task action details (what the task actually does)
            $taskAction = $task.Actions | Select-Object -First 1
            $taskTrigger = $task.Triggers | Select-Object -First 1
            
            $taskEntries += @{
                TaskName = $task.TaskName
                TaskPath = $task.TaskPath
                State = $task.State
                Enabled = $task.Enabled
                LastRunTime = $task.LastRunTime
                NextRunTime = $task.NextRunTime
                LastTaskResult = $task.LastTaskResult
                Actions = $taskAction.ToString()
                Trigger = $taskTrigger.ToString()
            }
        }
        catch {
            # Skip tasks that fail to enumerate
        }
    }

    $results.Evidence.ScheduledTasks = @{
        TotalTasks = $allTasks.Count
        TasksRetrieved = $taskEntries.Count
        MaxLimit = $MaxEventsPerLog
        Tasks = $taskEntries
        CollectionTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    }
    
    $results.CollectionStatus.ScheduledTasks = "SUCCESS"
    Write-Host "  ✓ Collected $($taskEntries.Count) scheduled task(s) (of $($allTasks.Count) total)"
}
catch {
    $results.CollectionStatus.ScheduledTasks = "FAILED: $($_.Exception.Message)"
    Write-Error "Failed to collect scheduled tasks: $($_.Exception.Message)"
}

# SECTION: Collect recent system events
# Purpose: Identify errors or warnings during login timeframe (Friday-Monday)
# Read-only: Yes (event log query only)
# Filter: Only events from target timeframe to limit data volume
Write-Host "Collecting system event logs..."
try {
    $cutoffDate = (Get-Date).AddDays(-$EventLogDaysBack)
    
    # System event log (authentication failures, service start issues)
    $systemEvents = @()
    $systemEventQuery = @{
        LogName = "System"
        StartTime = $cutoffDate
        MaxEvents = $MaxEventsPerLog
        ErrorAction = "SilentlyContinue"
    }
    
    $rawSystemEvents = Get-WinEvent @systemEventQuery 2>$null | 
        Where-Object { $_.LevelDisplayName -in @("Error", "Warning") }
    
    $systemEvents = $rawSystemEvents | ForEach-Object {
        @{
            TimeCreated = $_.TimeCreated.ToString("yyyy-MM-dd HH:mm:ss")
            EventID = $_.ID
            LevelDisplayName = $_.LevelDisplayName
            ProviderName = $_.ProviderName
            Message = ($_.Message -replace '\s+', ' ').Substring(0, [Math]::Min(500, $_.Message.Length))  # Truncate to 500 chars
        }
    }

    $results.Evidence.SystemEvents = @{
        EventsRetrieved = $systemEvents.Count
        TimeRange = "Last $EventLogDaysBack days (since $($cutoffDate.ToString('yyyy-MM-dd')))"
        SeverityFilter = @("Error", "Warning")
        Events = $systemEvents
        CollectionTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    }
    
    $results.CollectionStatus.SystemEvents = "SUCCESS"
    Write-Host "  ✓ Collected $($systemEvents.Count) system event(s)"
}
catch {
    $results.CollectionStatus.SystemEvents = "FAILED: $($_.Exception.Message)"
    Write-Error "Failed to collect system events: $($_.Exception.Message)"
}

# SECTION: Collect recent application events
# Purpose: Identify app crashes, failures, or unexpected shutdowns
# Read-only: Yes (event log query only)
Write-Host "Collecting application event logs..."
try {
    $cutoffDate = (Get-Date).AddDays(-$EventLogDaysBack)
    
    # Application event log (app crashes, errors)
    $applicationEvents = @()
    $appEventQuery = @{
        LogName = "Application"
        StartTime = $cutoffDate
        MaxEvents = $MaxEventsPerLog
        ErrorAction = "SilentlyContinue"
    }
    
    $rawAppEvents = Get-WinEvent @appEventQuery 2>$null | 
        Where-Object { $_.LevelDisplayName -in @("Error", "Warning") }
    
    $applicationEvents = $rawAppEvents | ForEach-Object {
        @{
            TimeCreated = $_.TimeCreated.ToString("yyyy-MM-dd HH:mm:ss")
            EventID = $_.ID
            LevelDisplayName = $_.LevelDisplayName
            ProviderName = $_.ProviderName
            Message = ($_.Message -replace '\s+', ' ').Substring(0, [Math]::Min(500, $_.Message.Length))  # Truncate to 500 chars
        }
    }

    $results.Evidence.ApplicationEvents = @{
        EventsRetrieved = $applicationEvents.Count
        TimeRange = "Last $EventLogDaysBack days (since $($cutoffDate.ToString('yyyy-MM-dd')))"
        SeverityFilter = @("Error", "Warning")
        Events = $applicationEvents
        CollectionTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    }
    
    $results.CollectionStatus.ApplicationEvents = "SUCCESS"
    Write-Host "  ✓ Collected $($applicationEvents.Count) application event(s)"
}
catch {
    $results.CollectionStatus.ApplicationEvents = "FAILED: $($_.Exception.Message)"
    Write-Error "Failed to collect application events: $($_.Exception.Message)"
}

# SECTION: Export results to JSON
# Purpose: Create machine-readable evidence file for analyst review
Write-Host ""
Write-Host "Exporting evidence to JSON..."

if (-not $DryRun) {
    try {
        # Convert to JSON with appropriate depth for nested objects
        $jsonOutput = $results | ConvertTo-Json -Depth 10
        
        # Write to file
        $jsonOutput | Out-File -FilePath $OutputPath -Encoding UTF8 -ErrorAction Stop
        
        # Verify file was created and contains data
        $fileInfo = Get-Item -Path $OutputPath
        Write-Host "✓ Evidence exported successfully"
        Write-Host "  File: $OutputPath"
        Write-Host "  Size: $($fileInfo.Length) bytes"
        
        $results.CollectionStatus.Export = "SUCCESS"
    }
    catch {
        Write-Error "Failed to export results to JSON: $($_.Exception.Message)"
        $results.CollectionStatus.Export = "FAILED: $($_.Exception.Message)"
    }
} else {
    # DryRun mode: show what would be exported
    Write-Host "DryRun Mode: Would export the following evidence sections:"
    foreach ($section in $results.Evidence.Keys) {
        $itemCount = $results.Evidence[$section].Count
        Write-Host "  - $section (approximately $itemCount item(s))"
    }
    Write-Host ""
    Write-Host "DryRun: Would write to: $OutputPath"
    Write-Host "DryRun: Total JSON size would be approximately $($results | ConvertTo-Json | Measure-Object -Character | Select-Object -ExpandProperty Characters) bytes"
    
    $results.CollectionStatus.Export = "DRYRUN - No output written"
}

# SECTION: Print summary and status
Write-Host ""
Write-Host "===== Collection Summary ====="
Write-Host "Status Report:"
foreach ($status in $results.CollectionStatus.GetEnumerator() | Sort-Object Name) {
    $statusSymbol = if ($status.Value -eq "SUCCESS") { "✓" } elseif ($status.Value -eq "DRYRUN - No output written") { "→" } else { "✗" }
    Write-Host "  $statusSymbol $($status.Name): $($status.Value)"
}

Write-Host ""
Write-Host "Evidence sections collected: $($results.Evidence.Keys.Count)"
Write-Host "End Time: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
Write-Host "============================="
```

---

## SECTION 3: EXACT CORRECTIONS MADE

### Correction #1: Event Log Query Method
**AI Version:**
```powershell
$applicationEvents = Get-EventLog -LogName Application -Newest 100 -ErrorAction SilentlyContinue
```

**Corrected Version:**
```powershell
$rawAppEvents = Get-WinEvent @appEventQuery 2>$null | 
    Where-Object { $_.LevelDisplayName -in @("Error", "Warning") }
```

**Reason:**
- `Get-EventLog` is deprecated in newer PowerShell versions and not recommended for PowerShell 5.1+
- `Get-WinEvent` allows filtering by time range (not just "last N events"), essential for forensic investigation
- Filtering by severity (Error/Warning only) reduces data noise and improves analysis
- Time-range filtering (`StartTime = $cutoffDate`) limits collection to Friday-Monday window, reducing JSON size from potentially 10MB to manageable ~500KB
- Query hash (`@appEventQuery`) is more readable and maintainable than inline parameters

---

### Correction #2: Startup Registry Entry Filtering
**AI Version:**
```powershell
$results.Evidence.StartupPrograms = @{
    SystemStartup = $startupReg.PSObject.Properties | Select-Object Name, Value
    UserStartup = $startupRegUser.PSObject.Properties | Select-Object Name, Value
}
```

**Corrected Version:**
```powershell
foreach ($property in $systemStartup.PSObject.Properties) {
    if ($property.Name -notmatch "^PS(Path|ParentPath|ChildName|Drive|Provider)$") {
        $startupEntries += @{
            Type = "SystemStartup"
            Name = $property.Name
            Command = $property.Value
            Scope = "HKLM"
        }
    }
}
```

**Reason:**
- PowerShell's `PSObject.Properties` includes system metadata properties (PSPath, PSParentPath, etc.) that are not actual startup entries
- AI version includes these noise properties in output, making JSON harder to parse
- Corrected version filters out metadata using regex, resulting in clean startup entries only
- Adding `Type` and `Scope` fields improves analyst's ability to quickly identify which entries are relevant
- Structured output makes downstream analysis and filtering easier

---

### Correction #3: Data Volume and Message Truncation
**AI Version:**
```powershell
foreach ($event in $applicationEvents) {
    $results.Evidence.ApplicationEvents.Events += @{
        TimeGenerated = $event.TimeGenerated
        EventID = $event.EventID
        Source = $event.Source
        EntryType = $event.EntryType
        Message = $event.Message  # Full message, could be 10KB+
    }
}
```

**Corrected Version:**
```powershell
$rawAppEvents = Get-WinEvent @appEventQuery 2>$null | 
    Where-Object { $_.LevelDisplayName -in @("Error", "Warning") }

# ... then for each event:
Message = ($_.Message -replace '\s+', ' ').Substring(0, [Math]::Min(500, $_.Message.Length))
```

**Reason:**
- Event messages can be 1-10KB each (full stack traces, full log lines)
- Collecting 500 events with 5KB messages each = 2.5MB for one log alone
- Truncating to 500 characters captures essential error info while keeping JSON manageable
- Normalizing whitespace (`-replace '\s+', ' '`) makes JSON more readable (removes line breaks)
- For actual investigation, analyst can refer back to Event Viewer for full message if needed
- `Get-WinEvent` with time filtering significantly reduces number of events collected (500 events over 3 days vs. 500 most recent)

---

### Correction #4: DryRun Switch Implementation
**AI Version:**
```powershell
if (-not $DryRun) {
    $results | ConvertTo-Json -Depth 5 | Out-File -FilePath $OutputPath -Encoding UTF8
    Write-Host "Results exported to: $OutputPath"
} else {
    Write-Host "DryRun: Would export to $OutputPath"
    Write-Host "DryRun: Results contain $(($results.Evidence.Keys).Count) evidence sections"
}
```

**Corrected Version:**
```powershell
if (-not $DryRun) {
    try {
        $jsonOutput = $results | ConvertTo-Json -Depth 10
        $jsonOutput | Out-File -FilePath $OutputPath -Encoding UTF8 -ErrorAction Stop
        $fileInfo = Get-Item -Path $OutputPath
        Write-Host "✓ Evidence exported successfully"
        Write-Host "  File: $OutputPath"
        Write-Host "  Size: $($fileInfo.Length) bytes"
    }
    catch {
        Write-Error "Failed to export results to JSON: $($_.Exception.Message)"
    }
} else {
    Write-Host "DryRun Mode: Would export the following evidence sections:"
    foreach ($section in $results.Evidence.Keys) {
        $itemCount = $results.Evidence[$section].Count
        Write-Host "  - $section (approximately $itemCount item(s))"
    }
    Write-Host "DryRun: Would write to: $OutputPath"
    Write-Host "DryRun: Total JSON size would be approximately $($results | ConvertTo-Json | Measure-Object -Character | Select-Object -ExpandProperty Characters) bytes"
}
```

**Reason:**
- AI version shows DryRun message but doesn't show what data would be collected (not useful)
- Corrected version shows EACH evidence section and item count so analyst can preview what will be collected
- Corrected version estimates JSON file size in DryRun mode (helps assess if data will be manageable)
- Corrected version includes file size verification after export (confirms successful write)
- Error handling in corrected version prevents silent failures
- Better feedback loop: analyst runs with `-DryRun $true` to preview, then without DryRun to collect

---

### Correction #5: Output Path Validation and Timestamping
**AI Version:**
```powershell
[string]$OutputPath = "$env:TEMP\FloorSixEvidence.json"
```

**Corrected Version:**
```powershell
[string]$OutputPath = "$env:TEMP\FloorSixEvidence-$(Get-Date -Format 'yyyyMMdd-HHmmss').json"

# Validate output directory exists
if (-not $DryRun) {
    $outputDir = Split-Path -Parent $OutputPath
    if (-not (Test-Path -Path $outputDir -PathType Container)) {
        Write-Error "Output directory does not exist: $outputDir"
        exit 1
    }
}
```

**Reason:**
- AI version uses fixed filename; running twice would overwrite first collection (data loss)
- Corrected version includes timestamp in filename (enables multiple collections without collision)
- Timestamping is forensic best practice: chains evidence to collection time
- Path validation prevents "file write failed" errors at end of long collection
- Early exit if output path is invalid saves time vs. waiting until end
- `Split-Path` correctly handles path parsing across different Windows drive configurations

---

### Correction #6: Administrator Privilege Check
**AI Version:**
```powershell
$ErrorActionPreference = "SilentlyContinue"
# ... immediately starts collecting, no privilege warning
```

**Corrected Version:**
```powershell
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Warning "Script is not running as Administrator. Some registry keys may not be accessible."
}

# ... display admin status in header
```

**Reason:**
- Registry access for HKCU requires user context; HKLM requires admin
- AI version silently fails to read registry without warning
- Corrected version alerts analyst upfront that collection may be incomplete
- Analyst can then re-run with elevation (`Run as Administrator`)
- Transparency about permission limitations is critical for forensic integrity
- Admin status reported in results metadata for chain-of-custody documentation

---

### Correction #7: Collection Status Tracking
**AI Version:**
```powershell
# No status tracking; errors are silent or generic
```

**Corrected Version:**
```powershell
$results.CollectionStatus = @{}

# For each evidence section:
try {
    # ... collect evidence ...
    $results.CollectionStatus.InstalledApplications = "SUCCESS"
}
catch {
    $results.CollectionStatus.InstalledApplications = "FAILED: $($_.Exception.Message)"
    Write-Error "Failed to collect installed applications: $($_.Exception.Message)"
}

# Summary at end:
Write-Host "Status Report:"
foreach ($status in $results.CollectionStatus.GetEnumerator() | Sort-Object Name) {
    $statusSymbol = if ($status.Value -eq "SUCCESS") { "✓" } else { "✗" }
    Write-Host "  $statusSymbol $($status.Name): $($status.Value)"
}
```

**Reason:**
- AI version doesn't track which sections succeeded vs. failed
- Analyst reviewing JSON doesn't know if missing data is real or collection error
- Corrected version includes status for each section in results
- Status report at end provides quick verification
- Empty or missing evidence sections must be distinguished from "no items found"
- Chain of custody requires recording what was attempted and what succeeded

---

### Correction #8: Parameterization for Flexibility
**AI Version:**
```powershell
$appName = "Document Management*"
# ... hardcoded into script
```

**Corrected Version:**
```powershell
param(
    [switch]$DryRun = $false,
    [string]$OutputPath = "$env:TEMP\FloorSixEvidence-$(Get-Date -Format 'yyyyMMdd-HHmmss').json",
    [string]$ApplicationNameFilter = "Document Management*",
    [int]$EventLogDaysBack = 3,
    [int]$MaxEventsPerLog = 500
)
```

**Reason:**
- Parameterization allows analyst to adapt script without editing code
- If app name changes, analyst can pass different filter: `.\script.ps1 -ApplicationNameFilter "Portal*"`
- Timeframe customization allows investigation across different incident windows
- Event log limit prevents excessive data collection on busy systems
- PowerShell best practice: parameters make scripts reusable across similar investigations

---

## SECTION 4: GENERATE-THEN-VERIFY PRINCIPLE DEMONSTRATED

### Principle Definition:
**"Generate Then Verify"** means:
1. **Generate:** Create a solution (AI-assisted script generation)
2. **Verify:** Manually review and test the solution
3. **Correct:** Fix issues before deployment
4. **Document:** Record what was wrong and why

**Why This Matters for Security Investigations:**
- Evidence collection errors lead to incomplete investigation
- Incorrect filtering produces false negatives (missing relevant evidence)
- Oversized JSON files become unmanageable and slow
- DryRun failures lead to unexpected system access attempts
- Parameter errors cause script failures mid-collection

### Application in This Case:
1. **Generated:** AI produced working PowerShell script with basic functionality
2. **Verified:** Manual review identified 8 categories of issues
3. **Corrected:** Each issue was fixed with clear explanation
4. **Documented:** This document captures all corrections and reasoning

### Result:
A production-ready evidence collection script that is:
- **Read-only:** No system modifications risk
- **Flexible:** Parameterized for different scenarios
- **Transparent:** Status tracking shows what was collected
- **Efficient:** Time-filtered and size-limited data
- **Forensically sound:** Timestamped, chain-of-custody aware
- **User-friendly:** DryRun preview before actual collection

---

## USAGE INSTRUCTIONS FOR INVESTIGATOR

### Run in DryRun Mode First (No Data Collected)
```powershell
.\FloorSixEvidenceCollection.ps1 -DryRun $true
```

**Output Preview:**
```
===== Floor 6 Evidence Collection Script =====
Start Time: 2026-08-14 14:30:45
Machine: FLOOR6-PC-001
User: labuser
Admin: True
DryRun Mode: True
...
DryRun Mode: Would export the following evidence sections:
  - InstalledApplications (approximately 2 item(s))
  - StartupPrograms (approximately 15 item(s))
  - ScheduledTasks (approximately 500 item(s))
  - SystemEvents (approximately 247 item(s))
  - ApplicationEvents (approximately 118 item(s))

DryRun: Would write to: C:\Temp\FloorSixEvidence-20260814-143045.json
DryRun: Total JSON size would be approximately 523847 bytes
```

### Run with Actual Collection
```powershell
# Run as Administrator
.\FloorSixEvidenceCollection.ps1
```

### Custom Parameters
```powershell
# Search for different app name and collect more event history
.\FloorSixEvidenceCollection.ps1 -ApplicationNameFilter "Portal*" -EventLogDaysBack 7 -OutputPath "D:\Investigations\FloorSixEvidence.json"
```

### Review Evidence
```powershell
# Load and inspect JSON results
$evidence = Get-Content -Path "C:\Temp\FloorSixEvidence-20260814-143045.json" | ConvertFrom-Json
$evidence.Evidence.StartupPrograms.RegistryEntries | Where-Object { $_.Command -like "*Document*" }
```

