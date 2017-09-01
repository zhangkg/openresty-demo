@echo off
tasklist | findstr /i "nginx.exe"
echo "nginx is running, stopping..."
rem nginx -s stop
TASKKILL /F /IM nginx.exe /T
echo "stop ok"  