# Generate Graphify code graph for sample-app into graph/graph.json
# and a browser-based interactive viewer at graph/graph.html
$ErrorActionPreference = "Stop"

$Root = Split-Path -Parent $PSScriptRoot
$RootEnvFile = Join-Path $Root ".env"

function Read-DotEnv {
    param([string]$Path)
    $map = @{}
    if (-not (Test-Path $Path)) { return $map }
    Get-Content $Path | ForEach-Object {
        $line = $_.Trim()
        if (-not $line -or $line.StartsWith("#")) { return }
        $parts = $line.Split("=", 2)
        if ($parts.Count -eq 2) {
            $map[$parts[0].Trim()] = $parts[1].Trim().Trim('"')
        }
    }
    return $map
}

$envMap = Read-DotEnv -Path $RootEnvFile
$SourceRel = if ($envMap["SOURCE_PATH"]) { $envMap["SOURCE_PATH"] -replace '^\./', '' } else { "sample-app" }
$OutRel = if ($envMap["GRAPH_OUT_DIR"]) { $envMap["GRAPH_OUT_DIR"] -replace '^\./', '' } else { "graph" }

$Source = if ([System.IO.Path]::IsPathRooted($SourceRel)) { $SourceRel } else { Join-Path $Root $SourceRel }
$OutDir = if ([System.IO.Path]::IsPathRooted($OutRel)) { $OutRel } else { Join-Path $Root $OutRel }
$Canonical = Join-Path $OutDir "graph.json"
$Viewer = Join-Path $OutDir "graph.html"
$ExtractPath = Join-Path $OutDir "graphify-out\graph.json"

Write-Host "[INFO] Generating graph"
Write-Host "[INFO] Source: $SourceRel/"
Write-Host "[INFO] Output: $OutRel/graph.json"
Write-Host "[INFO] Viewer: $OutRel/graph.html"

if (-not (Get-Command graphify -ErrorAction SilentlyContinue)) {
    Write-Host "[ERROR] graphify command not found. Install with: uv tool install graphifyy"
    exit 1
}

if (-not (Test-Path $Source -PathType Container)) {
    Write-Host "[ERROR] Source application not found at $Source"
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

Push-Location $OutDir
try {
    graphify export html --graph $Canonical
    if ($LASTEXITCODE -ne 0) {
        Write-Host "[ERROR] graphify export html failed with exit code $LASTEXITCODE"
        exit $LASTEXITCODE
    }
}
finally {
    Pop-Location
}

if (-not (Test-Path $Viewer)) {
    Write-Host "[ERROR] Failed to write $Viewer"
    exit 1
}

Write-Host "[INFO] Graph generated successfully"
Write-Host "[INFO] Location: $Canonical"
Write-Host "[INFO] Viewer: $Viewer"
Write-Host "[INFO] Open graph/graph.html in a browser to explore the graph"
