# Graphify generated artifacts

## Files

| File | Audience | Purpose |
|------|----------|---------|
| `graph.json` | AI / MCP | Machine-readable code graph |
| `graph.html` | Humans | Browser-based interactive graph viewer (no server required) |

## View the interactive graph

Open this file in any browser:

```text
graph/graph.html
```

Example (Windows):

```powershell
Start-Process .\graph\graph.html
```

## Regenerate

```powershell
powershell -File scripts/generate-graph.ps1
```

```bash
bash scripts/generate-graph.sh
```

Graphify CLI intermediate files may also appear under `graph/graphify-out/`.
