# Workspace Action Proof Protocol — Reference

This document describes the graph-first development rules enforced by the `CLAUDE.md` file that the Antigravity Starter installs into your project. It is a reference guide — the actual rules are in the project's `CLAUDE.md` file.

## Background

Graphify is a Claude Code skill that turns any folder of code, docs, papers, or images into a queryable knowledge graph. It uses tree-sitter for deterministic AST extraction (13 languages, zero LLM cost) and Claude for semantic extraction of documents, papers, and images. The result is a NetworkX graph clustered with the Leiden algorithm, annotated with community labels, cohesion scores, god nodes, and surprising connections.

The knowledge graph is stored in `graphify-out/` and provides:

- **Structural context** — code organisation, dependencies, call chains, import graphs
- **Community detection** — automatic grouping of related files and concepts
- **God nodes** — highest-degree concepts that everything connects through
- **Surprising connections** — cross-domain relationships you wouldn't expect
- **Token efficiency** — 71.5x reduction vs reading the full corpus on mixed corpora of 52+ files

## The Protocol

### Requirement 1: Graph First

Before answering any question about the codebase:

1. Check if `graphify-out/graph.json` exists and is reasonably recent
2. If missing or stale, run `/graphify . --update` (inside Claude Code) to rebuild
3. Run `/graphify query "<user's exact request>"` to get graph-based context
4. Only read raw source files when the graph context is insufficient

### Requirement 2: Context-Based Approach

After receiving graph results, choose the right analysis method:

- **Architecture/design** → analyse `GRAPH_REPORT.md` for communities, cohesion, and god nodes
- **Implementation** → use `/graphify path "A" "B"` for dependency tracing between concepts
- **Debugging** → use graph traversal to trace call chains and identify impact radius
- **Documentation** → use `/graphify explain "X"` for plain-language node descriptions

## How Graphify Actually Works

### Installation

```bash
pip install graphifyy && graphify install
```

- PyPI package name is `graphifyy` (double-y, temporary while reclaiming `graphify`)
- CLI command is `graphify` (single-y)
- `graphify install` copies the skill to `~/.claude/skills/graphify/SKILL.md` and registers it in `~/.claude/CLAUDE.md`
- No authentication required — everything runs locally
- Requires Python 3.10+ and Claude Code

### CLI Commands (run in terminal)

| Command | Purpose |
|---------|---------|
| `graphify install` | Register skill in Claude Code |
| `graphify hook install` | Install post-commit git hook (auto AST rebuild) |
| `graphify hook uninstall` | Remove the git hook |
| `graphify hook status` | Check if hook is installed |
| `graphify benchmark [graph.json]` | Measure token reduction |

### Skill Commands (run inside Claude Code via `/graphify`)

| Command | Purpose |
|---------|---------|
| `/graphify .` | Full pipeline: detect → extract → build → cluster → report → export |
| `/graphify . --no-viz` | Same but skip HTML visualisation |
| `/graphify . --update` | Incremental — only re-extract changed files |
| `/graphify . --deep` | More aggressive INFERRED edge extraction |
| `/graphify . --wiki` | Build agent-crawlable wiki |
| `/graphify query "<q>"` | BFS traversal for broad context |
| `/graphify query "<q>" --dfs` | DFS for tracing specific paths |
| `/graphify path "A" "B"` | Shortest path between two concepts |
| `/graphify explain "X"` | Plain-language explanation of a node |
| `/graphify add <url>` | Fetch URL, save to corpus, update graph |

### Post-Commit Hook

The git hook installed by `graphify hook install` runs on every commit:

1. Detects changed files via `git diff --name-only HEAD~1 HEAD`
2. Filters to code files only (`.py`, `.ts`, `.js`, `.go`, `.rs`, `.java`, `.cpp`, `.c`, `.rb`, `.swift`, `.kt`, `.cs`, `.scala`, `.php`, etc.)
3. Calls `graphify.watch._rebuild_code()` — a full AST rebuild using tree-sitter (no LLM, no cost)
4. If rebuild fails, prints error but exits cleanly (never blocks commits)

### Output Files

```
graphify-out/
├── graph.json           # Persistent graph — query without re-reading
├── graph.html           # Interactive vis.js visualisation
├── GRAPH_REPORT.md      # Audit: god nodes, surprising connections, communities
├── obsidian/            # Open as Obsidian vault
├── wiki/                # Agent-crawlable wiki (--wiki flag)
├── cache/               # SHA256 cache for incremental updates
├── memory/              # Q&A results from previous queries
└── cost.json            # Cumulative token cost tracker
```

## Key Facts

- **No authentication needed** — graphify is fully local, no login, no API keys
- **No server required** — uses NetworkX in-process, no Neo4j needed (optional export)
- **Claude Code only** — the skill commands (`/graphify .`, `/graphify query`) work inside Claude Code, not as CLI commands
- **13 languages supported** — Python, JS/TS, Go, Rust, Java, C, C++, Ruby, C#, Kotlin, Scala, PHP
- **Tree-sitter for code** — deterministic AST extraction, zero LLM cost
- **Claude for docs/papers/images** — semantic extraction cached per-file by SHA256
- **MIT licensed** — https://github.com/safishamsi/graphify

---

**Author**: Bilal Ansari — [ansaribilal.com](https://ansaribilal.com)
**Project**: [antigravity-starter](https://github.com/Bilal140202/antigravity-starter)
