#!/usr/bin/env bash
# Stop local Graphify MCP server started by start-mcp.sh
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PID_FILE="${ROOT}/mcp/.mcp.pid"

if [[ ! -f "${PID_FILE}" ]]; then
  echo "[INFO] No PID file found; nothing to stop"
  exit 0
fi

pid="$(cat "${PID_FILE}" | head -n 1 | tr -d '[:space:]')"
if [[ -z "${pid}" ]]; then
  rm -f "${PID_FILE}"
  echo "[INFO] Empty PID file removed"
  exit 0
fi

if ! kill -0 "${pid}" 2>/dev/null; then
  rm -f "${PID_FILE}"
  echo "[INFO] Process ${pid} not running; cleaned PID file"
  exit 0
fi

echo "[INFO] Stopping Graphify MCP server (pid=${pid})"
kill "${pid}" 2>/dev/null || kill -9 "${pid}"
rm -f "${PID_FILE}"
echo "[INFO] MCP server stopped"
