# Report Templates

Use these templates only when the user explicitly asks for a report/file/digest
or config enables `reporting.output_local`. Default `$github-babysitter` output
belongs in chat and should not create markdown files.

## Repo-Rounds

```markdown
# GitHub Babysitter Repo Rounds

Generated: {timestamp}
Scope: {org_or_repos}
Mode: read-only | approved writes
Data sources: {commands_or_api_calls_used}

## Scorecard

| Repo | Score | Open PRs | Issues | Workflow Signal | Top Risk |
| --- | ---: | ---: | ---: | --- | --- |
| owner/repo | 82 | 3 | 4 | passing | none |

## Top Risks

1. {repo}: {risk} - {recommended_action}

## Data Collection

| Repo | Source | Status | Notes |
| --- | --- | --- | --- |
| owner/repo | gh/API/connector | complete/partial/failed | {fallback_or_error} |

## Blocked PRs

| PR | Classification | Evidence | Recommended Action |
| --- | --- | --- | --- |

## Stale or Noisy Issues

| Issue | Classification | Evidence | Recommended Action |
| --- | --- | --- | --- |

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
Data sources: {commands_or_api_calls_used}

## Status

| Attribute | Value |
| --- | --- |
| State | open |
| Draft | false |
| Mergeable | clean |
| Review decision | approved |
| Checks | passing |
| Merge readiness | ready-to-merge/merged/blocked-needs-approval/blocked-needs-human/blocked-external/unknown |
| Loop state | draft/conflicted/behind-base/failing-ci/waiting-ci/changes-requested/unresolved-review/needs-review/reviewer-skipped/ready-to-merge/merged/blocked-needs-approval/blocked-needs-human/blocked-external |

## State Loop

| Iteration | Start State | Action Taken | Verification | End State |
| ---: | --- | --- | --- | --- |
| 1 | failing-ci | triaged failed job and applied local fix | unit test passed | waiting-ci |

## Findings

| ID | Source | Severity | Accuracy | Applicability | Decision | Confidence | Evidence |
| --- | --- | --- | --- | --- | --- | --- | --- |

## CI Triage

| Check | Status | Root Cause | Next Action |
| --- | --- | --- | --- |

## Fix Plan

1. {step}

## Merge Readiness

- Verdict: ready-to-merge/merged/blocked-needs-approval/blocked-needs-human/blocked-external/unknown
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
