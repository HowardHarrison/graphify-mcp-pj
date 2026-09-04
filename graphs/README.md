# Future multi-repository graph storage (Phase 7 prep).
#
# Today this project still uses the single active graph:
#   graph/graph.json
#   graph/graph.html
#
# When scaling to multiple repositories, prefer:
#
#   graphs/
#     sample-app/
#       graph.json
#       graph.html
#     repo-b/
#       graph.json
#     repo-c/
#       graph.json
#
# Then either:
#   1. Point GRAPH_PATH / MCP at one active graph, or
#   2. Merge graphs with Graphify (`graphify merge-graphs` / `graphify global`)
#      and serve a combined graph from a shared MCP server.
#
# Do not move production traffic here until a merge/serve strategy is chosen.
# See docs/SCALING.md.
