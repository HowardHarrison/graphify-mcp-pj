# Verify local Graphify MCP HTTP server against graph/graph.json
$ErrorActionPreference = "Stop"

$Root = Split-Path -Parent $PSScriptRoot
$HostBind = "127.0.0.1"
$Port = 8765
$BaseUrl = "http://${HostBind}:${Port}/mcp"
$TmpDir = Join-Path $Root "mcp\.verify"
New-Item -ItemType Directory -Force -Path $TmpDir | Out-Null

function Invoke-McpRpc {
    param(
        [string]$Body,
        [string]$SessionId = "",
        [string]$OutFile
    )
    $headersFile = Join-Path $TmpDir "headers.txt"
    $args = @(
        "-sS", "-D", $headersFile, "-o", $OutFile,
        "-X", "POST", $BaseUrl,
        "-H", "Content-Type: application/json",
        "-H", "Accept: application/json, text/event-stream"
    )
    if ($SessionId) {
        $args += @("-H", "mcp-session-id: $SessionId")
    }
    $bodyFile = Join-Path $TmpDir "req.json"
[System.IO.File]::WriteAllText($bodyFile, $Body, (New-Object System.Text.UTF8Encoding $false))
$args += @("--data-binary", "@$bodyFile")
    & curl.exe @args
    if ($LASTEXITCODE -ne 0) {
        throw "curl failed with exit code $LASTEXITCODE"
    }
    $headers = Get-Content $headersFile -Raw
    $session = $null
    if ($headers -match "(?im)^mcp-session-id:\s*(\S+)") {
        $session = $Matches[1].Trim()
    }
    $content = Get-Content $OutFile -Raw
    return @{
        Headers = $headers
        SessionId = $session
        Body = $content
    }
}

Write-Host "[INFO] Verifying Graphify MCP at $BaseUrl"

# Port check
$listening = netstat -ano | Select-String ":${Port}\s+.*LISTENING"
if (-not $listening) {
    Write-Host "[ERROR] Nothing listening on ${HostBind}:${Port}"
    Write-Host "[ERROR] Start the server first: powershell -File scripts/start-mcp.ps1"
    exit 1
}

$initBody = '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2024-11-05","capabilities":{},"clientInfo":{"name":"phase3-test","version":"1.0"}}}'
$init = Invoke-McpRpc -Body $initBody -OutFile (Join-Path $TmpDir "init.body")
if (-not $init.SessionId) {
    Write-Host "[ERROR] initialize did not return mcp-session-id"
    Write-Host $init.Body
    exit 1
}
if ($init.Body -notmatch '"name"\s*:\s*"graphify"') {
    Write-Host "[ERROR] initialize response missing graphify serverInfo"
    Write-Host $init.Body
    exit 1
}
Write-Host "[INFO] initialize OK (server=graphify)"

$sid = $init.SessionId
$null = Invoke-McpRpc -Body '{"jsonrpc":"2.0","method":"notifications/initialized"}' -SessionId $sid -OutFile (Join-Path $TmpDir "notify.body")

$tools = Invoke-McpRpc -Body '{"jsonrpc":"2.0","id":2,"method":"tools/list"}' -SessionId $sid -OutFile (Join-Path $TmpDir "tools.body")
$expected = @(
    "query_graph", "get_node", "get_neighbors", "get_community",
    "god_nodes", "graph_stats", "shortest_path",
    "list_prs", "get_pr_impact", "triage_prs"
)
$missing = @()
foreach ($name in $expected) {
    if ($tools.Body -notmatch [regex]::Escape("`"name`":`"$name`"")) {
        # SSE payload uses "name":"tool" order may vary - also check "name": "tool"
        if ($tools.Body -notmatch "`"name`"\s*:\s*`"$name`"") {
            $missing += $name
        }
    }
}
if ($missing.Count -gt 0) {
    Write-Host "[ERROR] Missing tools: $($missing -join ', ')"
    exit 1
}
Write-Host "[INFO] tools/list OK ($($expected.Count) tools)"

$stats = Invoke-McpRpc -Body '{"jsonrpc":"2.0","id":3,"method":"tools/call","params":{"name":"graph_stats","arguments":{}}}' -SessionId $sid -OutFile (Join-Path $TmpDir "stats.body")
if ($stats.Body -notmatch "Nodes:\s*\d+") {
    Write-Host "[ERROR] graph_stats did not return node count"
    Write-Host $stats.Body
    exit 1
}
Write-Host "[INFO] graph_stats OK"
Write-Host $stats.Body

$queryBody = '{"jsonrpc":"2.0","id":4,"method":"tools/call","params":{"name":"query_graph","arguments":{"question":"AuthController authentication flow","depth":2,"token_budget":500}}}'
$query = Invoke-McpRpc -Body $queryBody -SessionId $sid -OutFile (Join-Path $TmpDir "query.body")
if ($query.Body -notmatch "Auth") {
    Write-Host "[WARN] query_graph response did not clearly mention Auth (check graph content)"
    Write-Host $query.Body
} else {
    Write-Host "[INFO] query_graph OK (auth-related nodes found)"
}

Write-Host "[INFO] Graphify MCP verification passed"
exit 0
