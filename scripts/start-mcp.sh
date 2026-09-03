#!/usr/bin/env bash
# Start local Graphify MCP server over HTTP (127.0.0.1 only).
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_FILE="${ROOT}/mcp/.env"
DEFAULT_GRAPH="${ROOT}/graph/graph.json"
PID_FILE="${ROOT}/mcp/.mcp.pid"
LOG_FILE="${ROOT}/mcp/.mcp.log"

GRAPH_PATH="${DEFAULT_GRAPH}"
MCP_HOST="127.0.0.1"
MCP_PORT="8765"

if [[ -f "${ENV_FILE}" ]]; then
  # shellcheck disable=SC1090
  set -a
  # Only simple KEY=VALUE lines
  while IFS='=' read -r key value; do
    [[ -z "${key}" || "${key}" =~ ^# ]] && continue
    case "${key}" in
      GRAPH_PATH) GRAPH_PATH="${value}" ;;
      MCP_HOST) MCP_HOST="${value}" ;;
      MCP_PORT) MCP_PORT="${value}" ;;
    esac
  done < "${ENV_FILE}"
  set +a
fi

if [[ "${GRAPH_PATH}" != /* && "${GRAPH_PATH}" != [A-Za-z]:* ]]; then
  GRAPH_PATH="${ROOT}/${GRAPH_PATH}"
fi

if [[ "${MCP_HOST}" != "127.0.0.1" && "${MCP_HOST}" != "localhost" ]]; then
  echo "[ERROR] Refusing non-local bind host '${MCP_HOST}'. Use 127.0.0.1 for Phase 3."
  exit 1
fi

if ! command -v graphify-mcp >/dev/null 2>&1; then
  echo "[ERROR] graphify-mcp not found. Install with: uv tool install \"graphifyy[mcp]\""
  exit 1
fi

if [[ ! -f "${GRAPH_PATH}" ]]; then
  echo "[ERROR] Graph file missing: ${GRAPH_PATH}"
  echo "[ERROR] Run: bash scripts/generate-graph.sh"
  exit 1
fi

if [[ -f "${PID_FILE}" ]]; then
  existing="$(cat "${PID_FILE}" | head -n 1)"
  if [[ -n "${existing}" ]] && kill -0 "${existing}" 2>/dev/null; then
    echo "[INFO] Graphify MCP already running (pid=${existing})"
    echo "[INFO] Endpoint: http://${MCP_HOST}:${MCP_PORT}/mcp"
    exit 0
  fi
  rm -f "${PID_FILE}"
fi

echo "[INFO] Starting Graphify MCP server"
echo "[INFO] Loading graph"
echo "[INFO] Graph: ${GRAPH_PATH}"
echo "[INFO] Bind: ${MCP_HOST}:${MCP_PORT}"

nohup graphify-mcp "${GRAPH_PATH}" --transport http --host "${MCP_HOST}" --port "${MCP_PORT}" \
  >"${LOG_FILE}" 2>&1 &
echo $! >"${PID_FILE}"

sleep 2

if ! kill -0 "$(cat "${PID_FILE}")" 2>/dev/null; then
  echo "[ERROR] MCP server exited immediately. Log:"
  cat "${LOG_FILE}" || true
  rm -f "${PID_FILE}"
  exit 1
fi

echo "[INFO] Graph loaded successfully"
echo "[INFO] MCP server ready"
echo "[INFO] PID: $(cat "${PID_FILE}")"
echo "[INFO] Endpoint: http://${MCP_HOST}:${MCP_PORT}/mcp"
echo "[INFO] Stop with: bash scripts/stop-mcp.sh"
echo "[INFO] Log: ${LOG_FILE}"
