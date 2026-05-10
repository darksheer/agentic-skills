# Configuration Schema

Full schema for `.jules-triage.yml`.

---

## Complete Example

```yaml
# .jules-triage.yml — Jules Triage Configuration
# Place in repo root or workspace root

# Autonomy mode — controls how much the skill does without asking
# full: auto-promote all qualifying sessions
# approve-high-risk: auto-promote low-risk, ask for high-risk
# approve-all: never auto-promote, always show digest and wait
autonomy: approve-high-risk

# Cron schedule for automated triage runs
# Uses standard cron syntax (minute hour day month weekday)
schedule: "0 9 * * 1-5"   # 9am weekdays

# Repositories to monitor (org/repo format matching sourceContext.source)
# Empty list = monitor all repos connected to your Jules account
# All repos are under the darksheer org
repositories:
  - darksheer/ARC
  - darksheer/Acheron
  - darksheer/arc-powerup
  - darksheer/ft3
  - darksheer/synapse

# Promotion criteria — thresholds for deciding what gets promoted
promotion_criteria:
  # Minimum triage confidence score (0.0–1.0) to auto-promote
  min_confidence: 0.7

  # Only promote sessions where Jules' tests passed
  require_tests_pass: true

  # Skip sessions that changed too many files (flag for manual review)
  max_files_changed: 50

  # Minimum files changed (skip trivial single-line changes)
  min_files_changed: 1

  # Session categories eligible for promotion
  categories:
    - bug_fix
    - code_review
    - performance
    - security
    - refactor
    - documentation
    - test_coverage
    - ux_accessibility
    - code_cleanup

  # Categories that always require human approval regardless of score
  high_risk_categories:
    - security
    - architecture
    - dependency_update

# Agent-based filtering
# You run named recurring agents (Palette, Bolt, etc.) as scheduled Jules sessions.
# Configure per-agent behavior here.
agents:
  palette:
    # Match sessions whose title starts with "Palette"
    title_pattern: "^Palette"
    auto_promote: true          # Palette changes are low-risk UX tweaks
    max_files_changed: 10       # Override global limit for this agent
    require_tests_pass: true
  bolt:
    title_pattern: "^Bolt"
    auto_promote: true          # Bolt perf optimizations are generally safe
    max_files_changed: 20
    require_tests_pass: true
  # One-off Jules sessions (code reviews, fixes, etc.) use the global settings
  # They're identified by NOT matching any agent title pattern

# Interactive response settings (for AWAITING_USER_FEEDBACK sessions)
interactive:
  # Enable auto-responding to Jules' questions
  enabled: true

  # Auto-respond to simple confirmations ("are you satisfied?", "should I finalize?")
  auto_confirm_simple: true

  # Auto-answer substantive questions using codebase analysis
  # Only applies in 'full' autonomy mode
  auto_answer_substantive: true

  # Safety: never auto-answer questions in these categories
  never_auto_answer:
    - security_removal     # Questions about removing security controls
    - new_dependencies     # Questions about adding dependencies
    - breaking_changes     # Questions that imply public API changes

  # Max questions to auto-answer per triage run
  max_auto_answers_per_run: 5

  # Include draft answers in digest even when auto-sending (for visibility)
  log_answers_to_digest: true

  # Branch targeting — only promote sessions targeting these branches
  target_branches:
    - main
    - develop

# GitHub Babysitter integration
github_babysitter:
  # Enable/disable automatic handoff to github-babysitter pr-care
  enabled: true

  # Path to github-babysitter config (relative to repo root)
  config_path: .github-babysitter.yml

  # Autonomy mode override for Jules-promoted PRs
  # Useful if you want stricter PR care for auto-promoted PRs
  autonomy_override: ""   # empty = use github-babysitter's own config

# Notification settings
notifications:
  # Slack channel for digest notifications (requires Slack MCP)
  slack_channel: ""

  # Digest format
  # summary: one-paragraph overview + counts
  # detailed: full table with all sessions
  # minimal: just counts and action items
  digest_format: detailed

  # Post digest as GitHub issue on a tracking repo
  github_issue_repo: ""   # e.g., "owner/ops-tracking"

  # Label for tracking issues
  github_issue_label: "jules-triage"

# Session tracking — how to remember what's been triaged
tracking:
  # Where to store triage state
  # local: file in workspace (.jules-triage-state.json)
  # github: as issue comments on tracking repo
  store: local

  # How long to keep records of triaged sessions (days)
  retention_days: 90

# Learning system
learning:
  enabled: true

  # Track which promoted sessions ultimately get merged
  track_merge_outcomes: true

  # Auto-adjust min_confidence based on merge rates
  auto_tune: false

  # Minimum sessions before auto-tuning kicks in
  auto_tune_min_samples: 20

# Advanced settings
advanced:
  # Maximum sessions to process per triage run
  max_sessions_per_run: 50

  # Delay between API calls (ms) to respect rate limits
  api_delay_ms: 1000

  # Maximum re-check attempts for ACTIVE sessions
  active_session_patience: 3

  # Skip sessions older than N days
  max_session_age_days: 7
```

---

## Field Reference

### `autonomy`
- **Type**: enum
- **Values**: `full`, `approve-high-risk`, `approve-all`
- **Default**: `approve-high-risk`

Controls how aggressively the skill promotes sessions to PRs without human intervention.

### `schedule`
- **Type**: cron expression (string)
- **Default**: `"0 9 * * *"` (daily at 9am)

Standard 5-field cron. Use with the `/schedule` skill to activate.

### `repositories`
- **Type**: list of strings (`owner/repo` format)
- **Default**: `[]` (all repos)

When empty, the skill considers all sessions regardless of which repo they target. When populated, only sessions matching listed repos are triaged.

### `promotion_criteria`

#### `min_confidence`
- **Type**: float (0.0–1.0)
- **Default**: `0.7`

Sessions scoring below this are never auto-promoted (but may appear in the digest for manual review if above 0.3).

#### `require_tests_pass`
- **Type**: boolean
- **Default**: `true`

If true, only sessions where Jules successfully ran and passed tests are eligible for auto-promotion.

#### `max_files_changed`
- **Type**: integer
- **Default**: `50`

Sessions exceeding this threshold are flagged for manual review regardless of score.

#### `categories`
- **Type**: list of strings
- **Default**: all categories

Maps to the intent detected from the session prompt. Sessions whose detected category isn't in this list are skipped.

#### `high_risk_categories`
- **Type**: list of strings
- **Default**: `[security, architecture, dependency_update]`

These categories always require human approval in `approve-high-risk` mode, regardless of confidence score.

### `github_babysitter`

#### `enabled`
- **Type**: boolean
- **Default**: `true`

When false, PRs are created but not automatically handed to github-babysitter pr-care. Useful if you want to use a different review workflow for Jules-originated PRs.

### `tracking.store`
- **Type**: enum
- **Values**: `local`, `github`
- **Default**: `local`

`local` stores state in `.jules-triage-state.json` in the workspace. `github` posts tracking comments on a designated issue/repo for team visibility.

---

## Environment Variables

These override config file values:

| Variable | Overrides | Description |
|----------|-----------|-------------|
| `JULES_API_KEY` | (auth) | Jules API key |
| `JULES_TRIAGE_AUTONOMY` | `autonomy` | Autonomy mode |
| `JULES_TRIAGE_REPOS` | `repositories` | Comma-separated repo list |
| `JULES_TRIAGE_MIN_CONFIDENCE` | `promotion_criteria.min_confidence` | Score threshold |
