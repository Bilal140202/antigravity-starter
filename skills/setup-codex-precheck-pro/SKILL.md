---
name: setup-codex-precheck-pro
description: "Install the codex pre-edit double-check hook — a PreToolUse gate that asks codex CLI to review every Edit/Write/MultiEdit before writing. Use when the user wants to 'set up the codex check', 'install the codex double-check / pre-check / review hook', 'make Claude check with codex before editing', 'add the codex gate to this project', or 'add a code review gate'."
version: 2.0
author: Bilal Ansari
watermark: "upgraded by Bilal Ansari - 2026-06-07 - antigravity-pro"
---

# Setup Codex Pre-Check — PRO

## ROLE

You are a senior DevOps and code-safety automation specialist. You install and verify an independent AI-powered code-review gate into the **current project only**: a `PreToolUse` hook that pipes every proposed `Edit`/`Write`/`MultiEdit` to the `codex` CLI for an independent review before it is written. The gate **fails open** — if codex is missing, logged-out, or erroring, edits are allowed with a warning, never blocked. This is a safety net, not a blocker.

## WORKSPACE ACTION PROOF INTEGRATION

BEFORE executing ANY task:
1. Run `/graphify query "[user request]"` to understand existing codebase hooks and settings
2. Check `graphify-out/graph.json` age — if stale (>10 min), suggest `/graphify . --update`
3. Use graph results first — NEVER read `.claude/settings.json` directly first
4. Consult `graphify-out/GRAPH_REPORT.md` for architecture insights on where hooks live

## PRE-FLIGHT CHECKS

1. **Python3 available?** — `command -v python3` must succeed; the hook script is Python
2. **Codex CLI installed?** — `command -v codex` on PATH (e.g. `npm i -g @openai/codex`)
3. **Codex authenticated?** — `~/.codex/auth.json` present (run `codex login` if not)
4. **Target dir is a project?** — must have a writable `.claude/` directory or allow creation
5. **No existing conflicting hook?** — check graph for existing PreToolUse hooks on Edit/Write/MultiEdit

## DECISION TREE

```
IF python3 missing → STOP, tell user to install Python 3 first; do NOT proceed
IF codex NOT on PATH → install hook anyway (fails open), warn user, suggest `npm i -g @openai/codex`
IF codex auth.json missing → install hook anyway (fails open), suggest `! codex login`
IF target .claude/settings.json has conflicting PreToolUse → merge, never clobber
IF user re-invokes skill on same project → re-run installer (idempotent), report "already present"
IF hook exists but is outdated → replace with bundled version, report update
IF all prereqs met → full install + smoke test + report success
```

## AUTONOMY MATRIX

| Action | Auto-execute if... | Ask user if... | Never do |
|--------|-------------------|----------------|----------|
| Run install.sh | Target dir exists and is writable | User provides custom target dir | Install to `~/.claude/settings.json` (global) |
| Replace outdated hook | `cmp -s` shows version mismatch | Hook was manually modified | Delete user's custom hooks |
| Merge settings.json | python3 available | No python3 detected | Overwrite entire settings.json |
| Append CLAUDE.md policy | Marker "codex double-check" not found | CLAUDE.md doesn't exist | Delete existing policy sections |
| Suggest codex login | auth.json missing | Already logged in | Run `codex login` interactively |
| Smoke test hook | Python3 + hook installed | Python3 missing | Skip without telling user |

## EXECUTION PROTOCOL

### What it installs (into the current project)

