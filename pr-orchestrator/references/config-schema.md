# Configuration Schema Reference

The `.pr-orchestrator.yml` file controls how the skill operates for a specific repository. All fields are optional — the skill auto-detects sensible defaults for everything.

## Full Schema

```yaml
# ============================================================
# PR Orchestrator Configuration
# Place at repo root as .pr-orchestrator.yml
# ============================================================

# --- Autonomy Level ---
# Controls whether fixes are applied automatically.
#   full           - Apply all fixes deemed correct (default)
#   approve-high-risk - Auto-fix low/medium; require approval for high/critical
#   approve-all    - Annotate only; never commit without human approval
autonomy: full

# --- Review Tools ---
# Which code review tools to use.
#   auto           - Detect all available tools (default)
#   [list]         - Explicit list of tools to use
# Recognized tool names: coderabbit, codex, jules, gemini, pr-agent, graphite, reviewdog
review_tools: auto

# Per-tool overrides (optional)
tool_config:
  coderabbit:
    enabled: true
    priority: 1           # Lower = runs first (for cost-aware ordering)
    trust_level: high      # high | medium | low — affects triage weighting
    categories: []         # Empty = all categories; or list like [security, performance]
  codex:
    enabled: true
    priority: 2
    trust_level: high
    focus: []              # e.g., [security, correctness]
  jules:
    enabled: true
    priority: 3
    trust_level: medium
  gemini:
    enabled: true
    priority: 2
    trust_level: medium
  pr-agent:
    enabled: false         # Disabled by default since it overlaps with others
    priority: 4
    trust_level: medium
  graphite:
    enabled: true
    priority: 1
    trust_level: medium
  reviewdog:
    enabled: true          # Linter orchestration, complementary to AI review
    priority: 0            # Run linters first — they're fast and free

# --- Cost Budget ---
cost_budget:
  # Maximum GitHub Actions minutes to consume per PR review cycle
  max_actions_minutes_per_pr: 30
  
  # How to schedule review tool invocations
  #   smart      - Prioritize free tools (Apps), batch Actions, respect budget (default)
  #   parallel   - Run everything at once, regardless of cost
  #   sequential - Run one at a time in priority order, stop if budget exhausted
  batch_strategy: smart
  
  # Maximum number of review-fix-retest cycles before stopping
  max_iterations: 3
  
  # Group fix commits to reduce CI runs (true = push all fixes at once)
  batch_commits: true

# --- Compliance ---
compliance:
  # Check changes against claude.md conventions
  check_claude_md: true
  
  # Check changes against agents.md guidelines
  check_agents_md: true
  
  # Legal/regulatory domains to flag (not legal advice — just awareness flags)
  # Options: GDPR, HIPAA, SOC2, PCI-DSS, CCPA, licensing
  legal_domains: []
  
  # Additional compliance files to check (e.g., CONTRIBUTING.md, SECURITY.md)
  additional_policy_files: []

# --- Learning ---
learning:
  # Enable the learning system to track finding outcomes
  enabled: true
  
  # Where to store learning data
  #   local   - JSON files in .pr-orchestrator/learning/ (default)
  #   repo    - Dedicated branch or directory in the repo
  #   sqlite  - SQLite database at the specified path
  store: local
  
  # Path for local/sqlite storage (relative to repo root)
  store_path: .pr-orchestrator/learning
  
  # Minimum number of data points before using learned patterns for auto-skip
  min_samples_for_auto_skip: 10
  
  # False positive threshold — if a tool's precision for a category drops below
  # this percentage, auto-skip its findings in that category (with annotation)
  auto_skip_threshold: 0.3

# --- Reporting ---
reporting:
  # Post the final report as a PR comment
  post_to_pr: true
  
  # Also output the report to a local file
  output_local: true
  local_path: .pr-orchestrator/reports/
  
  # Report verbosity
  #   full     - Every finding, every decision, cost breakdown (default)
  #   summary  - Executive summary + findings table only
  #   minimal  - Just the decision counts and status
  verbosity: full
  
  # Include cost analysis in report
  include_cost_analysis: true
  
  # Include learning insights in report
  include_learning_insights: true

# --- Filtering ---
filters:
  # File patterns to exclude from review (glob syntax)
  exclude_paths:
    - "**/*.lock"
    - "**/node_modules/**"
    - "**/*.generated.*"
    - "**/vendor/**"
  
  # Only review these paths (if set, overrides exclude_paths)
  include_paths: []
  
  # Minimum severity to report (findings below this are collected but not shown)
  min_severity: info    # critical | high | medium | low | info
  
  # Skip review on draft PRs
  skip_drafts: true
  
  # Skip review if PR has fewer than N changed lines
  min_changed_lines: 1

# --- GitHub Interaction ---
github:
  # Preferred interaction method
  #   auto  - Try MCP → gh CLI → REST API (default)
  #   mcp   - Use MCP connector only
  #   cli   - Use gh CLI only
  #   api   - Use REST API only
  method: auto
  
  # For API method: token source
  # Reads from GITHUB_TOKEN env var by default
  token_env_var: GITHUB_TOKEN

# --- Notifications ---
notifications:
  # Mention specific users/teams when approval is needed
  approval_reviewers: []   # e.g., ["@username", "@org/team"]
  
  # Post a summary comment even when no findings are found
  report_on_clean: false
```

## Minimal Configuration Examples

### "Just work" (auto-detect everything):
```yaml
# No config file needed — all defaults are sensible
```

### Security-focused with approval gates:
```yaml
autonomy: approve-high-risk
compliance:
  legal_domains: [SOC2, GDPR]
tool_config:
  codex:
    focus: [security]
  jules:
    enabled: true
```

### Cost-conscious team:
```yaml
cost_budget:
  max_actions_minutes_per_pr: 10
  batch_strategy: smart
  batch_commits: true
review_tools: [coderabbit, gemini]  # Both are GitHub Apps = zero Actions cost
```

### Fully autonomous with learning:
```yaml
autonomy: full
learning:
  enabled: true
  store: sqlite
  store_path: .pr-orchestrator/learning.db
cost_budget:
  max_iterations: 5
```

## Environment Variables

The skill respects these environment variables:
- `GITHUB_TOKEN` — GitHub PAT for API access
- `OPENAI_API_KEY` — For Codex invocation
- `JULES_API_KEY` — For Jules API invocation
- `PR_ORCHESTRATOR_CONFIG` — Override config file path
