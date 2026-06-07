# Graph-First Development Rules

This project uses [graphify](https://github.com/safishamsi/graphify) for codebase intelligence. The knowledge graph at `graphify-out/` is the primary source of truth for code structure, dependencies, and relationships. Always consult it before reading raw files.

## Workspace Action Proof Protocol

Before executing ANY user request related to this codebase:

### 1. Graph First

- Check if `graphify-out/graph.json` exists and is recent
- If missing or stale, the user should run `/graphify . --update` before proceeding
- Prefer `/graphify query "<question>"` over reading multiple files — the graph provides structural context that raw files cannot
- When graph context answers the question, do not re-read source files

### 2. Agent Selection

After receiving graph results, choose the correct approach:

- **Architecture or design questions** → analyse graph communities, cohesion scores, and god nodes from `GRAPH_REPORT.md`
- **Code changes or implementation** → use graph path analysis to find affected files and dependencies
- **Testing or debugging** → use graph relationships to trace call chains and identify impact radius
- **Documentation or summaries** → query the graph for structural overview, then read specific files for details

## Token Efficiency

- Prefer `/graphify query` over reading multiple files — graphify claims a 71.5x token reduction on mixed corpora
- Use `graphify-out/GRAPH_REPORT.md` for god nodes, surprising connections, and community structure
- If `graphify-out/wiki/index.md` exists, navigate it instead of reading raw files
- Use `graphify-out/graph.json` for programmatic queries (BFS/DFS traversal)

## Post-Edit Graph Maintenance

After modifying code files in this session, keep the knowledge graph current by running:

```python
python3 -c "from graphify.watch import _rebuild_code; from pathlib import Path; _rebuild_code(Path('.'))"
```

Or rely on the post-commit git hook (installed via `graphify hook install`) which does this automatically on every commit.

## Graph Outputs Reference

| File | Purpose |
|------|---------|
| `graphify-out/graph.json` | Persistent graph — query without re-reading files |
| `graphify-out/graph.html` | Interactive vis.js visualisation |
| `graphify-out/GRAPH_REPORT.md` | Audit report: god nodes, surprising connections, communities |
| `graphify-out/obsidian/` | Open as Obsidian vault — notes with wikilinks |
| `graphify-out/wiki/` | Agent-crawlable wiki (if built with `--wiki`) |
| `graphify-out/cache/` | SHA256 cache — re-runs only process changed files |
| `graphify-out/memory/` | Q&A results saved from previous queries |

## Available Skills

This project has 20 custom skills installed in `.claude/skills/`. Type `/` in Claude Code to see them all. Key skills:

- `/researcher-pro` — Deep multi-source research & synthesis
- `/security-pro` — Application security reviews (OWASP, web & desktop)
- `/scalability-pro` — Scalable system design
- `/cost-reducer-pro` — Cloud & infrastructure cost optimization
- `/build-premium-website-pro` — Animated marketing sites (React + Vite + Tailwind + GSAP)
- `/new-client-system-pro` — Scaffold full-stack client projects (Next.js + Trigger.dev)
- `/n8n-pro` — n8n workflow automations & custom nodes
- `/composio-pro` — AI agent integrations with third-party apps
- `/know-me-pro` — Cross-session memory (auto-activates)
- `/self-healing-pro` — Self-improvement: pattern recognition & skill creation
- `/create-skill-pro` — Create new Claude Code custom skills
- `/wrapup-pro` — End-of-session summary

See `skills/README.md` for full documentation.
