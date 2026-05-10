---
name: jules-triage
description: >
  Scheduled triage agent for Google Jules coding sessions. Polls the Jules API for
  completed sessions (from agents like Bolt, Palette, and one-off code reviews),
  analyzes their changeSets, and determines which should be promoted to GitHub PRs.
  Supports configurable autonomy modes (full, approve-high-risk, approve-all) and
  per-agent configuration. Works across multiple GitHub orgs and repos. Once a session
  is promoted, hands off to github-babysitter pr-care for merge management. Also handles
  AWAITING_USER_FEEDBACK sessions that need confirmation. Designed to run daily
  on a schedule but can also be invoked on-demand. Use this skill when the user mentions
  Jules triage, Jules review triage, Jules session management, promoting Jules reviews
  to PRs, daily Jules digest, scheduling Jules review processing, Bolt sessions,
  Palette sessions, or managing Jules agents across repos.
---

# Jules Triage

A scheduled triage agent that bridges Google Jules coding sessions with your GitHub PR workflow.

## What This Skill Does

Jules operates asynchronously — it performs code reviews, generates fixes, and produces plans independently from your main GitHub workflow. This skill closes the loop by:

1. **Poll** — query the Jules API for sessions in completed/awaiting states
2. **Analyze** — inspect each session's activities, plan, and outputs
3. **Triage** — evaluate whether the session's work merits a PR
4. **Promote** — create GitHub PRs from approved sessions (or present for human approval)
5. **Handoff** — invoke github-babysitter pr-care to manage the PR lifecycle
6. **Report** — generate a daily digest of all triaged sessions
7. **Learn** — track promotion rates, rejection reasons, and quality outcomes

---

## Quick Start

```bash
# On-demand — triage all pending Jules sessions now
"Triage my Jules sessions"

# Scheduled — set up daily triage at 9am
"Schedule Jules triage daily at 9am"

# Specific repo — only triage sessions for a given repo
"Triage Jules sessions for owner/repo"

# Digest only — just show me what's pending without acting
"Show me a Jules session digest"
```

---

## Configuration

The skill reads `.jules-triage.yml` from the repo root (or a global config). If absent, it uses sensible defaults.

Read `references/config-schema.md` for the full schema. Key sections:

```yaml
# .jules-triage.yml
autonomy: approve-high-risk   # full | approve-high-risk | approve-all
schedule: "0 9 * * *"         # cron expression for scheduled runs
repositories:                  # repos to monitor (empty = all)
  - owner/repo-a
  - owner/repo-b
promotion_criteria:
  min_confidence: 0.7         # minimum triage confidence to auto-promote
  require_tests_pass: true    # only promote if Jules' tests passed
  max_files_changed: 50       # skip mega-sessions, flag for manual review
  categories:                  # which session types to consider
    - bug_fix
    - code_review
    - performance
    - security
github_babysitter:
  enabled: true               # hand off promoted PRs to github-babysitter pr-care
  config_path: .github-babysitter.yml
notifications:
  slack_channel: ""           # optional Slack notification channel
  digest_format: summary      # summary | detailed | minimal
```

---

## Authentication

The skill requires a Jules API key. It looks for credentials in this order:

1. **Environment variable**: `JULES_API_KEY`
2. **`.env` file**: in the repo root or workspace root
3. **Config file**: `jules_api_key` field in `.jules-triage.yml`

API keys are managed at https://jules.google.com/settings (max 3 keys per account).

All API calls use the header: `X-Goog-Api-Key: <your-key>`

Base URL: `https://jules.googleapis.com/v1alpha`

---

## Phase 1: Polling Jules Sessions

### Listing Sessions

Query the Jules API to find sessions requiring triage:

```bash
curl 'https://jules.googleapis.com/v1alpha/sessions?pageSize=100' \
  -H 'X-Goog-Api-Key: $JULES_API_KEY'
```

### Session States

Sessions progress through these states:

| State | Meaning | Triage Action |
|-------|---------|---------------|
| `ACTIVE` | Still running | Skip — check next cycle |
| `AWAITING_PLAN_APPROVAL` | Plan ready, needs approval | Review plan, approve or reject |
| `AWAITING_USER_FEEDBACK` | Jules needs input | Flag for human attention |
| `COMPLETED` | Work finished successfully | **Primary triage target** |
| `FAILED` | Session errored | Log failure, skip |

