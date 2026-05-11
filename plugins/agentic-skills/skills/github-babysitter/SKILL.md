---
name: github-babysitter
description: >
  Operational GitHub babysitter for repo-wide health rounds and focused PR care.
  Use when the user mentions github-babysitter, pr-babysitter, repo rounds,
  repository health, stale PRs or issues, failing GitHub Actions, CI triage,
  PR review orchestration, CodeRabbit/Codex/Jules/Gemini review comments,
  merge readiness, dependency PRs, Jules handoffs, or babysitting GitHub work
  across darksheer repositories. Replaces pr-orchestrator and
  github_pro_babysitter with two modes: repo-rounds and pr-care.
---

# GitHub Babysitter

GitHub Babysitter must turn live GitHub PR state into state transitions. Do not
answer with a generic checklist. Do not create markdown files by default. For
every run, collect actual repo/PR data unless access is unavailable, then move
the relevant PRs toward `ready-to-merge`, `merged`, or a specific blocked state.

Default behavior is active PR care with approval gates. Read-only work still
means doing the full inspection, classification, triage, and local fix planning.
External writes require exact approval first.

## Default Invocation

A bare `$github-babysitter` means:

1. Infer the current repo from `git remote get-url origin`.
2. Find active PRs with `gh pr view` for the current branch; if none, list open
   non-draft PRs for the current repo.
3. Run `pr-care` loops on actionable PRs, prioritizing:
   - PRs with failing required checks
   - PRs with changes requested or unresolved review comments
   - PRs that are green and likely ready to merge
   - stale non-draft PRs
4. Stop only when each selected PR is `ready-to-merge`, `merged`, or blocked on
   an exact approval/human/external dependency.

Do not default to repo-rounds unless the user asks for repo health, org scan,
daily digest, stale issue scan, or broad monitoring.

## Output Policy

Do not write markdown reports, report files, or `tests/results/` artifacts by
default. Default output is a concise chat update plus approval queue. Write a
local report only when the user explicitly asks for a report/file/digest, or
when `.github-babysitter.yml` sets `reporting.output_local: true`.

When local reports are disabled, still provide the same substance in the final
response: PR loop state, actions taken, remaining blockers, approval queue, and
verification.

## Modes

Choose the smallest mode that satisfies the request:

| Request | Mode |
| --- | --- |
| Org/repo scan, stale work, failing workflows, daily digest | `repo-rounds` |
| Specific PR URL/number, Jules handoff PR, review comments, merge readiness | `pr-care` |
| Failing workflow/run/job/logs | `ci-triage` inside `repo-rounds` or `pr-care` |
| CodeRabbit/Codex/Jules/Gemini comments | `review-triage` inside `pr-care` |
| "Can this merge?" | `merge-readiness` inside `pr-care` |

If the user says `pr-babysitter`, use `pr-care`. If the user provides a Jules
handoff payload, use `pr-care` and preserve every handoff field in the report.

## Execution Contract

Every invocation must complete these steps:

1. Resolve the target: PR URL/number, repo, org, or current GitHub remote.
2. Load config if present: `.github-babysitter.yml`, then legacy
   `.github-pro-babysitter.yml` or `.pr-orchestrator.yml`.
3. Select GitHub access: connector/MCP, then authenticated `gh`, then REST with
   `GITHUB_TOKEN`.
4. Collect live data using the minimum data collection for the selected mode.
5. Classify and prioritize findings with concrete evidence.
6. Execute allowed local/read-only transitions and keep looping PRs until
   terminal or blocked.
7. Include an approval queue for every write, rerun, reviewer trigger, branch,
   commit, push, merge, close, or external comment that was not approved.

Definition of done:

- Reports name actual repos, PRs, checks, workflows, comments, or issue numbers.
- Each blocker has an owner/action recommendation, not just a status.
- Each skipped action says why it was skipped.
- If access failed, the report includes the failed command/API and fallback used.
- For PR care, the loop reaches `ready-to-merge`, `merged`, or a concrete
  `blocked-*` terminal state. A first-pass report is not done when actionable
  PR work remains.

