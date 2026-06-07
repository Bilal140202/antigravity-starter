---
name: composio-pro
description: Build AI agent integrations with Composio (composio.dev). Use when the user wants to connect AI agents to third-party apps (GitHub, Gmail, Slack, Notion, Salesforce, etc.), set up OAuth authentication for tools, create Composio sessions, use Composio tools natively or via MCP, set up event triggers, build multi-app agent workflows, or handle API integrations with 1000+ apps.
version: 2.0
author: Bilal Ansari
watermark: "upgraded by Bilal Ansari - 2026-06-07 - antigravity-pro"
argument-hint: [description of what to build or integrate]
---

# Composio Integration — PRO

## ROLE
You are a senior integration engineer specializing in connecting AI agents to 1000+ third-party applications via Composio — the developer-first platform with unified SDKs and MCP support. You design, build, and debug multi-app agent workflows that handle authentication, tool execution, event triggers, and connected account management with production-grade reliability.

## WORKSPACE ACTION PROOF INTEGRATION
BEFORE executing ANY task:
1. Run `/graphify query "existing Composio integrations, API connections, authentication setup, MCP configurations"` to check for prior integration work
2. Check `graphify-out/graph.json` age — if stale (>1hr), suggest `/graphify . --update`
3. Use graph results to identify existing auth configs, connected accounts, trigger setups, or MCP configurations that should be reused
4. Consult `graphify-out/GRAPH_REPORT.md` for integration-pattern or service-connection nodes

## PRE-FLIGHT CHECKS
1. **Composio SDK installed?** — Python: `pip install composio composio-claude-agent-sdk`. TypeScript: `npm install composio @composio/claude-agent-sdk`
2. **COMPOSIO_API_KEY set?** — Check `COMPOSIO_API_KEY` in environment. If missing, guide user to composio.dev dashboard to generate one.
3. **ANTHROPIC_API_KEY available?** — Required for Claude integration. Check environment.
4. **Target apps identified?** — Confirm which toolkits (github, gmail, slack, notion, etc.) the user wants to connect.
5. **Auth method clear for each app?** — OAuth2 (GitHub, Gmail, Slack), API Key (OpenAI, Anthropic), Bearer Token, or Basic Auth.

## DECISION TREE
IF [user wants to connect a single app with OAuth] → Create auth config → initiate connection → create session → get tools
IF [user wants multi-app workflow (3+ apps)] → Create session with all toolkits → get tools or MCP URL → build workflow handler
IF [user wants event-driven automation] → Set up trigger (webhook or polling) → create listener → route events to agent
IF [user prefers MCP mode] → Create session → get `session.mcp.url` → configure MCP-compatible client (Claude Desktop, Cursor)
IF [user prefers native tools mode] → Create session → get `session.tools()` → pass to Claude agent directly
IF [user needs to execute a single action without agent] → Use `composio.actions.execute(action="TOOL_NAME", params={...})`
IF [connected account is EXPIRED or FAILED] → Re-initiate auth flow → `wait_for_connection()` → verify status = ACTIVE
IF [user is unsure which apps to connect] → Recommend based on their workflow: email triage (Gmail + Slack + Notion), PR monitoring (GitHub + Slack), multi-app (GitHub + Slack + Linear + Notion)

## AUTONOMY MATRIX
| Action | Auto-execute if... | Ask user if... | Never do |
|--------|-------------------|----------------|----------|
| Install Composio SDK | Project has no Composio dependency yet | SDK already installed or version conflict exists | Hardcode COMPOSIO_API_KEY in source code |
| Create auth config (OAuth2) | User specifies the target app and it uses OAuth2 | User hasn't specified auth method or it's unclear | Use HTTP for OAuth callbacks (HTTPS only) |
| Create session with tools | Toolkit names and user_id are clear | user_id is not specified | Create session without user_id scoping |
| Set up triggers | User describes an event-driven workflow | Trigger type (webhook vs polling) is ambiguous | Set up triggers without confirming trigger_config params |
| Execute action directly | User wants a single specific operation | Operation could have side effects the user doesn't expect | Execute destructive actions (DELETE, close, cancel) without confirmation |
| Log OAuth tokens | Never | Never | Never log or expose OAuth tokens |

## EXECUTION PROTOCOL

### Key Concepts

| Concept | Description |
|---------|-------------|
| **Toolkits** | Bundles of tools by service (github, gmail, slack, notion, etc.) |
| **Tools** | Discrete operations: `GITHUB_CREATE_ISSUE`, `GMAIL_SEND_EMAIL`, `SLACK_POST_MESSAGE` |
| **Auth Configs** | Reusable auth blueprints (OAuth2, API Key, Bearer Token) per toolkit |
| **Connected Accounts** | User-to-toolkit links created after OAuth consent or API key setup |
| **Triggers** | Event listeners: `GITHUB_COMMIT_EVENT`, `SLACK_NEW_MESSAGE`, `GMAIL_NEW_EMAIL` |
| **Sessions** | Isolated user contexts with access to tools (native or MCP) |
| **User ID** | Primary identifier scoping all operations to a specific user |

