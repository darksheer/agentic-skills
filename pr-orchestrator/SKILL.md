---
name: pr-orchestrator
description: >
  End-to-end GitHub PR review orchestration agent. Monitors PRs, auto-detects available
  code review tools (CodeRabbit, Codex, Jules, Gemini Code Assist, and others), invokes
  them, aggregates and triages every finding, deterministically evaluates whether each
  finding should be applied, annotates decisions inline, applies fixes autonomously (or
  with approval, per config), re-triggers reviews and tests after changes, enforces
  compliance (laws, claude.md, agents.md), learns from outcomes, and optimizes its own
  workflow for cost and speed. Works in Claude Code, Cursor, Codex CLI, and Gemini —
  GUI or CLI. Use this skill whenever the user mentions PR review, code review orchestration,
  PR monitoring, review automation, GitHub review workflow, pull request management,
  multi-reviewer coordination, or wants to automate any part of the PR review lifecycle.
  Also trigger when the user asks about CodeRabbit, Codex reviews, Jules, or Gemini
  Code Assist in the context of PRs.
---

# PR Orchestrator

A unified orchestration agent for GitHub Pull Request review, remediation, and continuous improvement.

## What This Skill Does

This skill turns a single PR event into a fully managed review lifecycle:

1. **Detect** — discover which review tools and CI pipelines are configured for the repo
2. **Invoke** — trigger all detected reviewers in parallel, cost-aware
3. **Collect** — gather findings from PR comments, review threads, and check runs
4. **Triage** — deterministically evaluate each finding for accuracy, applicability, and value
5. **Remediate** — apply fixes (per autonomy config), annotate decisions inline
6. **Re-verify** — re-trigger only the affected reviewers and tests, batched for cost
7. **Comply** — validate changes against applicable laws, `claude.md`, `agents.md`
8. **Report** — post a structured summary to the PR and output it locally
9. **Learn** — record finding outcomes to improve future triage accuracy
10. **Optimize** — continuously refine the workflow for speed, cost, and accuracy

---

## Quick Start

```bash
# Minimal — orchestrate reviews for a specific PR
"Review PR #42 on owner/repo"

# Monitor mode — watch for new PRs and review them as they arrive
"Monitor PRs on owner/repo and review them end-to-end"

# With config — use repo-specific settings
"Review PR #42 using the .pr-orchestrator.yml config"
```

---

## Configuration

The skill reads `.pr-orchestrator.yml` from the repo root (or a path you specify). If absent, it auto-detects everything and uses sensible defaults.

Read `references/config-schema.md` for the full schema. Key sections:

```yaml
# .pr-orchestrator.yml
autonomy: full          # full | approve-high-risk | approve-all
review_tools: auto      # auto | list of tool names
cost_budget:
  max_actions_minutes_per_pr: 30
  batch_strategy: smart  # smart | parallel | sequential
compliance:
  check_claude_md: true
  check_agents_md: true
  legal_domains: []      # e.g., [GDPR, HIPAA, SOC2]
learning:
  enabled: true
  store: local           # local | repo | sqlite
```

When `review_tools` is `auto`, the skill inspects the repo for:
- GitHub App installations (CodeRabbit, Gemini Code Assist, Graphite)
- GitHub Actions workflows referencing review tools (Codex Action, Jules Action, PR-Agent)
- Config files (`.coderabbit.yaml`, `.codex/`, etc.)
- MCP connectors available in the current session

---

## Phase 1: Detection & Invocation

### Detecting Available Tools

Before invoking anything, inventory what's available. Read `references/review-tools.md` for the full detection and invocation guide for each tool. The summary:

| Tool | Detection Signal | Invocation Method |
|------|-----------------|-------------------|
| CodeRabbit | `.coderabbit.yaml` or GitHub App installed | Auto-reviews on PR open; CLI for on-demand; `@coderabbitai` comments |
| Codex | `.github/workflows/*codex*` or App installed | `@codex review` comment or Action trigger |
| Jules | `.github/workflows/*jules*` or API key configured | Jules Action dispatch or API call |
| Gemini Code Assist | GitHub App installed | Auto-reviews; `/gemini review` comment |
| Qodo PR-Agent | `.github/workflows/*pr-agent*` | Action dispatch or Docker run |
| Graphite Agent | GitHub App installed | Auto-reviews within Graphite |
| Reviewdog | `.reviewdog.yml` | Linter orchestration via Action |

For tools that auto-review on PR open (CodeRabbit, Gemini), don't re-invoke — just wait for and collect their output. For tools that need explicit triggering, invoke them.

### GitHub Interaction Layer

