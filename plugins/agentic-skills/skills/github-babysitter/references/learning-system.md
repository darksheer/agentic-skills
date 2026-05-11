# Learning and State

When enabled, store repeated patterns locally under:

```text
.github-babysitter/
  state/
    workflow-failures.jsonl
    stale-items.jsonl
    noisy-automation.jsonl
    pr-finding-outcomes.jsonl
    suppressions.json
```

## Records

Workflow failure:

```json
{
  "timestamp": "2026-05-10T15:00:00Z",
  "repo": "darksheer/ARC",
  "workflow": "Optic Parity - Daily Scrape",
  "run_id": 25596610395,
  "conclusion": "failure",
  "head_branch": "main"
}
```

Stale item:

```json
{
  "timestamp": "2026-05-10T15:00:00Z",
  "repo": "darksheer/ARC",
  "type": "issue",
  "number": 286,
  "title_hash": "sha256:...",
  "age_days": 6,
  "labels": ["optic-parity", "stale"]
}
```

PR finding outcome:

```json
{
  "timestamp": "2026-05-10T15:00:00Z",
  "repo": "owner/repo",
  "pr_number": 42,
  "source": "coderabbit",
  "category": "correctness",
  "severity": "medium",
  "decision": "apply",
  "confidence": "high",
  "was_accurate": true,
  "fix_introduced_issues": false
}
```

## Suppressions

Suppression records prevent repeated acknowledged noise:

```json
{
  "suppressions": [
    {
      "repo": "darksheer/ARC",
      "match": "Optic Parity: Scrape pipeline stale",
      "expires": "2026-06-01T00:00:00Z",
      "reason": "Known tracker noise while parity migration is active"
    }
  ]
}
```

Learning data must not store source code. Store summaries, hashes, labels, and
outcomes only.
