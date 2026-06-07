#Requires -Version 5.1
<#
.SYNOPSIS
    Antigravity Starter — One-command workspace bootstrapper for graph-first AI development.
.DESCRIPTION
    Automates the full setup of a graph-first, rules-enforced AI development environment.
    Installs graphifyy (Claude Code knowledge-graph skill), registers it as a Claude Code skill,
    installs post-commit git hooks, sets up project-level CLAUDE.md rules, and installs
    custom helper skills — all in a single command.

    This script is idempotent: running it multiple times is safe and will upgrade
    existing installations without destroying user data.

    PREREQUISITES:
      - Python 3.10 or newer
      - Claude Code installed (for using /graphify commands)
.NOTES
    Author:     Bilal Ansari
    Website:    https://ansaribilal.com
    Repository: https://github.com/Bilal140202/antigravity-starter
    License:    MIT

    WHAT THIS ACTUALLY INSTALLS:
      1. graphifyy (PyPI package, double-y) — provides the `graphify` CLI command
      2. Claude Code skill — via `graphify install` (copies skill to ~/.claude/skills/)
      3. Post-commit git hook — via `graphify hook install` (auto-rebuilds graph on commit)
      4. Project CLAUDE.md — graph-first rules for Claude Code (copied to current directory)
      5. Custom skills — helper skills in .claude/skills/ (project-level)

    WHAT THIS DOES NOT DO:
      - Does NOT require any authentication, login, or API keys
      - Does NOT build the initial graph (that must be done inside Claude Code via /graphify)
      - Does NOT install Claude Code itself (install that separately first)
.EXAMPLE
    .\install.ps1
.EXAMPLE
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

# Determine the directory where this script lives (for finding companion files)
$scriptDir = $PSScriptRoot
if (-not $scriptDir) {
    $scriptDir = (Get-Location).Path
}

# ----------------------------------------------------------------
# Step 1: Check Python 3.10+
# graphifyy requires Python 3.10+ for structural pattern matching
# (match/case statements) and other modern language features.
# ----------------------------------------------------------------
Write-Step "Step 1/7: Checking Python 3.10+ ..."
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

    Write-Success "Python $pythonVersion meets requirements."
}
catch {
    Write-Fail "Could not determine Python version."
    Write-Host "  Error: $_"
    exit 1
}

# ----------------------------------------------------------------
# Step 2: Install uv (Astral's Python package manager)
# uv is used to install graphifyy as a global tool. It is faster and
# more reliable than pip for tool installations. Falls back to pip
# if uv installation fails.
# ----------------------------------------------------------------
Write-Step "Step 2/7: Checking uv package manager ..."
$usePipDirectly = $false

if (Assert-Command "uv") {
    $uvVersion = uv --version 2>&1
    Write-Success "uv already installed ($uvVersion)."
}
else {
    # Try winget first (Windows package manager)
    if (Assert-Command "winget") {
        Write-Host "  Installing uv via winget ..."
        try {
            winget install astral-sh.uv --accept-package-agreements --accept-source-agreements 2>&1 | Out-Null

            # Refresh PATH for current session
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

            # Second attempt after PATH refresh
            if (-not (Assert-Command "uv")) {
                Write-Warn "uv installed but not on PATH. Trying direct path ..."
                $uvExe = Get-ChildItem -Path "$env:LOCALAPPDATA\Programs\uv" -Filter "uv.exe" -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
                if ($uvExe) {
                    $env:PATH = "$($uvExe.DirectoryName);$env:PATH"
                }
            }

            if (Assert-Command "uv")) {
                Write-Success "uv installed via winget."
            }
            else {
                Write-Warn "winget install succeeded but uv not on PATH. Falling back to pip."
                $usePipDirectly = $true
            }
        }
        catch {
            Write-Warn "winget install failed. Falling back to pip."
            $usePipDirectly = $true
        }
    }
    else {
        Write-Warn "winget not available. Falling back to pip."
        $usePipDirectly = $true
    }
}

