# GitHub API Interaction Reference

The skill uses an adaptive three-tier approach for GitHub access. This document covers each tier and the specific API calls used throughout the workflow.

## Tier Selection

At the start of each session, detect the available tier:

### Tier 1: MCP Connector (preferred)
Check if a GitHub MCP is available in the current session. MCP connectors handle authentication automatically and provide structured tool calls.

Look for tools matching patterns like:
- `github_*` (native GitHub MCP)
- `linear_*` (Linear's GitHub integration)
- Any MCP tool that can read/write PRs and comments

If found, use MCP tool calls for all GitHub operations.

### Tier 2: GitHub CLI (`gh`)
```bash
gh auth status 2>/dev/null && echo "gh available" || echo "gh not available"
```

If authenticated, use `gh` commands. The CLI handles auth, pagination, and rate limiting.

### Tier 3: REST API
Fall back to direct API calls using `curl` with a PAT from `$GITHUB_TOKEN`.

```bash
curl -s -H "Authorization: Bearer $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  https://api.github.com/repos/{owner}/{repo}/...
```

## Core API Operations

### Get PR Details
```bash
# gh CLI
gh pr view {number} --repo {owner}/{repo} --json title,body,files,reviews,comments,state,headRefName,baseRefName

# REST API
GET /repos/{owner}/{repo}/pulls/{number}
GET /repos/{owner}/{repo}/pulls/{number}/files
```

### List PR Comments (issue comments — bot summaries live here)
```bash
# gh CLI
gh api /repos/{owner}/{repo}/issues/{number}/comments --paginate

# REST API
GET /repos/{owner}/{repo}/issues/{number}/comments?per_page=100
```

### List PR Review Comments (inline comments — findings live here)
```bash
# gh CLI
gh api /repos/{owner}/{repo}/pulls/{number}/comments --paginate

# REST API
GET /repos/{owner}/{repo}/pulls/{number}/comments?per_page=100
```

### List PR Reviews (review objects with verdict)
```bash
# gh CLI
gh api /repos/{owner}/{repo}/pulls/{number}/reviews --paginate

# REST API
GET /repos/{owner}/{repo}/pulls/{number}/reviews?per_page=100
```

### Post a Comment
```bash
# gh CLI
gh pr comment {number} --repo {owner}/{repo} --body "comment text"

# REST API
POST /repos/{owner}/{repo}/issues/{number}/comments
{"body": "comment text"}
```

### Reply to a Review Comment Thread
```bash
# gh CLI
gh api /repos/{owner}/{repo}/pulls/{number}/comments/{comment_id}/replies \
  -f body="reply text"

# REST API
POST /repos/{owner}/{repo}/pulls/{number}/comments/{comment_id}/replies
{"body": "reply text"}
```

### Get Check Runs (CI status)
```bash
# gh CLI
gh api /repos/{owner}/{repo}/commits/{sha}/check-runs --paginate

# REST API
GET /repos/{owner}/{repo}/commits/{sha}/check-runs?per_page=100
```

### List GitHub App Installations (for tool detection)
```bash
# gh CLI
gh api /repos/{owner}/{repo}/installation 2>/dev/null

# REST API — requires admin access
GET /repos/{owner}/{repo}/installations
```

Alternative detection: check for bot comments from known usernames:
- `coderabbitai[bot]`
- `codex[bot]` or `openai-codex[bot]`
- `jules[bot]` or `jules-agent[bot]`
- `gemini-code-assist[bot]`
- `github-actions[bot]` (for Action-based tools)

### Dispatch a Workflow (trigger an Action)
```bash
# gh CLI
gh workflow run {workflow_file} --repo {owner}/{repo} \
  -f pr_number={number}

# REST API
POST /repos/{owner}/{repo}/actions/workflows/{workflow_id}/dispatches
{"ref": "main", "inputs": {"pr_number": "{number}"}}
```

### Get Workflow Runs
```bash
# gh CLI
gh run list --repo {owner}/{repo} --branch {head_branch} --json databaseId,name,status,conclusion

# REST API
GET /repos/{owner}/{repo}/actions/runs?branch={head_branch}&per_page=10
```

### Get Workflow Run Logs
```bash
# gh CLI
gh run view {run_id} --repo {owner}/{repo} --log

# REST API
GET /repos/{owner}/{repo}/actions/runs/{run_id}/logs
```

## Pagination

GitHub API returns max 100 items per page. Always paginate:

```bash
# gh CLI handles pagination with --paginate flag

# REST API: follow Link header
page=1
while true; do
  response=$(curl -s -H "Authorization: Bearer $GITHUB_TOKEN" \
    "https://api.github.com/repos/{owner}/{repo}/pulls/{number}/comments?per_page=100&page=$page")
  # process response
  [ $(echo "$response" | jq length) -lt 100 ] && break
  page=$((page + 1))
done
```

## Rate Limiting

GitHub API has rate limits (5000 requests/hour for authenticated users). The skill should:
- Cache responses within a single review cycle (same PR data doesn't change mid-review)
- Use conditional requests (`If-None-Match` with ETags) for polling
- Batch operations where possible
- Check `X-RateLimit-Remaining` header and pause if below 100
