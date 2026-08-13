$ErrorActionPreference = 'Stop'

$registrationToken = 'eyJhbGciOiJSUzI1NiIsImtpZCI6IjQzQjM1MkE1MzExQkM4REJDNTIzRjdERUNGRkU1RTJDNUQxMkIxQTciLCJ0eXAiOiJKV1QifQ.eyJSZWdpc3RyYXRpb25JZCI6ImY4OWEyOGFlLTY3NTktNDIwOS1hYzU1LWU5NmU0ODhmZTM5NiIsIkJyb2tlclVyaSI6Imh0dHBzOi8vcmRicm9rZXItZy11cy1yMS53dmQubWljcm9zb2Z0LmNvbS8iLCJEaWFnbm9zdGljc1VyaSI6Imh0dHBzOi8vcmRkaWFnbm9zdGljcy1nLXVzLXIxLnd2ZC5taWNyb3NvZnQuY29tLyIsIkVuZHBvaW50UG9vbElkIjoiZWJmZGZlZDAtMzVkZS00ZWE5LTg4OTQtNmE1YjJlNjEwNDZlIiwiR2xvYmFsQnJva2VyVXJpIjoiaHR0cHM6Ly9yZGJyb2tlci53dmQubWljcm9zb2Z0LmNvbS8iLCJHZW9ncmFwaHkiOiJVUyIsIkdsb2JhbEJyb2tlclJlc291cmNlSWRVcmkiOiJodHRwczovL2ViZmRmZWQwLTM1ZGUtNGVhOS04ODk0LTZhNWIyZTYxMDQ2ZS5yZGJyb2tlci53dmQubWljcm9zb2Z0LmNvbS8iLCJCcm9rZXJSZXNvdXJjZUlkVXJpIjoiaHR0cHM6Ly9lYmZkZmVkMC0zNWRlLTRlYTktODg5NC02YTViMmU2MTA0NmUucmRicm9rZXItZy11cy1yMS53dmQubWljcm9zb2Z0LmNvbS8iLCJEaWFnbm9zdGljc1Jlc291cmNlSWRVcmkiOiJodHRwczovL2ViZmRmZWQwLTM1ZGUtNGVhOS04ODk0LTZhNWIyZTYxMDQ2ZS5yZGRpYWdub3N0aWNzLWctdXMtcjEud3ZkLm1pY3Jvc29mdC5jb20vIiwiQUFEVGVuYW50SWQiOiJmYTg0NDNjNi01YTM5LTRkZjUtYTAxOC05Yzg3NjQ1NWFkZjkiLCJuYmYiOjE3ODY2Mzk1MzIsImV4cCI6MTc4NjcwNDMwMCwiaXNzIjoiUkRJbmZyYVRva2VuTWFuYWdlciIsImF1ZCI6IlJEbWkifQ.BBq9g5napz3xC9PvvOgfFSKwucuSqffWZyS1W3p9_5NdzPCs69paKKImhUdwRlCdiRLx6fsR5QA-bsDeiCnBd-bWRpUBaPKEOQFBAJ89rgdWyFrv-cfw6PTBYb1NvrqyMx3Slkr2PTg0sEXDUdIGjBhNwr3dyzkbj3_oZdRD2GzR6B-XUbWkD3rJffiCcwTsz2-T4PNiPRK-qhjCmXtcj7PrSqGJBnZNZUQjh1lkjsLomJSvpXJ5oiFjO1yVMjx4ZbOD5ZjIOh6_ElRer_YPH7_kedhnxCL23GAzfTZ5Zu7Rc2-0KmCYRZNWb9NMriEdViGYCP4KOLP2Ds7Z38hjRQ'

$agentUrl = 'https://query.prod.cms.rt.microsoft.com/cms/api/am/binary/RWrmXv'
$bootUrl = 'https://query.prod.cms.rt.microsoft.com/cms/api/am/binary/RWrxrH'
$agentMsi = Join-Path $env:TEMP 'AVD-Agent.msi'
$bootMsi = Join-Path $env:TEMP 'AVD-Bootloader.msi'

Write-Host "Downloading AVD Bootloader..."
Invoke-WebRequest -Uri $bootUrl -OutFile $bootMsi

Write-Host "Downloading AVD Agent..."
Invoke-WebRequest -Uri $agentUrl -OutFile $agentMsi

Write-Host "Installing AVD Bootloader..."
Start-Process -FilePath 'msiexec.exe' -ArgumentList "/i `"$bootMsi`" /qn /norestart" -Wait -NoNewWindow

Write-Host "Installing AVD Agent..."
Start-Process -FilePath 'msiexec.exe' -ArgumentList "/i `"$agentMsi`" REGISTRATIONTOKEN=$registrationToken /qn /norestart" -Wait -NoNewWindow

Write-Host "Waiting for services to start..."
Start-Sleep -Seconds 20

Write-Host "Checking AVD Services..."
Get-Service -Name 'RDAgentBootLoader', 'RDAgent' -ErrorAction SilentlyContinue |
    Select-Object Name, Status, StartType |
    Format-Table -AutoSize |
    Out-String
