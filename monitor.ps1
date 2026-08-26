# SAFEclose - monitor.ps1
# Monitors AI agent processes and controls lid-close behavior

# --- Paths ---
$SCRIPT_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path
$AGENTS_FILE = Join-Path $SCRIPT_DIR "agents.txt"
$PID_FILE    = "$env:TEMP\safeclose.pid"
$LOG_FILE    = "$env:TEMP\safeclose.log"

# --- Logging ---
function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $line = "[$timestamp] [$Level] $Message"
    Add-Content -Path $LOG_FILE -Value $line -Encoding UTF8
}

# --- Load agents from agents.txt ---
function Load-AgentLists {
    $exact  = @()
    $broad  = @()

    if (-not (Test-Path $AGENTS_FILE)) {
        Write-Log "agents.txt not found at $AGENTS_FILE. Using built-in defaults." "WARN"
        # Built-in fallback defaults
        $exact  = @("claude","cursor","ollama","windsurf","gemini","n8n")
        $broad  = @("node","python")
        return @{ Exact = $exact; Broad = $broad }
    }

    $lines = Get-Content $AGENTS_FILE -Encoding UTF8
    foreach ($line in $lines) {
        $line = $line.Trim()
        if ($line -eq "" -or $line.StartsWith("#")) { continue }

        if ($line -match "^BROAD:\s*(.+)") {
            $broad += $Matches[1].Trim().ToLower()
        } else {
            # EXACT: prefix or no prefix → treat as exact
            $name = $line -replace "^EXACT:\s*", ""
            $exact += $name.Trim().ToLower()
        }
    }

    return @{ Exact = $exact; Broad = $broad }
}

# --- Save original lid action ---
function Get-OriginalLidAction {
    param([string]$PowerSource)
    $output = powercfg /query SCHEME_CURRENT SUB_BUTTONS LIDACTION 2>$null
    foreach ($line in $output) {
        if ($line -match "Current DC Power Setting Index:\s*(0x\w+)" -and $PowerSource -eq "DC") {
            return [Convert]::ToInt32($Matches[1], 16)
        }
        if ($line -match "Current AC Power Setting Index:\s*(0x\w+)" -and $PowerSource -eq "AC") {
            return [Convert]::ToInt32($Matches[1], 16)
        }
    }
    return 1
}

# --- Lid control ---
function Set-LidDoNothing {
    powercfg /setdcvalueindex SCHEME_CURRENT SUB_BUTTONS LIDACTION 0
    powercfg /setacvalueindex SCHEME_CURRENT SUB_BUTTONS LIDACTION 0
    powercfg /S SCHEME_CURRENT
}

function Restore-LidOriginal {
    param([int]$OriginalDC, [int]$OriginalAC)
    powercfg /setdcvalueindex SCHEME_CURRENT SUB_BUTTONS LIDACTION $OriginalDC
    powercfg /setacvalueindex SCHEME_CURRENT SUB_BUTTONS LIDACTION $OriginalAC
    powercfg /S SCHEME_CURRENT
}

# --- Process detection ---
function Get-RunningAIAgents {
    param($AgentLists)
    $found = @()

    foreach ($name in $AgentLists.Exact) {
        if (Get-Process -Name $name -ErrorAction SilentlyContinue) {
            $found += $name
        }
    }

    foreach ($name in $AgentLists.Broad) {
        $procs = Get-Process -Name $name -ErrorAction SilentlyContinue
        foreach ($proc in $procs) {
            try {
                $path = $proc.Path
                if ($path) {
                    foreach ($keyword in ($AgentLists.Exact + @("anthropic"))) {
                        if ($path -like "*$keyword*") {
                            $found += "$name (via $keyword)"
                            break
                        }
                    }
                }
            } catch {}
        }
    }

    return $found
}

# -------------------------------------------------------
# MAIN
# -------------------------------------------------------

$agents = Load-AgentLists
Write-Log "SAFEclose started. PID=$PID"
Write-Log "Loaded agents — EXACT: $($agents.Exact -join ', ') | BROAD: $($agents.Broad -join ', ')"

$originalDC = Get-OriginalLidAction -PowerSource "DC"
$originalAC = Get-OriginalLidAction -PowerSource "AC"
Write-Log "Original LIDACTION DC=$originalDC AC=$originalAC"

$PID | Out-File -FilePath $PID_FILE -Encoding ASCII -Force

$previousState = $false

while ($true) {
    # Reload agents.txt every loop — user bisa edit tanpa restart SAFEclose
    $agents = Load-AgentLists
    $running = Get-RunningAIAgents -AgentLists $agents
    $isRunning = $running.Count -gt 0

    if ($isRunning -and -not $previousState) {
        Set-LidDoNothing
        $previousState = $true
        Write-Log "AI agent detected: $($running -join ', '). Lid-close disabled."
    }
    elseif (-not $isRunning -and $previousState) {
        Restore-LidOriginal -OriginalDC $originalDC -OriginalAC $originalAC
        $previousState = $false
        Write-Log "No AI agent running. Lid-close restored (DC=$originalDC AC=$originalAC)."
    }

    Start-Sleep -Seconds 10
}