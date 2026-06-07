# Skills

Custom Claude Code skills installed by the Antigravity Starter. Each skill is a `SKILL.md` file following the [Claude Code skills format](https://docs.anthropic.com/en/docs/claude-code/skills) — markdown with YAML frontmatter that Claude Code discovers at startup.

**Author**: [Bilal Ansari](https://ansaribilal.com)
**Project**: [antigravity-starter](https://github.com/Bilal140202/antigravity-starter)

## How Claude Code Skills Work

Skills live in specific directories and are auto-discovered:

| Scope | Path | Availability |
|-------|------|-------------|
| Personal (global) | `~/.claude/skills/<name>/SKILL.md` | All your projects |
| Project (local) | `.claude/skills/<name>/SKILL.md` | This project only |
| Legacy commands | `.claude/commands/<name>.md` | This project only |

The **directory name** becomes the slash command. For example:
- `.claude/skills/wrapup/SKILL.md` → type `/wrapup` in Claude Code

## Skills in This Project

### `/graphify` — Knowledge Graph (installed by `graphify install`)

This is the core graphify skill, installed globally to `~/.claude/skills/graphify/SKILL.md` by running `graphify install`. It is NOT in this repository — it comes from the `graphifyy` Python package.

**Purpose**: Turn any folder into a queryable knowledge graph.

**Key commands** (typed inside Claude Code):
- `/graphify .` — Full pipeline
- `/graphify . --no-viz` — Skip visualisation
- `/graphify . --update` — Incremental rebuild
- `/graphify query "<question>"` — Query the graph
- `/graphify path "A" "B"` — Shortest path between concepts
- `/graphify explain "X"` — Explain a node

**Source**: [safishamsi/graphify](https://github.com/safishamsi/graphify)

---

### `/wrapup` — Session Summary

**Purpose**: End-of-session cleanup that generates a structured markdown summary and saves it to `.claude/memory/`.

**When to use**:
- End of a coding session to preserve context
- Before handing off a project to another developer
- After major architectural decisions

**Invoke**: Type `/wrapup` in Claude Code.

**Output**: `.claude/memory/session-<timestamp>.md` + append to `.claude/memory/decisions.md`

**File**: [`wrapup/SKILL.md`](./wrapup/SKILL.md)

## Installation

Skills are installed by the install scripts:

```powershell
# Windows PowerShell
.\install.ps1

# macOS / Linux
bash install.sh
```

The scripts copy skill directories to `.claude/skills/` and legacy `.md` files to `.claude/commands/` in the current project directory.

## Creating New Skills

To add a custom skill:

1. Create a directory in `skills/` with a descriptive name: `skills/my-skill/`
2. Create `SKILL.md` inside it with YAML frontmatter:

```yaml
---
name: my-skill
description: "What this skill does and when to use it."
---

# My Skill

Instructions for Claude Code to follow when this skill is invoked.
```

3. Re-run the install script to copy it to `.claude/skills/my-skill/SKILL.md`
4. Open Claude Code — the skill appears as `/my-skill`

## File Format

All skills are plain markdown with YAML frontmatter:
- **Maximum token efficiency** — no binary encoding
- **Easy version control** — diffable and reviewable
- **Direct readability** — both humans and AI can read skill files
