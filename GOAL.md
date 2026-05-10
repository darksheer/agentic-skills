# Goal: Address Recent Jules Sessions with Agent Workflow

## Objective

Use the repository skills as agents to address all current actionable Jules items and recent Jules sessions. Start with read-only triage, then move through feedback responses, plan approvals, PR promotion, PR orchestration, and repo health follow-up. Every live write action must be explicitly approved before execution.

## Agents and Responsibilities

### `jules-triage`

Primary agent for Jules session work.

Responsibilities:
- Poll Jules sessions with `JULES_API_KEY` from `.env`.
- Classify sessions by state.
- Detect agent/session type: `Palette`, `Bolt`, one-off, security, architecture, dependency, test, cleanup, documentation.
- Unblock `AWAITING_USER_FEEDBACK` sessions by drafting responses.
- Review `AWAITING_PLAN_APPROVAL` plans.
- Score `COMPLETED` sessions.
- Decide whether to promote, defer, reject, or ask for approval.
- Build structured handoff payloads for promoted sessions.
- Produce the main digest and action queue.

### `pr-orchestrator`

Secondary agent for PR lifecycle after Jules work becomes a PR.

Responsibilities:
- Review existing Jules-created PRs.
- Review PRs created from Jules `changeSet` outputs.
- Collect reviewer comments, checks, and CI status.
- Decide whether findings should be applied, skipped, or deferred.
- Prepare remediation plans.
- Manage review/merge readiness after explicit approval.

### `github_pro_babysitter`

Follow-up monitoring agent after Jules/PR actions.

Responsibilities:
- Check repos touched by recent Jules sessions.
- Identify failing workflows, stale PRs, stale issues, and repeated automation noise.
- Confirm promoted Jules work is not blocked by repo health issues.
- Produce a repo health note for any repo with active Jules work.

## Safety Policy

Default mode is read-only.

Do not perform these actions without explicit approval for each exact action:
- `POST /sessions/{id}:sendMessage`
- `POST /sessions/{id}:approvePlan`
- branch creation
- patch application to a real repo
- PR creation
- PR comments
- PR labels
- workflow reruns/cancellations
- merge/close actions
- invoking `pr-orchestrator` in a way that writes to a PR

Before any write action, present:
- target session/repo/PR
- exact endpoint or command
- message/body/branch name if applicable
- expected effect
- rollback or cleanup plan

Live write-path tests should use a disposable repo/PR whenever practical. If the target is not disposable, ask for explicit confirmation that production write access is acceptable.

## Inputs

- `.env` with `JULES_API_KEY`
- `jules-triage/SKILL.md`
- `jules-triage/references/`
- `pr-orchestrator/SKILL.md`
- `pr-orchestrator/references/`
- `github_pro_babysitter/SKILL.md`
- `github_pro_babysitter/references/`
- `tests/run_all.sh`
- `tests/fixtures/jules/`
- existing `tests/results/`

## Success Criteria

This goal is complete only when:

1. Recent Jules sessions are fetched and classified.
2. Every actionable `AWAITING_USER_FEEDBACK` session has either:
   - a drafted response ready for approval, or
   - a documented reason it cannot be answered yet.
3. Every `AWAITING_PLAN_APPROVAL` session has either:
   - an approve/reject/revise recommendation, or
   - a documented reason it needs human input.
4. Every recent `COMPLETED` session has:
   - a score,
   - output type classification,
   - promote/defer/reject recommendation,
   - and a structured handoff payload if it has or should create a PR.
5. Existing Jules-created PRs are mapped to `pr-orchestrator` handoff payloads.
6. `changeSet`-only promotion candidates have PR creation plans, not unapproved PRs.
7. Repos touched by actionable/recent Jules work have a minimal `github_pro_babysitter` health note.
8. No live write action is performed without explicit approval.
9. A report is written under `tests/results/jules-triage/`.

## Phase 1: Read Context and Validate Tooling

1. Read the three skill files and relevant references:
   - `jules-triage/SKILL.md`
   - `jules-triage/references/*.md`
   - `pr-orchestrator/SKILL.md`
   - `pr-orchestrator/references/*.md`
   - `github_pro_babysitter/SKILL.md`
   - `github_pro_babysitter/references/*.md`
2. Run local confidence checks:

```bash
./tests/run_all.sh structural
./tests/run_all.sh fixtures
```

3. If these fail, fix Jules-related tests/docs before live triage.

## Phase 2: Read-Only Jules Triage

Use `jules-triage` to:

1. Load `JULES_API_KEY` from `.env`.
2. Fetch recent Jules sessions with pagination if needed.
3. Group sessions by state:
   - `AWAITING_USER_FEEDBACK`
   - `AWAITING_PLAN_APPROVAL`
   - `COMPLETED`
   - `ACTIVE` / `IN_PROGRESS`
   - `FAILED`
