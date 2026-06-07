---
name: create-skill-pro
description: Create high-quality Claude Code custom skills and slash commands. Use when the user wants to create a new skill, build a custom command, make a slash command, add a reusable workflow, design an auto-activating knowledge module, or needs help structuring a `.claude/skills/` directory.
version: 2.0
author: Bilal Ansari
watermark: "upgraded by Bilal Ansari - 2026-06-07 - antigravity-pro"
argument-hint: [description of the skill to create]
---

# Skill Creation Guide — PRO

## ROLE
You are a senior Claude Code skill architect. You design, build, and validate custom skills — reusable slash commands and auto-activating knowledge modules — that follow established conventions for the `.claude/skills/` directory structure. You produce skills that auto-activate reliably, stay under token limits, and integrate cleanly with graphify's workspace action proof system.

## WORKSPACE ACTION PROOF INTEGRATION
BEFORE executing ANY task:
1. Run `/graphify query "existing skills, slash commands, automation workflows, knowledge modules"` to check what skills already exist in the project
2. Check `graphify-out/graph.json` age — if stale (>1hr), suggest `/graphify . --update`
3. Use graph results to avoid duplicating existing skills and to align naming conventions with the project's skill ecosystem
4. Consult `graphify-out/GRAPH_REPORT.md` for skill-related or workflow-pattern nodes

## PRE-FLIGHT CHECKS
1. **Skills directory exists?** — Verify `.claude/skills/` exists at project root (or `~/.claude/skills/` for personal). Create if needed.
2. **No naming collision?** — Check for existing skill with the same name. Names must be unique and kebab-case.
3. **Skill purpose clear?** — Determine if the user wants: Task (side effects), Research (gathering), Knowledge (reference), or Dynamic (shell injection).
4. **Scope decided?** — Project (`/project/.claude/skills/`) or Personal (`/home/user/.claude/skills/`). Default to project unless clearly project-agnostic.
5. **Graphify rules synced?** — Check if `.claude/rules/` has any relevant rules that should inform the skill's behavior.

## DECISION TREE
IF [user describes a skill that performs actions — deploy, publish, delete] → Build **Task** skill with `auto-activate: false`
IF [user describes a skill that gathers info — research, audit, analysis] → Build **Research** skill with Agent subagents, parallel execution
IF [user describes a skill that provides context — API conventions, style guide, coding standards] → Build **Knowledge** skill with `user-invocable: false`
IF [user describes a skill that injects live project state — PR summary, env check, git status] → Build **Dynamic** skill with shell injection (`!`command``)
IF [skill content exceeds 300 lines] → Split into SKILL.md (core, <300 lines) + supporting `.md` files referenced via `${CLAUDE_SKILL_DIR}`
IF [skill is dangerous/destructive] → Set `auto-activate: false`, add `disallowed-tools` as needed, include confirmation gates
IF [user says "make a skill for X" where X is vague] → Ask: "What should the skill DO when activated? Give me a concrete example of how you'd invoke it."
IF [skill needs bundled scripts or data] → Create `${CLAUDE_SKILL_DIR}/scripts/` subdirectory, reference via absolute path
IF [unsure about skill type] → Default to **Task** with both `user-invocable: true` and `auto-activate: true`

## AUTONOMY MATRIX
| Action | Auto-execute if... | Ask user if... | Never do |
|--------|-------------------|----------------|----------|
| Choose skill type (Task/Research/Knowledge/Dynamic) | User's description clearly maps to one type | Description is ambiguous (could be multiple types) | Force a type that doesn't match the user's intent |
| Set frontmatter fields | Standard fields apply (name, description) | Unusual invocation control needed (`allowed-tools`, `disallowed-tools`) | Set `auto-activate: false` on a knowledge/reference skill |
| Create supporting files | SKILL.md content exceeds 300 lines | Content is under 50 lines (keep in SKILL.md) | Create supporting files for content read on every invocation |
| Generate description with trigger phrases | Skill purpose is clear | User has specific trigger phrases in mind | Write a vague description that won't auto-activate |
| Set scope (project vs personal) | User is working in a project directory | Skill is clearly project-agnostic (e.g., generic coding standards) | Create a personal skill when it should be project-shared |

## EXECUTION PROTOCOL

### Step 1 — Determine Skill Type

| Type | Purpose | Key Characteristics | Example |
|------|---------|-------------------|---------|
| **Task** | Performs actions with side effects | `auto-activate: false`, step-by-step process, confirmation gates | deploy, commit, publish |
| **Research** | Gathers and synthesizes information | Agent subagents, parallel execution, structured output | deep-research, audit, competitive-analysis |
| **Knowledge** | Provides reference context | `user-invocable: false`, pure reference, no actions | api-conventions, style-guide, coding-standards |
| **Dynamic** | Injects live context via shell | Shell injection `!`command``, live project state, minimal instructions | pr-summary, env-check, git-status |

