# Graphify MCP Local Test Environment

Local proof that an AI coding agent can understand a codebase through a **code graph** (Graphify) exposed over **MCP**, instead of repeatedly scanning the whole repository.

## Project purpose

```text
Source Code (sample-app)
        ↓
     Graphify
        ↓
 graph.json + graph.html
        ↓
  Graphify MCP Server
        ↓
 Cursor / other MCP clients
```

`graph.json` is AI code intelligence — **not** an application database.

## Architecture

| Layer | Location | Role |
|-------|----------|------|
| Sample app | `sample-app/` | Auth + Payment layered TypeScript demo |
| Graph | `graph/graph.json` | Machine-readable code graph |
| Viewer | `graph/graph.html` | Browser interactive graph for humans |
| MCP docs/config | `mcp/` | Local MCP notes and Phase 5 report |
| Cursor MCP | `.cursor/mcp.json` | `graphify-local` stdio server |
| Docker | `Dockerfile`, `docker-compose.yml` | HTTP MCP on `127.0.0.1:8765` |
| Scaling prep | `docs/SCALING.md`, `graphs/` | Future multi-repo layout (not fully built) |

## Prerequisites

- Windows, macOS, or Linux
- [Docker Desktop](https://www.docker.com/products/docker-desktop/) (Phase 6+)
- [uv](https://docs.astral.sh/uv/) (recommended) or pipx
- Node.js 18+ (optional; only to run the sample app demo)
- Cursor (for IDE MCP integration)

Install Graphify:

```powershell
uv tool install "graphifyy[mcp]"
graphify --help
graphify-mcp --help
```

## Quick start

### 1. Generate the graph

```powershell
powershell -File scripts/generate-graph.ps1
```

Outputs:

- `graph/graph.json`
- `graph/graph.html` (open in a browser)

### 2a. Local HTTP MCP (no Docker)

```powershell
powershell -File scripts/start-mcp.ps1
powershell -File scripts/test-mcp.ps1
```

Stop:

```powershell
powershell -File scripts/stop-mcp.ps1
```

### 2b. Docker MCP

```powershell
docker compose up -d --build
powershell -File scripts/test-mcp.ps1
docker compose down
```

### 3. Cursor

Project config: `.cursor/mcp.json` (server id **`graphify-local`**, stdio).

1. Open this folder in Cursor
2. Customize → MCPs → enable `graphify-local`
3. Reload MCP / restart Cursor if needed

Windows uses `scripts/run-graphify-mcp-stdio.cmd` so path handling stays reliable.

## Graph generation

```powershell
powershell -File scripts/generate-graph.ps1
# or: bash scripts/generate-graph.sh
```

Override paths via root `.env` (from `.env.example`):

- `SOURCE_PATH` (default `./sample-app`)
- `GRAPH_OUT_DIR` (default `./graph`)

After source changes, regenerate before trusting MCP answers. Source code remains the authority if the graph is stale.

## Cursor configuration

| File | Purpose |
|------|---------|
| `.cursor/mcp.json` | Project MCP server `graphify-local` |
| `mcp/README.md` | Start/stop, PATH troubleshooting, Docker HTTP option |

Optional while Docker is running: point Cursor at `http://127.0.0.1:8765/mcp` instead of stdio (see `mcp/README.md`).

## Testing

Basic MCP:

```powershell
powershell -File scripts/test-mcp.ps1
```

Architecture queries (Phase 5):

```powershell
powershell -File scripts/test-mcp-queries.ps1
```

Example questions:

1. Trace authentication from controller to database
2. Trace payment processing flow
3. What depends on PaymentService?
4. If PaymentRepository changes, what is affected?
5. Shortest path between PaymentController and Database

Report: `mcp/PHASE5_TEST_REPORT.md`  
Checklist: `docs/VERIFICATION.md`

## Configuration

Copy `.env.example` → `.env` (optional):

| Variable | Default | Purpose |
|----------|---------|---------|
| `GRAPH_PATH` | `./graph/graph.json` | Active graph for Docker mount |
| `MCP_HOST` / `MCP_PORT` | `127.0.0.1` / `8765` | Local HTTP scripts |
| `MCP_HOST_BIND` / `MCP_HOST_PORT` | `127.0.0.1` / `8765` | Docker host publish |
| `GRAPHIFY_API_KEY` | unset | Optional HTTP auth |

## Exposed ports

| Port | Bind | Service |
|------|------|---------|
| `8765` | `127.0.0.1` only | Graphify MCP HTTP (`/mcp`) |

Do not publish MCP on `0.0.0.0` for local testing.

## Troubleshooting

| Issue | Fix |
|-------|-----|
| `graphify` / `graphify-mcp` not found | `uv tool install "graphifyy[mcp]"` and ensure `~/.local/bin` is on PATH |
| Graph file missing | Run `scripts/generate-graph.ps1` |
| MCP does not start (local) | Check `scripts/start-mcp.ps1` logs under `mcp/.mcp.*.log` |
| Cursor: invalid filename / volume syntax | Use committed Windows `.cmd` launcher in `.cursor/mcp.json` |
| Cursor cannot connect | Toggle MCP off/on; Output → MCP Logs |
| Graph outdated | Regenerate graph; retry queries |
| Docker container exits | `docker compose logs graphify-mcp`; confirm `graph/graph.json` exists |
| Port 8765 busy | `scripts/stop-mcp.ps1` or `docker compose down` |

## Future scaling

Phase 7 prepares multi-repo evolution without implementing the full shared platform yet.

See:

- `docs/SCALING.md`
- `graphs/README.md`

## Security

- Local-only MCP (`127.0.0.1`)
- No secrets in git (use `.env`)
- MCP is read-only over the code graph
- Docker runs as non-root and mounts `graph.json` read-only
