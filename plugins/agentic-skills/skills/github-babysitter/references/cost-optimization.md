# Cost and Rate Limits

GitHub Babysitter should be useful without creating avoidable Actions or API
costs.

## Repo Rounds

- Prefer summary endpoints before fetching full logs.
- Limit org-wide scans with `repo_rounds.max_repos_per_run`.
- Sort repos by recent `pushedAt` when a limit is needed.
- Fetch workflow logs only for failing runs that need root-cause evidence.
- Cache repo metadata within a run.
- Stop optional log/detail fetches when GitHub rate limit remaining drops below
  100 and report a partial result.

Suggested request budget per repo:

- one repo metadata request
- one open PR list request
- one open issue list request
- one workflow run summary request
- optional PR detail requests for blocked/stale PRs
- optional failed-log requests for top failures only

## PR Care

- Collect existing app/bot output before triggering any reviewer.
- Prefer GitHub App output over Actions-based reviewer runs.
- Batch commits so CI runs once instead of once per finding.
- Re-run only affected local tests first, then broader checks when needed.
- Use incremental re-review when the tool supports it.
- Do not request full re-review when new-commit review is enough.

## Reviewer Cost Order

When config says `batch_strategy: smart`, use this order:

1. Existing human and bot comments.
2. Existing deterministic checks and check annotations.
3. Existing GitHub App reviewers such as CodeRabbit, Gemini, or Graphite.
4. Actions-based reviewers such as Codex Action, Jules Action, PR-Agent, or
   Reviewdog only when approved or already running.

Always include skipped cost-related actions in the report.
