# Jules API Reference

Complete reference for the Jules REST API as used by the jules-wrangler skill.

## Base URL

```
https://jules.googleapis.com/v1alpha
```

## Authentication

All requests require the `X-Goog-Api-Key` header:

```bash
-H 'X-Goog-Api-Key: YOUR_API_KEY'
```

API keys are created at https://jules.google.com/settings (max 3 per account).

The API is currently in **alpha** — endpoints and schemas may change.

---

## Core Resources

### Sessions

A session is a contiguous unit of work within a single context. It's initiated with a prompt and a source (GitHub repo or repoless).

#### Create Session

```http
POST /v1alpha/sessions
Content-Type: application/json

{
  "prompt": "Fix the authentication bug in src/auth/handler.ts",
  "sourceContext": {
    "gitHub": {
      "owner": "my-org",
      "repository": "my-repo",
      "branch": "main"
    }
  },
  "title": "Fix auth handler bug",
  "automationMode": "AUTO_CREATE_PR",
  "requirePlanApproval": false
}
```

**Fields:**
- `prompt` (required): The task description for Jules
- `sourceContext` (optional): GitHub repo context. Omit for repoless sessions.
- `title` (optional): Human-readable session title
- `automationMode` (optional): `"AUTO_CREATE_PR"` to auto-create a PR on completion
- `requirePlanApproval` (optional): `true` to pause at plan stage for approval. Default: `false` (auto-approve)

#### List Sessions

```http
GET /v1alpha/sessions?pageSize=100&pageToken={nextPageToken}
```

**Query Parameters:**
- `pageSize` (optional): 1–100, default 30
- `pageToken` (optional): For pagination

**Response (actual shape from production):**
```json
{
  "sessions": [
    {
      "name": "sessions/10409236580371261383",
      "id": "10409236580371261383",
      "title": "⚡ Bolt: Performance Optimization Agent",
      "state": "COMPLETED",
      "createTime": "2026-05-03T...",
      "updateTime": "2026-05-03T...",
      "url": "https://jules.google.com/session/10409236580371261383",
      "sourceContext": {
        "source": "sources/github/darksheer-labs/ARC",
        "githubRepoContext": {
          "startingBranch": "main"
        },
        "environmentVariablesEnabled": true
      },
      "prompt": "You are Bolt ⚡ ...",
      "outputs": [
        {
          "changeSet": {
            "source": "sources/github/darksheer-labs/ARC",
            "gitPatch": {
              "unidiffPatch": "diff --git a/...",
              "baseCommitId": "a9aae35a2608e2d41a43b93cfa849f01b02cd9a0",
              "suggestedCommitMessage": "⚡ Bolt: Optimize timeline bucketing..."
            }
          }
        },
        {
          "pullRequest": {
            "url": "https://github.com/darksheer-labs/ARC/pull/281",
            "title": "⚡ Bolt: [performance improvement] optimize timeline bucketing",
            "description": "...",
            "baseRef": "main",
            "headRef": "bolt-timeline-map-lookup-10409236580371261383"
          }
        }
      ]
    }
  ],
  "nextPageToken": "token_for_next_page"
}
```

#### Get Session

```http
GET /v1alpha/sessions/{session_id}
```

Returns a single session object with full details.

#### Delete Session

```http
DELETE /v1alpha/sessions/{session_id}
```

Returns `{}` on success (HTTP 200). Permanently removes the session and all its activities.

Useful for cleaning up stale sessions (e.g., sessions targeting repos that have been migrated or deleted).

#### Send Message

```http
POST /v1alpha/sessions/{session_id}:sendMessage
Content-Type: application/json

{
  "prompt": "Actually, also update the unit tests for that handler"
}
```

Only works when session is in `ACTIVE` or `AWAITING_USER_FEEDBACK` state.

#### Approve Plan

```http
POST /v1alpha/sessions/{session_id}:approvePlan
```

Only works when session is in `AWAITING_PLAN_APPROVAL` state.

---

### Activities

Activities are events within a session — the log of everything Jules did.

#### List Activities

```http
GET /v1alpha/sessions/{session_id}/activities?pageSize=50&pageToken={token}
```

**Query Parameters:**
- `pageSize` (optional): 1–100, default 50
- `pageToken` (optional): For pagination
- Activity type filters may be available (check changelog)