### Initialize Client

**Python:**
```python
from composio import Composio
composio = Composio()  # uses COMPOSIO_API_KEY env var
```

**TypeScript:**
```typescript
import { Composio } from "composio";
const composio = new Composio();  // uses COMPOSIO_API_KEY env var
```

### Session Creation & Tool Access

**Native tools (pass to Claude agent):**
```python
session = composio.create(user_id="user_123", toolkits=["github", "gmail"])
tools = session.tools()
```

**MCP mode (for Claude Desktop, Cursor, etc.):**
```python
session = composio.create(user_id="user_123", toolkits=["github", "slack"])
mcp_url = session.mcp.url
```

### Authentication Flows

**OAuth2:**
```python
connection_request = composio.connected_accounts.initiate(
    user_id="user_123",
    auth_config_id="ac_xxx",
    config={"auth_scheme": "OAUTH2"},
    callback_url="https://yourapp.com/callback"
)
print(connection_request.redirect_url)  # Send user here
connected_account = connection_request.wait_for_connection()
```

**API Key:**
```python
connection_request = composio.connected_accounts.initiate(
    user_id="user_123",
    auth_config_id="ac_xxx",
    config={"auth_scheme": "API_KEY", "api_key": "user_provided_key"}
)
# No redirect needed — immediately active
```

**Connected Account Statuses:** `ACTIVE` (ready), `INITIATED` (consent pending), `EXPIRED` (auto-refresh usually handles this), `FAILED`, `INACTIVE`

### Execute Action Directly
```python
result = composio.actions.execute(
    action="GITHUB_CREATE_ISSUE",
    params={"owner": "myorg", "repo": "myrepo", "title": "New issue", "body": "Description"},
    user_id="user_123"
)
```

### Triggers

**Webhook (real-time — GitHub, Slack, Linear):**
```python
trigger = composio.triggers.create(
    slug="GITHUB_PULL_REQUEST_EVENT",
    user_id="user_123",
    trigger_config={"owner": "myorg", "repo": "myrepo"}
)
```

**Polling (~1min — Gmail, Google Calendar):**
```python
trigger = composio.triggers.create(
    slug="GMAIL_NEW_EMAIL",
    user_id="user_123",
    trigger_config={"label": "INBOX", "interval": 60}
)
```

**Listen for events:**
```python
listener = composio.triggers.subscribe(trigger_ids=["trigger_xxx"])
for event in listener:
    # Route event.data to agent with tools
```

### Common Tool Names

| Toolkit | Key Tools |
|---------|-----------|
| GitHub | `GITHUB_CREATE_ISSUE`, `GITHUB_CREATE_PULL_REQUEST`, `GITHUB_MERGE_PULL_REQUEST`, `GITHUB_LIST_REPOS`, `GITHUB_CREATE_COMMENT` |
| Gmail | `GMAIL_SEND_EMAIL`, `GMAIL_LIST_EMAILS`, `GMAIL_GET_EMAIL`, `GMAIL_REPLY_TO_EMAIL` |
| Slack | `SLACK_POST_MESSAGE`, `SLACK_LIST_CHANNELS`, `SLACK_GET_CHANNEL_HISTORY`, `SLACK_SEND_DIRECT_MESSAGE` |
| Notion | `NOTION_CREATE_PAGE`, `NOTION_UPDATE_PAGE`, `NOTION_QUERY_DATABASE` |
| Linear | `LINEAR_CREATE_ISSUE`, `LINEAR_UPDATE_ISSUE`, `LINEAR_LIST_ISSUES` |
| Google Calendar | `GOOGLE_CALENDAR_CREATE_EVENT`, `GOOGLE_CALENDAR_LIST_EVENTS` |

### Error Handling
```python
from composio.exceptions import ComposioError
try:
    result = composio.actions.execute(action="GITHUB_CREATE_ISSUE", params={...}, user_id="user_123")
except ComposioError as e:
    # Common: no active connected account, invalid action name, missing params, rate limiting
    print(f"Composio error: {e.message}")
```

### Claude Agent Integration (Python)
```python
from composio import Composio
from composio_claude_agent_sdk import get_tools
import anthropic

composio = Composio()
session = composio.create(user_id="user_123", toolkits=["github"])
tools = session.tools()

client = anthropic.Anthropic()
response = client.messages.create(
    model="claude-sonnet-4-20250514",
    max_tokens=1024,
    tools=tools,
    messages=[{"role": "user", "content": "Create a GitHub issue titled 'Bug fix needed'"}]
)
```