The skill uses an adaptive GitHub interaction strategy:

1. **Check for MCP connectors** — if a GitHub MCP (Linear, native GitHub, etc.) is available, use it for API calls. This avoids token management.
2. **Fall back to GitHub CLI (`gh`)** — if `gh` is authenticated, use it. Works in any terminal environment.
3. **Fall back to direct API** — use `curl` against `api.github.com` with a PAT from environment or config.

This three-tier approach ensures the skill works in Claude Code, Cursor, Codex CLI, Gemini, or any environment with shell access.

### Cost-Aware Invocation

Before triggering Actions-based tools, estimate the cost:
- Check `cost_budget.max_actions_minutes_per_pr`
- Prefer GitHub App-based tools (zero Actions cost) over Actions-based tools
- If budget is tight, run only the highest-value reviewers first
- Use `batch_strategy` to control parallelism vs. sequential execution

Read `references/cost-optimization.md` for detailed strategies.

---

## Phase 2: Collection & Aggregation

After all reviewers have run, collect every finding into a normalized format:

```
Finding {
  id: string               # unique across all tools
  source: string            # "coderabbit" | "codex" | "jules" | "gemini" | ...
  severity: string          # critical | high | medium | low | info
  category: string          # security | performance | correctness | style | ...
  file: string
  line_start: int
  line_end: int
  description: string
  suggested_fix: string?
  comment_url: string       # link to the original PR comment
  raw_data: object          # original payload for reference
}
```

### Collection methods by tool:
- **PR review comments**: GraphQL `pullRequest.reviews.comments` or REST `/pulls/{id}/comments`
- **Issue comments**: REST `/issues/{id}/comments` (for bot comments like CodeRabbit summaries)
- **Check runs**: REST `/check-runs` for CI-integrated tools
- **CodeRabbit CLI**: Direct JSON output when invoked locally

### Deduplication

Multiple tools often flag the same issue. Deduplicate by:
1. Exact file + line range match → merge, note which tools agreed (consensus signal)
2. Same file, overlapping lines, similar category → flag as potential duplicate, review together
3. Cross-tool consensus: when 2+ tools flag the same issue, boost confidence. This is the "consensus scoring" pattern — findings with multi-tool agreement are almost certainly real.

---

## Phase 3: Triage & Evaluation

This is the core decision-making phase. For each finding, perform a deterministic evaluation:

### Evaluation Framework

For every finding, answer these questions in order:

1. **Is it accurate?** Does the finding correctly identify an actual issue in the code?
   - Read the relevant code in full context (not just the diff)
   - Check if the finding misunderstands the code's intent
   - Verify against the language/framework's actual behavior
   - If uncertain, run the code or write a test to confirm

2. **Is it applicable?** Even if technically correct, does it matter for this codebase?
   - Check existing patterns — if the codebase consistently does X, a finding saying "do Y" may not apply
   - Check project conventions in `claude.md`, `agents.md`, `.editorconfig`, linter configs
   - Consider the PR's intent — a draft/WIP PR has different standards than a release PR

3. **Should it be implemented?** Cost-benefit analysis:
   - Risk of the current code vs. risk of the change
   - Scope of the fix — does it touch only changed files or require broader refactoring?
   - Alignment with PR scope — does fixing this belong in this PR or a follow-up?
   - Compliance requirements — if it's a legal/security issue, it must be fixed regardless

4. **Need more analysis?** If any of the above is uncertain:
   - Read related files and tests
   - Check git blame for why the code is written this way
   - Search for related issues or discussions
   - Run the test suite to see if the finding reveals a real failure
   - Only then make the call

### Annotating Decisions

After evaluating, post a reply on the finding's comment thread with a structured annotation:

```markdown
**PR Orchestrator Assessment**

| Attribute | Value |
|-----------|-------|
| Accurate | Yes / No / Partially |
| Applicable | Yes / No / Context-dependent |
| Decision | **Apply** / **Skip** / **Defer to follow-up** |
| Confidence | High / Medium / Low |
| Consensus | 2/3 tools agree (if applicable) |

**Reasoning:** [1-3 sentences explaining the decision]

**Action taken:** [Fix applied in commit abc123 / No action — see reasoning / Deferred to issue #XX]
```

---

## Phase 4: Remediation

Based on the autonomy configuration:

