@echo off
"C:\Program Files\Microsoft SDKs\Azure\CLI2\wbin\az.cmd" vm run-command invoke -g dwpai-lab-rg -n shfin0101 --command-id RunPowerShellScript --scripts @day8/register-avd-sessionhost-direct.ps1 --parameters registrationToken=%1 -o json
