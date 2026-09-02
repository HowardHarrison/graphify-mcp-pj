# AGENTS.md — Graphify MCP Local Test Environment

## Project Goal

Build and test a local Graphify MCP environment that allows AI coding agents to understand a codebase through a generated code graph instead of repeatedly searching and reading the entire repository.

The project must be designed so that it can later scale from:

```text
Single Developer
      ↓
Local Graphify MCP
      ↓
Cursor
```

to:

```text
Multiple Repositories
      ↓
Graph Generation Pipeline
      ↓
Shared Graphify MCP Server
      ↓
Multiple AI Agents
├── Cursor
├── ChatGPT
└── Other MCP-compatible clients
```

For this phase, everything must run locally.

---

# 1. Primary Objective

Create a local development environment where:

```text
Source Code
    ↓
Graphify
    ↓
graph.json
    ↓
Graphify MCP Server
    ↓
AI Agent
    ↓
Cursor MCP Tools
```

The AI agent should be able to query the code architecture using MCP tools before reading unnecessary source files.

The system should demonstrate that Graphify can help answer questions such as:

* Which service handles authentication?
* What is the request flow from controller to database?
* Which modules depend on a specific service?
* What files are related to a payment feature?
* What is the shortest dependency path between two components?

---

# 2. Important Architecture Rules

## Do Not Replace Application Databases

Graphify is not an application database.

The project must keep this distinction clear:

```text
Application Data

PostgreSQL / MySQL / MongoDB
        ↓
Users
Orders
Payments
Books
```

vs:

```text
AI Code Intelligence

Source Code
        ↓
Graphify
        ↓
graph.json
        ↓
MCP
        ↓
AI Agent
```

`graph.json` is a generated representation of code relationships.

It should not be used as the primary application database.

---

# 3. Target Local Architecture

Build the following structure:

```text
graphify-mcp-test/
│
├── sample-app/
│   │
│   ├── src/
│   │   ├── auth/
│   │   │   ├── auth.controller.*
│   │   │   ├── auth.service.*
│   │   │   └── auth.repository.*
│   │   │
│   │   ├── payment/
│   │   │   ├── payment.controller.*
│   │   │   ├── payment.service.*
│   │   │   └── payment.repository.*
│   │   │
│   │   └── database/
│   │
│   └── ...
│
├── graph/
│   └── graph.json
│
├── mcp/
│   └── configuration files
│
├── scripts/
│   ├── generate-graph.sh
│   ├── update-graph.sh
│   └── test-mcp.sh
│
├── Dockerfile
│
├── docker-compose.yml
│
├── README.md
│
└── AGENTS.md
```

The structure may be improved if necessary, but responsibilities must remain clearly separated.

---

# 4. Development Strategy

Implement the project in phases.

Do not attempt to build everything at once.

Follow this order:

```text
Phase 1
Create Sample Application
        ↓
Phase 2
Generate Code Graph
        ↓
Phase 3
Run Graphify MCP
        ↓
Phase 4
Connect Cursor
        ↓
Phase 5
Test MCP Queries
        ↓
Phase 6
Containerize
        ↓
Phase 7
Prepare for Future Scaling
```

After completing each phase, verify it before continuing.

---

# 5. Phase 1 — Create a Small but Realistic Sample Application

Create a small application with enough architecture to test code relationships.

The sample application should contain:

```text
Auth
│
├── Controller
├── Service
├── Repository
└── Database interaction


Payment
│
├── Controller
├── Service
├── Payment Provider
└── Repository
```

The architecture should demonstrate relationships such as:

```text
HTTP Request
    ↓
Controller
    ↓
Service
    ↓
Repository
    ↓
Database
```

And:

```text
Payment Request
    ↓
PaymentController
    ↓
PaymentService
    ↓
PaymentGateway
    ↓
PaymentRepository
```

Do not create an unnecessarily large application.

The goal is to have enough code to test graph relationships.

---

# 6. Phase 2 — Install and Run Graphify

Install Graphify using the recommended current installation method.

Do not assume package names, commands, or versions.

Verify the current Graphify documentation if installation commands are uncertain.

Generate a graph for:

```text
sample-app/
```

The generated output should be stored in:

```text
graph/
```

The expected output is:

```text
graph/
└── graph.json
```

Before continuing, verify:

```text
graph.json exists
```

Also verify that the graph contains nodes and relationships related to the sample application.

