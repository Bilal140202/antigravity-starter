# Skills

This directory contains Antigravity IDE skills — modular, plain-markdown capabilities that extend the AI assistant with specialised workflows. Each skill is a self-documented `.md` file with YAML frontmatter that the Antigravity IDE auto-detects and makes available as slash commands.

**Author**: [Bilal Ansari](https://ansaribilal.com)
**Project**: [antigravity-starter](https://github.com/Bilal140202/antigravity-starter)

## Available Skills

### `/notebooklm` — NotebookLM Integration

**Purpose**: Connect your workspace to Google NotebookLM for persistent, queryable AI memory that survives across sessions and projects.

**When to use**:
- Storing session context and decisions for future reference
- Retrieving past knowledge and architectural decisions from earlier sessions
- Cross-project memory and pattern reuse across different codebases

**Invoke**: Type `/notebooklm` in the Antigravity IDE chat for status, or `/notebooklm <command>` for specific actions.

**See**: [notebooklm.md](./notebooklm.md) for full documentation, prerequisites (Python 3.10+, venv, Google OAuth), usage patterns, and troubleshooting.

---

### `/wrapup` — Session Wrapup and Memory Sync

**Purpose**: End-of-session cleanup that generates a structured summary markdown, pushes it to NotebookLM for cloud persistence, and saves memories to local files for offline backup.

**When to use**:
- At the end of every coding session to preserve context
- Before handing off work to another team member
- After major architectural decisions to lock them into persistent memory
- As periodic checkpoints during long sessions (`/wrapup --quick`)

**Invoke**: Type `/wrapup` for a full session wrapup, or `/wrapup --quick` for a lightweight checkpoint that skips the NotebookLM upload.

**See**: [wrapup.md](./wrapup.md) for full documentation, the four-step pipeline, summary format, file output structure, and troubleshooting.

---

### `/graphify` — Graph-First Code Intelligence (built-in)

**Purpose**: Query the codebase knowledge graph to understand structure, relationships, and context without reading raw files. This is the core capability enforced by the Workspace Action Proof protocol.

**When to use**:
- Before starting any task (required by Workspace Action Proof protocol in `RULES.md`)
- Understanding how code is organised and what depends on what
- Finding relevant files, functions, and dependencies without manual searching

**Invoke**: Type `/graphify query "<your question>"` in the IDE chat, or run `graphify query "<question>"` directly in the terminal.

**Note**: This is a built-in graphify command, not a skill file. It is always available after running the install script. The knowledge graph is built by `graphify .` and stored in `graphify-out/`.

## Skill Installation

Skills are copied to `.agents/skills/` by the install script (`install.ps1` on Windows, `install.sh` on macOS/Linux). The Antigravity IDE automatically detects and loads all `.md` files in `.agents/skills/` as available slash commands.

To re-install or update skills after adding new files to this directory:

```powershell
# Windows PowerShell
.\install.ps1

# macOS / Linux
bash install.sh
```

## Creating New Skills

The skill system is designed to be extensible. To add your own custom skill:

1. Create a new `.md` file in this `skills/` directory with a descriptive name (e.g. `my-workflow.md`)
2. Add YAML frontmatter with the required `name` and `description` fields:

```yaml
---
name: my-workflow
description: "Brief description of what this skill does and when to use it."
author: "Bilal Ansari"
website: "https://ansaribilal.com"
---
```

3. Document the skill's purpose, available commands, usage patterns, and troubleshooting steps
4. Re-run the install script to copy the new skill to `.agents/skills/` where the IDE will detect it

## File Format

All skills are **plain markdown files with YAML frontmatter**. This design choice ensures:

- **Maximum token efficiency** — no binary encoding, no base64, no wasted tokens
- **Easy version control** — skills are diffable, mergeable, and reviewable in pull requests
- **Direct readability** — both humans and AI agents can read and understand skill files without parsing
- **Portable** — skills work across all platforms without compilation or platform-specific handling
