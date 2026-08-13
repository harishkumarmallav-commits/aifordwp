@echo off
"C:\Program Files\Microsoft SDKs\Azure\CLI2\wbin\az.cmd" resource list -g dwpai-lab-rg --resource-type Microsoft.DesktopVirtualization/hostpools/sessionhosts -o json