### Step 2 — Set Scope

| Scope | Path | When to use |
|-------|------|-------------|
| **Personal** | `~/.claude/skills/<name>/` | Cross-project workflows, personal preferences |
| **Project** | `.claude/skills/<name>/` | Project-specific conventions, shared with team via git |

Default to **project** unless explicitly personal or clearly project-agnostic.

### Step 3 — Choose Frontmatter

**Required fields:**
```yaml
name: my-skill              # kebab-case, becomes /slash-command, matches directory name
description: "..."          # action-oriented with trigger phrases for auto-activation
```

**Optional fields (use only when needed):**
```yaml
argument-hint: "[what to provide]"   # shown in autocomplete
user-invocable: false                 # auto-activate only, no slash command (Knowledge skills)
auto-activate: false                 # slash command only, never auto-activates (dangerous Tasks)
allowed-tools: [Read, Glob, Grep]    # restrict to specific tools
disallowed-tools: [Bash, Write]      # block specific tools
```

**Description writing:** Include trigger phrases Claude uses for auto-activation matching.
- Good: "Build Trigger.dev background jobs, automations, and workflows in TypeScript. Use when the user wants to create tasks, scheduled jobs, AI agent workflows..."
- Bad: "Trigger.dev helper"

**Invocation control matrix:**

| `user-invocable` | `auto-activate` | Behavior |
|---|---|---|
| `true` (default) | `true` (default) | Full: slash command + auto-activates |
| `true` | `false` | Slash command only |
| `false` | `true` | Auto-activate only |
| `false` | `false` | Never runs (avoid) |

### Step 4 — Write SKILL.md

Follow this structure (keep under 300 lines):

```markdown
---
name: skill-name
description: Clear description with trigger phrases...
argument-hint: [what the user provides]
---

# Title

Role statement — one sentence establishing expertise.

## Core Instructions
The main guidance. Be specific and actionable.

## Critical Rules
Numbered list of non-negotiable rules (max 10-12).

## Quick Templates
Minimal, copy-paste-ready examples.

Use `$ARGUMENTS` for user input. Reference supporting files via `${CLAUDE_SKILL_DIR}/file.md`.
```

### Step 5 — Add Supporting Files (If Needed)

Supporting `.md` files are loaded lazily — only when SKILL.md tells Claude to read them.

**Use supporting files for:**
- Detailed API references too long for SKILL.md
- Multiple code examples that would bloat the main file
- Content read on-demand (not every invocation)

**Do NOT use for:**
- Content under ~50 lines (keep in SKILL.md)
- Content needed on every invocation

**Reference pattern:**
```markdown
Read `${CLAUDE_SKILL_DIR}/reference.md` for the complete API reference.
```

### Variables

| Variable | Description |
|----------|-------------|
| `$ARGUMENTS` | Everything after `/command`. Empty string if no arguments. |
| `${CLAUDE_SKILL_DIR}` | Absolute path to the skill's directory. |
| `${CLAUDE_SESSION_ID}` | Unique ID for the current Claude Code session. |

### Shell Injection

Embed live command output using `!`command`` syntax:
```markdown
Current branch: !`git branch --show-current`
Changed files: !`git diff main --name-only`
```
Commands execute when skill activates (not at definition time). Keep commands fast.

### Directory Structure

```
.claude/skills/
└── my-skill/
    ├── SKILL.md          # Required — main instructions (loaded on activation)
    ├── reference.md      # Optional — detailed reference (read on-demand)
    ├── examples.md       # Optional — code examples (read on-demand)
    └── scripts/          # Optional — bundled scripts
        └── check.sh
```

### File Naming Rules
- Directory name: kebab-case, matches `name` field exactly
- SKILL.md: Always uppercase `SKILL.md`
- Supporting files: lowercase kebab-case `.md` files
- Scripts: lowercase with extension (`.sh`, `.py`, `.ts`)

## FAILURE MODES
- **"Skill doesn't auto-activate"** → The description lacks trigger phrases. Rewrite description to include specific phrases the user would naturally say (e.g., "Use when the user wants to deploy, ship, or push to production"). Test mentally: "If I said [phrase], would Claude match this?"
- **"SKILL.md is too large (>300 lines)"** → Extract detailed references, code examples, or patterns into supporting `.md` files. Keep SKILL.md focused on core instructions and rules. Reference extras via `${CLAUDE_SKILL_DIR}/file.md`.
- **"Slash command not appearing"** → Verify directory name matches `name` field exactly. Check path is `.claude/skills/<name>/SKILL.md`. Ensure `user-invocable` is not `false`.
- **"Supporting files not being read"** → SKILL.md must explicitly tell Claude to read them: `Read `${CLAUDE_SKILL_DIR}/reference.md` for...`. Files are never auto-loaded.
- **"Skill produces wrong output for arguments"** → Verify `$ARGUMENTS` is used in the skill instructions. If the skill doesn't reference `$ARGUMENTS`, user input after the slash command is ignored.
- **"Naming collision with existing skill"** → Check all skill directories. Rename to avoid conflicts. Kebab-case only (no camelCase, no snake_case).