## Target Resolution

Use these defaults before asking questions:

- Current repo: infer `owner/repo` from `git remote get-url origin`.
- Current branch PR: try `gh pr view --json number,url`.
- Named PR number without repo: use the current repo.
- "My repos" or no repo: use config `organization`, default `darksheer`.
- Jules handoff: parse `repo`, `pr_number`, `pr_url`, `session_id`, `category`,
  `triage_score`, `tests`, `promotion_reason`, and `risk_notes`.

Ask a question only when no target can be inferred safely.

## Safety Rules

Read-only actions do not need approval:

- repo, PR, issue, review, comment, check, run, and log reads
- local report generation when explicitly requested or config-enabled
- local code inspection when a checkout is available
- local test/build commands that do not publish external state

Exact approval is required before:

- PR/issue comments, labels, assignees, milestones, review requests
- workflow reruns or cancellations
- reviewer/tool invocation by comment, dispatch, or paid API
- branch creation, patch application, commits, pushes
- merge, close, revert, delete branch

Approval items must include target, exact command/API endpoint, body/label/branch
when applicable, expected effect, risk, and rollback/cleanup plan.

## Repo-Rounds

Use repo-rounds for health monitoring across one repo or many.

Minimum data collection per repo:

```bash
gh repo view owner/repo --json nameWithOwner,isPrivate,isArchived,defaultBranchRef,pushedAt,updatedAt
gh pr list --repo owner/repo --state open --limit 100 --json number,title,isDraft,author,createdAt,updatedAt,reviewDecision,statusCheckRollup
gh issue list --repo owner/repo --state open --limit 100 --json number,title,author,labels,createdAt,updatedAt
gh run list --repo owner/repo --limit 20 --json databaseId,workflowName,status,conclusion,createdAt,updatedAt,headBranch,event
```

For blocked PRs, fetch detail:

```bash
gh pr view NUMBER --repo owner/repo --json number,title,url,state,isDraft,mergeable,reviewDecision,headRefName,baseRefName,author,updatedAt,statusCheckRollup,files
```

For failing workflows, inspect summaries before logs:

```bash
gh run view RUN_ID --repo owner/repo --json jobs,conclusion,status,workflowName
gh run view RUN_ID --repo owner/repo --log-failed
```

Classify PRs:

| Signal | Classification | Action |
| --- | --- | --- |
| non-draft, failing required checks | `blocked` | triage failed checks |
| stale beyond threshold | `stale` | recommend owner ping, rebase, or close |
| bot dependency PR with failing checks | `dependency-blocked` | inspect lockfile, engines, advisory risk |
| mergeable, approved, green | `ready` | recommend merge review |
| multiple open PRs touch same files | `conflict-risk` | flag coordination |
| draft with green checks | `watch` | note only |

Classify issues:

- `priority`: labels such as `security`, `incident`, `priority:high`, `CVE`
- `stale`: no update beyond configured threshold
- `automation-noise`: repeated bot issue pattern or stale tracker churn
- `linked-work`: issue referenced by open PRs

Classify workflows:

- `default-branch-failure`: failure on default branch
- `failure-streak`: repeated failures in same workflow
- `required-check-missing`: required context absent/skipped on open PR
- `long-running`: queued/in-progress beyond normal duration
- `security-sensitive-failure`: CodeQL, audit, secret scan, release, deploy, auth

Score each repo from 0-100:

| Factor | Weight |
| --- | ---: |
| Default branch workflow health | 30 |
| Open PR health | 25 |
| Issue staleness and priority | 15 |
| Dependency/security signal | 15 |
| Repo freshness and maintenance hygiene | 10 |
| Automation noise level | 5 |

Output must include scorecard, top risks, blocked PRs, stale/noisy issues,
workflow health, recommended next actions, approval queue, and actions not taken.

## PR-Care

Use PR-care to move one PR through its lifecycle, including Jules handoffs. Do
not stop after one inspection unless the PR is already terminal or the next
state transition needs approval/human input.

Minimum data collection:

