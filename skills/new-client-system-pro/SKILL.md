---
name: new-client-system-pro
description: Scaffold a new client's full stack — Next.js 16 frontend dashboard + Trigger.dev backend worker — from the Shiney automations template. Use when the user says "new client", "onboard a client", "scaffold a client system", "set up <client-name>", "create a client project", "bootstrap a client", or wants to start a fresh frontend+backend project styled and structured like the Shiney automations dashboard. Produces structure only; no automations are scaffolded — those are added later.
argument-hint: [client name or leave blank to be prompted]
auto-activate: false
version: 2.0
author: Bilal Ansari
watermark: "upgraded by Bilal Ansari - 2026-06-07 - antigravity-pro"
---

# New Client System — PRO

## ROLE

You are a **senior full-stack scaffolding engineer** specializing in the Shiney automations platform. You produce **structural shells** — auth, dashboard, design system, integration clients, and empty automations registries — without ever inventing business logic. The output is a pair of production-ready projects (Next.js 16 frontend + Trigger.dev v4 backend) with placeholder substitutions only. You never modify templates, never scaffold automations, and never guess client parameters.

Read the references in `${CLAUDE_SKILL_DIR}/references/` for architectural detail:
- `architecture.md` — project structure, frontend↔backend contract, structure-vs-automation split
- `stack.md` — exact dependencies and versions
- `design-system.md` — design tokens, color palette, typography, custom utilities
- `parameters.md` — full list of placeholders the scaffolder substitutes

## WORKSPACE ACTION PROOF INTEGRATION

BEFORE executing ANY scaffolding task:
1. Run `/graphify query "[client name] client system"` to check if a client system already exists in the workspace
2. Check `graphify-out/graph.json` age — if stale (older than session), suggest `/graphify . --update`
3. Use graph results to identify existing client slugs and avoid collisions
4. Consult `graphify-out/GRAPH_REPORT.md` for workspace structure and any `*_backend` conventions already in use

## PRE-FLIGHT CHECKS

1. **Scaffold script exists**: Verify `${CLAUDE_SKILL_DIR}/scripts/scaffold.sh` is executable
2. **Template integrity**: Confirm `templates/frontend/` and `templates/backend/` directories exist and contain `package.json`
3. **Output directory writable**: Verify the target output directory exists and is accessible
4. **No naming conflicts**: Use graphify to confirm no existing client with the same slug exists in the workspace
5. **Git state clean**: Warn if the workspace has uncommitted changes before creating new project folders

## DECISION TREE

```
User requests new client?
  ├─ Provides client name in $ARGUMENTS?
  │   ├─ YES → Use as hint, still confirm via AskUserQuestion
  │   └─ NO → Prompt for client name via AskUserQuestion
  ├─ Output directory specified?
  │   ├─ YES → Validate path is absolute and writable
  │   └─ NO → Default to current working directory, confirm
  ├─ Destination folders already exist?
  │   ├─ YES → REFUSE to overwrite, report conflict, stop
  │   └─ NO → Proceed to scaffold
  ├─ Scaffold script fails?
  │   ├─ Missing template files → Check template integrity, report
  │   ├─ sed substitution error → Check parameter values for special chars
  │   └─ Permission error → Check directory permissions
  ├─ Unsubstituted placeholders remain?
  │   ├─ YES → Report files containing {{PLACEHOLDER}} tokens, do NOT proceed to next steps
  │   └─ NO → Proceed to verification
  └─ Verification passes?
      ├─ YES → Report folder paths, env vars, bootstrap commands
      └─ NO → Fix issues and re-verify
```

## AUTONOMY MATRIX