### `full` (default)
Apply all fixes the skill deems correct. For each fix:
1. Make the code change
2. Verify the change compiles/passes local checks
3. Commit with a descriptive message referencing the finding
4. Batch commits logically (don't commit one line at a time)

### `approve-high-risk`
Auto-fix findings categorized as `style`, `info`, or `low` severity. For `medium`, `high`, `critical`:
- Prepare the fix but don't commit
- Post the proposed fix as a PR comment and ask for approval
- Wait for approval before applying

### `approve-all`
Annotate all findings with assessments but make no code changes. Present a summary of recommended fixes and wait for human direction.

### Fix Quality Checks
Before committing any fix:
- Ensure it doesn't break existing tests (run relevant test files)
- Ensure it follows the project's code style (run the project's linter if configured)
- Ensure it doesn't conflict with other pending fixes
- Ensure it doesn't violate compliance constraints (Phase 6)

---

## Phase 5: Re-verification

After applying fixes, re-trigger only what's needed:

### Scoped Re-review
Don't re-run every reviewer on the whole PR. Instead:
1. Identify which files were changed by fixes
2. For each reviewer, determine if it supports incremental review:
   - CodeRabbit: auto-reviews new commits incrementally
   - Codex: re-invoke with `@codex review` on the new commits
   - Others: may need full re-review
3. Only re-trigger reviewers whose findings led to changes

### Scoped Re-testing
1. Identify which test files cover the changed code (use test file naming conventions, imports, and coverage data if available)
2. Run only affected tests first for fast feedback
3. If affected tests pass, run the full suite once at the end
4. Batch GitHub Actions runs — push all fix commits together rather than one at a time, so CI runs once

### Self-Review Loop Guard
The orchestrator must avoid chasing its own tail. When triaging findings after a fix cycle:
- Track which lines were modified by the orchestrator in this cycle (commit SHAs, file:line pairs)
- If a new finding targets a line the orchestrator just changed in this cycle, flag it as "self-induced" and evaluate with extra scrutiny — it may be the reviewer reacting to a legitimate fix
- If the same finding recurs across 2+ cycles on orchestrator-modified lines, auto-skip it (the reviewer and the orchestrator disagree — log it for human review)
- Always filter out findings authored by the orchestrator's own commits to prevent infinite loops

### Test Failure Root Cause Attribution
When tests fail after fixes:
1. Read the workflow run logs (not just pass/fail status)
2. Attribute the failure: was it pre-existing (failed before fixes), caused by an orchestrator fix, or a flaky test?
3. If caused by an orchestrator fix: revert that specific fix, annotate the finding as "fix caused test failure — reverted," and skip it
4. If pre-existing: note it in the report but don't block the review cycle
5. If flaky: re-run once; if it passes, continue; if it fails again, flag for human review

### Loop Termination
The re-verify loop exits when:
- No new findings are introduced by the fixes, OR
- New findings have been evaluated and none require action, OR
- A maximum iteration count is reached (default: 3 cycles, configurable)
- Cost budget is exhausted

---

## Phase 6: Compliance

Before finalizing, validate all changes against compliance requirements:

### Mandatory Checks
- **`claude.md`**: If present in the repo, read it and verify changes don't violate any stated conventions, architectural decisions, or constraints
- **`agents.md`**: If present, verify the PR's behavior aligns with agent guidelines
- **Code of conduct / contributing guidelines**: Ensure changes follow stated contribution norms

### Configurable Legal Checks
If `compliance.legal_domains` is set, flag any changes that touch areas relevant to those domains:
- **GDPR**: Data handling, PII exposure, consent mechanisms
- **HIPAA**: Health data, access controls, audit logging
- **SOC2**: Security controls, change management
- **Licensing**: Dependency license compatibility

These are flags for human review, not legal advice. The report clearly states this.

---

## Phase 7: Reporting

Post a comprehensive summary as a PR comment and output it locally.

Read `references/report-template.md` for the full template. The report includes:

1. **Executive Summary** — what happened, how many findings, how many fixed
2. **Review Tool Status** — which tools ran, their status, any failures
3. **Findings Table** — every finding with: source, severity, decision, reasoning
4. **Changes Made** — commits pushed, files modified, what each fix addressed
5. **Compliance Status** — any compliance flags raised
6. **Test Results** — CI/test outcomes after fixes
7. **Items Not Addressed** — findings skipped, with clear reasoning for each
8. **Cost Summary** — Actions minutes used, API calls made, estimated cost
9. **Learning Notes** — patterns observed, accuracy of each tool, optimization suggestions

---

## Phase 8: Learning & Optimization

### Learning System

After each PR review cycle, record outcomes. Read `references/learning-system.md` for details.

Key metrics tracked per finding:
- Was the finding accepted or rejected?
- If accepted, did the fix introduce new issues?
- Was the finding a duplicate caught by multiple tools?
- How long did triage take?
- Was human override needed?

