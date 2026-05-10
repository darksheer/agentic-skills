# Report Template

```markdown
# GitHub Health Digest - {date}

## Summary

| Metric | Value |
|--------|-------|
| Repos scanned | {repo_count} |
| Repos with failing workflows | {failing_repo_count} |
| Blocked PRs | {blocked_pr_count} |
| Stale PRs | {stale_pr_count} |
| Stale/noisy issues | {issue_count} |

## Repo Scorecard

| Repo | Score | PRs | Issues | Workflows | Top Risk |
|------|-------|-----|--------|-----------|----------|
| {repo} | {score} | {pr_summary} | {issue_summary} | {workflow_summary} | {risk} |

## Top Action Items

| Priority | Repo | Item | Evidence | Recommended Action |
|----------|------|------|----------|--------------------|
| High | {repo} | {item} | {evidence} | {action} |

## Blocked Pull Requests

| Repo | PR | State | Checks | Recommendation |
|------|----|-------|--------|----------------|
| {repo} | #{number} | {state} | {checks} | {recommendation} |

## Workflow Failures

| Repo | Workflow | Branch | Failures | Latest Run |
|------|----------|--------|----------|------------|
| {repo} | {workflow} | {branch} | {count} | {url} |

## Stale or Noisy Issues

| Repo | Issue | Labels | Last Updated | Recommendation |
|------|-------|--------|--------------|----------------|
| {repo} | #{number} | {labels} | {updated} | {recommendation} |

## Actions Not Taken

List any comments, reruns, labels, closes, merges, or notifications that were
recommended but not performed because `write_actions` was false or approval was
missing.
```
