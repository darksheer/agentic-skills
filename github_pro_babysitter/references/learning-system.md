# Learning and State

When enabled, store repeated monitoring patterns locally.

## File Layout

```text
.github-pro-babysitter/
  state/
    workflow-failures.jsonl
    stale-items.jsonl
    noisy-automation.jsonl
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

## Suppressions

Suppression records prevent repeating acknowledged noise:

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
