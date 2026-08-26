@echo off
echo ================================
echo   SAFEclose - Deactivating...
echo ================================

:: Check admin privileges
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [ERROR] Please run as Administrator!
    echo Right-click deactivate.bat and choose "Run as administrator"
    pause
    exit /b 1
)

:: Kill monitor process using saved PID
set PID_FILE=%TEMP%\safeclose.pid
if exist "%PID_FILE%" (
    set /p SAVED_PID=<"%PID_FILE%"
    echo Stopping SAFEclose process (PID: %SAVED_PID%)...
    taskkill /f /pid %SAVED_PID% >nul 2>&1
    del "%PID_FILE%" >nul 2>&1
    echo [OK] Process stopped.
) else (
    echo [WARNING] PID file not found. Attempting fallback kill...
    taskkill /f /im powershell.exe /fi "WINDOWTITLE eq SAFEclose*" >nul 2>&1
)

:: Delete Task Scheduler task
schtasks /delete /tn "SAFEclose" /f >nul 2>&1
if %errorLevel% equ 0 (
    echo [OK] Startup task removed.
) else (
    echo [WARNING] Task not found or already removed.
)

:: Safety fallback: restore lid to sleep
powercfg /setdcvalueindex SCHEME_CURRENT SUB_BUTTONS LIDACTION 1
powercfg /setacvalueindex SCHEME_CURRENT SUB_BUTTONS LIDACTION 1
powercfg /S SCHEME_CURRENT

echo.
echo [OK] SAFEclose deactivated successfully!
echo [OK] Lid-close behavior restored.
echo.
echo Log file: %TEMP%\safeclose.log

pause