**Response:**
```json
{
  "activities": [
    {
      "name": "sessions/abc123/activities/1",
      "createTime": "2026-05-08T14:30:05Z",
      "planGenerated": {
        "plan": "1. Read src/auth/handler.ts\n2. Identify the bug...\n3. Fix..."
      }
    },
    {
      "name": "sessions/abc123/activities/2",
      "createTime": "2026-05-08T14:30:10Z",
      "planApproved": {}
    },
    {
      "name": "sessions/abc123/activities/3",
      "createTime": "2026-05-08T14:31:00Z",
      "progressUpdated": {
        "message": "Reading authentication handler...",
        "step": 1,
        "totalSteps": 5
      }
    },
    {
      "name": "sessions/abc123/activities/4",
      "createTime": "2026-05-08T14:35:00Z",
      "agentMessage": {
        "content": "I've identified the issue: the token validation..."
      }
    }
  ],
  "nextPageToken": "..."
}
```

**Activity Event Types** (one or more payload fields may be populated per activity):
- `planGenerated`: Jules created a work plan. Contains `plan.id` and `plan.steps[]` (each with `id`, `title`, `description`, `index`)
- `planApproved`: Plan was approved. Contains `planId`
- `progressUpdated`: Progress update during execution
- `artifacts`: Opaque progress/output metadata, often paired with `progressUpdated`
- `agentMessaged`: Jules sent a message. Contains `agentMessage` (string). Often asking for user confirmation.
- `sessionCompleted`: Completion marker for finished sessions

**Base fields**: Each activity has `id`, `name`, `createTime`, and
`originator: "agent" | "user"` indicating who generated it.

**Key pattern for AWAITING_USER_FEEDBACK detection**: The last `agentMessaged` activity (where originator=agent) contains Jules' question. Example:
```json
{
  "originator": "agent",
  "agentMessaged": {
    "agentMessage": "Can you confirm if you are satisfied with these optimizations? Should I look for more, or finalize?"
  }
}
```

---

### Sources

Sources represent connected repositories.

#### List Sources

```http
GET /v1alpha/sources
```

#### Get Source

```http
GET /v1alpha/sources/{source_id}
```

---

## Session States

| State | Description | Valid Actions |
|-------|-------------|--------------|
| `ACTIVE` | Session is executing | sendMessage |
| `AWAITING_PLAN_APPROVAL` | Plan ready, needs approval | approvePlan, sendMessage |
| `AWAITING_USER_FEEDBACK` | Jules needs input | sendMessage |
| `COMPLETED` | Successfully finished | (read-only) |
| `FAILED` | Errored during execution | (read-only) |

---

## Repoless Sessions

Sessions can be created without a source context for quick prototyping:

```json
{
  "prompt": "Create a Python script that processes CSV files",
  "title": "CSV processor script"
}
```

Repoless sessions spawn ephemeral cloud environments with Node, Python, Rust, Bun, and other runtimes preloaded. Outputs are available as file artifacts rather than PRs.

---

## Rate Limits & Quotas

- API is alpha — rate limits may change
- Current observed: ~60 requests/minute
- Session creation: depends on account tier
- Pagination: always use pageToken for large result sets

---

## Error Handling

Standard Google API error format:

```json
{
  "error": {
    "code": 429,
    "message": "Rate limit exceeded",
    "status": "RESOURCE_EXHAUSTED"
  }
}
```

Common errors:
- `401 UNAUTHENTICATED`: Invalid or missing API key
- `404 NOT_FOUND`: Session ID doesn't exist
- `429 RESOURCE_EXHAUSTED`: Rate limited
- `400 INVALID_ARGUMENT`: Bad request parameters

---

## Polling Strategy for Triage

For the jules-wrangler skill, the recommended polling approach:

1. **List all sessions** with `pageSize=100`
2. **Filter locally** by state (`COMPLETED`, `AWAITING_PLAN_APPROVAL`)
3. **Track last-seen** session IDs to avoid re-processing
4. **Paginate** if `nextPageToken` is present
5. **Respect rate limits** — add 1s delay between paginated requests

```bash
# Example: list completed sessions
curl 'https://jules.googleapis.com/v1alpha/sessions?pageSize=100' \
  -H 'X-Goog-Api-Key: $JULES_API_KEY' \
  | jq '.sessions[] | select(.state == "COMPLETED")'
```