Over time, this builds a profile for each review tool:
- **Precision**: what % of its findings are actually valid?
- **Recall signal**: do other tools catch things it misses?
- **Category strength**: which categories is each tool best at?
- **False positive patterns**: recurring bad suggestions to auto-skip

### Self-Optimization

The skill periodically reviews its own performance data and suggests (or auto-applies) workflow improvements:

- **Tool ordering**: Run the highest-precision tool first, use its findings to pre-filter others
- **Category routing**: If Tool A is great at security but weak on style, and Tool B is the opposite, weight accordingly
- **Cost reduction**: If a tool consistently adds no value beyond what others catch, suggest disabling it
- **Batch sizing**: Adjust how many commits to batch before re-triggering CI based on historical pass rates
- **Loop depth**: If re-review cycles rarely find new issues after cycle 1, reduce max iterations

---

## Cross-Platform Compatibility

This skill works across environments by adapting its tooling:

| Environment | GitHub Access | Shell | Review Tool Invocation |
|------------|--------------|-------|----------------------|
| Claude Code | MCP or `gh` CLI | Full bash | CLI + API + comments |
| Cursor | Extension API or `gh` | Integrated terminal | CLI + comments |
| Codex CLI | `gh` CLI or API | Full bash | CLI + API + comments |
| Gemini | API or `gh` | Cloud VM | API + comments |

### Environment Auto-Detection
The skill detects its environment at startup:
1. Check for `CURSOR_SESSION` or Cursor-specific env vars → Cursor
2. Check for `CODEX_CLI` env var or running inside `codex exec` → Codex CLI
3. Check for available MCP tools matching `github_*` patterns → Claude Code
4. Check for Google Cloud VM signals or Gemini-specific context → Gemini
5. Default: assume CLI with `gh` available

The detection affects only the I/O layer (which GitHub access tier to try first, how to present output). Core logic is identical everywhere.

---

## Monitoring Lifecycle

### Single PR Mode (default)
The skill is invoked for a specific PR and runs the full lifecycle once. This is the typical usage pattern.

### Monitor Mode
When the user says "monitor PRs," the skill enters a polling loop:
1. Poll for new/updated PRs on the target repo (via `gh pr list` or API)
2. For each PR that hasn't been reviewed yet (tracked by a label or comment marker), run the full lifecycle
3. For PRs the orchestrator has already reviewed, check for new commits pushed by the PR author (not by the orchestrator itself — filter by committer)
4. If new author commits are found, re-run the lifecycle from Phase 1
5. Continue until the PR is merged, closed, or the user cancels

### PR State Transitions
The orchestrator tracks PR state throughout:
- **Open + new commits**: re-trigger review cycle
- **Review requested**: prioritize this PR
- **Changes requested by human reviewer**: pause orchestrator, human is driving
- **Approved**: skip further review unless new commits arrive
- **Merged / Closed**: finalize learning data, stop monitoring

### Commit Author Filtering
Critical for avoiding self-review loops in monitor mode:
- Tag orchestrator commits with a trailer: `Signed-off-by: pr-orchestrator`
- When checking for new commits, filter out commits with this trailer
- Only re-trigger reviews when the PR author (or other humans) push new commits

---

## Reference Files

Read these as needed — don't load them all upfront:

| File | When to Read |
|------|-------------|
| `references/review-tools.md` | When detecting or invoking a specific review tool |
| `references/config-schema.md` | When parsing or generating a `.pr-orchestrator.yml` |
| `references/cost-optimization.md` | When planning invocation strategy or analyzing costs |
| `references/learning-system.md` | When recording outcomes or querying historical data |
| `references/report-template.md` | When generating the final PR summary |
| `references/compliance-checks.md` | When running legal/policy compliance validation |
| `references/github-api.md` | When making GitHub API calls (adaptive layer details) |

---

## Workflow Summary

```
PR Event (open/update/comment)
    │
    ├─ 1. Detect available review tools and CI pipelines
    ├─ 2. Invoke reviewers (cost-aware, parallel where possible)
    ├─ 3. Collect and normalize all findings
    ├─ 4. Deduplicate, apply consensus scoring
    │
    ├─ For each finding:
    │   ├─ Evaluate: accurate? applicable? implement?
    │   ├─ Annotate decision on the finding's comment thread
    │   └─ Apply fix if warranted (per autonomy config)
    │
    ├─ 5. Re-trigger scoped reviews and tests
    ├─ 6. Loop until clean or max iterations reached
    ├─ 7. Run compliance checks
    ├─ 8. Generate and post final report
    └─ 9. Record learning data, suggest optimizations
```
