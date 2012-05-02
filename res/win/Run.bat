@echo off
where  PortFusion >PortFusion.path
set /p PortFusion=<PortFusion.path
dir %PortFusion%

echo Signing ...
"C:\Program Files (x86)\Microsoft SDKs\Windows\v7.0A\Bin\signtool.exe" sign /d "PortFusion Native Binary" /du "http://fusion.corsis.eu" /f "c:\corsis\certificates\corsis.eu.pfx" /t http://timestamp.verisign.com/scripts/timestamp.dll "%PortFusion%"