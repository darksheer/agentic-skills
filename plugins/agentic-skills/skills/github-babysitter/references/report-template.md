# Report Templates

## Repo-Rounds

```markdown
# GitHub Babysitter Repo Rounds

Generated: {timestamp}
Scope: {org_or_repos}
Mode: read-only | approved writes

## Scorecard

| Repo | Score | Open PRs | Issues | Workflow Signal | Top Risk |
| --- | ---: | ---: | ---: | --- | --- |
| owner/repo | 82 | 3 | 4 | passing | none |

## Top Risks

1. {repo}: {risk} - {recommended_action}

## Blocked PRs

| PR | Reason | Recommended Action |
| --- | --- | --- |

## Stale or Noisy Issues

| Issue | Signal | Recommended Action |
| --- | --- | --- |

## Workflow Health

| Repo | Workflow | Signal | Evidence |
| --- | --- | --- | --- |

## Approval Queue

| ID | Action | Target | Exact Command/API | Risk | Cleanup |
| --- | --- | --- | --- | --- | --- |

## Actions Not Taken

- No comments/labels/reruns/merges unless listed as approved.
```

## PR-Care

```markdown
# GitHub Babysitter PR Care

Generated: {timestamp}
PR: {url}
Mode: read-only | approved writes

## Status

| Attribute | Value |
| --- | --- |
| State | open |
| Draft | false |
| Mergeable | clean |
| Review decision | approved |
| Checks | passing |

## Findings

| ID | Source | Severity | Decision | Confidence | Notes |
| --- | --- | --- | --- | --- | --- |

## CI Triage

| Check | Status | Root Cause | Next Action |
| --- | --- | --- | --- |

## Fix Plan

1. {step}

## Merge Readiness

- Checks: pass/fail/unknown
- Reviews: approved/changes-requested/unknown
- Threads: resolved/unresolved/unknown
- Conflicts: none/conflict/unknown
- Risk notes: {notes}

## Approval Queue

| ID | Action | Target | Exact Command/API | Body/Branch | Risk | Cleanup |
| --- | --- | --- | --- | --- | --- | --- |

## Actions Not Taken

- No writes unless explicitly approved.
```
