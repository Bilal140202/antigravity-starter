---
name: notebooklm
description: "Interface with Google NotebookLM to create, manage, and query AI-powered research notebooks. Syncs session context and codebase knowledge into persistent memory."
author: "Bilal Ansari"
website: "https://ansaribilal.com"
---

# NotebookLM Skill

## Overview

The NotebookLM skill bridges your Antigravity IDE workspace with Google NotebookLM, creating a persistent "AI Brain" notebook that stores session summaries, codebase insights, architectural decisions, and project knowledge. This gives your AI assistant **long-term memory across sessions** — every coding session can be remembered, referenced, and built upon without losing context.

This skill is part of the [antigravity-starter](https://github.com/Bilal140202/antigravity-starter) project by [Bilal Ansari](https://ansaribilal.com).

## Purpose

Traditional AI coding assistants lose all context when a session ends. The NotebookLM skill solves this by:

- **Persisting session context** — every coding session produces a structured summary stored in NotebookLM
- **Enabling cross-session recall** — future sessions can query past decisions, patterns, and solutions
- **Supporting cross-project memory** — insights from one project are accessible in another
- **Providing offline backup** — all memories are also saved as local markdown files

## Prerequisites

### Python 3.10+

This skill requires Python 3.10 or newer. Verify your installed version:

```bash
python3 --version   # or: python --version on Windows
```

The minimum version requirement exists because graphifyy uses Python 3.10+ syntax features including structural pattern matching (`match/case` statements) and other modern language constructs that are not available in earlier versions.

**Install or upgrade Python:**

| Platform | Command |
|----------|---------|
| macOS | `brew install python@3.12` |
| Ubuntu / Debian | `sudo apt install python3.12 python3.12-venv` |
| Windows | Download from [python.org](https://www.python.org/downloads/) — check "Add to PATH" during installation |

### Virtual Environment (Recommended)

Creating an isolated virtual environment prevents dependency conflicts between graphifyy and other Python projects on your system. This is strongly recommended for all users.

```bash
# Create the virtual environment
python3 -m venv .venv

# Activate it (pick the command for your platform)
# macOS / Linux:
source .venv/bin/activate
# Windows PowerShell:
.\.venv\Scripts\Activate.ps1
# Windows CMD:
.\.venv\Scripts\activate.bat
```

After activation, your terminal prompt will change to show `(.venv)` indicating the virtual environment is active. All subsequent Python and pip commands will run inside this isolated environment.

### Authentication — Google OAuth

The NotebookLM integration uses Google OAuth 2.0 for authentication. The first time you use this skill, a browser window will open for Google login. **This step cannot be automated** — you must sign in manually once per machine.

```bash
# Authenticate — opens a browser window for Google login
graphify auth login

# Verify that authentication succeeded
graphify auth status
```

**If authentication fails, follow these steps:**

1. Ensure you are signed into a Google account that has access to NotebookLM
2. Clear any stale credentials: `graphify auth logout` followed by `graphify auth login`
3. Verify your network allows access to Google OAuth endpoints (corporate proxies may block this)
4. If the browser does not open automatically, check the terminal output for a URL you can paste manually

## Commands

### `/notebooklm` — Open NotebookLM Interface

Query and manage your AI Brain notebook from within the Antigravity IDE chat. The following sub-commands are available:

```text
/notebooklm                                    # Show notebook status and recent entries
/notebooklm list                               # List all available notebooks
/notebooklm create "Project Alpha"             # Create a new notebook with a given name
/notebooklm query "How does auth work?"        # Query the knowledge base for context
/notebooklm source add <file.md>               # Add a markdown file as a knowledge source
/notebooklm summary                            # Generate a summary of the current notebook
```

Each command integrates with the Workspace Action Proof protocol — the graph is queried before any code-related actions are taken.

## Usage Patterns

### Storing Session Context

After a productive coding session, push your context into NotebookLM so future sessions can pick up exactly where you left off:

```text
/notebooklm source add session-summary.md
```

This uploads the session summary as a new source in the AI Brain notebook, making every decision, file change, and architectural insight queryable in future sessions.

### Retrieving Past Knowledge

Before starting a new task in an existing project, query the knowledge base to avoid re-researching decisions you have already made:

```text
/notebooklm query "What was the architecture decision for the auth module?"
```

The response includes graph-enriched context from previous sessions, saving significant time and reducing the risk of contradicting earlier decisions.

### Cross-Project Memory

The AI Brain notebook spans all projects in your workspace. Use it to carry insights, patterns, and solutions between different codebases:

```text
/notebooklm query "What database patterns did we use in project-x?"
```

This is particularly valuable for reusable patterns like authentication flows, error handling strategies, and API design conventions.

## Implementation Notes

- The NotebookLM integration is powered by the `graphify` Python package under the hood
- All API calls are routed through authenticated Google OAuth 2.0 — no API keys are stored in configuration files
- Source files are synchronised as plain markdown for maximum token efficiency and readability
- The skill fully respects the Workspace Action Proof protocol defined in `RULES.md`: it queries the graph before acting on any code
- Local markdown backups are maintained alongside the cloud NotebookLM notebook, providing resilience against network failures

## Troubleshooting

| Problem | Solution |
|---------|----------|
| `graphify: command not found` | Run the install script or execute `uv tool install graphifyy` manually |
| Authentication browser doesn't open | Run `graphify auth login` manually in your terminal and paste the URL |
| "Session expired" error | Run `graphify auth login` to refresh your OAuth credentials |
| Notebook not found | Run `/notebooklm create "AI Brain"` to initialise a new notebook |
| Python version too old | Install Python 3.10+ following the Prerequisites section above |
| Upload fails silently | Check `graphify auth status` to verify your credentials are still valid |

---

**Author**: Bilal Ansari — [ansaribilal.com](https://ansaribilal.com)
**Project**: [antigravity-starter](https://github.com/Bilal140202/antigravity-starter)