---

# 7. Phase 3 — Start the MCP Server

Start Graphify's MCP server locally.

The server must expose the generated graph to MCP-compatible clients.

Initially prefer a simple local configuration.

The expected architecture is:

```text
graph.json
    ↓
Graphify MCP Server
    ↓
MCP Client
```

Document:

* how to start the MCP server
* how to stop the MCP server
* where the graph file is located
* how to regenerate the graph

Do not expose the MCP server publicly.

This phase is local development only.

---

# 8. Phase 4 — Configure Cursor

Create the appropriate Cursor MCP configuration.

The configuration should connect Cursor to the local Graphify MCP server.

Document where the configuration belongs.

For example, depending on the current Cursor MCP configuration format:

```text
.cursor/
└── mcp.json
```

The agent must verify the current supported Cursor configuration format rather than assuming an outdated format.

The MCP configuration should clearly identify the server:

```text
team-graph-local
```

or:

```text
graphify-local
```

---

# 9. Phase 5 — Test the MCP Tools

Test the MCP integration using architectural questions.

The AI agent should attempt to use Graphify before performing broad file searches.

Test queries should include:

## Test 1 — Authentication Flow

Question:

```text
Trace the authentication request flow from the controller to the database.
```

Expected conceptual result:

```text
AuthController
        ↓
AuthService
        ↓
AuthRepository
        ↓
Database
```

---

## Test 2 — Payment Flow

Question:

```text
Trace the payment processing flow.
```

Expected conceptual result:

```text
PaymentController
        ↓
PaymentService
        ↓
PaymentGateway
        ↓
PaymentRepository
```

---

## Test 3 — Dependency Search

Question:

```text
What components depend on PaymentService?
```

The MCP graph should be used to identify relationships.

---

## Test 4 — Impact Analysis

Question:

```text
If PaymentRepository changes, which components might be affected?
```

The agent should use graph relationships before manually searching all files.

---

## Test 5 — Shortest Path

Test finding the relationship path between:

```text
PaymentController
```

and:

```text
Database
```

Expected conceptual path:

```text
PaymentController
    ↓
PaymentService
    ↓
PaymentRepository
    ↓
Database
```

---

# 10. AI Agent Behaviour Rules

When working on this project, the AI agent must follow this strategy.

## Preferred Investigation Flow

```text
User Request
     ↓
Graphify MCP Query
     ↓
Identify Relevant Components
     ↓
Identify Relevant Files
     ↓
Read Only Necessary Files
     ↓
Implement Changes
```

Avoid this unless necessary:

```text
User Request
     ↓
Read Entire Repository
     ↓
Search Everything
     ↓
Read Many Unrelated Files
```

---

## Rule: Graph First

For questions about:

* architecture
* dependencies
* data flow
* service relationships
* impact analysis
* module relationships

Attempt to query Graphify MCP first.

Examples:

```text
"Where is this service used?"
```

```text
"What is the request flow?"
```

```text
"What depends on this module?"
```

```text
"Which components are affected?"
```

After the graph identifies relevant files, inspect the actual source code.

---

# 11. Source Code Is the Final Authority

Graphify provides an index of the codebase.

The source code remains the source of truth.

If Graphify reports something inconsistent with the source code:

```text
Source Code
    >
Graph Representation
```

When this happens:

1. Verify the source code.
2. Determine whether the graph is outdated.
3. Regenerate the graph.
4. Retry the MCP query.

---

# 12. Graph Update Workflow

Create a script for regenerating the graph.

Example conceptual workflow:

```text
Source Code Changes
       ↓
Run Update Script
       ↓
Graphify Rebuilds Graph
       ↓
graph.json Updated
```

Create a script similar to:

```text
scripts/update-graph.sh
```

The script should:

1. Detect the project root.
2. Run Graphify.
3. Generate or update `graph.json`.
4. Validate that the output exists.
5. Print a useful success/failure message.

Do not silently ignore failures.

---

# 13. Docker Requirements

The project must eventually run through Docker Compose.

Use separate responsibilities.

Conceptual architecture:

```text
Docker Compose
│
├── graphify-mcp
│
└── optional sample-app
```

Do not expose unnecessary ports.

For local development, prefer:

```text
127.0.0.1
```

instead of:

```text
0.0.0.0
```

unless required by the container networking architecture.

Document every exposed port.

