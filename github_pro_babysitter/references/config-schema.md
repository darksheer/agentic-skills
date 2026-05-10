# Configuration Schema

Full schema for `.github-pro-babysitter.yml`. All fields are optional.

```yaml
organization: darksheer
repositories: []              # empty = all visible repos
exclude_repositories: []
include_private: true
include_archived: false

lookback_days: 14
stale_after_days: 7
max_repos_per_run: 50

pull_requests:
  include_drafts: true
  stale_after_days: 7
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

reporting:
  output_local: true
  local_path: tests/results/github_pro_babysitter/
  post_to_github: false
  post_to_slack: false

write_actions: false

learning:
  enabled: true
  store_path: .github-pro-babysitter/state
```

## Environment Variables

| Variable | Use |
|----------|-----|
| `GITHUB_TOKEN` | REST fallback if `gh` is unavailable |
| `GITHUB_PRO_BABYSITTER_ORG` | Overrides `organization` |
| `GITHUB_PRO_BABYSITTER_REPOS` | Comma-separated repo allowlist |

## Write Safety

`write_actions` defaults to false. When false, the skill must not post comments,
close issues, add labels, rerun workflows, cancel workflows, merge PRs, or push
commits. It may still recommend those actions in the report.
