#!/usr/bin/env bash
# ==============================================================================
# Antigravity Starter — One-command workspace bootstrapper
#
# Automates the full setup of a graph-first, rules-enforced AI development
# environment. Installs graphifyy (Claude Code knowledge-graph skill), registers
# it as a Claude Code skill, installs post-commit git hooks, sets up
# project-level CLAUDE.md rules, and installs custom helper skills.
#
# This script is idempotent: running it multiple times is safe.
#
# Author:     Bilal Ansari
# Website:    https://ansaribilal.com
# Repository: https://github.com/Bilal140202/antigravity-starter
# License:    MIT
#
# WHAT THIS ACTUALLY INSTALLS:
#   1. graphifyy (PyPI package, double-y) — provides the `graphify` CLI command
#   2. Claude Code skill — via `graphify install` (copies to ~/.claude/skills/)
#   3. Post-commit git hook — via `graphify hook install` (auto-rebuilds graph)
#   4. Project CLAUDE.md — graph-first rules (copied to current directory)
#   5. Custom skills — in .claude/skills/ (project-level)
#
# WHAT THIS DOES NOT DO:
#   - Does NOT require any authentication, login, or API keys
#   - Does NOT build the initial graph (done inside Claude Code via /graphify)
#   - Does NOT install Claude Code itself
#
# Quick start:
#   curl -fsSL https://raw.githubusercontent.com/Bilal140202/antigravity-starter/main/install.sh | bash
# ==============================================================================

set -euo pipefail

# ---------------------------------------------------------------------------
# Colour helpers — disabled when stdout is not a terminal
# ---------------------------------------------------------------------------
if [[ -t 1 ]]; then
    C_CYAN='\033[0;36m'
    C_GREEN='\033[0;32m'
    C_YELLOW='\033[1;33m'
    C_RED='\033[0;31m'
    C_BOLD='\033[1m'
    C_RESET='\033[0m'
else
    C_CYAN='' C_GREEN='' C_YELLOW='' C_RED='' C_BOLD='' C_RESET=''
fi

step()   { echo -e "${C_CYAN}==> $1${C_RESET}" ; }
ok()     { echo -e "  ${C_GREEN}[OK]${C_RESET} $1" ; }
warn()   { echo -e "  ${C_YELLOW}[WARN]${C_RESET} $1" ; }
fail()   { echo -e "  ${C_RED}[FAIL]${C_RESET} $1" ; }

command_exists() { command -v "$1" &>/dev/null ; }

# Determine script directory (for finding companion files)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ---------------------------------------------------------------------------
# Step 1: Python 3.10+
# graphifyy requires Python 3.10+ for match/case and other modern syntax.
# ---------------------------------------------------------------------------
step "Step 1/7: Checking Python 3.10+ ..."
if ! command_exists python3 && ! command_exists python; then
    fail "Python is not installed or not on PATH."
    echo "  Install Python 3.10+ from https://www.python.org/downloads/"
    exit 1
fi

# Prefer python3, fall back to python
PYTHON="python3"
if ! command_exists python3; then
    PYTHON="python"
fi

PY_VERSION=$($PYTHON --version 2>&1 | sed 's/Python //')
echo "  Found Python $PY_VERSION"

PY_MAJOR=$(echo "$PY_VERSION" | cut -d. -f1)
PY_MINOR=$(echo "$PY_VERSION" | cut -d. -f2)

if [[ "$PY_MAJOR" -lt 3 ]] || [[ "$PY_MAJOR" -eq 3 && "$PY_MINOR" -lt 10 ]]; then
    fail "Python 3.10 or newer is required (found $PY_VERSION)."
    exit 1
fi

ok "Python $PY_VERSION meets requirements."

# ---------------------------------------------------------------------------
# Step 2: Install uv
# uv is Astral's fast Python package manager. Falls back to pip if it
# cannot be installed.
# ---------------------------------------------------------------------------
step "Step 2/7: Checking uv package manager ..."
USE_PIP_DIRECTLY=false

if command_exists uv; then
    UV_VERSION=$(uv --version 2>&1)
    ok "uv already installed ($UV_VERSION)."
else
    echo "  Installing uv via official installer ..."
    if curl -LsSf https://astral.sh/uv/install.sh | sh 2>&1; then
        export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$PATH"
        if command_exists uv; then
            ok "uv installed successfully."
        else
            warn "uv installed but not on PATH. Falling back to pip."
            USE_PIP_DIRECTLY=true
        fi
    else
        warn "uv installer failed. Falling back to pip."
        USE_PIP_DIRECTLY=true
    fi
fi

# ---------------------------------------------------------------------------
# Step 3: Install graphifyy (PyPI package — note the double-y)
# After install, the CLI command is `graphify` (single-y). Depends on
# networkx, graspologic, tree-sitter, and 13 language grammars.
# ---------------------------------------------------------------------------
step "Step 3/7: Installing graphifyy (knowledge graph tool) ..."
if $USE_PIP_DIRECTLY; then
    if $PYTHON -m pip install --user graphifyy --upgrade 2>&1; then
        ok "graphifyy installed via pip."
    else
        fail "Failed to install graphifyy."
        echo "  Try manually: pip install graphifyy"
        exit 1
    fi
else
    if uv tool install graphifyy --upgrade 2>&1; then
        ok "graphifyy installed via uv."
    else
        fail "Failed to install graphifyy."
        echo "  Try manually: pip install graphifyy"
        exit 1
    fi
fi

# ---------------------------------------------------------------------------
# Step 4: Register graphify as a Claude Code skill
# `graphify install` copies skill.md to ~/.claude/skills/graphify/SKILL.md
# and registers it in ~/.claude/CLAUDE.md. This is the only install
# command graphify provides — there is no 'antigravity install'.
# ---------------------------------------------------------------------------
step "Step 4/7: Registering graphify as Claude Code skill ..."
if graphify install 2>&1; then
    ok "Claude Code skill registered at ~/.claude/skills/graphify/SKILL.md"
