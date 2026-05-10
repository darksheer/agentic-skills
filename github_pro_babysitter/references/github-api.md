# GitHub API Reference

Prefer `gh` when authenticated because it handles auth and pagination.

## Repo Discovery

```bash
gh repo list darksheer --limit 100 \
  --json name,nameWithOwner,visibility,isArchived,defaultBranchRef,pushedAt,updatedAt
```

## Repo Metadata

```bash
gh repo view owner/repo \
  --json nameWithOwner,isPrivate,isArchived,defaultBranchRef,pushedAt,updatedAt,issues,pullRequests,licenseInfo,repositoryTopics
```

## Pull Requests

```bash
gh pr list --repo owner/repo --state open --limit 100 \
  --json number,title,isDraft,author,createdAt,updatedAt,mergeable,reviewDecision,statusCheckRollup

gh pr view 42 --repo owner/repo \
  --json number,title,state,isDraft,author,baseRefName,headRefName,files,comments,reviews,statusCheckRollup
```

## Issues

```bash
gh issue list --repo owner/repo --state open --limit 100 \
  --json number,title,author,createdAt,updatedAt,labels,url
```

## Workflow Runs

```bash
gh api /repos/owner/repo/actions/runs \
  --jq '{total:.total_count, recent:[.workflow_runs[:10][] | {id,name,status,conclusion,event,created_at,updated_at,head_branch,html_url}]}'

gh run view RUN_ID --repo owner/repo \
  --json name,status,conclusion,event,createdAt,updatedAt,headBranch,jobs
```

Fetch logs only when the job summary is insufficient:

```bash
gh run view RUN_ID --repo owner/repo --log-failed
```

## REST Fallback

Use `curl` with `Authorization: Bearer $GITHUB_TOKEN` against:
- `GET /orgs/{org}/repos`
- `GET /repos/{owner}/{repo}`
- `GET /repos/{owner}/{repo}/pulls`
- `GET /repos/{owner}/{repo}/issues`
- `GET /repos/{owner}/{repo}/actions/runs`

Always paginate REST calls and respect rate limits.
