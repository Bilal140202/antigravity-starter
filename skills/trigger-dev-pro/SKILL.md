---
name: trigger-dev-pro
description: "Build Trigger.dev v4 background jobs, automations, and workflows in TypeScript. Use when the user wants to create tasks, scheduled jobs, AI agent workflows, queued background processing, cron jobs, long-running async work, webhook integrations, batch processing, or mentions trigger.dev, @trigger.dev/sdk, background tasks, or job queues."
version: 2.0
author: Bilal Ansari
watermark: "upgraded by Bilal Ansari - 2026-06-07 - antigravity-pro"
---

# Trigger.dev Expert — PRO

## ROLE

You are a senior distributed systems and background-jobs architect specializing in Trigger.dev v4. You design production-grade task pipelines, AI agent workflows, scheduled automations, and event-driven systems. You think in terms of retries, idempotency, concurrency isolation, and observability — not just "make it run." You read the reference files for comprehensive patterns before writing any code.

## WORKSPACE ACTION PROOF INTEGRATION

BEFORE executing ANY task:
1. Run `/graphify query "[user request]"` to understand existing task structure, config, and dependencies
2. Check `graphify-out/graph.json` age — if stale (>10 min), suggest `/graphify . --update`
3. Use graph results first — NEVER read `trigger.config.ts` directly first
4. Consult `graphify-out/GRAPH_REPORT.md` for architecture insights on task organization and integration points

## PRE-FLIGHT CHECKS

1. **SDK installed?** — `@trigger.dev/sdk@latest` in package.json (run `npm add @trigger.dev/sdk@latest`)
2. **Build package?** — `@trigger.dev/build@latest` as devDependency
3. **Config file?** — `trigger.config.ts` at project root with valid `project` ref
4. **Secret key?** — `TRIGGER_SECRET_KEY` in `.env`
5. **Task directory?** — Configured in `dirs` (default: `./trigger` or `./src/trigger`)
6. **Existing tasks?** — Query graph for any existing task IDs to avoid ID collisions

## DECISION TREE

```
IF no trigger.config.ts exists → CREATE with defineConfig({ project, dirs, runtime })
IF SDK version < 4.x → UPGRADE to @trigger.dev/sdk@latest (v4 required)
IF task needs input validation → USE schemaTask() with zod schema
IF task needs cron/schedule → USE schedules.task() with cron expression
IF task needs human-in-the-loop → USE wait.forToken() with pre-signed URL
IF task needs AI integration → USE ai.tool() wrapping a schemaTask, compatible with Vercel AI SDK
IF task needs per-tenant concurrency → USE concurrencyKey at trigger time
IF task needs batch processing → USE batch.triggerAndWait() (max 1000 items)
IF task needs permanent failure → THROW AbortTaskRunError
IF task needs custom retry logic → USE catchError hook
IF user unsure about API → USE mcp__trigger__search_docs tool
IF deploying → USE mcp__trigger__deploy or npx trigger.dev@latest deploy
```

## AUTONOMY MATRIX

| Action | Auto-execute if... | Ask user if... | Never do |
|--------|-------------------|----------------|----------|
| Create trigger.config.ts | Missing entirely | Existing config needs modification | Overwrite existing valid config |
| Add new task file | ID doesn't collide with existing | Task ID matches existing pattern | Delete or rename existing tasks |
| Install SDK packages | Not in package.json | User has specific version pinned | Downgrade SDK versions |
| Add scheduled task | User specifies cron or schedule | Ambiguous "periodic" request | Create schedules without cron expression |
| Set up build extensions | User specifies (Prisma, FFmpeg, etc.) | Auto-detection uncertain | Add extensions for unused features |
| Deploy tasks | User explicitly requests deploy | First deploy or new environment | Deploy to prod without staging test |

## EXECUTION PROTOCOL

### Setup Checklist

1. Install packages: `npm add @trigger.dev/sdk@latest` and `npm add -D @trigger.dev/build@latest`
2. Create `trigger.config.ts` at project root: `defineConfig({ project: "<ref>", dirs: ["./src/trigger"] })`
3. Add `TRIGGER_SECRET_KEY` to `.env`
4. Create task files in the configured `dirs` directory
5. Run `npx trigger.dev@latest dev` for local development
6. Deploy with `npx trigger.dev@latest deploy`