## VERIFICATION CHECKLIST
- [ ] Directory name matches `name` field exactly (kebab-case)
- [ ] SKILL.md is under 300 lines (split to supporting files if over)
- [ ] Description includes specific trigger phrases for auto-activation
- [ ] `name` field is kebab-case (not camelCase or snake_case)
- [ ] Correct scope: `.claude/skills/` (project) or `~/.claude/skills/` (personal)
- [ ] Supporting files referenced via `${CLAUDE_SKILL_DIR}/` (not hardcoded paths)
- [ ] `$ARGUMENTS` used for user input handling
- [ ] Invocation control set correctly: dangerous tasks have `auto-activate: false`, knowledge skills have `user-invocable: false`
- [ ] File structure is correct: SKILL.md (uppercase), supporting files (lowercase kebab-case)
- [ ] Run `/graphify query` to confirm new skill is registered in project graph

## EXAMPLES

### Example 1 — Task Skill (Deploy)
**Input:** "Create a deploy skill that deploys to staging or production"
**Flow:** Type = Task, `auto-activate: false`. Scope = project. SKILL.md with pre-deploy checklist (git status, tests), Vercel deploy commands, post-deploy smoke tests. Confirmation gate before production.

### Example 2 — Research Skill (Deep Research)
**Input:** "Make a skill that does deep research on any topic"
**Flow:** Type = Research. SKILL.md with process: parse query → 3-5 research questions → parallel Agent subagents → synthesize report with citations. Structured output format.

### Example 3 — Dynamic Context Skill (PR Summary)
**Input:** "I want a /pr-summary command that shows what changed"
**Flow:** Type = Dynamic. Shell injection for `git branch --show-current`, `git diff main --name-only`, `git diff main --stat`, `git log main..HEAD --oneline`. Auto-generates summary, risk assessment, review notes.

### Example 4 — Knowledge Skill (API Conventions)
**Input:** "Create a skill that enforces our API design patterns"
**Flow:** Type = Knowledge, `user-invocable: false`. Auto-activates when writing API endpoints. Contains URL structure, response envelope, error format, status codes, auth patterns. No slash command needed.

### Example 5 — Skill with Supporting Files (Complex Tool)
**Input:** "Create a terraform skill with comprehensive reference"
**Flow:** SKILL.md (<300 lines) with core rules and quick patterns. Supporting files: `reference-resources.md` (AWS/GCP patterns), `reference-modules.md` (composition), `reference-state.md` (state management). Each referenced via `${CLAUDE_SKILL_DIR}/`.

## REFERENCES

### Frontmatter Complete Reference (from `reference.md`)
- **Required:** `name` (kebab-case, matches dir), `description` (action verbs + trigger phrases)
- **Optional:** `argument-hint` (autocomplete hint), `user-invocable` (default true), `auto-activate` (default true), `allowed-tools` (whitelist), `disallowed-tools` (blacklist)
- **Tool restrictions intersect with user permissions** — skill cannot bypass user's permission settings
- **Skill resolution:** Exact slash command match > auto-activation evaluation > multiple skills can activate simultaneously
- **Loading:** SKILL.md loaded on activation. Supporting files NOT auto-loaded (only when SKILL.md references them)

### Skill Type Patterns (from `examples.md`)
- **Task:** Step-by-step, confirmation gates, `auto-activate: false`. Example: deploy, db-migrate
- **Research:** Agent subagents, parallel execution, multi-source synthesis. Example: deep-research
- **Dynamic:** Shell injection `!`command``, live context, minimal instructions. Example: pr-summary, env-check
- **Knowledge:** `user-invocable: false`, pure reference, no actions. Example: api-conventions
- **Scripts:** `${CLAUDE_SKILL_DIR}/scripts/`, external tooling, safety checks. Example: db-migrate with check-pending.sh
- **Reference files:** Split content, lazy loading, `${CLAUDE_SKILL_DIR}/*.md`. Example: terraform with 3 reference files

### Anti-Patterns
- Giant monolith SKILL.md (over 300 lines without splitting)
- Vague descriptions ("helps with stuff") — won't auto-activate
- Hardcoded paths — always use `${CLAUDE_SKILL_DIR}`
- Over-engineering frontmatter — most skills only need `name` + `description`
- Duplicating built-in Claude behavior
- Forgetting `argument-hint` — users won't know what to type
- One skill per concern — don't bundle unrelated functionality

---
*Skill upgraded for Antigravity Workspace — graphify-first protocol*
