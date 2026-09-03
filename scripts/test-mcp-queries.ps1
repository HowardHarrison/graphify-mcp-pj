# Run Phase 5 Graphify architecture query checks via HTTP MCP (optional offline verify).
# Requires: powershell -File scripts/start-mcp.ps1
$ErrorActionPreference = "Stop"

$Root = Split-Path -Parent $PSScriptRoot
$BaseUrl = "http://127.0.0.1:8765/mcp"
$TmpDir = Join-Path $Root "mcp\.verify-phase5"
New-Item -ItemType Directory -Force -Path $TmpDir | Out-Null

function Invoke-McpRpc {
    param([string]$Body, [string]$SessionId = "", [string]$OutFile)
    $headersFile = Join-Path $TmpDir "headers.txt"
    $bodyFile = Join-Path $TmpDir "req.json"
    [System.IO.File]::WriteAllText($bodyFile, $Body, (New-Object System.Text.UTF8Encoding $false))
    $curlArgs = @(
        "-sS", "-D", $headersFile, "-o", $OutFile,
        "-X", "POST", $BaseUrl,
        "-H", "Content-Type: application/json",
        "-H", "Accept: application/json, text/event-stream"
    )
    if ($SessionId) { $curlArgs += @("-H", "mcp-session-id: $SessionId") }
    $curlArgs += @("--data-binary", "@$bodyFile")
    & curl.exe @curlArgs
    if ($LASTEXITCODE -ne 0) { throw "curl failed: $LASTEXITCODE" }
    $headers = Get-Content $headersFile -Raw
    $session = $null
    if ($headers -match "(?im)^mcp-session-id:\s*(\S+)") { $session = $Matches[1].Trim() }
    return @{ SessionId = $session; Body = (Get-Content $OutFile -Raw) }
}

Write-Host "[INFO] Phase 5 query checks against $BaseUrl"

$init = Invoke-McpRpc -Body '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2024-11-05","capabilities":{},"clientInfo":{"name":"phase5","version":"1.0"}}}' -OutFile (Join-Path $TmpDir "init.body")
$sid = $init.SessionId
$null = Invoke-McpRpc -Body '{"jsonrpc":"2.0","method":"notifications/initialized"}' -SessionId $sid -OutFile (Join-Path $TmpDir "notify.body")

$tests = @(
    @{ Name = "T1 auth flow"; Body = '{"jsonrpc":"2.0","id":10,"method":"tools/call","params":{"name":"query_graph","arguments":{"question":"Trace authentication from AuthController to Database","mode":"dfs","depth":4,"token_budget":2000}}}'; Expect = "AuthController" },
    @{ Name = "T2 payment flow"; Body = '{"jsonrpc":"2.0","id":11,"method":"tools/call","params":{"name":"query_graph","arguments":{"question":"Trace payment PaymentController PaymentService PaymentGateway","mode":"dfs","depth":4,"token_budget":2000}}}'; Expect = "PaymentGateway" },
    @{ Name = "T3 PaymentService neighbors"; Body = '{"jsonrpc":"2.0","id":12,"method":"tools/call","params":{"name":"get_neighbors","arguments":{"label":"src_payment_payment_service_paymentservice","token_budget":2000}}}'; Expect = "payment.controller.ts" },
    @{ Name = "T4 PaymentRepository impact"; Body = '{"jsonrpc":"2.0","id":13,"method":"tools/call","params":{"name":"get_neighbors","arguments":{"label":"src_payment_payment_repository_paymentrepository","token_budget":2000}}}'; Expect = "payment.service.ts" },
    @{ Name = "T5 shortest path"; Body = '{"jsonrpc":"2.0","id":14,"method":"tools/call","params":{"name":"shortest_path","arguments":{"source":"PaymentController","target":"Database","undirected":true,"max_hops":8}}}'; Expect = "Database" }
)

$failed = 0
foreach ($t in $tests) {
    $res = Invoke-McpRpc -Body $t.Body -SessionId $sid -OutFile (Join-Path $TmpDir (($t.Name -replace '\s','_') + ".body"))
    if ($res.Body -match [regex]::Escape($t.Expect)) {
        Write-Host ('[PASS] {0}' -f $t.Name)
    } else {
        Write-Host ('[FAIL] {0} - expected to mention {1}' -f $t.Name, $t.Expect)
        Write-Host $res.Body
        $failed++
    }
}

if ($failed -gt 0) {
    Write-Host ('[ERROR] {0} Phase 5 check(s) failed' -f $failed)
    exit 1
}

Write-Host '[INFO] Phase 5 query checks passed'
Write-Host '[INFO] Full narrative report: mcp/PHASE5_TEST_REPORT.md'
exit 0
