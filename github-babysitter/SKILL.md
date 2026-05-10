---
name: github-babysitter
description: >
  Unified GitHub operations skill for repo-wide health monitoring and focused PR
  care. Use when the user mentions github-babysitter, pr-babysitter, repo rounds,
  repository health, stale PRs or issues, failing GitHub Actions, CI triage,
  PR review orchestration, CodeRabbit/Codex/Jules/Gemini review comments,
  merge readiness, dependency PRs, or babysitting GitHub work across darksheer
  repositories. Replaces the separate pr-orchestrator and github_pro_babysitter
  mental model with one skill that has repo-rounds and pr-care modes.
---

# GitHub Babysitter

GitHub Babysitter turns GitHub noise into an action queue. It has two scopes:

- `repo-rounds`: broad scan across one repo or many repos.
- `pr-care`: focused work on one PR, also called `pr-babysitter`.

Default behavior is read-only. It may inspect, classify, report, and prepare
approval queues. It must not comment, label, rerun, cancel, push, merge, close,
or invoke paid/review automation unless the user explicitly approves the exact
action.

## Quick Start

```text
"Run repo rounds for darksheer/ARC"
"Babysit PR #312 in darksheer/ARC"
"Why is this PR blocked?"
"Check my repos for stale PRs and failing workflows"
"Take this Jules handoff payload and babysit the PR"
```

## Mode Selection

Choose the smallest mode that satisfies the request:

| Request Shape | Mode |
| --- | --- |
| Org/repo scan, stale work, failing workflows, daily digest | `repo-rounds` |
| Specific PR URL/number, review comments, checks, merge readiness | `pr-care` |
| Failing check/run/job/logs | `ci-triage` inside `pr-care` or `repo-rounds` |
| CodeRabbit/Codex/Jules/Gemini comments | `review-triage` inside `pr-care` |
| "Can this merge?" | `merge-readiness` inside `pr-care` |

If the user says `pr-babysitter`, use `pr-care`.

## Configuration

Read `.github-babysitter.yml` from the workspace or target repo when present.
For migration compatibility, also understand `.github-pro-babysitter.yml` and
`.pr-orchestrator.yml`; prefer `.github-babysitter.yml` when multiple exist.

Read `references/config-schema.md` before generating or changing config.

## GitHub Access

Use the safest available read path:

1. GitHub connector/MCP when available.
2. `gh` CLI when authenticated.
3. REST/GraphQL API with `GITHUB_TOKEN`.

Read `references/github-api.md` for command and field patterns.

## Safety Rules

Read-only actions do not require approval:

- repo/PR/issue/check/run metadata reads
- review/comment reads
- workflow log reads when needed for diagnosis
- local report generation

These write actions require exact approval first:

- PR or issue comments
- labels, assignees, milestones, review requests
- workflow reruns or cancellations
- branch creation, patch application, commits, pushes
- reviewer/tool invocation by comment or dispatch
- merge, close, revert, or delete branch actions

Every approval item must include target, command/API endpoint, body or branch
name, expected effect, risk, and rollback/cleanup plan.

## Repo-Rounds Workflow

Use this for repository health monitoring.

1. Select target repos from the user request or config.
2. Collect repo metadata: visibility, archived state, default branch, pushedAt,
   updatedAt, branch protection if available.
3. Collect open PRs, issues, and recent workflow runs.
4. Classify:
   - blocked PR
   - stale PR
   - ready PR
   - dependency-blocked PR
   - conflict-risk PR
   - stale/noisy/priority issue
   - failing scheduled/default-branch workflow
5. Score health using config weights.
6. Produce a digest with recommended next actions and actions not taken.

Do not hand off to another skill for PR work. If one PR needs deep care, switch
to `pr-care` within GitHub Babysitter and keep the context.

## PR-Care Workflow

Use this for a single PR lifecycle.

1. Identify owner/repo/PR number.
2. Fetch PR metadata: state, draft, author, base/head, mergeability, changed
   files, commits, reviews, review threads, issue comments, and checks.
3. Detect review tools and automation signals. Read `references/review-tools.md`
   when interpreting CodeRabbit, Codex, Jules, Gemini, PR-Agent, Graphite, or
   Reviewdog output.
4. Collect and dedupe findings from humans, bots, check runs, and logs.
5. Triage each finding:
   - accurate?
   - applicable?
   - worth fixing in this PR?
   - needs more analysis?
6. Build a fix plan. Apply fixes only when explicitly approved or when config
   and user instruction allow it.
7. Re-check only the relevant tests/checks after fixes.
8. Produce a merge-readiness report.

## CI-Triage Workflow

When a PR or repo has failing GitHub Actions:

1. Identify failing workflow, job, step, branch, event, and commit SHA.
2. Read summaries first; fetch full logs only when needed.
3. Separate product failures from infrastructure/flaky failures.
4. Map the failure to owner/action:
   - fix code
   - update tests
   - re-run flaky job
   - investigate infrastructure
   - defer to human
5. Queue exact write actions only when approval is needed.

## Review-Triage Workflow

Normalize findings into:

```text
Finding {
  id, source, severity, category, file, line_start, line_end,
  description, suggested_fix, comment_url, raw_data
}
```

Deduplicate by file/range/category and boost confidence when multiple tools or
humans agree. For bot-authored dependency PRs, prioritize package consistency,
security advisories, CI status, and release-note risk before requesting more AI
review.

## Merge-Readiness Checklist

A PR is ready only when:

- state is open and not draft
- required checks pass or missing checks are documented
- review decision is approved or approval requirement is absent/documented
- mergeability is clean or conflict risk is documented
- unresolved review threads are handled or explicitly deferred
- dependency/security/compliance risks are noted
- final report lists actions taken and actions intentionally not taken

## Jules Handoff

Accept handoff payloads from `jules-triage`/`jules-wrangler` with:

```json
{
  "source_skill": "jules-triage",
  "target_skill": "github-babysitter",
  "mode": "pr-care",
  "session_id": "session_abc123",
  "session_url": "https://jules.google.com/session/abc123",
  "repo": "owner/repo",
  "pr_number": 42,
  "pr_url": "https://github.com/owner/repo/pull/42",
  "category": "security",
  "triage_score": 0.9,
  "tests": "passed|failed|not_run|unknown",
  "promotion_reason": "Score exceeded threshold and scope was within limits",
  "risk_notes": []
}
```

If a field is unknown, keep it with value `unknown` rather than omitting it.

## Reporting

Write reports under `tests/results/github-babysitter/` unless the user or config
chooses another path.

For repo rounds, use `references/report-template.md#repo-rounds`.
For PR care, use `references/report-template.md#pr-care`.

Always include:

- scope scanned
- key findings
- recommended next actions
- approval queue
- write actions not taken
- verification performed or skipped

## References

| File | When to Read |
| --- | --- |
| `references/config-schema.md` | Parsing or generating config. |
| `references/github-api.md` | GitHub connector, `gh`, REST, or GraphQL field patterns. |
| `references/review-tools.md` | Interpreting review bots and CI/review automation. |
| `references/report-template.md` | Writing repo-rounds or pr-care reports. |
