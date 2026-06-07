#!/usr/bin/env bash
# ==============================================================================
# Antigravity Starter — One-command workspace bootstrapper
#
# Automates the full setup of a graph-first, rules-enforced AI development
# environment for Google Antigravity IDE. Installs graphifyy, shared rules,
# IDE skills, and builds the initial codebase knowledge graph.
#
# This script is idempotent: running it multiple times is safe and will
# upgrade existing installations without destroying user data.
#
# Author:     Bilal Ansari
# Website:    https://ansaribilal.com
# Repository: https://github.com/Bilal140202/antigravity-starter
# License:    MIT
#
# Quick start:
#   curl -fsSL https://raw.githubusercontent.com/Bilal140202/antigravity-starter/main/install.sh | bash
# ==============================================================================

set -euo pipefail

# ---------------------------------------------------------------------------
# Colour helpers — disabled when stdout is not a terminal (e.g. CI pipelines)
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

# ---------------------------------------------------------------------------
# Step 1: Python 3.10+
# graphifyy requires Python 3.10+ for match statements and modern syntax.
# ---------------------------------------------------------------------------
step "Checking Python 3.10+ ..."
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

ok "Python version meets requirements."

# ---------------------------------------------------------------------------
# Step 2: Install uv
# uv is Astral's fast Python package manager (same team behind Ruff).
# It manages tool installations, virtual environments, and dependencies.
# ---------------------------------------------------------------------------
step "Checking uv package manager ..."
if command_exists uv; then
    UV_VERSION=$(uv --version 2>&1)
    ok "uv already installed ($UV_VERSION)."
else
    echo "  Installing uv via official installer ..."
    if curl -LsSf https://astral.sh/uv/install.sh | sh; then
        # Source the updated profile so 'uv' is available in this session
        export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$PATH"

        if command_exists uv; then
            ok "uv installed successfully."
        else
            warn "uv installed but not yet on PATH. Restart your terminal or run:"
            echo "    export PATH=\"\$HOME/.local/bin:\$PATH\""
            exit 1
        fi
    else
        fail "Failed to install uv."
        echo "  Install manually: https://docs.astral.sh/uv/getting-started/installation/"
        exit 1
    fi
fi

# ---------------------------------------------------------------------------
# Step 3: Install graphifyy via uv
# graphifyy (double-y) is the PyPI package name. It provides the `graphify`
# CLI for codebase knowledge graph generation and AI-assisted workflows.
# ---------------------------------------------------------------------------
step "Installing graphifyy (graph-first code intelligence) ..."
if uv tool install graphifyy --upgrade 2>&1; then
    ok "graphifyy installed."
else
    fail "Failed to install graphifyy."
    echo "  Try manually: uv tool install graphifyy"
    exit 1
fi

# ---------------------------------------------------------------------------
# Step 4: Run graphify antigravity install
# Sets up the Antigravity IDE extension within graphify for graph-first AI.
# ---------------------------------------------------------------------------
step "Running graphify antigravity install ..."
if graphify antigravity install 2>&1; then
    ok "Antigravity extension installed."
else
    warn "graphify antigravity install failed (may not be required yet)."
fi

# ---------------------------------------------------------------------------
# Step 5: Copy RULES.md to agent-rules-sync directory
# RULES.md enforces the "Workspace Action Proof" protocol — two hard
# requirements: (1) Graph First, (2) Agent Selection. Synced to the
# standard config location for global enforcement across all projects.
# ---------------------------------------------------------------------------
step "Installing shared rules ..."
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RULES_SRC="$SCRIPT_DIR/RULES.md"
RULES_DEST_DIR="$HOME/.config/agent-rules-sync"
RULES_DEST="$RULES_DEST_DIR/RULES.md"

mkdir -p "$RULES_DEST_DIR"

if [[ -f "$RULES_SRC" ]]; then
    cp -f "$RULES_SRC" "$RULES_DEST"
    ok "RULES.md copied to $RULES_DEST"
else
    warn "RULES.md not found at $RULES_SRC. Skipping rules installation."
fi

# ---------------------------------------------------------------------------
# Step 6: Copy skills to .agents/skills/
# Skills are markdown files with YAML frontmatter that extend the AI with
# specialised workflows (NotebookLM, session wrapup). Auto-detected by IDE.
# ---------------------------------------------------------------------------
step "Installing skills ..."
SKILLS_SRC_DIR="$SCRIPT_DIR/skills"
SKILLS_DEST_DIR="$(pwd)/.agents/skills"

if [[ -d "$SKILLS_SRC_DIR" ]]; then
    mkdir -p "$SKILLS_DEST_DIR"
    SKILL_COUNT=0
    for skill_file in "$SKILLS_SRC_DIR"/*.md; do
        [[ -f "$skill_file" ]] || continue
        cp -f "$skill_file" "$SKILLS_DEST_DIR/"
        ok "Installed skill: $(basename "$skill_file")"
        ((SKILL_COUNT++)) || true
    done
    echo "  $SKILL_COUNT skill(s) installed to .agents/skills/"
else
    warn "skills/ directory not found. Skipping skill installation."
fi

# ---------------------------------------------------------------------------
# Step 7: Install graphify hooks
# Hooks integrate graphify into the AI agent's workflow for automatic graph
# maintenance and query capabilities during development.
# ---------------------------------------------------------------------------
step "Installing graphify hooks ..."
if graphify hook install 2>&1; then
    ok "Graphify hooks installed."
else
    warn "graphify hook install failed (non-critical)."
fi

# ---------------------------------------------------------------------------
# Step 8: Initial graph build (no visualisation)
# Builds the knowledge graph of the workspace — captures code structure,
# dependencies, and relationships for AI-powered querying.
# ---------------------------------------------------------------------------
step "Building initial knowledge graph (no visualisation) ..."
if graphify . --no-viz 2>&1; then
    ok "Initial graph built."
else
    warn "Initial graph build failed — this is normal for empty projects."
    echo "  Run 'graphify .' manually once your code is in place."
fi

# ---------------------------------------------------------------------------
# Installation complete — print summary and next steps
# ---------------------------------------------------------------------------
echo ""
echo -e "${C_GREEN}============================================="
echo -e "  Antigravity workspace is ready!"
echo -e "=============================================${C_RESET}"
echo ""
echo -e "  Created by ${C_BOLD}Bilal Ansari${C_RESET} — https://ansaribilal.com"
echo ""
echo "  Next steps:"
echo ""
echo "  1. Run 'graphify .'          to rebuild the knowledge graph"
echo "  2. Type  '/graphify query'   to query your codebase"
echo "  3. Type  '/notebooklm'       to open NotebookLM skill"
echo "  4. Type  '/wrapup'           to save session summary"
echo ""
echo "  NOTE: First run may open a browser for Google login — sign in once."
echo ""
echo "  Rules installed at: $RULES_DEST"
echo "  Skills installed at: $SKILLS_DEST_DIR"
echo ""
echo -e "${C_RESET}  Repository: https://github.com/Bilal140202/antigravity-starter"
echo ""
