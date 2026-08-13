@echo off
"C:\Program Files\Microsoft SDKs\Azure\CLI2\wbin\az.cmd" vm run-command invoke -g dwpai-lab-rg -n shfin0101 --command-id RunPowerShellScript --scripts @day8/check-rdinfra-services-and-reg.ps1 -o json
