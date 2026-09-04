#!/usr/bin/env bash
# Generate Graphify code graph into graph/graph.json (+ graph.html viewer)
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOURCE_REL="sample-app"
OUT_REL="graph"

if [[ -f "${ROOT}/.env" ]]; then
  while IFS='=' read -r key value; do
    [[ -z "${key}" || "${key}" =~ ^# ]] && continue
    value="${value%\"}"
    value="${value#\"}"
    case "${key}" in
      SOURCE_PATH) SOURCE_REL="${value#./}" ;;
      GRAPH_OUT_DIR) OUT_REL="${value#./}" ;;
    esac
  done < "${ROOT}/.env"
fi

SOURCE="${ROOT}/${SOURCE_REL}"
OUT_DIR="${ROOT}/${OUT_REL}"
# Allow absolute overrides
[[ "${SOURCE_REL}" = /* || "${SOURCE_REL}" =~ ^[A-Za-z]: ]] && SOURCE="${SOURCE_REL}"
[[ "${OUT_REL}" = /* || "${OUT_REL}" =~ ^[A-Za-z]: ]] && OUT_DIR="${OUT_REL}"

CANONICAL="${OUT_DIR}/graph.json"
VIEWER="${OUT_DIR}/graph.html"
EXTRACT_DIR="${OUT_DIR}/graphify-out/graph.json"

echo "[INFO] Generating graph"
echo "[INFO] Source: ${SOURCE_REL}/"
echo "[INFO] Output: ${OUT_REL}/graph.json"
echo "[INFO] Viewer: ${OUT_REL}/graph.html"

if ! command -v graphify >/dev/null 2>&1; then
  echo "[ERROR] graphify command not found. Install with: uv tool install graphifyy"
  exit 1
fi

if [[ ! -d "${SOURCE}" ]]; then
  echo "[ERROR] Source application not found at ${SOURCE}"
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
echo "[INFO] Open ${OUT_REL}/graph.html in a browser to explore the graph"
