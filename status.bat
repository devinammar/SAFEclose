@echo off
echo ================================
echo   SAFEclose - Status Check
echo ================================
echo.

:: Check if SAFEclose task exists
schtasks /query /tn "SAFEclose" >nul 2>&1
if %errorLevel% equ 0 (
    echo [ACTIVE]   SAFEclose is installed and set to run on startup.
) else (
    echo [INACTIVE] SAFEclose is NOT installed.
)

:: Check if monitor process is running via PID file
set PID_FILE=%TEMP%\safeclose.pid
if exist "%PID_FILE%" (
    set /p SAVED_PID=<"%PID_FILE%"
    tasklist /fi "PID eq %SAVED_PID%" 2>nul | find "powershell" >nul
    if %errorLevel% equ 0 (
        echo [RUNNING]  Monitor process is running. PID: %SAVED_PID%
    ) else (
        echo [STOPPED]  Monitor process is NOT running.
    )
) else (
    echo [STOPPED]  Monitor process is NOT running.
)

echo.
echo --- AI Agents Currently Detected ---
echo.

set SCRIPT_DIR=%~dp0
set AGENTS_FILE=%SCRIPT_DIR%agents.txt

powershell.exe -NoProfile -ExecutionPolicy Bypass -Command ^
    "$agentsFile = '%AGENTS_FILE%'; " ^
    "$exact = @(); $broad = @(); " ^
    "if (Test-Path $agentsFile) { " ^
    "  $lines = Get-Content $agentsFile -Encoding UTF8; " ^
    "  foreach ($l in $lines) { $l = $l.Trim(); if ($l -eq '' -or $l.StartsWith('#')) { continue }; if ($l -match '^BROAD:\s*(.+)') { $broad += $Matches[1].Trim().ToLower() } else { $exact += ($l -replace '^EXACT:\s*','').Trim().ToLower() } } " ^
    "} else { $exact = @('claude','cursor','ollama','windsurf','gemini','n8n'); $broad = @('node','python') }; " ^
    "$found = @(); " ^
    "foreach ($n in $exact) { if (Get-Process -Name $n -EA SilentlyContinue) { $found += $n } }; " ^
    "foreach ($n in $broad) { $procs = Get-Process -Name $n -EA SilentlyContinue; foreach ($p in $procs) { try { $path = $p.Path; if ($path) { foreach ($kw in ($exact + @('anthropic'))) { if ($path -like ('*'+$kw+'*')) { $found += ($n+' (via '+$kw+')'); break } } } } catch {} } }; " ^
    "if ($found.Count -eq 0) { Write-Host '  (none detected)' -ForegroundColor Gray } else { foreach ($a in $found) { Write-Host ('  [RUNNING] ' + $a) -ForegroundColor Green } }"

echo.
echo --- Registered AI Agents (from agents.txt) ---
echo.
if exist "%AGENTS_FILE%" (
    powershell.exe -NoProfile -ExecutionPolicy Bypass -Command ^
        "$lines = Get-Content '%AGENTS_FILE%' -Encoding UTF8; " ^
        "foreach ($l in $lines) { $l = $l.Trim(); if ($l -eq '' -or $l.StartsWith('#')) { continue }; Write-Host ('  ' + $l) }"
) else (
    echo   agents.txt not found. Using built-in defaults.
)

echo.
echo --- Log File ---
echo   %TEMP%\safeclose.log
echo.
pause