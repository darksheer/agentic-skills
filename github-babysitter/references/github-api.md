# GitHub API Reference

Prefer the GitHub connector/MCP when available. Otherwise use `gh`; use direct
REST/GraphQL only as a fallback.

## Repo Metadata

```bash
gh repo view owner/repo \
  --json nameWithOwner,isPrivate,isArchived,defaultBranchRef,pushedAt,updatedAt
```

## Open PRs

```bash
gh pr list --repo owner/repo --state open --limit 100 \
  --json number,title,isDraft,author,createdAt,updatedAt,reviewDecision,statusCheckRollup
```

For one PR:

```bash
gh pr view 42 --repo owner/repo \
  --json number,title,url,state,isDraft,mergeable,reviewDecision,headRefName,baseRefName,author,createdAt,updatedAt,statusCheckRollup,files,commits,reviews,comments
```

## Issues

```bash
gh issue list --repo owner/repo --state open --limit 100 \
  --json number,title,author,labels,createdAt,updatedAt
```

Some repos disable issues. Treat that as a repo property, not a failure.

## Workflow Runs

```bash
gh run list --repo owner/repo --limit 20 \
  --json databaseId,workflowName,status,conclusion,createdAt,updatedAt,headBranch,event
```

For a failing run:

```bash
gh run view RUN_ID --repo owner/repo --json jobs,conclusion,status,workflowName
gh run view RUN_ID --repo owner/repo --log-failed
```

Fetch logs only when summaries are insufficient.

## Review Comments

```bash
gh api repos/owner/repo/pulls/42/comments
gh api repos/owner/repo/issues/42/comments
```

Use GraphQL when review threads and resolution state are needed.

## Write Actions

These need exact approval before execution:

```bash
gh pr comment 42 --repo owner/repo --body-file report.md
gh pr edit 42 --repo owner/repo --add-label label
gh run rerun RUN_ID --repo owner/repo
gh pr merge 42 --repo owner/repo --squash
```

Approval must include target, command, body/labels when applicable, expected
effect, risk, and rollback/cleanup plan.