### Filtering Strategy

On each triage run:
1. List all sessions (paginate if > 100)
2. Filter to `COMPLETED` and `AWAITING_PLAN_APPROVAL` states
3. Cross-reference with previously triaged sessions (tracked locally)
4. Skip sessions already promoted or explicitly rejected
5. For remaining sessions, proceed to analysis

### Source Context Matching

Sessions use the format `sourceContext.source` = `"sources/github/{org}/{repo}"`.

If `repositories` is configured, parse the source string and match against configured repos. Note that repos may exist under multiple orgs (e.g., `darksheer/Acheron` and `darksheer-labs/Acheron`). Match by `{org}/{repo}` pair.

```bash
# Example source values observed:
# "sources/github/darksheer-labs/ARC"
# "sources/github/darksheer-labs/Acheron"
# "sources/github/darksheer/Acheron"
# "sources/github/darksheer/ft3"
```

The `sourceContext.githubRepoContext.startingBranch` field indicates which branch the session targets.

---

## Phase 2: Session Analysis

For each session requiring triage, gather full context:

### Retrieving Activities

```bash
curl 'https://jules.googleapis.com/v1alpha/sessions/{SESSION_ID}/activities' \
  -H 'X-Goog-Api-Key: $JULES_API_KEY'
```

Activities contain the session's full history. Each activity has `id`, `name`,
`createTime`, and `originator` fields, plus one or more event payload fields:

- **`planGenerated`**: Jules created a work plan (contains `plan.steps[]` with `title` and `description`)
- **`planApproved`**: Plan was approved (contains `planId`)
- **`agentMessaged`**: Jules sent a message (contains `agentMessage` text — often asking for confirmation)
- **`progressUpdated`**: Human-readable progress message for an execution step
- **`artifacts`**: Opaque progress/output metadata, often paired with `progressUpdated`
- **`sessionCompleted`**: Completion marker for finished sessions
- **User messages**: User sent feedback (originator = `"user"`)

### Handling AWAITING_USER_FEEDBACK Sessions

Sessions in `AWAITING_USER_FEEDBACK` fall into two categories:

#### Simple Confirmations (auto-respondable)
Bolt/Palette agents asking for approval before finalizing:
- "Can you confirm if you are satisfied with these optimizations?"
- "Should I look for more improvements or finalize?"

In `full` autonomy mode, auto-respond with: "Looks good, please finalize and submit."

#### Substantive Questions (require context)
Jules asking clarifying questions before it can proceed — these need real answers:
- "Should I group parameters into a dataclass? What name?"
- "The function name doesn't match — which one should I update?"
- "Should I keep recommendation X or replace it with Y?"

**These are the highest-value triage targets.** An unanswered question blocks the entire session.

### Interactive Response Phase

When the skill encounters a substantive question, it can:

1. **Read the codebase** — pull the relevant files Jules is asking about (via GitHub MCP or `gh`)
2. **Analyze the question** — determine what context is needed to answer
3. **Formulate a response** — using codebase context, project conventions, and the session prompt
4. **Send the response** via `POST /sessions/{id}:sendMessage`
5. **Monitor** — wait for Jules to resume and either complete or ask follow-ups

#### Autonomy Modes for Question Answering

| Mode | Behavior |
|------|----------|
| `full` | Auto-answer questions using codebase analysis. Send response directly. |
| `approve-high-risk` | Draft an answer, present to user for approval before sending. Auto-answer simple confirmations. |
| `approve-all` | Surface the question in the digest. Never auto-respond. |

#### Auto-Answer Strategy (full mode)

For each question Jules asks:
1. Parse the question into discrete decision points
2. For each decision point:
   - Read relevant source files mentioned in the question
   - Check project conventions (`.editorconfig`, lint configs, `CLAUDE.md`, existing patterns)
   - Look at git history for the files in question (why is it written this way?)
   - Formulate the most conservative, consistent-with-codebase answer
3. Compose a response addressing each point
4. Send via `sendMessage` API

**Safety guardrails:**
- Never answer questions about removing security controls or access checks
- Never answer architectural questions that would add new dependencies
- If confidence is low, defer to human (include in digest instead)
- Always include reasoning in the response so Jules (and humans reviewing later) understand why