---

# 14. Docker Compose Requirements

The final Compose setup should support:

```bash
docker compose up -d --build
```

and:

```bash
docker compose down
```

The graph file should be mounted rather than unnecessarily rebuilding the Docker image every time the graph changes.

Preferred conceptual pattern:

```text
Host
│
└── graph/
      └── graph.json
            │
            ▼
Docker Volume Mount
            │
            ▼
Graphify MCP Container
```

Use read-only mounting where possible.

---

# 15. Health and Verification

Create a verification process.

The following must be tested:

```text
[ ] Sample application exists
[ ] Graph generation succeeds
[ ] graph.json exists
[ ] MCP server starts
[ ] MCP client can connect
[ ] Graphify tools are visible
[ ] Authentication query works
[ ] Payment query works
[ ] Dependency query works
[ ] Graph can be regenerated
[ ] Docker environment starts
```

Do not consider the project complete until all items are tested.

---

# 16. Logging

Use useful logs.

For example:

```text
[INFO] Starting Graphify MCP server
[INFO] Loading graph
[INFO] Graph loaded successfully
[INFO] MCP server ready
```

For graph generation:

```text
[INFO] Generating graph
[INFO] Source: sample-app/
[INFO] Output: graph/graph.json
[INFO] Graph generated successfully
```

Errors must include enough information to debug the problem.

---

# 17. README Requirements

Create a `README.md` containing:

## Project Purpose

Explain why Graphify MCP is being tested.

## Architecture

Include:

```text
Source Code
    ↓
Graphify
    ↓
graph.json
    ↓
MCP Server
    ↓
Cursor
```

## Prerequisites

Document required software.

## Quick Start

Include exact commands.

For example:

```bash
git clone ...
cd graphify-mcp-test
```

Then:

```bash
docker compose up -d --build
```

or the appropriate local setup commands.

## Graph Generation

Explain how to regenerate the graph.

## Cursor Configuration

Explain how to connect Cursor.

## Testing

List the test questions.

## Troubleshooting

Include common issues such as:

* Graphify command not found.
* Graph file missing.
* MCP server does not start.
* Cursor cannot connect.
* Graph is outdated.
* Docker container exits immediately.

---

# 18. Future Scalability

Design the local project so that it can later evolve into:

```text
Repository A ──► graph-a.json
Repository B ──► graph-b.json
Repository C ──► graph-c.json
                       │
                       ▼
                Shared MCP Server
                       │
             ┌─────────┼─────────┐
             ▼         ▼         ▼
           Cursor    ChatGPT   Other AI
```

Do not implement complex multi-repository infrastructure during the first local test unless necessary.

However, avoid hardcoding paths in a way that would make future expansion difficult.

Prefer configuration through environment variables where appropriate.

Example conceptual configuration:

```text
GRAPH_PATH
MCP_PORT
MCP_HOST
```

---

# 19. Security Rules

This is a local test project.

Therefore:

* Do not expose the MCP server publicly.
* Do not store API keys in Git.
* Use `.env.example` instead of committing `.env`.
* Keep the MCP server read-only.
* Do not give the MCP server source-code modification capabilities.
* Do not run containers as root unless required.

---

# 20. Definition of Done

The project is complete only when the following flow works:

```text
Developer changes source code
            ↓
Runs graph update command
            ↓
graph.json is regenerated
            ↓
Graphify MCP loads the graph
            ↓
Cursor connects to MCP
            ↓
AI asks architecture question
            ↓
AI queries Graphify
            ↓
Relevant components identified
            ↓
AI reads only required files
```

The final project must be:

* scalable
* maintainable
* clearly documented
* Docker-ready
* easy for another developer to run
* easy to migrate to a shared MCP server later

---

# Final AI Agent Instructions

Before making significant changes:

1. Inspect the existing project structure.
2. Understand the current implementation.
3. Prefer Graphify MCP for architecture and dependency questions when available.
4. Make small, verifiable changes.
5. Test each phase.
6. Do not introduce unnecessary dependencies.
7. Keep responsibilities separated.
8. Keep configuration external where possible.
9. Update documentation when the setup changes.
10. Do not claim success without verifying the relevant command or test result.

The goal is not simply to start an MCP server.

The goal is to prove that an AI coding agent can use a code graph to navigate and understand a codebase more efficiently than repeatedly scanning the entire repository.
