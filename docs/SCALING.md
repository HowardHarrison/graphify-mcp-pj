# Scaling readiness (Phase 7)

This project proves a **single-repo local Graphify MCP** loop. Phase 7 prepares the layout and configuration so a shared multi-repo MCP can be added later without rewriting the local workflow.

## Current (local single developer)

```text
sample-app/  ──extract──►  graph/graph.json (+ graph.html)
                                │
                    ┌───────────┼───────────┐
                    ▼                       ▼
            Cursor stdio MCP          Docker HTTP MCP
            (.cursor/mcp.json)        (127.0.0.1:8765/mcp)
```

## Target (future shared MCP)

```text
Repository A ──► graphs/a/graph.json ──┐
Repository B ──► graphs/b/graph.json ──┼──► merge / select ──► Shared MCP
Repository C ──► graphs/c/graph.json ──┘         │
                                       ┌─────────┼─────────┐
                                       ▼         ▼         ▼
                                     Cursor   ChatGPT   Other MCP clients
```

## Configuration contract

Prefer environment variables (see `.env.example`):

| Variable | Role |
|----------|------|
| `GRAPH_PATH` | Active graph JSON for serve/mount |
| `SOURCE_PATH` | Source tree for extract |
| `GRAPH_OUT_DIR` | Output directory for extract/viewer |
| `MCP_HOST` / `MCP_PORT` | Local HTTP bind (scripts) |
| `MCP_HOST_BIND` / `MCP_HOST_PORT` | Docker host publish |
| `MCP_CONTAINER_HOST` / `MCP_CONTAINER_PORT` | In-container listen |
| `GRAPHIFY_API_KEY` | Optional HTTP auth for shared deployments |

## What is intentionally not built yet

- Multi-repo CI graph pipelines
- Automatic merge of many graphs into one served index
- Cloud-hosted shared MCP
- Neo4j / FalkorDB backends
- Multi-tenant auth beyond optional API key

## Recommended next evolution steps

1. Generate per-repo graphs into `graphs/<repo-id>/`.
2. Choose serve mode: one graph at a time via `GRAPH_PATH`, or merged graph via Graphify merge/global tools.
3. Run one Docker HTTP MCP for the team; keep stdio for solo Cursor work.
4. Require `GRAPHIFY_API_KEY` when the MCP leaves pure loopback access.
5. Point additional MCP clients at the same HTTP URL.

## Compatibility rules

- Keep `graph/graph.json` as the default active graph for this test project.
- Keep MCP read-only over graphs (no source modification tools).
- Keep host publishes on `127.0.0.1` for local work.
- Avoid baking `graph.json` into Docker images.
