# GitHub Babysitter Config Schema

Use `.github-babysitter.yml` for new configuration.

Compatibility inputs:

- `.github-pro-babysitter.yml`: map repo health settings into `repo_rounds`.
- `.pr-orchestrator.yml`: map PR review settings into `pr_care`.

Prefer `.github-babysitter.yml` when multiple configs are present.

## Complete Example

```yaml
organization: darksheer
repositories: []
exclude_repositories: []
include_private: true
include_archived: false

default_mode: pr-care       # pr-care | repo-rounds
write_actions: false
autonomy: approve-all       # full | approve-high-risk | approve-all

repo_rounds:
  lookback_days: 14
  stale_after_days: 7
  max_repos_per_run: 50
  pull_requests:
    include_drafts: true
    flag_failing_checks: true
    flag_review_required: true
    flag_conflicting_files: true
  issues:
    stale_after_days: 14
    priority_labels: [priority:high, security, incident]
    noise_labels: [stale, parity-item, optic-parity]
  workflows:
    lookback_days: 7
    failure_streak_threshold: 2
    fetch_logs: on_failure_summary_only  # never | on_failure_summary_only | always
  scoring:
    default_branch_workflows: 30
    pull_requests: 25
    issues: 15
    dependency_security: 15
    freshness: 10
    automation_noise: 5

pr_care:
  review_tools: auto
  skip_drafts: true
  min_changed_lines: 1
  max_iterations: 3
  batch_commits: true
  bot_prs:
    trigger_reviewers: false
    require_ci_green: true
    dependency_update_focus: [lockfile, advisories, release_notes, engines]
  filters:
    exclude_paths:
      - "**/*.lock"
      - "**/node_modules/**"
      - "**/*.generated.*"
      - "**/vendor/**"
    include_paths: []
    min_severity: info

review_tools:
  coderabbit:
    enabled: true
    trust_level: high
  codex:
    enabled: true
    trust_level: high
    focus: []
  jules:
    enabled: true
    trust_level: medium
  gemini:
    enabled: true
    trust_level: medium
  pr-agent:
    enabled: false
    trust_level: medium
  graphite:
    enabled: true
    trust_level: medium
  reviewdog:
    enabled: true
    trust_level: high

cost_budget:
  max_actions_minutes_per_pr: 30
  batch_strategy: smart    # smart | parallel | sequential

compliance:
  check_agents_md: true
  check_claude_md: true
  legal_domains: []
  additional_policy_files: []

reporting:
  output_local: false
  local_path: tests/results/github-babysitter/
  post_to_github: false
  post_to_slack: false
  verbosity: full          # full | summary | minimal

learning:
  enabled: true
  store_path: .github-babysitter/state
```

## Write Safety

`write_actions` defaults to `false`. When false, GitHub Babysitter must not:

- post comments
- add labels, assignees, milestones, or reviewers
- rerun or cancel workflows
- create branches, commits, or pushes
- merge, close, revert, or delete branches
- trigger review bots or paid automation

It may still recommend those actions in an approval queue.

## Reporting Defaults

`reporting.output_local` defaults to `false`. GitHub Babysitter should not create
markdown files, report files, or `tests/results/` artifacts unless the user
explicitly asks for a report/file/digest or config opts in.

`default_mode` defaults to `pr-care`. Broad repo-rounds scans are opt-in by user
request or config because the normal babysitter job is to move PRs toward merge
readiness.

## Environment Variables

| Variable | Use |
| --- | --- |
| `GITHUB_BABYSITTER_CONFIG` | Override config path. |
| `GITHUB_TOKEN` | REST/GraphQL fallback if connector and `gh` are unavailable. |
| `GITHUB_BABYSITTER_ORG` | Override `organization`. |
| `GITHUB_BABYSITTER_REPOS` | Comma-separated repo allowlist. |
| `PR_ORCHESTRATOR_CONFIG` | Legacy config override for PR-care compatibility. |
| `GITHUB_PRO_BABYSITTER_ORG` | Legacy org override for repo-rounds compatibility. |