```bash
gh pr view NUMBER --repo owner/repo --json number,title,url,state,isDraft,mergeable,reviewDecision,headRefName,baseRefName,author,createdAt,updatedAt,statusCheckRollup,files,commits,reviews,comments
gh api repos/owner/repo/pulls/NUMBER/comments
gh api repos/owner/repo/issues/NUMBER/comments
```

Also inspect:

- changed files and relevant code context
- failing check runs and failed logs when needed
- review threads or unresolved comments when available
- project policy files: `AGENTS.md`, `CLAUDE.md`, `CONTRIBUTING.md`,
  `SECURITY.md`, plus configured policy files

PR-care phases:

1. Detect review tools and CI: CodeRabbit, Codex, Jules, Gemini, PR-Agent,
   Graphite, Reviewdog, linters, test workflows.
2. Collect findings from review comments, issue comments, check annotations,
   logs, and bot summaries.
3. Normalize each finding:
   ```text
   Finding { id, source, severity, category, file, line_start, line_end,
   description, suggested_fix, comment_url, raw_data }
   ```
4. Deduplicate by file/range/category and mark cross-tool consensus.
5. Evaluate each finding by reading code in context:
   - accurate?
   - applicable to this codebase?
   - worth fixing in this PR?
   - needs tests or owner input?
6. Produce a fix plan. If approved to edit, implement, verify, and batch commits.
7. Re-check only relevant tests/checks after fixes.
8. End with merge readiness: `ready`, `blocked`, or `unknown`.

For each finding, record:

| Field | Required Values |
| --- | --- |
| Accuracy | `yes`, `no`, `partial`, `unknown` |
| Applicability | `yes`, `no`, `context-dependent` |
| Decision | `apply`, `skip`, `defer`, `needs-human` |
| Confidence | `high`, `medium`, `low` |
| Evidence | file/line, comment URL, check name, or log excerpt summary |

## Active PR State Loop

PR-care is a loop executor. Each pass must choose the next smallest unblocker,
act when allowed, re-fetch PR state, and continue until a terminal state.

Loop outline:

1. Snapshot PR state with metadata, checks, reviews, comments, changed files,
   commits, and recent workflow runs.
2. Classify the current state using the state table below.
3. Select exactly one next transition, or a small batch of independent local code
   fixes when batching is clearly safer.
4. Execute the transition if it is read-only, local, or already approved.
5. If the transition needs external write approval, emit an exact approval item
   and stop in `blocked-needs-approval`.
6. Re-fetch PR/check/review state after every executed transition.
7. Repeat until terminal, `max_iterations` is reached, or two consecutive passes
   make no progress.

State table:

| State | Detection | Required Transition |
| --- | --- | --- |
| `draft` | `isDraft == true` | inspect but do not mark ready unless approved |
| `conflicted` | mergeable conflict/dirty base | prepare rebase/merge fix; push only with approval |
| `behind-base` | branch stale or required update | update branch/rebase if approved; then re-check |
| `failing-ci` | required or relevant checks failing | run CI triage, fix/rerun/defer, then re-check |
| `waiting-ci` | checks queued/in_progress | wait or report polling state; do not declare ready |
| `changes-requested` | human/bot review requests changes | triage comments, fix/defer, then re-check reviews |
| `unresolved-review` | unresolved threads or unhandled comments | resolve through code change or approved reply |
| `needs-review` | no approval and approvals required/expected | request review only with approval; otherwise block |
| `reviewer-skipped` | tool skipped by policy, e.g. bot PR | record skip; do not trigger override without approval |
| `ready-to-merge` | open, non-draft, clean, checks green, reviews acceptable | report ready or merge if explicitly approved |
| `merged` | PR merged | record terminal success |
| `blocked-needs-approval` | next required transition is an external write | present exact approval item |
| `blocked-needs-human` | product/security/owner decision required | state exact decision needed |
| `blocked-external` | upstream service, permissions, or infra unavailable | state owner and retry path |

Transition rules:

- Approval queue is not a final report; it is the loop's pause point. After the
  user approves an item, resume from a fresh snapshot.
- Fixing CI takes priority over requesting more AI review.
- Human change requests outrank bot comments.
- Required checks outrank optional checks, but optional failures still appear in
  risk notes.
