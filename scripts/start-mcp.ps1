# Start local Graphify MCP server over HTTP (127.0.0.1 only).
$ErrorActionPreference = "Stop"

$Root = Split-Path -Parent $PSScriptRoot
$EnvFile = Join-Path $Root "mcp\.env"
$DefaultGraph = Join-Path $Root "graph\graph.json"
$PidFile = Join-Path $Root "mcp\.mcp.pid"
$OutLog = Join-Path $Root "mcp\.mcp.out.log"
$ErrLog = Join-Path $Root "mcp\.mcp.err.log"

function Read-DotEnv {
    param([string]$Path)
    $map = @{}
    if (-not (Test-Path $Path)) { return $map }
    Get-Content $Path | ForEach-Object {
        $line = $_.Trim()
        if (-not $line -or $line.StartsWith("#")) { return }
        $parts = $line.Split("=", 2)
        if ($parts.Count -eq 2) {
            $map[$parts[0].Trim()] = $parts[1].Trim()
        }
    }
    return $map
}

function Get-ListenerPid {
    param([int]$Port)
    $line = netstat -ano | Select-String ":$Port\s+.*LISTENING" | Select-Object -First 1
    if (-not $line) { return $null }
    if ($line.Line -match "(\d+)\s*$") { return [int]$Matches[1] }
    return $null
}

$envMap = Read-DotEnv -Path $EnvFile
$GraphPath = if ($envMap["GRAPH_PATH"]) { $envMap["GRAPH_PATH"] } else { $DefaultGraph }
if (-not [System.IO.Path]::IsPathRooted($GraphPath)) {
    $GraphPath = Join-Path $Root $GraphPath
}
$HostBind = if ($envMap["MCP_HOST"]) { $envMap["MCP_HOST"] } else { "127.0.0.1" }
$Port = if ($envMap["MCP_PORT"]) { [int]$envMap["MCP_PORT"] } else { 8765 }

if ($HostBind -ne "127.0.0.1" -and $HostBind -ne "localhost") {
    Write-Host "[ERROR] Refusing non-local bind host '$HostBind'. Use 127.0.0.1 for Phase 3."
    exit 1
}

$graphifyCmd = Get-Command graphify-mcp -ErrorAction SilentlyContinue
if (-not $graphifyCmd) {
    $fallback = Join-Path $env:USERPROFILE ".local\bin\graphify-mcp.exe"
    if (Test-Path $fallback) {
        $graphifyExe = $fallback
    } else {
        Write-Host "[ERROR] graphify-mcp not found. Install with: uv tool install `"graphifyy[mcp]`""
        exit 1
    }
} else {
    $graphifyExe = $graphifyCmd.Source
}

if (-not (Test-Path $GraphPath)) {
    Write-Host "[ERROR] Graph file missing: $GraphPath"
    Write-Host "[ERROR] Run: powershell -File scripts/generate-graph.ps1"
    exit 1
}

$existingListener = Get-ListenerPid -Port $Port
if ($existingListener) {
    Write-Host "[INFO] Graphify MCP already listening on ${HostBind}:${Port} (pid=$existingListener)"
    Write-Host "[INFO] Endpoint: http://${HostBind}:${Port}/mcp"
    Set-Content -Path $PidFile -Value $existingListener -Encoding ascii
    exit 0
}

Write-Host "[INFO] Starting Graphify MCP server"
Write-Host "[INFO] Loading graph"
Write-Host "[INFO] Graph: $GraphPath"
Write-Host "[INFO] Executable: $graphifyExe"
Write-Host "[INFO] Bind: ${HostBind}:${Port}"

$argList = @(
    $GraphPath,
    "--transport", "http",
    "--host", $HostBind,
    "--port", "$Port"
)

Remove-Item -Force $OutLog, $ErrLog -ErrorAction SilentlyContinue

$proc = Start-Process -FilePath $graphifyExe `
    -ArgumentList $argList `
    -WorkingDirectory $Root `
    -RedirectStandardOutput $OutLog `
    -RedirectStandardError $ErrLog `
    -PassThru `
    -WindowStyle Hidden

# Wait for the HTTP listener (child process may own the port)
$listenerPid = $null
for ($i = 0; $i -lt 20; $i++) {
    Start-Sleep -Milliseconds 500
    $listenerPid = Get-ListenerPid -Port $Port
    if ($listenerPid) { break }
    if (-not (Get-Process -Id $proc.Id -ErrorAction SilentlyContinue)) { break }
}

if (-not $listenerPid) {
    Write-Host "[ERROR] MCP server did not start listening on port $Port"
    if (Test-Path $OutLog) { Write-Host "--- stdout ---"; Get-Content $OutLog }
    if (Test-Path $ErrLog) { Write-Host "--- stderr ---"; Get-Content $ErrLog }
    Stop-Process -Id $proc.Id -Force -ErrorAction SilentlyContinue
    Get-Process graphify-mcp -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
    exit 1
}

Set-Content -Path $PidFile -Value $listenerPid -Encoding ascii

Write-Host "[INFO] Graph loaded successfully"
Write-Host "[INFO] MCP server ready"
Write-Host "[INFO] PID: $listenerPid (launcher=$($proc.Id))"
Write-Host "[INFO] Endpoint: http://${HostBind}:${Port}/mcp"
Write-Host "[INFO] Stop with: powershell -File scripts/stop-mcp.ps1"
Write-Host "[INFO] Logs: $OutLog / $ErrLog"
