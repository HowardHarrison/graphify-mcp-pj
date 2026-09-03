# Graphify MCP — Local Server

Local-only Graphify MCP server for this project. Do **not** expose it publicly.

## Architecture

```text
graph/graph.json
        ↓
Graphify MCP Server (stdio or HTTP on 127.0.0.1)
        ↓
MCP Client (Cursor / scripts)
```

## Graph location

| Artifact | Path |
|----------|------|
| Machine-readable graph | `graph/graph.json` |
| Human interactive viewer | `graph/graph.html` |

Regenerate both with:

```powershell
powershell -File scripts/generate-graph.ps1
```

## Prerequisites

```powershell
uv tool install "graphifyy[mcp]"
```

Confirm:

```powershell
graphify-mcp --help
```

## Configuration

Copy `.env.example` to `.env` (optional). Defaults are local-only:

| Variable | Default | Purpose |
|----------|---------|---------|
| `GRAPH_PATH` | `graph/graph.json` | Path to graph JSON |
| `MCP_HOST` | `127.0.0.1` | HTTP bind host (local only) |
| `MCP_PORT` | `8765` | HTTP bind port |
| `MCP_PATH` | `/mcp` | HTTP mount path |

## Start (HTTP — easy to verify)

```powershell
powershell -File scripts/start-mcp.ps1
```

Or manually:

```powershell
graphify-mcp .\graph\graph.json --transport http --host 127.0.0.1 --port 8765
```

Expected log lines:

```text
[INFO] Starting Graphify MCP server
[INFO] Loading graph
[INFO] Graph loaded successfully
[INFO] MCP server ready
```

(Exact Graphify CLI wording may differ; the process must stay running and bind to `127.0.0.1:8765`.)

## Start (stdio — for Cursor later)

```powershell
graphify-mcp .\graph\graph.json --transport stdio
```

stdio is used by MCP clients that spawn the process. Prefer HTTP for manual Phase 3 checks.

## Stop

```powershell
powershell -File scripts/stop-mcp.ps1
```

Or press `Ctrl+C` in the terminal that started the server.

## Verify

```powershell
powershell -File scripts/test-mcp.ps1
```

This checks that the HTTP MCP endpoint responds and Graphify tools are available against `graph/graph.json`.

Expected verification highlights:

* `initialize` returns `serverInfo.name = graphify`
* `tools/list` exposes 10 tools (`query_graph`, `get_node`, `get_neighbors`, `get_community`, `god_nodes`, `graph_stats`, `shortest_path`, `list_prs`, `get_pr_impact`, `triage_prs`)
* `graph_stats` reports nodes/edges from `graph/graph.json`

## Security

- Bind to `127.0.0.1` only
- Do not use `0.0.0.0` for local testing
- Do not commit secrets
- MCP server is read-only over the code graph
