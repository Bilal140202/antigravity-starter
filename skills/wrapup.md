---
name: wrapup
description: "End-of-session cleanup. Generates a structured summary markdown, pushes it to NotebookLM for cloud persistence, and saves memories to local files for offline backup and persistent AI memory."
author: "Bilal Ansari"
website: "https://ansaribilal.com"
---

# Wrapup Skill

## Overview

The wrapup skill ensures that **no session knowledge is ever lost**. At the end of every Antigravity IDE session — or on demand at any point — it generates a structured, comprehensive summary of everything discussed, decided, and implemented during the session. This summary is then synchronised to both NotebookLM (cloud storage, queryable in future sessions) and local files (offline backup, always accessible).

This skill is part of the [antigravity-starter](https://github.com/Bilal140202/antigravity-starter) project by [Bilal Ansari](https://ansaribilal.com).

## Purpose

Without a wrapup mechanism, valuable context from each coding session is lost when the session ends. The AI starts fresh every time, leading to repeated research, forgotten decisions, and inconsistent patterns. The wrapup skill eliminates this problem by:

- **Generating structured summaries** — capturing tasks, actions, decisions, modified files, and open items
- **Syncing to NotebookLM** — making session knowledge queryable in all future sessions via `/notebooklm query`
- **Saving local backups** — writing markdown files to `.agents/memory/` for offline access and resilience
- **Tracking decisions over time** — maintaining an append-only log of architectural and design decisions
- **Managing open items** — pruning completed items and surfacing unfinished work

## When to Use

| Scenario | Command |
|----------|---------|
| End of a coding session | `/wrapup` |
| Before handing off a project to another developer | `/wrapup` |
| After making a major architectural decision | `/wrapup` |
| During a long session as a periodic checkpoint | `/wrapup --quick` |
| When you want to save progress but keep working | `/wrapup --quick` |

## Commands

### `/wrapup` — Full Session Wrapup

Run without arguments to perform a complete end-of-session wrapup:

```text
/wrapup
```

This executes the full four-step pipeline:

1. **Check AI Brain notebook in NotebookLM** — verifies the target notebook exists and is accessible; creates it if missing
2. **Create session summary markdown** — generates a structured markdown document covering the entire session
3. **Push summary to NotebookLM** — uploads the summary as a new source in the AI Brain notebook for future querying
4. **Save memories to local files** — writes the summary and extracted memories to the local `.agents/memory/` directory

### `/wrapup --quick` — Quick Checkpoint

Generates a lightweight checkpoint without the full NotebookLM upload. Useful during long sessions when you want to save progress but continue working:

```text
/wrapup --quick
```

The quick variant only performs Steps 2 and 4 (local summary creation and file saving), skipping the NotebookLM upload to minimise latency.

## Session Summary Format

The generated summary follows a consistent, machine-readable structure that is optimised for both human review and AI parsing:

```markdown
# Session Summary — 2025-06-07 14:30

## Task
<What the user asked for — their exact request>

## Actions Taken
<Step-by-step account of what was done, including commands run>

## Key Decisions
<Architectural or design decisions made during this session>

## Files Modified
<Comprehensive list of files created, edited, or deleted>

## Open Items
<Unfinished work, blockers, or items deferred to the next session>

## Graph State
- Graph built: yes/no
- Last graphify query: <timestamp>
- Graph files: <count>
```

This format is designed to be easily parsed by the AI in future sessions, enabling efficient context retrieval through `/notebooklm query`.

## Local File Output

Summaries and memories are saved to a dedicated directory structure:

```
.agents/memory/
├── session-2025-06-07-143000.md      # Full session summary (timestamped)
├── session-2025-06-07-160000.md      # Another session summary
├── decisions.md                       # Accumulated key decisions (append-only)
└── open-items.md                      # Rolling list of unfinished work (pruned)
```

**File management rules:**

- `decisions.md` is **append-only** — new decisions are prepended to the top, existing entries are never modified or deleted
- `open-items.md` is **auto-pruned** — completed items are removed during each wrapup, leaving only genuinely unfinished work
- Individual session files are **immutable** — once created, they are never modified, ensuring a reliable audit trail

## Pipeline Details

### Step 1: Check AI Brain Notebook

```
graphify notebooklm status
```

This step verifies that the target NotebookLM notebook is accessible:

- If the AI Brain notebook does not exist, the skill prompts the user to create it via `/notebooklm create "AI Brain"`
- If Google OAuth authentication has expired, the skill prompts `graphify auth login` to refresh credentials
- This step is **non-critical** — if NotebookLM is unavailable (network issues, auth problems), the wrapup continues and local files are always written successfully

### Step 2: Create Session Summary

The summary is assembled from three sources:

1. **Conversation history** — the full transcript of the current Antigravity IDE session
2. **Graph query output** — the last `graphify query` result (if any), providing codebase context
3. **Git diff** — a diff of files modified during the session (if git is initialised in the workspace)

The combination of these sources produces a comprehensive summary that captures both what was discussed and what was actually changed in the codebase.

### Step 3: Push to NotebookLM

```
notebooklm source add <session-summary-file>
```

The generated summary markdown is uploaded as a new source in the AI Brain notebook. Once uploaded, it becomes instantly queryable in future sessions through `/notebooklm query`, enabling the AI to recall exactly what happened in this session.

### Step 4: Save Local Files

Writes to `.agents/memory/` following the structure described above. These local files serve three purposes:

- **Offline backup** — memories are accessible even without network connectivity
- **Graph integration** — the graphify query system can index these files for local-only knowledge retrieval
- **Audit trail** — a permanent, tamper-evident record of all session activity and decisions

## Troubleshooting

| Problem | Solution |
|---------|----------|
| `/wrapup` not recognised | Ensure skills are installed: re-run the install script or verify `.agents/skills/wrapup.md` exists |
| NotebookLM upload fails | Check auth with `graphify auth status`. Local files are always saved regardless of cloud status. |
| `.agents/memory/` not created | Check directory permissions. Manually run `mkdir -p .agents/memory` and retry. |
| Empty summary generated | Ensure you had an active session with at least one task completed before running `/wrapup`. |
| `decisions.md` is empty | Decisions are only recorded when the session includes architectural or design choices. |

---

**Author**: Bilal Ansari — [ansaribilal.com](https://ansaribilal.com)
**Project**: [antigravity-starter](https://github.com/Bilal140202/antigravity-starter)
