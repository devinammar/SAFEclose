@echo off
echo ================================
echo   SAFEclose - Activating...
echo ================================

:: Check admin privileges
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [ERROR] Please run as Administrator!
    echo Right-click activate.bat and choose "Run as administrator"
    pause
    exit /b 1
)

:: Check if SAFEclose is already running
schtasks /query /tn "SAFEclose" >nul 2>&1
if %errorLevel% equ 0 (
    echo [WARNING] SAFEclose is already active!
    echo [WARNING] Run deactivate.bat first if you want to restart it.
    pause
    exit /b 0
)

:: Get current directory
set SCRIPT_DIR=%~dp0
set PS_SCRIPT=%SCRIPT_DIR%monitor.ps1

:: Create Task Scheduler task
schtasks /create /tn "SAFEclose" /tr "powershell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -File \"%PS_SCRIPT%\"" /sc onlogon /ru "%USERNAME%" /f

if %errorLevel% equ 0 (
    echo.
    echo [OK] SAFEclose activated successfully!
    echo [OK] It will now run automatically on every startup.
    echo.
    echo Starting SAFEclose now...
    powershell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -File "%PS_SCRIPT%"
) else (
    echo [ERROR] Failed to activate SAFEclose.
)

pause