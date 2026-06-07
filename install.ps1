#Requires -Version 5.1
<#
.SYNOPSIS
    Antigravity Starter — One-command workspace bootstrapper for Google Antigravity IDE.
.DESCRIPTION
    Automates the full setup of a graph-first, rules-enforced AI development environment.
    Installs graphifyy (Python knowledge-graph tool), shared rules, IDE skills, and
    builds the initial codebase knowledge graph — all in a single command.

    This script is idempotent: running it multiple times is safe and will upgrade
    existing installations without destroying user data.
.NOTES
    Author:     Bilal Ansari
    Website:    https://ansaribilal.com
    Repository: https://github.com/Bilal140202/antigravity-starter
    License:    MIT
.PARAMETER Force
    Skip confirmation prompts (reserved for future interactive use).
.EXAMPLE
    # Run locally from the cloned repository
    .\install.ps1

.EXAMPLE
    # Run remotely via PowerShell one-liner
    iwr https://raw.githubusercontent.com/Bilal140202/antigravity-starter/main/install.ps1 | iex
#>

param([switch]$Force)

$ErrorActionPreference = "Stop"

# ---------------------------------------------------------------------------
# Logging helpers — coloured output for terminal clarity
# ---------------------------------------------------------------------------
function Write-Step($message) {
    Write-Host ""
    Write-Host -ForegroundColor Cyan "==> $message"
}

function Write-Success($message) {
    Write-Host -ForegroundColor Green "  [OK] $message"
}

function Write-Warn($message) {
    Write-Host -ForegroundColor Yellow "  [WARN] $message"
}

function Write-Fail($message) {
    Write-Host -ForegroundColor Red "  [FAIL] $message"
}

function Assert-Command($name) {
    try {
        $null = Get-Command $name -ErrorAction Stop
        return $true
    }
    catch {
        return $false
    }
}

# ----------------------------------------------------------------
# Step 1: Check Python 3.10+
# graphifyy requires Python 3.10 or newer for match statements and
# other modern syntax features.
# ----------------------------------------------------------------
Write-Step "Checking Python 3.10+ ..."
if (-not (Assert-Command "python")) {
    Write-Fail "Python is not installed or not on PATH."
    Write-Host "  Install Python 3.10+ from https://www.python.org/downloads/"
    Write-Host "  Make sure to check 'Add Python to PATH' during installation."
    exit 1
}

try {
    $pythonVersion = python --version 2>&1 | ForEach-Object { $_ -replace "Python ", "" }
    Write-Host "  Found Python $pythonVersion"

    # Parse major.minor for version comparison
    $parts = $pythonVersion -split '\.'
    $major = [int]$parts[0]
    $minor = [int]$parts[1]

    if ($major -lt 3 -or ($major -eq 3 -and $minor -lt 10)) {
        Write-Fail "Python 3.10 or newer is required (found $pythonVersion)."
        Write-Host "  Upgrade at https://www.python.org/downloads/"
        exit 1
    }

    Write-Success "Python version meets requirements."
}
catch {
    Write-Fail "Could not determine Python version."
    Write-Host "  Error: $_"
    exit 1
}

# ----------------------------------------------------------------
# Step 2: Install uv via winget
# uv is the fast Python package manager from Astral (creators of Ruff).
# It manages Python tool installations, virtual environments, and
# dependency resolution — used here to install graphifyy.
# ----------------------------------------------------------------
Write-Step "Checking uv package manager ..."
if (Assert-Command "uv") {
    $uvVersion = uv --version 2>&1
    Write-Success "uv already installed ($uvVersion)."
}
else {
    if (Assert-Command "winget") {
        Write-Host "  Installing uv via winget ..."
        try {
            winget install astral-sh.uv --accept-package-agreements --accept-source-agreements 2>&1 | Out-Null

            # Refresh PATH for current session — uv installs to common locations
            $uvPaths = @(
                "$env:LOCALAPPDATA\Programs\uv",
                "$env:USERPROFILE\.local\bin",
                "$env:USERPROFILE\.cargo\bin"
            )
            foreach ($p in $uvPaths) {
                if ((Test-Path $p) -and (-not $env:PATH.Contains($p))) {
                    $env:PATH = "$p;$env:PATH"
                }
            }

            if (-not (Assert-Command "uv")) {
                Write-Warn "uv installed but not yet on PATH. You may need to restart your terminal."
                Write-Host "  Attempting to use common path ..."
                $uvExe = Get-ChildItem -Path "$env:LOCALAPPDATA\Programs\uv" -Filter "uv.exe" -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
                if ($uvExe) {
                    $env:PATH = "$($uvExe.DirectoryName);$env:PATH"
                }
            }

            if (Assert-Command "uv") {
                Write-Success "uv installed successfully."
            }
            else {
                Write-Fail "uv installed but not found on PATH. Restart your terminal and run this script again."
                exit 1
            }
        }
        catch {
            Write-Fail "Failed to install uv via winget."
            Write-Host "  Error: $_"
            Write-Host "  Install uv manually: https://docs.astral.sh/uv/getting-started/installation/"
            exit 1
        }
    }
    else {
        Write-Fail "winget is not available. Install uv manually:"
        Write-Host "  powershell -ExecutionPolicy ByPass -c `"irm https://astral.sh/uv/install.ps1 | iex`""
        exit 1
    }
}

