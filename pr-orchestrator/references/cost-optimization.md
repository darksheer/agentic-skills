# Cost Optimization Reference

GitHub Actions minutes and API calls cost real money. This reference covers strategies to minimize costs while maximizing review quality.

## Cost Model

### GitHub Actions Pricing (as of Jan 2026)
- Linux runners: ~$0.008/minute (reduced from ~$0.013 after Jan 2026 price cut)
- Larger runners: proportionally more per minute but faster — often cheaper total
- Public repos: free runners
- Self-hosted runners: $0.002/minute platform fee (since March 2026)

### Zero-Cost Review Tools
These run on their own infrastructure (GitHub Apps), not GitHub Actions:
- **CodeRabbit** — GitHub App, auto-reviews for free (within plan limits)
- **Gemini Code Assist** — GitHub App, free tier available
- **Graphite Agent** — GitHub App

### Actions-Based Review Tools
These consume GitHub Actions minutes:
- **Codex Action** (`openai/codex-action@v1`) — runs Codex CLI in CI
- **Jules Action** (`google-labs-code/jules-action`) — runs Jules in CI
- **PR-Agent** — runs as a GitHub Action
- **Reviewdog** — runs linters as GitHub Actions

### API Costs
- **OpenAI API** (for Codex): varies by model, typically $0.01-0.10 per review
- **Jules API**: varies by task complexity
- **GitHub API**: free within rate limits (5000 req/hour authenticated)

## Optimization Strategies

### Strategy 1: Prefer Apps Over Actions
When `batch_strategy: smart` (default), the skill orders invocations:
1. First: GitHub App-based tools (free) — CodeRabbit, Gemini, Graphite
2. Then: Evaluate if Actions-based tools are needed based on what Apps already found
3. Last: Only invoke expensive tools if the Apps missed coverage areas

This means a simple PR might be fully reviewed at zero Actions cost.

### Strategy 2: Batch Commits
Instead of pushing each fix individually (triggering CI each time):
1. Apply all fixes locally
2. Run local checks (lint, type-check, unit tests if fast)
3. Push all fixes in a single commit or squashed batch
4. CI runs once instead of N times

With `cost_budget.batch_commits: true`, the skill always batches. This alone can reduce CI costs by 50-80% for PRs with multiple findings.

### Strategy 3: Scoped Re-testing
After fixes, don't re-run the entire CI pipeline:
1. Identify which test files cover the changed code
2. If the CI supports path-based triggers, only affected workflows run
3. If not, use `workflow_dispatch` to trigger only specific jobs

```yaml
# Example: path-based CI trigger
on:
  push:
    paths:
      - 'src/api/**'      # Only run API tests when API code changes
      - 'tests/api/**'
```

### Strategy 4: Conditional Review Depth
Not every PR needs every reviewer:
- **Draft PRs**: Skip entirely (configurable via `filters.skip_drafts`)
- **Small PRs (<10 lines)**: Run only linters and one AI reviewer
- **Documentation-only PRs**: Skip AI review, run only link/spelling checks
- **Dependency updates**: Run security-focused review only

```yaml
# In .pr-orchestrator.yml
filters:
  skip_drafts: true
  min_changed_lines: 1
```

### Strategy 5: Tool Category Routing
Based on learning data, route reviews to the best tool per category:
- Security findings: route to Codex (if it has highest precision for security)
- Style findings: route to CodeRabbit (if it's best for style)
- Skip tools that are weak in the PR's primary area

This avoids paying for redundant reviews that don't add unique findings.

### Strategy 6: Incremental Over Full Reviews
For re-reviews after fixes:
- CodeRabbit: auto-incremental (free)
- Codex: post `@codex review` (reviews only new commits)
- Jules: re-invoke with changed-files-only scope
- Gemini: auto-incremental

Never request a full re-review when an incremental one is available.

### Strategy 7: Cache and Skip
- If a finding was auto-skipped by the learning system, don't spend time triaging it
- If the same file hasn't changed since last review cycle, skip re-reviewing it
- Cache GitHub API responses within a single review cycle (PR data doesn't change mid-review)

## Cost Tracking

The skill tracks costs per PR cycle:

```json
{
  "actions_minutes": {
    "ci_runs": 12.5,
    "reviewer_actions": 3.2,
    "total": 15.7
  },
  "api_calls": {
    "github": 42,
    "openai": 3,
    "jules": 1,
    "total": 46
  },
  "estimated_cost_usd": {
    "actions": 0.126,
    "api": 0.045,
    "total": 0.171
  }
}
```

Include this in the final PR report so the team can see the cost of each review cycle.

## Budget Enforcement

When `max_actions_minutes_per_pr` is set:
1. Track cumulative Actions minutes throughout the review cycle
2. Before triggering each new Action, estimate its cost (based on historical data)
3. If the estimate would exceed the budget:
   - If `batch_strategy: smart`: skip the Action, note in report
   - If `batch_strategy: sequential`: stop reviewing, note in report
   - If `batch_strategy: parallel`: cannot enforce (all triggered at once) — use smart instead

The report always flags when budget constraints caused tools to be skipped.