#### Example Response Flow

Jules asks: "Should I remove the unused `before` parameter from `_write_report`?"

Skill analysis:
1. Read `src/acheron/intel_draft_finalizer.py`
2. Confirm `before` is truly unused (`_ = before` pattern)
3. Check git blame — was it intentionally left for future use?
4. Check callers — are any passing a meaningful `before` argument?
5. Decision: "Yes, remove it. It's unused and callers pass it but don't rely on the value."

Response sent to Jules:
```
Yes, please remove the `before` parameter entirely. It's unused (just assigned to `_`) 
and the callers will be cleaner without it. Also yes, group the remaining parameters 
into a dataclass — `ReportContext` would be a good name. Keep `summary` and 
`missing_items` as explicit kwargs since they're the primary outputs.
```

### Extracting Key Signals

From the activities, extract:

1. **Intent**: What was the session trying to accomplish? (from the initial prompt)
2. **Scope**: How many files were changed? Which areas of the codebase?
3. **Quality signals**: Did Jules' internal tests pass? Any errors during execution?
4. **PR readiness**: Does the session have `AUTO_CREATE_PR` outputs, or does it need manual PR creation?
5. **Confidence markers**: How complex was the task? Did Jules express uncertainty?

### Session Scoring

Assign a triage score (0.0–1.0) based on:

| Factor | Weight | Signal |
|--------|--------|--------|
| Tests pass | 0.30 | Jules ran tests and they passed |
| Scope appropriate | 0.20 | Files changed within `max_files_changed` threshold |
| Clear intent | 0.15 | Session prompt was specific and well-defined |
| Category match | 0.15 | Matches configured `categories` |
| No errors | 0.10 | No failures or retries during execution |
| Plan approval | 0.10 | Plan was reviewed (manual or auto) |

Sessions scoring >= `min_confidence` are candidates for promotion.

---

## Phase 3: Triage Decision

### Autonomy Modes

#### `full`
Auto-promote all sessions scoring above `min_confidence`. Create PRs immediately and hand off to github-babysitter pr-care. No human input required.

#### `approve-high-risk`
Auto-promote sessions that are:
- Bug fixes with passing tests
- Style/formatting changes
- Documentation updates

Require approval for:
- Security-related changes
- Architectural changes (new files, dependency additions)
- Sessions touching > 20 files
- Sessions with confidence score between 0.5–0.7

#### `approve-all`
Never auto-promote. Generate the daily digest with recommendations and wait for explicit human approval before creating any PRs.

### Rejection Criteria

Automatically reject (never promote) sessions that:
- Failed during execution
- Touch files outside the session's stated scope
- Conflict with open PRs on the same files
- Have been explicitly rejected by a human in a prior cycle
- Score below 0.3 confidence

---

## Phase 4: Promotion

When a session is approved for promotion:

### Output Structure

Sessions produce two output types in `session.outputs[]`:

1. **`changeSet`** — always present when work was done:
   ```json
   {
     "changeSet": {
       "source": "sources/github/darksheer-labs/ARC",
       "gitPatch": {
         "unidiffPatch": "diff --git a/...",
         "baseCommitId": "a9aae35a2608...",
         "suggestedCommitMessage": "⚡ Bolt: Optimize timeline bucketing..."
       }
     }
   }
   ```

2. **`pullRequest`** — only present if Jules auto-created a PR:
   ```json
   {
     "pullRequest": {
       "url": "https://github.com/darksheer-labs/ARC/pull/281",
       "title": "⚡ Bolt: [performance improvement] optimize timeline bucketing",
       "description": "...",
       "baseRef": "main",
       "headRef": "bolt-timeline-map-lookup-10409236580371261383"
     }
   }
   ```

Many sessions have only `changeSet` without `pullRequest`, so the triage skill
must be able to promote patches manually. Do not assume the current percentage
is stable; report the observed counts in each digest.

### If Jules Already Created a PR

The PR already exists. The skill:
1. Locates the PR URL from `session.outputs[].pullRequest.url`
2. Verifies the PR is open and targeting the correct branch
3. Adds a triage annotation comment to the PR
4. Hands off to github-babysitter pr-care

### If Only a changeSet Exists (Common Case)