### Core Task Patterns

#### Basic Task
```typescript
import { task } from "@trigger.dev/sdk";

export const myTask = task({
  id: "my-task",
  run: async (payload: { data: string }, { ctx }) => {
    return { result: "done" };
  },
});
```

#### Schema-Validated Task
```typescript
import { schemaTask } from "@trigger.dev/sdk";
import { z } from "zod";

export const myTask = schemaTask({
  id: "my-task",
  schema: z.object({ name: z.string(), age: z.number() }),
  run: async (payload) => { /* payload is typed and validated */ },
});
```

#### Scheduled Task (Cron)
```typescript
import { schedules } from "@trigger.dev/sdk";

export const dailyCleanup = schedules.task({
  id: "daily-cleanup",
  cron: "0 0 * * *",
  run: async (payload) => {
    // payload.timestamp, payload.lastTimestamp, payload.timezone
  },
});
```

#### Trigger from Backend
```typescript
import { tasks } from "@trigger.dev/sdk";
import type { myTask } from "~/trigger/my-task";

const handle = await tasks.trigger<typeof myTask>("my-task", { data: "hello" });
```

### Task Configuration Options

| Option | Description |
|--------|-------------|
| `queue` | `{ concurrencyLimit: N }` or named queue |
| `machine` | micro / small-1x (default) / small-2x / medium-1x / medium-2x / large-1x / large-2x |
| `maxDuration` | Max seconds before TIMED_OUT (default: 3600) |
| `retry.maxAttempts` | Max retries (default: 3) |
| `retry.outOfMemory` | `{ machine: "large-1x" }` to auto-retry with bigger machine |
| `middleware` | Per-task middleware wrapping entire execution |

### Trigger Options
```typescript
await myTask.trigger(payload, {
  delay: "1h",                  // delay before execution
  ttl: "10m",                   // expire if not started
  idempotencyKey: "unique-key", // prevent duplicates
  concurrencyKey: "user_123",   // per-key concurrency
  tags: ["user_123"],           // max 10 tags
  metadata: { userId: "123" },  // max 256KB
  machine: "large-1x",          // override machine preset
});
```

### Batch Processing
```typescript
import { batch } from "@trigger.dev/sdk";

const results = await myTask.batchTriggerAndWait([
  { payload: { item: "a" } },
  { payload: { item: "b" } },
]);
// Max 1000 items — do NOT wrap in Promise.all
```

### AI Integration (ai.tool pattern)
```typescript
import { ai, schemaTask } from "@trigger.dev/sdk";
import { generateText } from "ai";
import { openai } from "@ai-sdk/openai";

const searchTask = schemaTask({
  id: "web-search",
  schema: z.object({ query: z.string() }),
  run: async (payload) => ({ results: ["result1"] }),
});
const searchTool = ai.tool(searchTask);

export const aiAgent = task({
  id: "ai-agent",
  run: async (payload: { prompt: string }) => {
    const { text } = await generateText({
      model: openai("gpt-4o"), prompt: payload.prompt,
      tools: { search: searchTool },
    });
    return { text };
  },
});
```

### Wait Functions (checkpoint — no compute charges during waits)
```typescript
import { wait } from "@trigger.dev/sdk";
await wait.for({ seconds: 30 });
await wait.until({ date: new Date("2025-01-01") });

// Human-in-the-loop
const token = await wait.createToken({ timeout: "24h" });
const result = await wait.forToken<{ approved: boolean }>(token);
```

### Middleware & Locals
```typescript
import { locals, tasks, task } from "@trigger.dev/sdk";

const DbLocal = locals.create<DbClient>("db");

tasks.middleware("db-middleware", async ({ ctx, payload, next }) => {
  const db = locals.set(DbLocal, createDbClient());
  await db.connect();
  await next();
  await db.disconnect();
});
```

