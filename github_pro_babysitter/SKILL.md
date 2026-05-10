---
name: github_pro_babysitter
description: >
  Legacy compatibility wrapper for GitHub repository health monitoring. Prefer
  the merged github-babysitter skill, mode repo-rounds, for new work. This
  legacy skill audits repos, pull requests, issues, Actions runs, stale work,
  and automation drift when an old prompt or config explicitly names
  github_pro_babysitter.
---

# GitHub Pro Babysitter

Compatibility note: for new work, use `github-babysitter` with `repo-rounds`
mode. Keep this skill available only for old prompts, existing
`.github-pro-babysitter.yml` configs, or migration checks.

Monitors GitHub repositories and turns scattered repo signals into a concise
action queue.

## What This Skill Does

1. **Discover** - list target repos under `darksheer/` unless the user names a repo
2. **Inspect** - collect open PRs, open issues, recent workflow runs, and repo metadata
3. **Classify** - identify stale work, failing automation, blocked PRs, and noisy bots
4. **Prioritize** - rank items by age, risk, recency, and user impact
5. **Recommend** - propose concrete next actions without making external changes by default
6. **Report** - produce a local digest or optional GitHub/Slack notification
7. **Learn** - record repeated failures and recurring stale patterns

This skill is monitoring-first. It should not merge, close, comment, rerun,
cancel, or edit anything unless the user explicitly asks for that action.

---

## Quick Start

```bash
"Check health for darksheer/ARC"
"Babysit my GitHub repos"
"Find stale PRs and failing workflows in darksheer"
"Give me a daily GitHub health digest"
```

---

## Configuration

The skill reads `.github-pro-babysitter.yml` from the workspace or target repo.
If absent, use the defaults in `references/config-schema.md`.

Important defaults:

```yaml
organization: darksheer
repositories: []        # empty = all visible repos in the org
lookback_days: 14
stale_after_days: 7
include_private: true
write_actions: false    # report only unless user opts in
```

Read `references/config-schema.md` before parsing or generating config.

---

## GitHub Access

Use the safest available read path:

1. GitHub MCP connector, if available
2. GitHub CLI (`gh`) when authenticated
3. REST API with `GITHUB_TOKEN`

Read `references/github-api.md` for command patterns and response fields.

---

## Phase 1: Target Selection

If the user names a repo, inspect only that repo. Otherwise:

1. List repos under the configured organization.
2. Exclude archived repos unless `include_archived: true`.
3. Respect `repositories` allowlist and `exclude_repositories`.
4. Prefer recently pushed repos first when limiting the scan.

For each repo, collect:
- visibility, archived status, default branch, pushedAt, updatedAt
- open PR count and issue count
- latest workflow runs in the lookback window
- branch protection and required status context data when available

---

## Phase 2: Pull Request Health

For each open PR, collect:
- number, title, author, draft state, createdAt, updatedAt
- mergeability, review decision, changed files
- status check rollup
- recent review and issue comments

Classify PRs:

| Signal | Classification | Default Action |
|--------|----------------|----------------|
| Draft PR with green checks | watch | note only |
| Non-draft PR with failing checks | blocked | inspect failing checks |
| Non-draft PR stale beyond threshold | stale | recommend owner ping or close/rebase |
| Bot dependency PR with failing checks | dependency-blocked | inspect lockfile, engine, and audit risk |
| Mergeable PR with approvals and green checks | ready | recommend merge review |
| Multiple PRs touching same files | conflict-risk | flag coordination need |

Do not trigger reviewers or post comments in monitoring mode. If review
orchestration is needed, use `github-babysitter` `pr-care` with the PR URL and why.

---

## Phase 3: Issue Health

For each open issue, collect:
- number, title, author, labels, createdAt, updatedAt
- whether it is bot-authored
- whether labels indicate priority, stale, parity, security, or incident

Classify issues:
- **stale**: no update beyond `stale_after_days`
- **automation-noise**: repeated bot issues with same title/labels
- **priority**: labels such as `priority:high`, `security`, `incident`
- **linked-work**: issue appears referenced by an open PR

Recommend actions, but do not close or label issues unless explicitly asked.

---

## Phase 4: Workflow Health

Fetch recent GitHub Actions runs for each repo. Group by workflow name and
conclusion.

Flag:
- failure streaks on the default branch
- scheduled jobs failing repeatedly
- dependency-update runs failing repeatedly
- required checks missing or skipped on open PRs
- long-running queued/in-progress workflows

When a run failed, inspect summary/job names first. Fetch full logs only when
needed for root-cause evidence, since logs can be large.

---

## Phase 5: Scoring

Assign a repo health score from 0 to 100:

| Factor | Weight |
|--------|--------|
| Default branch workflow health | 30 |
| Open PR health | 25 |
| Issue staleness and priority | 15 |
| Dependency/security signal | 15 |
| Repo freshness and maintenance hygiene | 10 |
| Automation noise level | 5 |

Use `references/review-tools.md` for signal-source details and
`references/cost-optimization.md` for polling limits.

---

## Phase 6: Reporting

Write a digest with:
- scorecard by repo
- top risks
- blocked PRs
- stale or noisy issues
- failing workflows
- recommended next actions
- actions intentionally not taken

Use `references/report-template.md` for the report shape.

---

## Phase 7: Learning

Record repeated patterns locally when `learning.enabled` is true:
- recurring failing workflow names
- recurring bot issue titles
- repos that repeatedly need attention
- PR authors or automation sources associated with stale work

Read `references/learning-system.md` before writing learning data.

---

## Reference Files

| File | When to Read |
|------|-------------|
| `references/config-schema.md` | When parsing or generating config |
| `references/github-api.md` | When collecting GitHub data |
| `references/review-tools.md` | When interpreting PR/review/automation signals |
| `references/cost-optimization.md` | When planning org-wide polling |
| `references/report-template.md` | When writing digests |
| `references/compliance-checks.md` | When flagging governance/security policy signals |
| `references/learning-system.md` | When recording repeated patterns |

---

## Workflow Summary

```
Manual or scheduled trigger
    |
    +- 1. Load config and discover target repos
    +- 2. Collect repo metadata, PRs, issues, and workflow runs
    +- 3. Classify blocked, stale, risky, and noisy items
    +- 4. Score repo health
    +- 5. Recommend next actions
    +- 6. Write digest
    +- 7. Record repeated patterns
```
