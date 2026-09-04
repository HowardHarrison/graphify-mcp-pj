# Stop local Graphify MCP server started by start-mcp.ps1
$ErrorActionPreference = "Stop"

$Root = Split-Path -Parent $PSScriptRoot
$PidFile = Join-Path $Root "mcp\.mcp.pid"
$Port = 8765

function Read-PortFromEnvFile {
    param([string]$Path, [int]$Current)
    if (-not (Test-Path $Path)) { return $Current }
    Get-Content $Path | ForEach-Object {
        $line = $_.Trim()
        if (-not $line -or $line.StartsWith("#")) { return }
        if ($line.StartsWith("MCP_PORT=") -or $line.StartsWith("MCP_HOST_PORT=")) {
            $val = $line.Split("=", 2)[1].Trim().Trim('"')
            if ($val) { $script:Port = [int]$val }
        }
    }
    return $Port
}

$Port = Read-PortFromEnvFile -Path (Join-Path $Root ".env") -Current $Port
$Port = Read-PortFromEnvFile -Path (Join-Path $Root "mcp\.env") -Current $Port

function Get-ListenerPid {
    param([int]$Port)
    $line = netstat -ano | Select-String ":$Port\s+.*LISTENING" | Select-Object -First 1
    if (-not $line) { return $null }
    if ($line.Line -match "(\d+)\s*$") { return [int]$Matches[1] }
    return $null
}

$targets = @()
if (Test-Path $PidFile) {
    $pidValue = (Get-Content $PidFile | Select-Object -First 1).Trim()
    if ($pidValue) { $targets += [int]$pidValue }
}

$listener = Get-ListenerPid -Port $Port
if ($listener) { $targets += $listener }

# Also stop graphify-mcp launchers
Get-Process graphify-mcp -ErrorAction SilentlyContinue | ForEach-Object { $targets += $_.Id }

$targets = $targets | Select-Object -Unique
if ($targets.Count -eq 0) {
    Remove-Item -Force $PidFile -ErrorAction SilentlyContinue
    Write-Host "[INFO] No Graphify MCP process found; nothing to stop"
    exit 0
}

foreach ($pidValue in $targets) {
    $proc = Get-Process -Id $pidValue -ErrorAction SilentlyContinue
    if ($proc) {
        Write-Host "[INFO] Stopping process pid=$pidValue ($($proc.ProcessName))"
        Stop-Process -Id $pidValue -Force -ErrorAction SilentlyContinue
    }
}

Remove-Item -Force $PidFile -ErrorAction SilentlyContinue
Start-Sleep -Milliseconds 500

if (Get-ListenerPid -Port $Port) {
    Write-Host "[ERROR] Port $Port still listening after stop attempt"
    exit 1
}

Write-Host "[INFO] MCP server stopped"
