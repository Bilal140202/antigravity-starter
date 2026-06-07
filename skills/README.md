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
- `.claude/skills/wrapup/SKILL.md` → type `/wrapup-pro` in Claude Code

## Skills in This Project

### `/graphify-pro` — PRO: Knowledge Graph (installed by `graphify install`)

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

### `/albert-dm-pro` — PRO: Albert DM Voice

Reply to DMs and messages the way Albert would. Albert sells AI voice agents / automations to local service businesses (Go High Level, lead follow-up, bookings).

**Invoke**: `/albert-dm [paste the conversation / message you want an Albert-style reply to]`

**File**: [`albert-dm/SKILL.md`](./albert-dm/SKILL.md)

---

### `/build-premium-website-pro` — PRO: Premium Website Builder

Build a premium, animated marketing website (React + Vite + Tailwind + GSAP) for any industry. Adapts color, copy, services, and signature animation to the industry.

**Invoke**: `/build-premium-website [business name or industry]`

**References**: design system, animations, code snippets, industry themes, tech setup, visual examples, full reference files.

**File**: [`build-premium-website/SKILL.md`](./build-premium-website/SKILL.md)

---

### `/composio-pro` — PRO: Composio Integrations

Build AI agent integrations with Composio (composio.dev). Connect AI agents to third-party apps (GitHub, Gmail, Slack, Notion, Salesforce, etc.), set up OAuth, create sessions, use tools natively or via MCP.

**Invoke**: `/composio [integration task]`

**References**: SDK reference, auth & triggers.

**File**: [`composio/SKILL.md`](./composio/SKILL.md)

---

### `/cost-reducer-pro` — PRO: Cloud & Infrastructure Cost Optimizer

Reduce cloud, infrastructure, and operational costs while maintaining performance. Covers AWS/GCP/Vercel pricing, database optimization, serverless tuning, image pipelines, observability costs, and FinOps practices.

**Invoke**: `/cost-reducer [area to optimize]`

**References**: cloud & infra, code-level savings, services & FinOps.

**File**: [`cost-reducer/SKILL.md`](./cost-reducer/SKILL.md)

---

### `/create-skill-pro` — PRO: Skill Creator

Create high-quality Claude Code custom skills and slash commands. Guides you through building a new skill with proper YAML frontmatter, structure, and documentation.

**Invoke**: `/create-skill`

**References**: reference guide, examples.

**File**: [`create-skill/SKILL.md`](./create-skill/SKILL.md)

---

### `/customer-support-pro` — PRO: Customer Support Handler

Handle customer support tasks professionally. Draft responses, triage tickets, write help articles, create macros/templates, review conversations for quality, and build support workflows.

**Invoke**: `/customer-support [support task]`

**References**: response templates, escalation guide.

**File**: [`customer-support/SKILL.md`](./customer-support/SKILL.md)

---

### `/frontend-design-pro` — PRO: Production-Grade Frontend Design

Create distinctive, production-grade frontend interfaces with high design quality. Generates creative, polished code that avoids generic AI aesthetics.

**Invoke**: `/frontend-design [component or page request]`

**File**: [`frontend-design/SKILL.md`](./frontend-design/SKILL.md)

---

### `/instantly-campaign-pro` — PRO: Cold Email Campaign Creator

Create a new Instantly cold-email campaign in the proven 5-email structure of the user's top-performing campaign (~16% reply rate). Structurally identical to the winner — only the angle, language, and specifics change.

**Invoke**: `/instantly-campaign [service or niche]`

**References**: voice guide, winning template.

**File**: [`instantly-campaign/SKILL.md`](./instantly-campaign/SKILL.md)

---

### `/know-me-pro` — PRO: Cross-Session Memory

Learn about the user across sessions. Observes preferences, habits, corrections, and context. Saves to memory topic files and references stored knowledge to personalize responses. Auto-activates.

**Invoke**: Auto-activates (or `/know-me`)

**References**: what to track, memory operations.

**File**: [`know-me/SKILL.md`](./know-me/SKILL.md)

---

### `/n8n-pro` — PRO: n8n Workflow Automation

Build n8n workflow automations, custom nodes, and integrations. Create workflows, build custom nodes, write expressions, configure triggers, handle errors, and set up webhook automations.

**Invoke**: `/n8n [automation task]`

**References**: workflow reference, custom nodes reference, API reference.

**File**: [`n8n/SKILL.md`](./n8n/SKILL.md)

---

### `/new-client-system-pro` — PRO: Client Project Scaffolder