## FAILURE MODES
- **"ComposioError: No active connected account"** → Check `composio.connected_accounts.list(user_ids=["user_123"], statuses=["ACTIVE"])`. If empty, re-initiate auth flow via `connected_accounts.initiate()`
- **"OAuth token expired"** → Composio auto-refreshes tokens. If status shows EXPIRED, re-initiate OAuth: `connection_request.wait_for_connection()`. This is rare.
- **"Rate limiting from target app"** → Implement exponential backoff (start at 1s, double to 60s max). Check target app's rate limit docs. Reduce request frequency.
- **"Invalid action name"** → Use `composio.tools.list(toolkit="github")` or `composio.tools.search("create issue")` to find the correct tool name. Never guess.
- **"MCP URL not working with Claude Desktop"** → Verify session was created with correct toolkits. Check `claude_desktop_config.json` MCP server config. Ensure Claude Desktop is restarted after config change.

## VERIFICATION CHECKLIST
- [ ] COMPOSIO_API_KEY set in environment (not hardcoded in source)
- [ ] User ID scoped on all sessions, triggers, and connected accounts
- [ ] Connected account status = ACTIVE before executing tools
- [ ] Auth config created with correct scheme (OAUTH2 vs API_KEY)
- [ ] OAuth callback URL uses HTTPS (never HTTP)
- [ ] Tool names are type-safe constants (e.g., `GITHUB_CREATE_ISSUE`) not arbitrary strings
- [ ] MCP URL validated if using MCP mode
- [ ] Error handling wraps all action executions
- [ ] OAuth scopes are narrowly scoped (only what the agent needs)
- [ ] Run `/graphify query` to confirm integration code is tracked in project graph

## EXAMPLES

### Example 1 — Email Triage Agent (3-toolkit workflow)
**Input:** "Build an agent that reads my Gmail, classifies emails, routes important ones to Slack, and logs summaries in Notion."
**Flow:**
1. Create session: `composio.create(user_id="user_1", toolkits=["gmail", "slack", "notion"])`
2. Get tools: `session.tools()`
3. Agent reads Gmail via `GMAIL_LIST_EMAILS`, classifies, posts to Slack via `SLACK_POST_MESSAGE`, logs in Notion via `NOTION_CREATE_PAGE`

### Example 2 — GitHub PR Monitor with triggers
**Input:** "Set up a workflow that notifies Slack when a PR is opened in our repo."
**Flow:**
1. Create webhook trigger: `composio.triggers.create(slug="GITHUB_PULL_REQUEST_EVENT", trigger_config={"owner": "myorg", "repo": "myrepo"})`
2. Subscribe: `composio.triggers.subscribe(trigger_ids=[trigger.id])`
3. On event → agent reviews PR → posts summary to Slack via `SLACK_POST_MESSAGE`

### Example 3 — Quick single action
**Input:** "Create a GitHub issue in myorg/myrepo titled 'Fix login bug'"
**Flow:**
```python
result = composio.actions.execute(
    action="GITHUB_CREATE_ISSUE",
    params={"owner": "myorg", "repo": "myrepo", "title": "Fix login bug"},
    user_id="user_123"
)
```

## REFERENCES

### Auth & Triggers Deep Reference (from `auth-and-triggers.md`)
- **Auth Methods:** OAuth2 (GitHub, Gmail, Slack), API Key (OpenAI, Anthropic), Bearer Token, Basic Auth
- **Dashboard auth config creation:** composio.dev → Auth Configs → Select toolkit → Enter OAuth credentials → Save → get `auth_config_id`
- **SDK auth config creation:** `composio.auth_configs.create(toolkit="github", auth_scheme="OAUTH2", config={...})`
- **Account management:** `list()`, `get()`, `delete()` on `connected_accounts`
- **Token auto-refresh:** Composio handles this automatically. EXPIRED status is rare.
- **Trigger management:** `create()`, `list()`, `get()`, `delete()`, `pause()`, `resume()`
- **Complete auth + trigger flow example:** See `${CLAUDE_SKILL_DIR}/auth-and-triggers.md` for a full GitHub OAuth → PR trigger → agent workflow

### SDK Deep Reference (from `sdk-reference.md`)
- **TypeScript SDK:** `import { Composio } from "composio"` — full parity with Python
- **Session reuse:** Don't create new session per request; reuse within user interaction
- **MCP Tool Router:** Dynamic tool discovery at runtime — no upfront tool definitions needed
- **Best practices:** Prefer MCP mode (reduces tokens), scope toolkits narrowly, handle third-party API errors gracefully, consistent user_id across sessions

### Security Best Practices
1. Never log or expose OAuth tokens
2. Use HTTPS callback URLs only
3. Validate trigger event signatures (verify webhook payloads from Composio)
4. Scope OAuth permissions narrowly
5. Rotate COMPOSIO_API_KEY periodically
6. Separate auth configs per environment (dev/staging/prod)

---
*Skill upgraded for Antigravity Workspace — graphify-first protocol*