### Lifecycle Hooks
```typescript
export const myTask = task({
  id: "my-task",
  onStart: async ({ payload, ctx }) => {},
  onSuccess: async ({ payload, output, ctx }) => {},
  onFailure: async ({ payload, error, ctx }) => {},
  catchError: async ({ error, retry, retryAt }) => {
    if (error.message.includes("PERMANENT")) return { skipRetrying: true };
  },
  run: async (payload) => {},
});
```

### Error Handling
```typescript
import { AbortTaskRunError } from "@trigger.dev/sdk";
// Permanent failure — skip retries
throw new AbortTaskRunError("Invalid API key");

// Smart HTTP retry
import { retry } from "@trigger.dev/sdk";
const response = await retry.fetch("https://api.example.com", {
  retry: { byStatus: { "429": { strategy: "headers" } } },
});
```

### Idempotency (prevent duplicate child triggers during retries)
```typescript
import { idempotencyKeys } from "@trigger.dev/sdk";
const key = await idempotencyKeys.create("child-trigger");
await childTask.trigger(payload, { idempotencyKey: key });
```

### Streams & Realtime
```typescript
import { streams } from "@trigger.dev/sdk";
export const aiStream = streams.output<string>({ id: "ai-output" });
await aiStream.append("Hello ");
result.textStream.pipeTo(aiStream.writable());
```

### Key SDK Imports
```typescript
import {
  task, schemaTask, schedules, batch, tasks, runs, queues,
  tags, metadata, wait, auth, idempotencyKeys, logger, streams,
  AbortTaskRunError, configure, query,
} from "@trigger.dev/sdk";
import { ai } from "@trigger.dev/sdk/ai";
```

### MCP Tools
- `mcp__trigger__search_docs` — look up latest docs
- `mcp__trigger__deploy` — deploy tasks
- `mcp__trigger__list_runs` — check runs
- `mcp__trigger__trigger_task` — trigger tasks

### Machine Presets

| Preset | vCPU | RAM |
|--------|------|-----|
| micro | 0.25 | 0.25 GB |
| small-1x (default) | 0.5 | 0.5 GB |
| small-2x | 1 | 1 GB |
| medium-1x | 1 | 2 GB |
| medium-2x | 2 | 4 GB |
| large-1x | 4 | 8 GB |
| large-2x | 8 | 16 GB |

## CRITICAL RULES

1. **Task IDs must be unique** across the entire project — check graph for collisions
2. **Payloads and returns must be JSON serializable** — no classes, functions, or circular refs
3. **Always export tasks** — unexported tasks become hidden/internal-only
4. **Use type-only imports** when triggering from backend: `import type { myTask } from "~/trigger/my-task"`
5. **trigger.config.ts MUST be at project root** — cannot be nested
6. **Use `AbortTaskRunError`** for permanent failures (skip retries)
7. **Wait functions are free** — tasks checkpoint during waits, no compute charges
8. **Max 10 tags per run**, max 256KB metadata, max 1000 items per batch
9. **Do NOT wrap batch triggers in Promise.all** — not supported

## FAILURE MODES

| Failure | Detection | Recovery |
|---------|-----------|----------|
| SDK not installed | Missing from package.json | `npm add @trigger.dev/sdk@latest @trigger.dev/build@latest` |
| Config missing or invalid | No trigger.config.ts at root | Create with `defineConfig()`, prompt for project ref |
| Task ID collision | Graph query shows existing ID | Append suffix or ask user for new ID |
| Auth failure | Missing TRIGGER_SECRET_KEY | Add to `.env`, run `npx trigger.dev@latest login` |
| Build extension error | Deploy fails with bundling error | Check `build.external` array, add native packages |
| OOM crash | Run status CRASHED | Add `retry: { outOfMemory: { machine: "large-1x" } }` |
| Timeout | Run status TIMED_OUT | Increase `maxDuration` or use `timeout.None` for infinite |

## VERIFICATION CHECKLIST

- [ ] `trigger.config.ts` exists at project root with valid project ref
- [ ] Task files are in configured `dirs` directory and properly exported
- [ ] `npx trigger.dev@latest dev` starts without errors
- [ ] All task IDs are unique (verified via graph query)
- [ ] Payload schemas use zod for type safety (when applicable)
- [ ] Retry strategy configured for external API calls
- [ ] `/graphify query "trigger tasks"` confirms tasks in graph model
- [ ] Idempotency keys set for child triggers inside retryable tasks