Scaffold a new client's full stack — Next.js 16 frontend dashboard + Trigger.dev backend worker — from the Shiney automations template. Produces structure only; no automations are scaffolded — those are added later.

**Invoke**: `/new-client-system [client name]`

**References**: architecture, design system, stack, parameters, full frontend/backend templates.

**File**: [`new-client-system/SKILL.md`](./new-client-system/SKILL.md)

---

### `/researcher-pro` — PRO: Deep Research Analyst

Deep research on any topic using web search, multiple sources, and synthesis. Delivers well-organized, actionable summaries with sources.

**Invoke**: `/researcher [topic or question]`

**File**: [`researcher/SKILL.md`](./researcher/SKILL.md)

---

### `/scalability-pro` — PRO: Scalability Engineer

Design and build scalable software systems. Covers database scaling, caching strategies, async processing, API design for scale, concurrency, frontend performance, observability, and infrastructure patterns.

**Invoke**: `/scalability [area to scale]`

**References**: infrastructure, database scaling, caching & queues, API & services.

**File**: [`scalability/SKILL.md`](./scalability/SKILL.md)

---

### `/security-pro` — PRO: Application Security

Secure web and desktop application development. Covers OWASP Top 10, XSS, CSRF, SQL injection, SSRF, command injection, path traversal, Electron/Tauri IPC security, and more.

**Invoke**: `/security [area to secure or review]`

**References**: auth & secrets, web security, database & deps, desktop security.

**File**: [`security/SKILL.md`](./security/SKILL.md)

---

### `/self-healing-pro` — PRO: Self-Improvement Engine

Continuously improve Claude's effectiveness by recognizing patterns, saving memory, creating skills, and refining project knowledge. Learns from repeated workflows and past problems.

**Invoke**: `/self-healing`

**References**: pattern recognition, memory management, skill creation guide.

**File**: [`self-healing/SKILL.md`](./self-healing/SKILL.md)

---

### `/setup-codex-precheck-pro` — PRO: Codex Pre-Edit Review Hook

Install a PreToolUse hook that asks the codex CLI to review every Edit/Write/MultiEdit before it is written, blocking risky changes. Checks prerequisites (codex, python3, codex login) and installs anything missing.

**Invoke**: `/setup-codex-precheck`

**References**: install script, codex precheck script.

**File**: [`setup-codex-precheck/SKILL.md`](./setup-codex-precheck/SKILL.md)

---

### `/trigger-dev-pro` — PRO: Trigger.dev Background Jobs

Build Trigger.dev background jobs, automations, and workflows in TypeScript. Create tasks, scheduled jobs, AI agent workflows, queued background processing, cron jobs, and long-running async work.

**Invoke**: `/trigger-dev [automation task]`

**References**: core reference, config reference, advanced reference.

**File**: [`trigger-dev/SKILL.md`](./trigger-dev/SKILL.md)

---

### `/upwork-pro` — PRO: Upwork Profile Optimizer

Audit and rewrite Upwork freelancer profiles using patterns from Top Rated Plus / Expert Vetted top earners. Improve headlines, bios, overviews, specialized profiles, project catalogs, skills tags, and more.

**Invoke**: `/upwork [section to improve]`

**References**: patterns, examples.

**File**: [`upwork/SKILL.md`](./upwork/SKILL.md)

---

### `/upwork-proposal-pro` — PRO: Upwork Proposal Writer

Write a high-converting Upwork proposal for a job post. Paste a job description and get a tailored, compelling cover letter.

**Invoke**: `/upwork-proposal [paste job description]`

**File**: [`upwork-proposal/SKILL.md`](./upwork-proposal/SKILL.md)

---

### `/wrapup-pro` — PRO: Session Summary

End-of-session cleanup that generates a structured markdown summary and saves it to `.claude/memory/`.

**When to use**:
- End of a coding session to preserve context
- Before handing off a project to another developer
- After major architectural decisions

**Invoke**: Type `/wrapup-pro` in Claude Code.

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

The scripts copy **entire skill directories** (SKILL.md + all reference files) to `.claude/skills/` in the current project directory.

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

3. Optionally add reference files in subdirectories (e.g., `references/`, `templates/`)
4. Re-run the install script to copy everything to `.claude/skills/my-skill/`
5. Open Claude Code — the skill appears as `/my-skill`

## File Format

All skills are plain markdown with YAML frontmatter:
- **Maximum token efficiency** — no binary encoding
- **Easy version control** — diffable and reviewable
- **Direct readability** — both humans and AI can read skill files