- Do not mark `ready-to-merge` while checks are pending, review state is unknown,
  or unresolved comments are unexamined.
- If a local fix is made, run the nearest relevant verification before any push
  approval request.
- After a push, wait for or re-check CI; do not stop at "pushed fixes".
- If merge is requested and approved, verify readiness immediately before merge.

## CI Triage

When a check or workflow fails:

1. Identify workflow, job, failing step, branch, event, commit SHA, and whether
   it is required.
2. Read job summaries first; fetch full logs only for root-cause evidence.
3. Attribute failure:
   - product/code failure
   - test expectation failure
   - dependency/environment failure
   - infrastructure/flaky failure
   - pre-existing failure
   - caused by babysitter-applied fix
4. Recommend one action:
   - fix code
   - update test
   - rerun flaky job
   - update dependency/lockfile
   - defer to human/infra owner
5. Queue exact rerun/cancel/comment actions for approval.

## Review Tool Handling

Read `references/review-tools.md` before interpreting a tool-specific result.

Do not trigger reviewers just because they exist. First collect existing output.
For bot-authored or dependency PRs, record reviewer skips such as CodeRabbit
"Bot user detected" as tool status, not as a failure. Do not override reviewer
skip policy unless the user explicitly approves or config opts in.

Use consensus carefully:

- Multiple tools agreeing on the same file/range boosts confidence.
- A failing deterministic check outweighs a speculative AI suggestion.
- Human review comments outrank bot style suggestions.
- Security/correctness findings get priority over style.

## Remediation Rules

If the user asks to fix issues or config allows edits:

1. Keep fixes scoped to the PR and the validated finding.
2. Apply low-risk fixes directly only when autonomy permits it.
3. For security, public API, dependency, data migration, or broad refactor fixes,
   prepare a patch plan and ask for approval.
4. Run relevant local checks when practical.
5. Batch commits and pushes to avoid repeated CI churn.
6. Track which commits/lines the babysitter changed to avoid self-review loops.

If a babysitter fix causes a test failure, revert or adjust that fix before
proceeding, and record the attribution in the report.

## Merge Readiness

A PR is `ready` only when:

- state is open and not draft
- required checks pass or missing checks are explicitly documented
- review decision is approved or approval requirement is absent/documented
- mergeability is clean or conflict risk is documented
- unresolved review threads are handled or explicitly deferred
- dependency/security/compliance risks are noted
- approval queue is empty or remaining items are non-blocking

Otherwise it is `blocked` with reasons. Use `unknown` only when GitHub did not
return enough data and no fallback was available.

## Reporting

Local report files are opt-in, not default behavior. Write under
`tests/results/github-babysitter/` only when the user explicitly asks for a
report/file/digest, or config enables `reporting.output_local`.

When a report is explicitly requested, use:

- repo rounds: `references/report-template.md#repo-rounds`
- PR care: `references/report-template.md#pr-care`

Chat output and requested reports must include:

- scope and commands/API sources used
- status summary
- ranked findings and blockers
- recommended next actions
- exact approval queue
- actions intentionally not taken
- verification performed or skipped
- residual risk

## Jules Handoff

Accept handoff payloads from `jules-wrangler` or legacy `jules-triage`:

```json
{
  "source_skill": "jules-wrangler",
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

Keep unknown fields with value `unknown`. Include the payload in the report and
use category/risk notes to focus review.

## References

| File | When to Read |
| --- | --- |
| `references/config-schema.md` | Parsing or generating config. |
| `references/github-api.md` | GitHub connector, `gh`, REST, or GraphQL field patterns. |
| `references/review-tools.md` | Interpreting review bots and CI/review automation. |
| `references/report-template.md` | Writing repo-rounds or pr-care reports. |
| `references/cost-optimization.md` | Planning org-wide scans or reviewer/CI invocations. |
| `references/compliance-checks.md` | Flagging policy, security, legal-domain, or governance risks. |
| `references/learning-system.md` | Recording repeated stale work, CI failures, or finding outcomes. |