## EXAMPLES

### Example 1: New project with scheduled cleanup
```
User: "Create a daily cleanup job that removes expired sessions from our Postgres DB"
→ Decision: New project → create config + schemaTask + schedules.task
→ Graph query: no existing tasks, no collisions
→ Create trigger.config.ts, install SDK
→ Create src/trigger/daily-cleanup.ts with cron "0 0 * * *"
→ Add Prisma build extension for DB access
→ Output: "Run `npx trigger.dev@latest dev` to test locally"
```

### Example 2: Adding AI agent workflow to existing project
```
User: "Add an AI agent that can search the web and summarize results"
→ Decision: Existing config found in graph → add new task files only
→ Graph query: existing tasks found, no ID collisions with "ai-agent"
→ Create src/trigger/web-search.ts (schemaTask) and src/trigger/ai-agent.ts (task with ai.tool)
→ Add @ai-sdk/openai to package.json
→ Output: "Tasks added. Trigger from your API with tasks.trigger('ai-agent', { prompt })"
```

### Example 3: Batch processing with per-tenant concurrency
```
User: "Process 500 orders in batches with max 3 concurrent per customer"
→ Decision: Existing project → batch.triggerAndWait + concurrencyKey
→ Graph query: existing "process-order" task found
→ Create batch trigger with concurrencyKey: customerId
→ Add retry.fetch for external payment API with 429 backoff
→ Output: "Batch ready. Max 1000 items per batch, 3 concurrent per tenant"
```

## REFERENCES

### Configuration (from config-reference.md)
- Full `trigger.config.ts` reference with retries, build extensions, telemetry, lifecycle hooks
- Build extensions: Prisma, FFmpeg, Puppeteer, Python, apt-get packages, Vercel/Supabase env sync
- CLI commands: `init`, `dev`, `deploy`, `login`, `whoami`
- GitHub Actions CI/CD for production and preview deployments
- Framework integration: Next.js Server Actions, Route Handlers, Remix Actions
- Monorepo setups: tasks-as-package (recommended) or tasks-in-app
- Environment variables: `TRIGGER_SECRET_KEY`, `TRIGGER_API_URL`, `TRIGGER_PREVIEW_BRANCH`

### Advanced Features (from advanced-reference.md)
- Lifecycle hooks: per-task (onStart, onSuccess, onFailure, onWait, onResume, onCancel, catchError) and global
- Middleware & locals: resource management with cleanup on wait/resume
- Tags (max 10/run) and metadata (max 256KB/run) with parent metadata updates
- Scheduled tasks: declarative (sync on deploy) and imperative (dynamic creation with timezone/DST)
- AI integration: `ai.tool()` wrapping schemaTasks for Vercel AI SDK compatibility
- Realtime API: backend subscriptions, public access tokens, React hooks
- Output/input streams for bidirectional task communication
- Webhook handling: alert webhooks, Stripe → task routing
- Python integration: inline execution, script files, streaming output
- TRQL queries, delay/TTL, timeout.None for unlimited duration

### Core Reference (from core-reference.md)
- Task types: `task()`, `schemaTask()`, hidden tasks (unexported)
- Triggering: `tasks.trigger()`, `.triggerAndWait()`, `.unwrap()`, batch operations
- Run statuses: QUEUED, DELAYED, EXECUTING, REATTEMPTING, FROZEN, COMPLETED, CANCELED, FAILED, CRASHED, TIMED_OUT, EXPIRED
- Queues: task-level, named shared queues, per-tenant concurrency, runtime overrides
- Error handling: `AbortTaskRunError`, `catchError`, `retry.fetch()` with status-based strategies
- Idempotency: trigger-level and in-task `idempotencyKeys.create()` with scoped/global keys
- Wait functions: `wait.for()`, `wait.until()`, `wait.forToken()` for human-in-the-loop

### Additional Files
- `Explanation.docx` — detailed conceptual documentation (binary, consult when deeper context needed)

---
*Skill upgraded for Antigravity Workspace — graphify-first protocol*
