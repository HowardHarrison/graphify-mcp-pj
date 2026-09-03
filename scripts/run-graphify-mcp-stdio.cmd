@echo off
setlocal EnableExtensions
REM Cursor-friendly stdio launcher for Graphify MCP (Windows-safe paths).

set "ROOT=%~dp0.."
for %%I in ("%ROOT%") do set "ROOT=%%~fI"
set "GRAPH=%ROOT%\graph\graph.json"

if not exist "%GRAPH%" (
  echo [ERROR] Graph file missing: %GRAPH% 1>&2
  exit /b 1
)

set "BIN="
where graphify-mcp >nul 2>&1
if not errorlevel 1 (
  for /f "delims=" %%P in ('where graphify-mcp') do (
    set "BIN=%%P"
    goto :run
  )
)

if exist "%USERPROFILE%\.local\bin\graphify-mcp.exe" (
  set "BIN=%USERPROFILE%\.local\bin\graphify-mcp.exe"
  goto :run
)

echo [ERROR] graphify-mcp not found. Install with: uv tool install "graphifyy[mcp]" 1>&2
exit /b 1

:run
"%BIN%" "%GRAPH%" --transport stdio
exit /b %ERRORLEVEL%