# ----------------------------------------------------------------
# Step 3: Install graphifyy (the PyPI package — note double-y)
# graphifyy is the PyPI package name (the 'graphify' name is being
# reclaimed). After installation, the CLI command is `graphify` (single-y).
# graphifyy requires Python 3.10+ and depends on networkx, graspologic,
# tree-sitter, and 13 language-specific tree-sitter grammars.
# ----------------------------------------------------------------
Write-Step "Step 3/7: Installing graphifyy (knowledge graph tool) ..."
try {
    if ($usePipDirectly) {
        python -m pip install --user graphifyy --upgrade 2>&1 | ForEach-Object { Write-Host "  $_" }
    }
    else {
        uv tool install graphifyy --upgrade 2>&1 | ForEach-Object { Write-Host "  $_" }
    }
    Write-Success "graphifyy installed."
}
catch {
    Write-Fail "Failed to install graphifyy."
    Write-Host "  Error: $_"
    Write-Host "  Try manually: pip install graphifyy"
    exit 1
}

# ----------------------------------------------------------------
# Step 4: Register graphify as a Claude Code skill
# `graphify install` copies the skill definition to ~/.claude/skills/graphify/SKILL.md
# and registers it in ~/.claude/CLAUDE.md so Claude Code discovers it at startup.
# This is the ONLY install command graphify provides — there is no 'antigravity install'.
# ----------------------------------------------------------------
Write-Step "Step 4/7: Registering graphify as Claude Code skill ..."
try {
    graphify install 2>&1 | ForEach-Object { Write-Host "  $_" }
    Write-Success "Claude Code skill registered at ~/.claude/skills/graphify/SKILL.md"
}
catch {
    Write-Warn "graphify install failed: $_"
    Write-Host "  You can run 'graphify install' manually later."
}

# ----------------------------------------------------------------
# Step 5: Install post-commit git hook
# `graphify hook install` adds a post-commit hook to .git/hooks/post-commit
# that automatically rebuilds the knowledge graph (AST-only, no LLM needed)
# when code files change. Safe to run multiple times — checks for duplicates.
# ----------------------------------------------------------------
Write-Step "Step 5/7: Installing post-commit git hook ..."
try {
    graphify hook install 2>&1 | ForEach-Object { Write-Host "  $_" }
    Write-Success "Post-commit hook installed (auto-rebuilds graph on code changes)."
}
catch {
    Write-Warn "graphify hook install failed (non-critical): $_"
    Write-Host "  This usually means you're not inside a git repository."
    Write-Host "  Run 'git init' first, then 'graphify hook install' manually."
}

# ----------------------------------------------------------------
# Step 6: Set up project-level graph-first rules (CLAUDE.md)
# CLAUDE.md is Claude Code's project-level instruction file. It is loaded
# at the start of every session and tells Claude to query the knowledge
# graph before reading raw files — enforcing the "graph-first" protocol.
# ----------------------------------------------------------------
Write-Step "Step 6/7: Setting up graph-first rules (CLAUDE.md) ..."
$claudeMdSource = Join-Path $scriptDir "CLAUDE.md"
$claudeMdDest = Join-Path (Get-Location).Path "CLAUDE.md"

if (Test-Path $claudeMdSource) {
    if (Test-Path $claudeMdDest) {
        $existingContent = Get-Content $claudeMdDest -Raw
        if ($existingContent -match "graphify") {
            Write-Success "CLAUDE.md already exists with graphify rules (no change)."
        }
        else {
            # Prepend our rules to existing CLAUDE.md
            $newContent = (Get-Content $claudeMdSource -Raw) + "`n`n" + $existingContent
            Set-Content -Path $claudeMdDest -Value $newContent
            Write-Success "Graph-first rules prepended to existing CLAUDE.md."
        }
    }
    else {
        Copy-Item -Path $claudeMdSource -Destination $claudeMdDest
        Write-Success "CLAUDE.md created with graph-first rules."
    }
}
else {
    Write-Warn "CLAUDE.md not found in script directory. Skipping rules setup."
}