The skill creates a PR from the patch:
1. Parse `gitPatch.unidiffPatch` for the diff
2. Create a branch from `gitPatch.baseCommitId`
3. Apply the patch
4. Open a PR with:
   - Title from `gitPatch.suggestedCommitMessage` (first line)
   - Body containing session context, triage score, and link to Jules session URL (`session.url`)
   - Labels: `jules-triage`, agent name label (e.g., `bolt`, `palette`)
5. Hand off to github-babysitter pr-care

### Handoff to GitHub Babysitter

Once the PR exists, invoke github-babysitter pr-care with:
```
"Review PR #{number} on {owner}/{repo} — promoted from Jules session"
```

GitHub Babysitter takes over from here: running PR care, triaging review and CI findings, preparing fixes, and managing merge readiness.

---

## Phase 5: Reporting

### Daily Digest

After each triage run, generate a structured digest:

```markdown
# Jules Triage Digest — {date}

## Summary
- Sessions scanned: {total}
- Promoted to PR: {promoted_count}
- Awaiting approval: {pending_count}
- Rejected: {rejected_count}
- Still active (skipped): {active_count}

## Promoted Sessions
| Session | Repo | Category | Score | PR |
|---------|------|----------|-------|-----|
| {title} | {repo} | {cat} | {score} | #{pr_number} |

## Awaiting Your Approval
| Session | Repo | Category | Score | Risk |
|---------|------|----------|-------|------|
| {title} | {repo} | {cat} | {score} | {risk_reason} |

## Rejected
| Session | Repo | Reason |
|---------|------|--------|
| {title} | {repo} | {rejection_reason} |
```

### Notification Channels

If `notifications.slack_channel` is configured, post the digest there. Otherwise, output locally or post as a GitHub issue on a designated tracking repo.

---

## Phase 6: Learning

Track outcomes to improve triage over time:

### Metrics Collected

Per session:
- Was the promoted PR ultimately merged, closed, or abandoned?
- How many github-babysitter pr-care cycles did it take?
- Were there human overrides of the triage decision?
- Time from triage to merge

Per category:
- Which categories have the highest promotion-to-merge rate?
- Which categories get rejected most often after promotion?

### Feedback Loop

Over time, adjust:
- `min_confidence` threshold based on actual merge rates
- Category weights based on which types succeed
- Scope limits based on what humans actually approve

---

## Scheduling

Use the `/schedule` skill to set up daily runs (e.g., "Schedule jules-triage daily at 9am"). Manual invocation also works: "Triage my Jules sessions now" or "Triage Jules session {session_id} specifically".

---

## Jules API Reference

Read `references/jules-api.md` for complete endpoint documentation, request patterns, and response shapes.

---

## Reference Files

| File | When to Read |
|------|-------------|
| `references/jules-api.md` | When making Jules API calls or debugging responses |
| `references/config-schema.md` | When parsing or generating `.jules-triage.yml` |
| `references/triage-scoring.md` | When evaluating session quality or tuning thresholds |
| `references/promotion-workflow.md` | When creating PRs from sessions or handing off |
| `references/digest-template.md` | When generating the daily report |

---

## Workflow Summary

```
Schedule Trigger (or manual invocation)
    │
    ├─ 1. Load config, authenticate with Jules API
    ├─ 2. List sessions, filter to triage-eligible states
    │
    ├─ 3. AWAITING_USER_FEEDBACK sessions (unblock first):
    │   ├─ Read last agentMessaged activity
    │   ├─ Classify: simple confirmation vs. substantive question
    │   ├─ Simple → auto-respond "finalize and submit" (full mode)
    │   ├─ Substantive → analyze codebase, formulate answer
    │   ├─ Send response via sendMessage API (or defer to digest)
    │   └─ Session resumes → will appear as COMPLETED next cycle
    │
    ├─ 4. COMPLETED sessions (promote):
    │   ├─ Retrieve activities and outputs
    │   ├─ Score the session (tests, scope, intent, category)
    │   ├─ Apply autonomy rules
    │   └─ Decision: promote / request approval / reject
    │
    ├─ 5. For promoted sessions:
    │   ├─ Create PR (if not already created by Jules)
    │   └─ Hand off to github-babysitter pr-care
    │
    ├─ 6. Generate daily digest
    ├─ 7. Post notifications (Slack, GitHub issue, local)
    └─ 8. Record learning data
```
