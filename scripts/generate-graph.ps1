# Generate Graphify code graph for sample-app into graph/graph.json
$ErrorActionPreference = "Stop"

$Root = Split-Path -Parent $PSScriptRoot
$Source = Join-Path $Root "sample-app"
$OutDir = Join-Path $Root "graph"
$Canonical = Join-Path $OutDir "graph.json"
$ExtractPath = Join-Path $OutDir "graphify-out\graph.json"

Write-Host "[INFO] Generating graph"
Write-Host "[INFO] Source: sample-app/"
Write-Host "[INFO] Output: graph/graph.json"

if (-not (Get-Command graphify -ErrorAction SilentlyContinue)) {
    Write-Host "[ERROR] graphify command not found. Install with: uv tool install graphifyy"
    exit 1
}

if (-not (Test-Path $Source -PathType Container)) {
    Write-Host "[ERROR] Sample application not found at $Source"
    exit 1
}

New-Item -ItemType Directory -Force -Path $OutDir | Out-Null

graphify extract $Source --code-only --out $OutDir
if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERROR] graphify extract failed with exit code $LASTEXITCODE"
    exit $LASTEXITCODE
}

if (-not (Test-Path $ExtractPath)) {
    Write-Host "[ERROR] Graphify did not produce $ExtractPath"
    exit 1
}

Copy-Item -Force $ExtractPath $Canonical

if (-not (Test-Path $Canonical)) {
    Write-Host "[ERROR] Failed to write $Canonical"
    exit 1
}

Write-Host "[INFO] Graph generated successfully"
Write-Host "[INFO] Location: $Canonical"
