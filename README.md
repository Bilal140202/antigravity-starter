# antigravity-starter

> **One-command Antigravity workspace with graph-first AI**
>
> Created by [Bilal Ansari](https://ansaribilal.com)

Eliminate manual setup. Run one command and get a graph-first, rules-enforced development environment for Google Antigravity IDE. No more telling the AI to "install tools, add skills, set rules" every time — it all just works.

The system enforces **Workspace Action Proof** — two hard requirements that apply to every task, in every project, forever:

1. **Graph First** — the AI must query the knowledge graph before reading any raw files
2. **Agent Selection** — the AI must choose the correct specialised agent based on context

---

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

---

## What It Installs

| Component | Description | Details |
|-----------|-------------|---------|
| **graphifyy** | Graph-first code intelligence tool | Installed via `uv tool install graphifyy` (note the double-y in the package name) |
| **RULES.md** | Shared rules enforcing Workspace Action Proof protocol | Copied to `~/.config/agent-rules-sync/RULES.md` for global enforcement |
| **Skills** | Modular AI capabilities in plain markdown | `/notebooklm` (persistent memory), `/wrapup` (session summary) |
| **Graph hooks** | Automatic graph maintenance hooks | Installed via `graphify hook install` |
| **Knowledge graph** | Initial graph build of your workspace | Created via `graphify . --no-viz` — captures code structure and dependencies |

---

## How It Works

The install script performs eight sequential steps, each with error handling and idempotent behaviour:

| Step | Action | What it does |
|------|--------|-------------|
| 1 | Check Python 3.10+ | Verifies Python is installed and meets the minimum version requirement |
| 2 | Install uv | Installs [Astral uv](https://docs.astral.sh/uv/) package manager via `winget` (Windows) or `curl` (macOS/Linux) |
| 3 | Install graphifyy | Runs `uv tool install graphifyy --upgrade` to get the graph-first CLI |
| 4 | Antigravity setup | Runs `graphify antigravity install` to configure IDE extensions |
| 5 | Copy rules | Copies `RULES.md` to `~/.config/agent-rules-sync/RULES.md` for global enforcement |
| 6 | Install skills | Copies all `.md` files from `skills/` to `.agents/skills/` in the workspace |
| 7 | Install hooks | Runs `graphify hook install` for automatic graph maintenance |
| 8 | Build graph | Runs `graphify . --no-viz` to generate the initial knowledge graph |

### Workspace Action Proof Protocol

After installation, every AI interaction in the workspace follows two non-negotiable rules defined in `RULES.md`:

**Requirement 1 — Graph First:**
1. Check if `graphify-out/graph.json` exists and is less than 1 hour old
2. If missing or stale, run `graphify . --update`
3. Run `graphify query "<user's exact request>"` to get codebase context
4. NEVER use Read, Glob, or Grep tools before completing step 3

**Requirement 2 — Agent Selection:**
After receiving graph results, route to the correct specialised agent:
- Architecture, design, or planning requests → `@architect` agent
- Code changes, implementation, or building → `@builder` agent
- Testing, debugging, or verification → `@tester` agent
- Documentation or summaries → `@documenter` agent

These rules are enforced by `RULES.md` and apply to **every task, in every project, forever**.

---

## Manual Steps Required

> **Important: First run opens a browser for Google login — sign in once.**

The initial `graphify auth login` requires interactive Google OAuth 2.0 authentication. This step **cannot be automated** for security reasons. After signing in once, your credentials are cached and subsequent sessions work without any prompts.

```bash
# Authenticate — opens a browser window for Google login
graphify auth login

# Verify that authentication succeeded
graphify auth status
```

---

## How to Verify

After installation, run these commands to confirm everything is working correctly:

```bash
# Check graphify is installed and accessible
graphify --version

# Query the knowledge graph to test the full pipeline
graphify query "test"

# Verify shared rules are in place
cat ~/.config/agent-rules-sync/RULES.md          # macOS / Linux
type %USERPROFILE%\.config\agent-rules-sync\RULES.md   # Windows

# Verify skills were installed
ls .agents/skills/      # macOS / Linux
dir .agents\skills\     # Windows
```

Expected output: `graphify --version` should print a version number, `graphify query "test"` should return a response about the workspace, and the rules and skills directories should contain the installed files.

---

## Available Skills

After installation, these skills are available as slash commands in the Antigravity IDE:

| Command | Description | Details |
|---------|-------------|---------|
| `/notebooklm` | Connect to Google NotebookLM for persistent AI memory across sessions | Stores session summaries, architectural decisions, and project knowledge |
| `/wrapup` | End-of-session summary and memory sync | Generates structured markdown, pushes to NotebookLM, saves local backups |
| `/graphify query` | Query the codebase knowledge graph | Built-in graphify command — always available after installation |

See [`skills/README.md`](./skills/README.md) for comprehensive documentation of each skill, including prerequisites, commands, usage patterns, and troubleshooting.

---

## How to Update

Re-run the install script at any time. The scripts are **idempotent** — running them multiple times is safe. Existing tools are upgraded to the latest version, rules are overwritten with the current `RULES.md`, and skills are re-copied. No user data is destroyed on re-run.

```powershell
# Windows
.\install.ps1

# macOS / Linux
bash install.sh
```

---

## Troubleshooting

### `graphify: command not found`

**Cause**: uv binaries are not on your system PATH after installation.

**Fix**:
- **Windows**: Close and reopen PowerShell. If that does not work, add `%LOCALAPPDATA%\Programs\uv` to your system PATH manually via System Properties > Environment Variables.
- **macOS/Linux**: Run `export PATH="$HOME/.local/bin:$PATH"` in your terminal, or add it to your `~/.bashrc` / `~/.zshrc` for persistence.

### `Python too old` or `Python 3.10+ required`

**Cause**: Your system Python version is older than 3.10, which is the minimum required by graphifyy.

**Fix**: Install Python 3.10 or newer:
- **Windows**: Download from [python.org](https://www.python.org/downloads/) — check "Add to PATH" during installation
- **macOS**: `brew install python@3.12`
- **Ubuntu/Debian**: `sudo apt install python3.12 python3.12-venv`

Ensure the new version appears first on your PATH.

### `auth failed` or browser doesn't open

**Cause**: Google OAuth 2.0 requires interactive authentication — this is a security feature and cannot be bypassed.

**Fix**:
1. Run `graphify auth logout` to clear any stale credentials
2. Run `graphify auth login` in your terminal
3. A browser window should open — sign into your Google account with NotebookLM access
4. If the browser does not open, copy the URL from the terminal output and paste it into your browser manually

### `RULES.md not found` after install

**Cause**: The install script could not locate `RULES.md` next to itself in the repository root.

**Fix**: Ensure you downloaded or cloned the **entire repository** (not just the install script alone). Clone the repo or download the ZIP archive, then run the install script from the repository root directory.

### Skills don't appear in IDE

**Cause**: The `.agents/skills/` directory was not created or populated during installation.

**Fix**:
1. Verify the `skills/` directory exists next to the install script in the repository root
2. Re-run the install script (`.\install.ps1` or `bash install.sh`)
3. Confirm that `.agents/skills/` contains `.md` files after installation

---

## Repository Structure

```
antigravity-starter/
├── install.ps1                          # Windows PowerShell installer (primary)
├── install.sh                           # macOS / Linux bash installer
├── RULES.md                             # Shared rules — Workspace Action Proof protocol
├── skills/
│   ├── notebooklm.md                   # NotebookLM integration skill (persistent AI memory)
│   ├── wrapup.md                        # Session wrapup skill (summary and memory sync)
│   └── README.md                        # Skills documentation and usage guide
├── .github/
│   └── workflows/
│       └── test-install.yml             # CI: automated install testing on Ubuntu
├── README.md                            # This file — project documentation
├── LICENSE                              # MIT License
└── .gitignore                           # Git ignore rules
```

---

## Author

**Bilal Ansari** — [ansaribilal.com](https://ansaribilal.com)

## License

[MIT](./LICENSE) — free for personal and commercial use.
