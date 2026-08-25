@echo off
echo ================================
echo   Safeclose - Activating...
echo ================================

:: Check admin privileges
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [ERROR] Please run as Administrator!
    echo Right-click activate.bat and choose "Run as administrator"
    pause
    exit /b 1
)

:: Get current directory
set SCRIPT_DIR=%~dp0
set PS_SCRIPT=%SCRIPT_DIR%monitor.ps1

:: Create Task Scheduler task
schtasks /create /tn "Safeclose" /tr "powershell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -File \"%PS_SCRIPT%\"" /sc onlogon /ru "%USERNAME%" /f

if %errorLevel% equ 0 (
    echo.
    echo [OK] Safeclose activated successfully!
    echo [OK] It will now run automatically on every startup.
    echo.
    echo Starting Safeclose now...
    powershell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -File "%PS_SCRIPT%"
) else (
    echo [ERROR] Failed to activate Safeclose.
)

pause
