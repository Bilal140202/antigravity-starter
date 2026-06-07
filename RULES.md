# Shared Rules

## Workspace Action Proof Protocol

BEFORE executing ANY user request, regardless of project, folder, or task type:

### Requirement 1: Graph First
1. Check if `graphify-out/graph.json` exists and is less than 1 hour old
2. If missing or stale: run `graphify . --update`
3. Run `graphify query "<user's exact request>"` to get codebase context
4. NEVER use Read, Glob, or Grep tools before completing step 3

### Requirement 2: Agent Selection
After receiving graph results:
- If query mentions architecture, design, or planning → use @architect agent
- If query mentions code changes, implementation, or building → use @builder agent
- If query mentions testing, debugging, or verification → use @tester agent
- If query mentions documentation or summaries → use @documenter agent

DO NOT proceed with the task until both requirements are complete.

## Token Efficiency
- Prefer `graphify query` over reading multiple files
- Use graph results to avoid re-researching known code
- When graph context is sufficient, do not re-read source files
- Summarise graph output before expanding into full file reads

## Idempotency
- Every operation must be safe to run multiple times
- Install scripts must detect existing installations and skip or upgrade gracefully
- Never destroy user data on re-run
- Copy operations should always use force/overwrite flags

## Error Handling
- All scripts must handle errors gracefully with clear messages
- On failure, print the step that failed and a suggested fix
- Never silently continue after a critical error
- Non-critical failures (e.g. optional hooks) should warn and continue

## Cross-Platform Compatibility
- Scripts must work on Windows (PowerShell 5.1+), macOS, and Linux (bash)
- Use platform-appropriate path separators and environment variables
- Respect $HOME on Unix and $HOME/$USERPROFILE on Windows
- File encodings must be UTF-8 throughout

## Security
- Never store credentials in plain text files
- Google OAuth tokens are managed by the graphify auth layer
- RULES.md is a declarative file — it contains no secrets
- All network operations go through authenticated channels only
