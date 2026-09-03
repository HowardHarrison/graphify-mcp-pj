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

## Start (stdio — used by Cursor)

```powershell
graphify-mcp .\graph\graph.json --transport stdio
```

Cursor launches this automatically via `.cursor/mcp.json` (you normally do **not** run it manually when using Cursor).

Prefer HTTP (`scripts/start-mcp.ps1`) for manual Phase 3 script checks.

## Cursor configuration (Phase 4)

Project MCP config (committed):

```text
.cursor/mcp.json
```

Server id:

```text
graphify-local
```

Transport: **stdio** (Cursor starts `graphify-mcp` and loads `graph/graph.json`).

Current config shape (see official Cursor MCP docs):

```json
{
  "mcpServers": {
    "graphify-local": {
      "type": "stdio",
      "command": "${userHome}/.local/bin/graphify-mcp.exe",
      "args": [
        "${workspaceFolder}/graph/graph.json",
        "--transport",
        "stdio"
      ]
    }
  }
}
```

On macOS/Linux, change `command` to `"graphify-mcp"` (or `${userHome}/.local/bin/graphify-mcp`) after installing with `uv tool install "graphifyy[mcp]"`.

### Enable in Cursor

1. Ensure `uv tool install "graphifyy[mcp]"` is done and `graphify-mcp` is on your PATH.
2. Open this project in Cursor.
3. Open **Customize → MCPs** (or **Settings → Tools & MCP**) and confirm `graphify-local` is listed and enabled.
4. If the server was just added, reload MCP / restart Cursor.
5. In chat, Graphify tools such as `query_graph`, `graph_stats`, and `shortest_path` should appear under available tools.

### PATH troubleshooting (Windows)

If Cursor shows `graphify-mcp` not found, either:

* Add `C:\Users\<YOU>\.local\bin` to your user PATH and restart Cursor, or
* Change `command` in `.cursor/mcp.json` to the full executable path, for example:

```json
"command": "${userHome}/.local/bin/graphify-mcp.exe"
```

### Optional HTTP config (not default)

If you prefer Cursor to talk to the already-running HTTP server from Phase 3:

```json
{
  "mcpServers": {
    "graphify-local": {
      "url": "http://127.0.0.1:8765/mcp"
    }
  }
}
```

Start that server first with `powershell -File scripts/start-mcp.ps1`.

## Stop

```powershell
powershell -File scripts/stop-mcp.ps1
```

Or press `Ctrl+C` in the terminal that started the HTTP server.

(stdio servers started by Cursor stop when Cursor disconnects them.)

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