# ----------------------------------------------------------------
# Step 3: Install graphifyy via uv
# graphifyy (double-y) is the Python package name on PyPI. It provides
# the `graphify` CLI command for codebase knowledge graph generation,
# querying, and AI-assisted development workflow hooks.
# ----------------------------------------------------------------
Write-Step "Installing graphifyy (graph-first code intelligence) ..."
try {
    uv tool install graphifyy --upgrade 2>&1 | ForEach-Object { Write-Host "  $_" }
    Write-Success "graphifyy installed."
}
catch {
    Write-Fail "Failed to install graphifyy."
    Write-Host "  Error: $_"
    Write-Host "  Try manually: uv tool install graphifyy"
    exit 1
}

# ----------------------------------------------------------------
# Step 4: Run graphify antigravity install
# Sets up the Antigravity IDE extension within graphify, configuring
# the workspace for graph-first AI interactions.
# ----------------------------------------------------------------
Write-Step "Running graphify antigravity install ..."
try {
    graphify antigravity install 2>&1 | ForEach-Object { Write-Host "  $_" }
    Write-Success "Antigravity extension installed."
}
catch {
    Write-Warn "graphify antigravity install failed (may not be required yet): $_"
}

# ----------------------------------------------------------------
# Step 5: Copy RULES.md to agent-rules-sync directory
# RULES.md enforces the "Workspace Action Proof" protocol — two hard
# requirements that every AI interaction must follow:
#   1. Graph First — query the knowledge graph before reading files
#   2. Agent Selection — choose the correct specialised agent based on context
# This file is synced to the standard config location so it applies globally.
# ----------------------------------------------------------------
Write-Step "Installing shared rules ..."
$rulesDestDir = Join-Path $HOME ".config" "agent-rules-sync"
$rulesDest = Join-Path $rulesDestDir "RULES.md"

if (-not (Test-Path $rulesDestDir)) {
    New-Item -ItemType Directory -Path $rulesDestDir -Force | Out-Null
}

# Locate RULES.md next to this script
$scriptDir = $PSScriptRoot
if (-not $scriptDir) {
    $scriptDir = (Get-Location).Path
}
$rulesSource = Join-Path $scriptDir "RULES.md"

if (Test-Path $rulesSource) {
    Copy-Item -Path $rulesSource -Destination $rulesDest -Force
    Write-Success "RULES.md copied to $rulesDest"
}
else {
    Write-Warn "RULES.md not found at $rulesSource. Skipping rules installation."
}

# ----------------------------------------------------------------
# Step 6: Copy skills to .agents/skills/
# Skills are markdown files with YAML frontmatter that extend the AI
# assistant with specialised workflows. They are placed in .agents/skills/
# where the Antigravity IDE auto-detects them.
# Available skills: notebooklm (persistent memory), wrapup (session summary)
# ----------------------------------------------------------------
Write-Step "Installing skills ..."
$skillsSourceDir = Join-Path $scriptDir "skills"
$skillsDestDir = Join-Path (Get-Location).Path ".agents" "skills"

if (Test-Path $skillsSourceDir) {
    if (-not (Test-Path $skillsDestDir)) {
        New-Item -ItemType Directory -Path $skillsDestDir -Force | Out-Null
    }

    $skillFiles = Get-ChildItem -Path $skillsSourceDir -Filter "*.md" -File
    foreach ($skill in $skillFiles) {
        Copy-Item -Path $skill.FullName -Destination $skillsDestDir -Force
        Write-Success "Installed skill: $($skill.Name)"
    }

    $skillCount = @($skillFiles).Count
    Write-Host "  $skillCount skill(s) installed to .agents/skills/"
}
else {
    Write-Warn "skills/ directory not found. Skipping skill installation."
}

# ----------------------------------------------------------------
# Step 7: Install graphify hooks
# Hooks integrate graphify into the AI agent's workflow, ensuring
# automatic graph maintenance and query capabilities.
# ----------------------------------------------------------------
Write-Step "Installing graphify hooks ..."
try {
    graphify hook install 2>&1 | ForEach-Object { Write-Host "  $_" }
    Write-Success "Graphify hooks installed."
}
catch {
    Write-Warn "graphify hook install failed (non-critical): $_"
}

# ----------------------------------------------------------------
# Step 8: Initial graph build (no visualisation)
# Builds the knowledge graph of the current workspace without generating
# HTML visualisation files. The graph captures code structure, dependencies,
# and relationships for AI-powered querying via `graphify query`.
# ----------------------------------------------------------------
Write-Step "Building initial knowledge graph (no visualisation) ..."
try {
    graphify . --no-viz 2>&1 | ForEach-Object { Write-Host "  $_" }
    Write-Success "Initial graph built."
}
catch {
    Write-Warn "Initial graph build failed — this is normal for empty projects."
    Write-Host "  Run 'graphify .' manually once your code is in place."
}

# ----------------------------------------------------------------
# Installation complete — print summary and next steps
# ----------------------------------------------------------------
Write-Host ""
Write-Host -ForegroundColor Green "============================================="
Write-Host -ForegroundColor Green "  Antigravity workspace is ready!"
Write-Host -ForegroundColor Green "============================================="
Write-Host ""
Write-Host "  Created by Bilal Ansari — https://ansaribilal.com"
Write-Host ""
Write-Host "  Next steps:"
Write-Host ""
Write-Host "  1. Run 'graphify .'          to rebuild the knowledge graph"
Write-Host "  2. Type  '/graphify query'   to query your codebase"
Write-Host "  3. Type  '/notebooklm'       to open NotebookLM skill"
Write-Host "  4. Type  '/wrapup'           to save session summary"
Write-Host ""
Write-Host "  NOTE: First run may open a browser for Google login — sign in once."
Write-Host ""
Write-Host "  Rules installed at: $rulesDest"
Write-Host "  Skills installed at: $skillsDestDir"
Write-Host ""
Write-Host -ForegroundColor DarkGray "  Repository: https://github.com/Bilal140202/antigravity-starter"
Write-Host ""
