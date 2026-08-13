@echo off
"C:\Program Files\Microsoft SDKs\Azure\CLI2\wbin\az.cmd" desktopvirtualization hostpool show -g dwpai-lab-rg -n POOL-FIN-01 --query registrationInfo -o json
