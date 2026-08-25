# Safeclose - monitor.ps1
# Monitors AI agent processes and controls lid-close behavior

$AI_PROCESSES = @(
    "claude",
    "cursor",
    "n8n",
    "node",
    "python",
    "ollama"
)

function Set-LidDoNothing {
    powercfg /setdcvalueindex SCHEME_CURRENT SUB_BUTTONS LIDACTION 0
    powercfg /setacvalueindex SCHEME_CURRENT SUB_BUTTONS LIDACTION 0
    powercfg /S SCHEME_CURRENT
}

function Set-LidSleep {
    powercfg /setdcvalueindex SCHEME_CURRENT SUB_BUTTONS LIDACTION 1
    powercfg /setacvalueindex SCHEME_CURRENT SUB_BUTTONS LIDACTION 1
    powercfg /S SCHEME_CURRENT
}

function Is-AIAgentRunning {
    foreach ($proc in $AI_PROCESSES) {
        if (Get-Process -Name $proc -ErrorAction SilentlyContinue) {
            return $true
        }
    }
    return $false
}

$previousState = $false

Write-Host "Safeclose is running..." -ForegroundColor Green

while ($true) {
    $isRunning = Is-AIAgentRunning

    if ($isRunning -and -not $previousState) {
        Write-Host "[Safeclose] AI agent detected. Lid-close disabled." -ForegroundColor Yellow
        Set-LidDoNothing
        $previousState = $true
    }
    elseif (-not $isRunning -and $previousState) {
        Write-Host "[Safeclose] No AI agent running. Lid-close restored." -ForegroundColor Cyan
        Set-LidSleep
        $previousState = $false
    }

    Start-Sleep -Seconds 10
}