# ----------------------------------------------------------------
# Step 7: Install custom skills to .claude/skills/ (project-level)
# Claude Code discovers skills in .claude/skills/<name>/SKILL.md at startup.
# Each skill's directory name becomes its slash command (e.g., /wrapup).
# ----------------------------------------------------------------
Write-Step "Step 7/7: Installing custom skills ..."
$skillsSourceDir = Join-Path $scriptDir "skills"

if (Test-Path $skillsSourceDir) {
    # Copy skill directories that contain a SKILL.md file
    $skillDirs = Get-ChildItem -Path $skillsSourceDir -Directory
    $skillsDestRoot = Join-Path (Get-Location).Path ".claude" "skills"
    $skillCount = 0

    foreach ($skillDir in $skillDirs) {
        $skillMd = Join-Path $skillDir.FullName "SKILL.md"
        if (Test-Path $skillMd) {
            $destDir = Join-Path $skillsDestRoot $skillDir.Name
            # Copy entire skill directory (SKILL.md + all reference files)
            Copy-Item -Path $skillDir.FullName -Destination $destDir -Recurse -Force
            Write-Success "Installed skill: /$($skillDir.Name)"
            $skillCount++
        }
    }

    # Also copy any top-level .md files as legacy commands (.claude/commands/)
    $skillFiles = Get-ChildItem -Path $skillsSourceDir -Filter "*.md" -File
    $commandsDestRoot = Join-Path (Get-Location).Path ".claude" "commands"
    foreach ($skillFile in $skillFiles) {
        if (-not (Test-Path $commandsDestRoot)) {
            New-Item -ItemType Directory -Path $commandsDestRoot -Force | Out-Null
        }
        $commandName = $skillFile.BaseName
        # Skip README.md — not a command
        if ($commandName -eq "README") { continue }
        Copy-Item -Path $skillFile.FullName -Destination (Join-Path $commandsDestRoot "$commandName.md") -Force
        Write-Success "Installed command: /$commandName"
        $skillCount++
    }

    if ($skillCount -eq 0) {
        Write-Warn "No skills or commands found to install."
    }
    else {
        Write-Host "  $skillCount skill(s)/command(s) installed to .claude/"
    }
}
else {
    Write-Warn "skills/ directory not found. Skipping skill installation."
}

# ----------------------------------------------------------------
# Installation complete — print summary and next steps
# ----------------------------------------------------------------
Write-Host ""
Write-Host -ForegroundColor Green "============================================="
Write-Host -ForegroundColor Green "  Antigravity workspace is ready!"
Write-Host -ForegroundColor Green "============================================="
Write-Host ""
Write-Host "  Created by Bilal Ansari - https://ansaribilal.com"
Write-Host ""
Write-Host "  Next steps (inside Claude Code):"
Write-Host ""
Write-Host "  1. Open Claude Code in this directory"
Write-Host "  2. Type  /graphify . --no-viz     to build the initial knowledge graph"
Write-Host "  3. Type  /graphify query `"test`"   to query your codebase"
Write-Host "  4. Type  /wrapup                   to save a session summary"
Write-Host ""
Write-Host "  Note: The initial graph build runs INSIDE Claude Code via the"
Write-Host "  /graphify skill command. It is NOT a CLI command."
Write-Host ""
Write-Host "  Files created:"
Write-Host "    - CLAUDE.md              (graph-first rules for this project)"
Write-Host "    - .claude/skills/        (custom skills)"
Write-Host "    - .git/hooks/post-commit (auto-rebuild on code changes)"
Write-Host ""
Write-Host -ForegroundColor DarkGray "  Repository: https://github.com/Bilal140202/antigravity-starter"
Write-Host ""
