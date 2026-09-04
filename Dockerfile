# Graphify MCP HTTP server for local Docker Compose testing.
# Graph data is mounted at runtime — never baked into the image.
#
# Build:  docker compose build
# Run:    docker compose up -d --build
FROM python:3.12-slim

WORKDIR /app

# Official PyPI package is graphifyy (double-y); CLI/module name is graphify.
RUN pip install --no-cache-dir "graphifyy[mcp]==0.9.53" \
    && useradd --create-home --uid 10001 graphify \
    && mkdir -p /data \
    && chown graphify:graphify /data

USER graphify

# Container must listen on 0.0.0.0 so Docker port publishing works.
# Host bind stays on 127.0.0.1 via docker-compose ports mapping.
EXPOSE 8080

ENTRYPOINT ["python", "-m", "graphify.serve"]
CMD ["/data/graph.json", "--transport", "http", "--host", "0.0.0.0", "--port", "8080"]