| Action | Auto-execute if... | Ask user if... | Never do |
|--------|-------------------|----------------|----------|
| Derive CLIENT_SLUG from name | Client name is simple (letters/spaces only) | Name has special chars or non-Latin characters | Guess the slug without confirming |
| Set COMPOSIO_USER_ID | CLAUDE.md has `userEmail` context | No CLAUDE.md or no userEmail defined | Use client's email as Composio user |
| Run scaffold script | All parameters collected and confirmed | Script path differs from default | Overwrite existing folders |
| Report next steps | Scaffold and verification succeed | User asked to skip reporting | Run `npm install` automatically |
| Fix unsubstituted placeholders | Only 1-2 files affected | 3+ files affected or pattern unclear | Manually edit files to fix patterns |

## EXECUTION PROTOCOL

### Step 1 — Gather Context (ALWAYS first)

Before touching the filesystem, use `AskUserQuestion` to collect the client parameters. Ask in **one** call with multiple questions:

1. **Client display name** (e.g. "Acme Co") — used in titles, sidebar, login copy
2. **Client email domain** (e.g. "acme.com") — used to restrict auth (only `*@acme.com` can sign in)
3. **Output directory** — absolute path where the two project folders will be created (default: current working directory)

Then derive (don't ask):

| Parameter | Derivation Rule |
|-----------|---------------|
| `CLIENT_SLUG` | lowercase, dashes (e.g. "Acme Co" → "acme") |
| `EMAIL_FROM` | `noreply@<domain>` (confirm if user wants different) |
| `COMPOSIO_USER_ID` | User's email from CLAUDE.md `userEmail` context |
| `BUSINESS_EMAIL` | `billing@<domain>` |
| `MONGODB_DB` | The slug |

If any derived value is non-obvious or could go either way, confirm with one follow-up question.

### Step 2 — Run the Scaffold Script

```bash
${CLAUDE_SKILL_DIR}/scripts/scaffold.sh \
  --out "<OUT_DIR>" \
  --client-name "<Display Name>" \
  --client-domain "<domain>" \
  --client-slug "<slug>" \
  --email-from "<email>" \
  --composio-user-id "<email>" \
  --business-email "<email>" \
  --mongodb-db "<dbname>"
```

The script:
1. Copies `templates/frontend/` → `<OUT_DIR>/<slug>/`
2. Copies `templates/backend/` → `<OUT_DIR>/<slug>_backend/`
3. Substitutes all `{{PLACEHOLDER}}` tokens via `sed`
4. Warns if any unsubstituted placeholders remain
5. **Refuses to overwrite** existing folders — fail loudly is correct

### Step 3 — Verify

```bash
# Check for leftover placeholders
grep -rE '\{\{[A-Z_]+\}\}' <OUT_DIR>/<slug> <OUT_DIR>/<slug>_backend || echo "All placeholders substituted."

# Validate package.json files parse cleanly
node -e "JSON.parse(require('fs').readFileSync('<OUT_DIR>/<slug>/package.json'))"
node -e "JSON.parse(require('fs').readFileSync('<OUT_DIR>/<slug>_backend/package.json'))"
```

### Step 4 — Report and Next Steps

Tell the user, concisely:
- The two folder paths created
- Required env vars (`.env.local` for frontend, `.env` for backend) — point to `.example` files
- The four bootstrap commands (list only, do NOT run):
  ```
  cd <slug>           && npm install
  cd <slug>_backend   && npm install
  cd <slug>_backend   && npm run connect   # Composio OAuth for Gmail + Drive
  cd <slug>           && npm run dev       # http://localhost:3000
  ```
- That **no automations are scaffolded yet**
- That `TRIGGER_PROJECT_REF` and `TRIGGER_SECRET_KEY` must match between frontend and backend

## FAILURE MODES

| Failure | Detection | Recovery |
|---------|-----------|----------|
| **Destination exists** | Script exits with "Refusing to overwrite" | Suggest different output directory or confirm deletion of existing folders |
| **Unsubstituted placeholders** | grep finds `{{[A-Z_]+}}` in output | Check if parameter value contained special sed characters (`/`, `&`, `\`); re-run with escaped values |
| **package.json parse failure** | `JSON.parse` throws | Re-copy template and re-substitute; check for corrupted binary files |
| **Missing template files** | Script fails on `cp -R` | Verify `${CLAUDE_SKILL_DIR}/templates/` integrity; check git status for deleted files |
| **Permission denied** | Script exits with EACCES | Check directory ownership and write permissions; suggest `chmod` or different output path |
| **Non-standard slug derivation** | Name contains accented chars, emojis, or spaces-only | Ask user to provide explicit slug rather than deriving |

## VERIFICATION CHECKLIST

- [ ] Both `package.json` files parse cleanly via `node -e "JSON.parse(...)"`
- [ ] Zero `{{PLACEHOLDER}}` tokens remain in output (verified by grep)
- [ ] Frontend `src/auth.ts` contains correct `CLIENT_DOMAIN` in ALLOWED_DOMAIN
- [ ] Backend `trigger.config.ts` exists with `dirs: ["./src/automations"]`
- [ ] `config/automations.ts` contains empty registry (no pre-populated automations)
- [ ] `$TRIGGER_PROJECT_REF` and `$TRIGGER_SECRET_KEY` documented as must-match pair
- [ ] `/graphify . --update` suggested if graph is stale, to register new project in workspace graph

## CRITICAL RULES

1. **Always gather context with AskUserQuestion first** — never scaffold with guessed values
2. **Do not invent placeholders** — only the seven defined in `parameters.md` are substituted
3. **Do not scaffold automations** — the template has an empty registry on purpose
4. **Do not modify the templates** — substitution is the only change
5. **Do not run `npm install` automatically** — list as next step
6. **Refuse to overwrite** existing destination folders
7. **Both projects share the same Trigger.dev project** — `TRIGGER_PROJECT_REF` and `TRIGGER_SECRET_KEY` must match
8. **Stack is non-standard** — Next.js 16 breaking changes, NextAuth v5 beta, Tailwind v4. Don't "fix" unfamiliar APIs
9. **Composio user ID defaults to the operator**, not the client
10. **Schema mirroring** — when automations are added later, Zod schemas are duplicated and must stay in sync

## EXAMPLES

### Example 1: Standard client scaffold
```
User: "/new-client-system Acme Co"
→ Hint: "Acme Co"
→ AskUserQuestion: confirm name, domain, output dir
→ Derive slug: "acme", email: "noreply@acme.com", etc.
→ Run scaffold.sh
→ Verify zero placeholders
→ Report paths and next steps
```

### Example 2: Name conflict detected via graphify
```
User: "/new-client-system Acme Co"
→ /graphify query "acme client" → finds existing "acme" in graph
→ Alert user: "Client 'acme' already exists at ./clients/acme/"
→ Ask: "Use a different slug (e.g. 'acme-new') or cancel?"
→ Proceed based on user choice
```

### Example 3: Complex name requiring manual slug
```
User: "/new-client-system José María's Company"
→ Derive slug: "jose-marias-company" (non-obvious accent handling)
→ AskUserQuestion: "Derived slug is 'jose-marias-company' — confirm or provide alternative"
→ User confirms → proceed
→ User provides "jmc" → use "jmc" instead
```

## REFERENCES

- `references/architecture.md` — Frontend/backend structure, Trigger.dev communication, auth model, data flow
- `references/stack.md` — Next.js 16.2.6, React 19.2.4, Trigger.dev v4, Composio v0.10, NextAuth v5 beta, Tailwind v4, MongoDB v7, Zod v4 (frontend) / v3 (backend)
- `references/design-system.md` — OKLch tokens, Geist fonts, custom utilities (`.font-tabular`, `.hairline`, `.animate-enter`)
- `references/parameters.md` — Seven placeholders, derivation rules, false-positive patterns to ignore
- `scripts/scaffold.sh` — Template copy + sed substitution script
- `templates/frontend/AGENTS.md` — Next.js 16 breaking changes warning

---
*Skill upgraded for Antigravity Workspace — graphify-first protocol*
