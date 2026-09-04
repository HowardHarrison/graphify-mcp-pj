# Verification checklist

Use this list to confirm the local Graphify MCP environment is complete.

## Core

- [ ] Sample application exists under `sample-app/`
- [ ] `uv tool install "graphifyy[mcp]"` succeeds (`graphify` / `graphify-mcp` available)
- [ ] Graph generation succeeds: `powershell -File scripts/generate-graph.ps1`
- [ ] `graph/graph.json` exists
- [ ] `graph/graph.html` exists and opens in a browser

## Local MCP

- [ ] `powershell -File scripts/start-mcp.ps1` starts HTTP MCP on `127.0.0.1:8765`
- [ ] `powershell -File scripts/test-mcp.ps1` passes
- [ ] Graphify tools are visible (10 tools including `query_graph`, `graph_stats`, `shortest_path`)
- [ ] `powershell -File scripts/test-mcp-queries.ps1` passes Phase 5 architecture checks
- [ ] Graph can be regenerated without breaking MCP (restart or hot-reload after update)

## Cursor

- [ ] `.cursor/mcp.json` defines `graphify-local`
- [ ] Cursor MCP shows `graphify-local` connected
- [ ] Agent can call Graphify tools for architecture questions before broad file search

## Docker

- [ ] Docker Desktop is running
- [ ] `docker compose up -d --build` starts `graphify-mcp-local` (healthy)
- [ ] Host endpoint `http://127.0.0.1:8765/mcp` responds
- [ ] `graph/graph.json` is mounted read-only (image rebuild not required after graph regen)
- [ ] `docker compose down` stops cleanly

## Scaling readiness (Phase 7)

- [ ] `.env.example` documents `GRAPH_PATH`, `MCP_*`, and Docker bind vars
- [ ] `docs/SCALING.md` describes the future multi-repo path
- [ ] `graphs/README.md` exists as the future multi-graph layout placeholder
- [ ] Root `README.md` covers purpose, architecture, quick start, troubleshooting

## Security

- [ ] No secrets committed (use `.env`, not git)
- [ ] Host MCP port bound to `127.0.0.1` only
- [ ] MCP remains read-only over the code graph
