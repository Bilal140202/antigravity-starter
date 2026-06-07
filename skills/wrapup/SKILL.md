---
name: wrapup
description: "End-of-session cleanup. Generates a structured session summary markdown and saves it locally. Use at the end of coding sessions, before handoffs, or after major decisions to preserve context."
---

# Wrapup — Session Summary

Generate a structured summary of the current session and save it to `.claude/memory/`.

## What to do

1. Review the conversation history of this session
2. Generate a structured markdown summary following the format below
3. Save it to `.claude/memory/session-<YYYY-MM-DD-HHmmss>.md`
4. Update `.claude/memory/decisions.md` if any architectural or design decisions were made (append-only, newest first)
5. Print a brief confirmation of what was saved

## Summary Format

```markdown
# Session Summary — <date> <time>

## Task
<What the user asked for>

## Actions Taken
<Step-by-step what was done>

## Key Decisions
<Architectural or design decisions made this session (if any)>

## Files Modified
<List of files created, edited, or deleted>

## Open Items
<Unfinished work or blockers>

## Graph State
- Graph exists: yes/no
- Graph location: graphify-out/graph.json (if present)
```

## Rules

- Do NOT overwrite existing session files — each gets a unique timestamp
- `decisions.md` is append-only — new entries go at the TOP, never delete old ones
- If `.claude/memory/` does not exist, create it
- If this was a short session with no meaningful output, say so and skip saving
