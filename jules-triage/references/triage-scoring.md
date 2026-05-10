# Triage Scoring System

How the jules-triage skill evaluates whether a completed Jules session should be promoted to a PR.

---

## Scoring Model

Each session receives a confidence score from 0.0 to 1.0. The score is a weighted sum of binary and continuous signals extracted from the session's activities and metadata.

### Factors and Weights

| Factor | Weight | How to Evaluate |
|--------|--------|-----------------|
| Tests pass | 0.30 | Check activities for test execution. If tests ran and passed → 1.0. If tests ran and failed → 0.0. If no tests ran → 0.5 (neutral). |
| Scope appropriate | 0.20 | Count files changed. If within `max_files_changed` → 1.0. If 80-100% of limit → 0.7. If over → 0.0. |
| Clear intent | 0.15 | Analyze the session prompt. Specific file/function references → 1.0. Vague or broad → 0.5. |
| Category match | 0.15 | Detect category from prompt/activities. If in configured `categories` list → 1.0. If not → 0.0. |
| No errors | 0.10 | Check activities for error indicators or retries. Clean execution → 1.0. Recoverable errors → 0.5. Failures → 0.0. |
| Plan approval | 0.10 | Was the plan explicitly approved? Manual approval → 1.0. Auto-approved → 0.7. No plan phase → 0.5. |

### Score Calculation

```
score = (tests_pass × 0.30) + (scope × 0.20) + (intent × 0.15) 
      + (category × 0.15) + (no_errors × 0.10) + (plan_approval × 0.10)
```

### Score Interpretation

| Score Range | Interpretation | Default Action |
|-------------|---------------|----------------|
| 0.85–1.00 | High confidence | Auto-promote in all modes except `approve-all` |
| 0.70–0.84 | Good confidence | Auto-promote in `full` mode; ask in `approve-high-risk` for high-risk categories |
| 0.50–0.69 | Moderate confidence | Include in digest, require approval |
| 0.30–0.49 | Low confidence | Include in digest with warning, recommend skip |
| 0.00–0.29 | Very low confidence | Auto-reject, log reason |

---

## Category Detection

The skill infers the session's category from its prompt and activities:

### Detection Heuristics

**Agent-based detection (primary)**: Named agents are the most reliable signal:

| Agent | Title Pattern | Category | Typical Risk |
|-------|--------------|----------|--------------|
| Palette | `^Palette` | `ux_accessibility` | Low |
| Bolt | `^Bolt` | `performance` | Low-Medium |

**One-off session detection (fallback)**: For sessions not matching a known agent, detect from title/prompt:

| Category | Signal Words/Patterns |
|----------|----------------------|
| `bug_fix` | "fix", "bug", "error", "crash", "broken", "issue #" |
| `security` | "security", "vulnerability", "CVE", "XSS", "injection", "unsafe" |
| `performance` | "optimize", "slow", "performance", "speed", "cache", "O(N)" |
| `refactor` | "refactor", "restructure", "extract", "move", "rename", "unused parameter" |
| `test_coverage` | "test", "coverage", "spec", "missing test" |
| `code_cleanup` | "console.log", "leftover", "stray", "remove unused" |
| `dependency_update` | "update", "upgrade", "bump", "dependency", "package" |
| `architecture` | "architect", "design", "new service", "migration", "schema" |

If multiple categories match, prefer the more specific one. If ambiguous, default to the agent name if present, otherwise `code_review`.

---

## Scope Analysis

### File Count Scoring

```
if files_changed <= max_files_changed * 0.5:
    scope_score = 1.0
elif files_changed <= max_files_changed * 0.8:
    scope_score = 0.7
elif files_changed <= max_files_changed:
    scope_score = 0.5
else:
    scope_score = 0.0  # over limit
```

### Scope Red Flags

Reduce scope score by 0.2 for each:
- Changes to CI/CD files (`.github/`, `Jenkinsfile`, etc.)
- Changes to package manifests (`package.json`, `Cargo.toml`, etc.) without lockfile updates
- Changes spanning 5+ top-level directories
- Deletion of files not mentioned in the prompt

---

## Intent Clarity

### High Clarity (1.0)
- References specific files: "Fix bug in `src/auth/handler.ts`"
- References specific issues: "Fix #123"
- Has clear acceptance criteria: "Make the login test pass"

### Medium Clarity (0.5)
- General area: "Improve the authentication flow"
- Broad task: "Clean up the utils directory"
- No specific files or issues referenced

### Low Clarity (0.2)
- Very vague: "Make it better"
- No context: "Fix things"
- Contradictory: multiple unrelated tasks in one prompt

---

## Adjusting Weights via Learning

If `learning.auto_tune` is enabled, the skill adjusts weights based on outcomes:

1. Track which factors correlate most with successful merges
2. After `auto_tune_min_samples` sessions, compute factor-outcome correlations
3. Shift weight toward factors that predict merge success
4. Never let any single factor exceed 0.50 weight
5. Never let any factor drop below 0.05 weight
6. Log all weight adjustments for transparency

---

## Edge Cases

### Session with No Source Context (Repoless)
- Can't promote to PR directly
- Score for triage purposes, but action is "flag for manual integration"
- Include in digest with note: "Repoless session — requires manual repo assignment"

### Session That Created Its Own PR
- Skip PR creation phase entirely
- Verify the PR exists and is open
- Score normally and decide whether to hand off to github-babysitter pr-care

### Multiple Sessions Targeting Same Files
- Detect overlap via file paths in activities
- Flag the conflict in the digest
- Only promote the highest-scoring one; defer others with note
