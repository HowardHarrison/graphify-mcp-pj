#!/usr/bin/env bash
# Generate Graphify code graph for sample-app into graph/graph.json
# and a browser-based interactive viewer at graph/graph.html
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOURCE="${ROOT}/sample-app"
OUT_DIR="${ROOT}/graph"
CANONICAL="${OUT_DIR}/graph.json"
VIEWER="${OUT_DIR}/graph.html"
EXTRACT_DIR="${OUT_DIR}/graphify-out/graph.json"

echo "[INFO] Generating graph"
echo "[INFO] Source: sample-app/"
echo "[INFO] Output: graph/graph.json"
echo "[INFO] Viewer: graph/graph.html"

if ! command -v graphify >/dev/null 2>&1; then
  echo "[ERROR] graphify command not found. Install with: uv tool install graphifyy"
  exit 1
fi

if [[ ! -d "${SOURCE}" ]]; then
  echo "[ERROR] Sample application not found at ${SOURCE}"
  exit 1
fi

mkdir -p "${OUT_DIR}"

graphify extract "${SOURCE}" --code-only --out "${OUT_DIR}"

if [[ ! -f "${EXTRACT_DIR}" ]]; then
  echo "[ERROR] Graphify did not produce ${EXTRACT_DIR}"
  exit 1
fi

cp "${EXTRACT_DIR}" "${CANONICAL}"

if [[ ! -f "${CANONICAL}" ]]; then
  echo "[ERROR] Failed to write ${CANONICAL}"
  exit 1
fi

(
  cd "${OUT_DIR}"
  graphify export html --graph "${CANONICAL}"
)

if [[ ! -f "${VIEWER}" ]]; then
  echo "[ERROR] Failed to write ${VIEWER}"
  exit 1
fi

echo "[INFO] Graph generated successfully"
echo "[INFO] Location: ${CANONICAL}"
echo "[INFO] Viewer: ${VIEWER}"
echo "[INFO] Open graph/graph.html in a browser to explore the graph"