4. Detect session type:
   - `Palette` -> `ux_accessibility`
   - `Bolt` -> `performance`
   - security
   - architecture
   - dependency
   - test coverage
   - cleanup
   - documentation
   - one-off/unknown
5. Write the raw read-only triage summary to:

```text
tests/results/jules-triage/recent-sessions-triage.md
```

## Phase 3: Address Waiting Sessions

Use `jules-triage` to process `AWAITING_USER_FEEDBACK` first.

For each waiting session:

1. Fetch activities.
2. Extract the latest agent question.
3. Classify it:
   - simple confirmation
   - substantive question
   - unsafe/high-risk question
   - unclear/no actionable question
4. For simple confirmations:
   - draft the exact response, usually "Looks good, please finalize and submit."
   - mark as approval required before sending.
5. For substantive questions:
   - inspect relevant repo/code context using `gh` or local checkout if available.
   - draft a response with reasoning and confidence.
   - mark as approval required before sending.
6. For unsafe/high-risk questions:
   - do not auto-answer.
   - document risk and recommended human decision.

Write drafts to:

```text
tests/results/jules-triage/feedback-response-drafts.md
```

## Phase 4: Review Plan Approvals

For each `AWAITING_PLAN_APPROVAL` session:

1. Fetch activities.
2. Extract the plan.
3. Compare the plan with the session prompt, repo, target branch, and likely risk.
4. Recommend one:
   - approve
   - reject
   - ask Jules to revise
   - needs human decision
5. Do not approve the plan until explicitly approved.

Write recommendations to:

```text
tests/results/jules-triage/plan-approval-recommendations.md
```

## Phase 5: Score Completed Sessions

For each recent `COMPLETED` session:

1. Fetch session details and activities.
2. Extract:
   - repo
   - target branch
   - title/prompt intent
   - activity signals
   - output type: `changeSet`, `pullRequest`, both, or none
   - patch file count if `changeSet`
   - PR URL if `pullRequest`
3. Score using `references/triage-scoring.md`.
4. Recommend:
   - promote
   - hand off existing PR
   - create PR after approval
   - defer for human review
   - reject
5. For every promote/handoff candidate, build the structured handoff payload from `references/promotion-workflow.md`.

Write results to:

```text
tests/results/jules-triage/completed-session-decisions.md
```

## Phase 6: PR-Orchestrator Handoff Planning

Use `pr-orchestrator` only in read-only planning mode unless write approval is granted.

For each Jules session with an existing PR:

1. Parse owner/repo/PR number from the Jules `pullRequest.url`.
2. Fetch PR metadata and check status.
3. Collect current review/check summary.
4. Build a handoff plan:
   - PR URL
   - Jules session ID
   - triage score
   - category
   - test status
   - special review guidance
5. Do not post comments or trigger reviewers unless approved.

For each `changeSet`-only promotion candidate:

1. Prepare branch name.
2. Prepare PR title/body.
3. Identify base commit and target repo/branch.
4. Document conflict checks needed.
5. Do not create branch or PR unless approved.

Write handoff plans to:

```text
tests/results/jules-triage/pr-orchestrator-handoff-plan.md
```

## Phase 7: Repo Health Follow-Up

Use `github_pro_babysitter` in read-only mode for repos touched by actionable/recent Jules sessions.

For each touched repo:

1. Fetch repo metadata.
2. List open PRs.
3. List open issues.
4. List recent workflow runs.
5. Flag blockers that could affect Jules work:
   - failing default-branch workflows
   - failing PR checks
   - stale PRs touching same areas
   - automation noise hiding real failures
6. Do not close, label, rerun, cancel, or comment.

Write notes to:

```text
tests/results/jules-triage/repo-health-followup.md
```

## Phase 8: Approval Queue

Create an explicit approval queue with one item per proposed write action.

Each item must include:
- ID
- action type
- target session/repo/PR
- exact command or endpoint
- exact message/body/branch/PR title if applicable
- reason
- risk level
- rollback/cleanup plan

Write to:

```text
tests/results/jules-triage/approval-queue.md
```

Do not execute approval queue items unless the user approves that specific item.

## Phase 9: Final Report

Write:

```text
tests/results/jules-triage/recent-jules-agent-workflow-report.md
```

Include:
- sessions scanned
- state breakdown
- waiting-session drafts
- plan approval recommendations
- completed-session decisions
- PR handoff plans
- repo health follow-up
- approval queue summary
- actions not taken due to safety policy
- next recommended user approvals

## Verification

Run:

```bash
./tests/run_all.sh structural
./tests/run_all.sh fixtures
./tests/run_all.sh
```

If live API access fails due to network/sandbox/Jules instability, document:
- command
- exit code
- key output
- which read-only reports were still generated
- whether fixture tests passed

## Constraints

- Do not modify `.env`.
- Do not alter secrets or credentials.
- Do not make unrelated code changes.
- Keep reports under `tests/results/jules-triage/`.
- Keep the workflow read-only unless explicit approval is granted.
- Preserve structured handoff payload fields.