else
    warn "graphify install failed. You can run it manually later."
fi

# ---------------------------------------------------------------------------
# Step 5: Install post-commit git hook
# `graphify hook install` adds a hook to .git/hooks/post-commit that
# auto-rebuilds the graph (AST-only, no LLM) on code changes.
# ---------------------------------------------------------------------------
step "Step 5/7: Installing post-commit git hook ..."
if graphify hook install 2>&1; then
    ok "Post-commit hook installed (auto-rebuilds graph on code changes)."
else
    warn "graphify hook install failed (non-critical)."
    echo "  This usually means you are not inside a git repository."
    echo "  Run 'git init' first, then 'graphify hook install' manually."
fi

# ---------------------------------------------------------------------------
# Step 6: Set up project-level graph-first rules (CLAUDE.md)
# CLAUDE.md is Claude Code's project instruction file. Loaded every session.
# Tells Claude to query the knowledge graph before reading raw files.
# ---------------------------------------------------------------------------
step "Step 6/7: Setting up graph-first rules (CLAUDE.md) ..."
CLAUDE_MD_SRC="$SCRIPT_DIR/CLAUDE.md"
CLAUDE_MD_DEST="$(pwd)/CLAUDE.md"

if [[ -f "$CLAUDE_MD_SRC" ]]; then
    if [[ -f "$CLAUDE_MD_DEST" ]]; then
        if grep -q "graphify" "$CLAUDE_MD_DEST" 2>/dev/null; then
            ok "CLAUDE.md already exists with graphify rules (no change)."
        else
            # Prepend our rules to existing CLAUDE.md
            echo "$(cat "$CLAUDE_MD_SRC")" > "$CLAUDE_MD_DEST"
            echo "" >> "$CLAUDE_MD_DEST"
            echo "" >> "$CLAUDE_MD_DEST"
            # No need to re-append since we just prepended
            ok "Graph-first rules prepended to existing CLAUDE.md."
        fi
    else
        cp -f "$CLAUDE_MD_SRC" "$CLAUDE_MD_DEST"
        ok "CLAUDE.md created with graph-first rules."
    fi
else
    warn "CLAUDE.md not found in script directory. Skipping rules setup."
fi

# ---------------------------------------------------------------------------
# Step 7: Install custom skills to .claude/skills/ (project-level)
# Claude Code discovers skills in .claude/skills/<name>/SKILL.md at startup.
# The directory name becomes the slash command name (e.g., /wrapup).
# ---------------------------------------------------------------------------
step "Step 7/7: Installing custom skills ..."
SKILLS_SRC_DIR="$SCRIPT_DIR/skills"

if [[ -d "$SKILLS_SRC_DIR" ]]; then
    SKILLS_DEST_ROOT="$(pwd)/.claude/skills"
    COMMANDS_DEST_ROOT="$(pwd)/.claude/commands"
    SKILL_COUNT=0

    # Copy skill directories containing SKILL.md
    for skill_dir in "$SKILLS_SRC_DIR"/*/; do
        [[ -d "$skill_dir" ]] || continue
        skill_name=$(basename "$skill_dir")
        skill_md="$skill_dir/SKILL.md"

        if [[ -f "$skill_md" ]]; then
            mkdir -p "$SKILLS_DEST_ROOT/$skill_name"
            cp -f "$skill_md" "$SKILLS_DEST_ROOT/$skill_name/SKILL.md"
            ok "Installed skill: /$skill_name"
            ((SKILL_COUNT++)) || true
        fi
    done

    # Copy top-level .md files as legacy commands (.claude/commands/)
    for skill_file in "$SKILLS_SRC_DIR"/*.md; do
        [[ -f "$skill_file" ]] || continue
        command_name=$(basename "$skill_file" .md)
        # Skip README.md — not a command
        [[ "$command_name" == "README" ]] && continue
        mkdir -p "$COMMANDS_DEST_ROOT"
        cp -f "$skill_file" "$COMMANDS_DEST_ROOT/$command_name.md"
        ok "Installed command: /$command_name"
        ((SKILL_COUNT++)) || true
    done

    if [[ "$SKILL_COUNT" -eq 0 ]]; then
        warn "No skills or commands found to install."
    else
        echo "  $SKILL_COUNT skill(s)/command(s) installed to .claude/"
    fi
else
    warn "skills/ directory not found. Skipping skill installation."
fi

# ---------------------------------------------------------------------------
# Done
# ---------------------------------------------------------------------------
echo ""
echo -e "${C_GREEN}============================================="
echo -e "  Antigravity workspace is ready!"
echo -e "=============================================${C_RESET}"
echo ""
echo -e "  Created by ${C_BOLD}Bilal Ansari${C_RESET} — https://ansaribilal.com"
echo ""
echo "  Next steps (inside Claude Code):"
echo ""
echo "  1. Open Claude Code in this directory"
echo "  2. Type  /graphify . --no-viz     to build the initial knowledge graph"
echo "  3. Type  /graphify query \"test\"   to query your codebase"
echo "  4. Type  /wrapup                   to save a session summary"
echo ""
echo "  Note: The initial graph build runs INSIDE Claude Code via the"
echo "  /graphify skill command. It is NOT a CLI command."
echo ""
echo "  Files created:"
echo "    - CLAUDE.md              (graph-first rules for this project)"
echo "    - .claude/skills/        (custom skills)"
echo "    - .git/hooks/post-commit (auto-rebuild on code changes)"
echo ""
echo -e "${C_RESET}  Repository: https://github.com/Bilal140202/antigravity-starter"
echo ""
