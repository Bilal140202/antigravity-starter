# antigravity-starter

> **One-command graph-first workspace bootstrapper for Claude Code**
>
> Created by [Bilal Ansari](https://ansaribilal.com)

Run one command and get a graph-first, rules-enforced development environment powered by [graphify](https://github.com/safishamsi/graphify) — a Claude Code skill that turns any codebase into a queryable knowledge graph. No more reading files one-by-one to understand structure. The graph knows.

## What This Actually Does

Graphify is a **Claude Code skill** that reads your code, docs, and papers, builds a knowledge graph using tree-sitter AST extraction (13 languages) and Claude for semantic analysis, then lets you query it with `/graphify query`. It runs **100% locally** — no server, no authentication, no API keys.

This starter kit automates the entire setup:

1. Installs `graphifyy` (the Python package — note double-y on pip, single-y on CLI)
2. Registers the Claude Code skill via `graphify install`
3. Installs a post-commit git hook for automatic graph rebuilds
4. Sets up project-level `CLAUDE.md` with graph-first rules
5. Installs 20 PRO skills (v2.0 with graphify-first protocol, decision trees, autonomy matrices, failure recovery, verification checklists) (e.g., `/wrapup`, `/researcher`, `/security`, `/build-premium-website`, and more)

## Quick Start

### Windows (PowerShell)

```powershell
iwr https://raw.githubusercontent.com/Bilal140202/antigravity-starter/main/install.ps1 | iex
```

### macOS / Linux

```bash
curl -fsSL https://raw.githubusercontent.com/Bilal140202/antigravity-starter/main/install.sh | bash
```

### From a cloned repository

```bash
git clone https://github.com/Bilal140202/antigravity-starter.git
cd antigravity-starter

# Windows
.\install.ps1

# macOS / Linux
bash install.sh
```

## Prerequisites

| Requirement | Why |
|-------------|-----|
| **Python 3.10+** | graphifyy uses `match/case` and modern syntax |
| **Claude Code** | The `/graphify` skill command runs inside Claude Code |
| **pip or uv** | For installing the `graphifyy` package |

> **No authentication needed.** Graphify runs entirely locally. No login, no OAuth, no API keys.

## What Gets Installed

| Component | Source | Destination |
|-----------|--------|-------------|
| **graphifyy** | PyPI (`pip install graphifyy`) | Global Python tool |
| **Claude Code skill** | `graphify install` | `~/.claude/skills/graphify/SKILL.md` |
| **Skill registration** | `graphify install` | `~/.claude/CLAUDE.md` |
| **Post-commit hook** | `graphify hook install` | `.git/hooks/post-commit` |
| **Project rules** | This repo's `CLAUDE.md` | `./CLAUDE.md` in your project |
| **Custom skills** | This repo's `skills/` | `./.claude/skills/` |

## After Installation

Open Claude Code in your project directory and run:

```
/graphify . --no-viz
```

This builds the initial knowledge graph. The `--no-viz` flag skips the HTML visualisation (faster). After that:

```
/graphify query "test"        # Query the codebase
/graphify query "how does auth work?"   # Get context from the graph
/graphify path "UserModel" "Database"   # Trace dependencies
/graphify explain "main"               # Understand a specific node
```

> **Important**: `/graphify .` and `/graphify query` are **Claude Code skill commands**, not terminal CLI commands. They only work inside Claude Code after the skill is registered. The CLI only supports `graphify install`, `graphify hook install`, and `graphify benchmark`.

## Graph-First Rules

After installation, your project's `CLAUDE.md` contains rules that tell Claude to:

1. **Check the graph first** — consult `graphify-out/GRAPH_REPORT.md` before reading raw files
2. **Query, don't read** — use `/graphify query` instead of opening multiple files
3. **Keep the graph current** — run AST rebuild after code changes (or rely on the git hook)

See [`RULES.md`](./RULES.md) for the full reference documentation.

## Output Files

After running `/graphify .`, these files appear in `graphify-out/`:

| File | Purpose |
|------|---------|
| `graph.json` | Persistent graph data — query without re-reading files |
| `graph.html` | Interactive vis.js visualisation (click nodes, search, filter) |
| `GRAPH_REPORT.md` | Audit report: god nodes, surprising connections, communities |
| `obsidian/` | Open as an Obsidian vault with wikilinks and Canvas layout |
| `wiki/index.md` | Agent-crawlable wiki (with `--wiki` flag) |
| `cache/` | SHA256 cache — only changed files are re-processed |
| `memory/` | Q&A results from previous queries (fed back on `--update`) |

## How the Post-Commit Hook Works

The git hook installed by `graphify hook install` runs automatically on every commit:

1. Detects changed files via `git diff`
2. Filters to code files only (`.py`, `.ts`, `.js`, `.go`, `.rs`, `.java`, `.cpp`, `.c`, `.rb`, `.kt`, `.cs`, `.scala`, `.php`)
3. Runs a full AST rebuild using tree-sitter — **no LLM needed, zero cost**
4. If rebuild fails, prints an error but never blocks the commit

## Custom Skills

20 PRO skills (v2.0) installed alongside graphify. Each skill has graphify-first protocol, decision trees, autonomy matrices, failure modes, and verification checklists.

| Command | Purpose |
|---------|---------|
| `/albert-dm-pro` | Reply to DMs in Albert's voice |
| `/build-premium-website-pro` | Build animated marketing sites (React + Vite + Tailwind + GSAP) |
| `/composio-pro` | AI agent integrations with third-party apps |
| `/cost-reducer-pro` | Cloud & infrastructure cost optimization |
| `/create-skill-pro` | Create new Claude Code custom skills |
| `/customer-support-pro` | Customer support responses & workflows |
| `/frontend-design-pro` | Production-grade frontend interfaces |
| `/instantly-campaign-pro` | Cold email campaign creator (Instantly) |
| `/know-me-pro` | Cross-session memory (auto-activates) |
| `/n8n-pro` | n8n workflow automations & custom nodes |
| `/new-client-system-pro` | Scaffold full-stack client projects (Next.js + Trigger.dev) |
| `/researcher-pro` | Deep multi-source research & synthesis |
| `/scalability-pro` | Scalable system design & optimization |
| `/security-pro` | Application security (OWASP, web & desktop) |
| `/self-healing-pro` | Self-improvement: pattern recognition & skill creation |
| `/setup-codex-precheck-pro` | Install codex pre-edit review hook |
| `/trigger-dev-pro` | Trigger.dev background jobs & automations |
| `/upwork` | Upwork profile optimization |
| `/upwork-proposal-pro` | Upwork proposal writer |
| `/wrapup-pro` | End-of-session summary saved to `.claude/memory/` |

See [`skills/README.md`](./skills/README.md) for full documentation and how to create your own skills.

## How to Update

Re-run the install script. It is **idempotent** — safe to run multiple times. Existing tools are upgraded, rules are merged, and skills are re-copied.

```powershell
# Windows
.\install.ps1

# macOS / Linux
bash install.sh
```

## Troubleshooting

### `graphify: command not found`

**Cause**: The `graphifyy` package binaries are not on PATH.

**Fix**:
- **Windows**: Close and reopen PowerShell. Or add `%LOCALAPPDATA%\Programs\uv` to PATH.
- **macOS/Linux**: Run `export PATH="$HOME/.local/bin:$PATH"` or restart terminal.

### `Python too old`

**Cause**: graphifyy requires Python 3.10+.

**Fix**: Install Python 3.10+ from [python.org](https://www.python.org/downloads/) or via your package manager.

### `/graphify` command not recognised in Claude Code

**Cause**: The skill wasn't registered properly.

**Fix**: Run `graphify install` manually. Verify `~/.claude/skills/graphify/SKILL.md` exists. Restart Claude Code.

### Git hook not triggering

**Cause**: You may not be in a git repository, or the hook was installed in a different repo.

**Fix**: Run `git init` if needed, then `graphify hook install` inside the repo. Check with `graphify hook status`.

### CLAUDE.md conflicts

**Cause**: Your project already has a CLAUDE.md without graphify rules.

**Fix**: The install script prepends graphify rules without overwriting existing content. Review `CLAUDE.md` and adjust as needed.

## Repository Structure

```
antigravity-starter/
├── install.ps1                      # Windows PowerShell installer
├── install.sh                       # macOS / Linux bash installer
├── CLAUDE.md                        # Project-level graph-first rules
├── RULES.md                         # Detailed protocol reference
├── skills/
│   ├── albert-dm-pro/                   # Albert DM voice (PRO) skill
│   ├── build-premium-website-pro/       # Premium site builder (PRO, 14 refs) builder (14 reference files)
│   ├── composio-pro/                    # Composio integrations (PRO) integrations
│   ├── cost-reducer-pro/                # Cost optimization (PRO) optimization
│   ├── create-skill-pro/                # Skill creator meta-tool (PRO) meta-tool
│   ├── customer-support-pro/            # Support workflows (PRO) workflows
│   ├── frontend-design-pro/             # Frontend design (PRO) design quality
│   ├── instantly-campaign-pro/         # Cold email campaigns (PRO) email campaigns
│   ├── know-me-pro/                     # Cross-session memory (PRO)-session memory
│   ├── n8n-pro/                         # n8n automation (PRO) workflow automation
│   ├── new-client-system-pro/           # Client scaffolder (PRO, 69 templates) scaffolder (69 template files)
│   ├── researcher-pro/                  # Deep research (PRO) research analyst
│   ├── scalability-pro/                 # Scalability (PRO) scalability
│   ├── security-pro/                    # Security (PRO) security
│   ├── self-healing-pro/                # Self-improvement (PRO)-improvement engine
│   ├── setup-codex-precheck-pro/        # Codex review hook (PRO) review hook
│   ├── trigger-dev-pro/                 # Trigger.dev jobs (PRO).dev background jobs
│   ├── upwork-pro/                      # Profile optimizer (PRO) optimizer
│   ├── upwork-proposal-pro/             # Proposal writer (PRO) writer
│   ├── wrapup-pro/                      # Session summary (PRO) summary
│   └── README.md                    # Skills documentation
├── .github/
│   └── workflows/
│       └── test-install.yml         # CI: test install on Ubuntu
├── README.md                        # This file
├── LICENSE                          # MIT License
└── .gitignore                       # Git ignore rules
```

## Credits

- [graphify](https://github.com/safishamsi/graphify) by safishamsi — the knowledge graph engine
- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) by Anthropic — the AI coding assistant

## Author

**Bilal Ansari** — [ansaribilal.com](https://ansaribilal.com)

## License

[MIT](./LICENSE)
