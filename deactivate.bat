@echo off
echo ================================
echo   Safeclose - Deactivating...
echo ================================

:: Check admin privileges
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [ERROR] Please run as Administrator!
    echo Right-click deactivate.bat and choose "Run as administrator"
    pause
    exit /b 1
)

:: Stop running monitor process
taskkill /f /im powershell.exe /fi "WINDOWTITLE eq Safeclose*" >nul 2>&1

:: Delete Task Scheduler task
schtasks /delete /tn "Safeclose" /f

:: Restore lid-close to sleep
powercfg /setdcvalueindex SCHEME_CURRENT SUB_BUTTONS LIDACTION 1
powercfg /setacvalueindex SCHEME_CURRENT SUB_BUTTONS LIDACTION 1
powercfg /S SCHEME_CURRENT

if %errorLevel% equ 0 (
    echo.
    echo [OK] Safeclose deactivated successfully!
    echo [OK] Lid-close behavior restored to default.
) else (
    echo [ERROR] Something went wrong.
)

pause
