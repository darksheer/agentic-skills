# Polling Cost and Rate Limits

Monitoring should be cheap and read-only by default.

## Cost Rules

- Prefer summary endpoints before fetching full logs.
- Limit org-wide scans with `max_repos_per_run`.
- Sort repos by recent `pushedAt` when a limit is needed.
- Fetch workflow logs only for failing runs that need root-cause evidence.
- Cache repo metadata within a run.
- Do not trigger workflows or reviewers unless explicitly requested.

## Suggested Request Budget

For each repo:
- 1 repo metadata request
- 1 open PR list request
- 1 open issue list request
- 1 workflow run summary request
- optional PR detail requests for blocked/stale PRs
- optional failed-log requests for top failures only

## Rate Limit Handling

If GitHub rate limit remaining drops below 100, stop optional log/detail fetches
and produce a partial report with a rate-limit note.