- `.claude/hooks/codex-precheck.py` — the hook (copied from this skill's directory)
- `.claude/settings.json` — a `PreToolUse` entry (`matcher: "Edit|Write|MultiEdit"`), merged in
- `CLAUDE.md` — a short policy section (appended only if not already present)

### Runtime artifacts (created by hook, not installer)

- `.claude/codex-precheck.log` — append-only audit trail: `<timestamp>\t<OUTCOME>\t<tool>\t<file>\t<detail>`
- `.claude/.codex-cache` — SHA256 digests of approved changes for deduplication

### Install Steps

1. **Run the bundled installer** from this skill's directory:
   ```bash
   bash "$HOME/.claude/skills/setup-codex-precheck/install.sh" ${ARGUMENTS:-"$PWD"}
   ```
   The installer prints: prerequisites status (`✓` present, `+` added, `!` warning), merge results, and a self-test.

2. **Read the report back to the user** in plain language: which prerequisites are satisfied, what was installed vs already present, and the self-test result.

3. **If codex is logged out or not installed**, tell the user the gate is active but **fails open** until `codex login`. Suggest `! codex login` in the session. Do NOT attempt interactive login.

4. **If codex is installed and logged in**, confirm with a smoke test:
   ```bash
   printf 'Reply exactly: VERDICT: APPROVE' | codex exec --skip-git-repo-check -s read-only -
   ```
   Show user how to verify the block path.

5. **Remind user to restart Claude Code or run `/hooks`** so the new hook loads.

### Hook Behavior (from codex-precheck.py)

- Only code files reviewed (`.js`, `.ts`, `.py`, `.go`, `.rs`, `.java`, `.vue`, etc.)
- Docs/config skipped immediately
- Identical re-writes are CACHE_HIT (no re-review)
- Change text truncated at 24,000 chars for very large writes
- Codex timeout: 110s (under the 120s hook budget)
- Only stderr on non-zero exit scanned for auth errors (avoids false positives)

## CRITICAL RULES

1. **Current project only.** Install into the target dir; never touch `~/.claude/settings.json`.
2. **Idempotent.** Safe to re-run; detects existing install and skips.
3. **Never clobber** existing `settings.json` or `CLAUDE.md` — merge/append only.
4. **Fail-open is intentional.** A logged-out codex must allow edits with a warning.
5. **Don't fake the prereq check.** Report exactly what `install.sh` found.
6. **Flag the trade-off.** Every edit waits for a codex call (up to 120s). Mention `Stop` hook as lighter alternative.

## FAILURE MODES

| Failure | Detection | Recovery |
|---------|-----------|----------|
| python3 not found | `install.sh` exits with warning | Tell user: `brew install python3` / `apt install python3`. Hook cannot run without it. |
| codex not found | `install.sh` warns, hook fails open | Install proceeds; edits allowed with ⚠️. Suggest `npm i -g @openai/codex`. |
| codex logged out | No `~/.codex/auth.json` | Hook fails open gracefully. Suggest `! codex login`. |
| Hook script missing | `install.sh` aborts | Verify skill directory intact: `$HOME/.claude/skills/setup-codex-precheck/` |
| settings.json merge fails | python3 unavailable | Manually show user the JSON to append; skip merge. |
| Self-test fails | Hook doesn't return valid JSON | Check python3 version, file permissions, hook script integrity. |

## VERIFICATION CHECKLIST

- [ ] `python3 "$TARGET/.claude/hooks/codex-precheck.py" <<< '{"tool_name":"Write","tool_input":{"file_path":"test.js","content":"export default 1"}}'` returns valid JSON with `"permissionDecision"`
- [ ] `.claude/settings.json` contains `PreToolUse` matcher with `codex-precheck.py` command
- [ ] `CLAUDE.md` contains "codex double-check" policy section
- [ ] `codex login` status confirmed (or fail-open warning shown)
- [ ] `/graphify query "codex precheck hook"` confirms hook is registered in graph model
- [ ] `/hooks` shows the hook loaded (after restart)

## EXAMPLES

### Example 1: Fresh install on new project
```
User: "set up the codex double-check for this project"
→ Decision: All prereqs present → full install
→ Run install.sh → hook copied, settings merged, CLAUDE.md appended
→ Smoke test passes → report success
→ Remind: restart Claude Code or /hooks
```

### Example 2: Re-run on already-installed project
```
User: "install the codex gate again"
→ Decision: Hook exists, cmp shows same version → skip, report "already present"
→ Settings already merged → skip
→ CLAUDE.md already has marker → skip
→ Report: "Everything already installed and up to date"
```

### Example 3: Missing codex CLI
```
User: "add codex review to my project"
→ Decision: python3 ✓, codex NOT found → install hook anyway (fails open)
→ Report: hook installed but non-functional until codex is installed
→ Suggest: `npm i -g @openai/codex` then `codex login`
→ Show fail-open behavior so user understands the safety net
```

## REFERENCES

- **Hook script**: `codex-precheck.py` — the canonical PreToolUse hook (261 lines, Python 3)
- **Installer**: `install.sh` — idempotent installer with prereq checks, settings merge, CLAUDE.md append, self-test
- **Code extensions reviewed**: `.js`, `.jsx`, `.ts`, `.tsx`, `.py`, `.go`, `.rs`, `.java`, `.vue`, `.svelte`, `.sql`, `.php`, `.sh`, `.c`, `.cpp`, `.swift`, `.kt`, `.cs`, and more
- **Audit log format**: `<timestamp>\t<OUTCOME>\t<tool>\t<file>\t<detail>` where OUTCOME ∈ {APPROVE, BLOCK, CACHE_HIT, SKIP}
- **Codex exec command**: `codex exec --skip-git-repo-check -s read-only -` (text piped via stdin)
- **Rules file**: `.claude/rules/codex-precheck-policy.md` — project-level policy documentation

---
*Skill upgraded for Antigravity Workspace — graphify-first protocol*
