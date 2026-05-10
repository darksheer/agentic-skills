# Learning System Reference

The learning system tracks the outcome of every finding across PR reviews, building a knowledge base that improves triage accuracy and workflow efficiency over time.

## Data Model

### Finding Record
Each finding that passes through triage gets a record:

```json
{
  "finding_id": "cr-2024-0142",
  "timestamp": "2026-05-09T14:30:00Z",
  "repo": "owner/repo",
  "pr_number": 42,
  "source_tool": "coderabbit",
  "category": "security",
  "severity": "high",
  "file_pattern": "src/api/**/*.ts",
  "language": "typescript",
  "description_hash": "sha256:abc123",
  "description_summary": "SQL injection risk in query builder",
  "decision": "apply",
  "confidence": "high",
  "consensus_count": 2,
  "consensus_tools": ["coderabbit", "codex"],
  "was_accurate": true,
  "fix_introduced_issues": false,
  "human_override": false,
  "human_override_reason": null,
  "triage_duration_ms": 1200,
  "fix_duration_ms": 3400
}
```

### Tool Profile
Aggregated metrics per tool, updated after each PR cycle:

```json
{
  "tool": "coderabbit",
  "total_findings": 342,
  "by_category": {
    "security": {"total": 45, "accepted": 38, "precision": 0.844},
    "performance": {"total": 67, "accepted": 41, "precision": 0.612},
    "style": {"total": 120, "accepted": 95, "precision": 0.792},
    "correctness": {"total": 80, "accepted": 72, "precision": 0.900},
    "other": {"total": 30, "accepted": 18, "precision": 0.600}
  },
  "overall_precision": 0.772,
  "avg_triage_time_ms": 980,
  "consensus_rate": 0.34,
  "last_updated": "2026-05-09T15:00:00Z"
}
```

### Workflow Metrics
Per-PR and aggregate workflow stats:

```json
{
  "pr": "owner/repo#42",
  "total_findings": 15,
  "unique_findings": 12,
  "duplicates_caught": 3,
  "findings_applied": 8,
  "findings_skipped": 4,
  "review_cycles": 2,
  "total_duration_minutes": 12,
  "actions_minutes_used": 8,
  "estimated_cost_usd": 0.12,
  "tools_used": ["coderabbit", "codex", "gemini"],
  "new_issues_from_fixes": 0
}
```

## Storage Backends

### Local JSON (default)
```
.pr-orchestrator/
  learning/
    findings/
      2026-05.jsonl       # Append-only log, one JSON per line, rotated monthly
    profiles/
      coderabbit.json     # Tool profile
      codex.json
      ...
    workflow/
      metrics.jsonl       # Per-PR workflow metrics
    patterns/
      false-positives.json  # Known false positive patterns
      auto-skip-rules.json  # Generated skip rules
```

JSONL format (one JSON object per line) is used for findings and metrics because:
- Append-only writes (no read-modify-write race conditions)
- Works with simple `echo >> file` in any shell
- Easy to grep/filter with standard tools
- No file locking needed

### SQLite
Single file at configured path. Schema:

```sql
CREATE TABLE findings (
  id TEXT PRIMARY KEY,
  timestamp TEXT,
  repo TEXT,
  pr_number INTEGER,
  source_tool TEXT,
  category TEXT,
  severity TEXT,
  file_pattern TEXT,
  language TEXT,
  description_hash TEXT,
  description_summary TEXT,
  decision TEXT,
  confidence TEXT,
  consensus_count INTEGER,
  was_accurate BOOLEAN,
  fix_introduced_issues BOOLEAN,
  human_override BOOLEAN,
  triage_duration_ms INTEGER,
  fix_duration_ms INTEGER
);

CREATE TABLE tool_profiles (
  tool TEXT,
  category TEXT,
  total INTEGER,
  accepted INTEGER,
  precision REAL,
  last_updated TEXT,
  PRIMARY KEY (tool, category)
);

CREATE TABLE workflow_metrics (
  pr TEXT PRIMARY KEY,
  total_findings INTEGER,
  unique_findings INTEGER,
  findings_applied INTEGER,
  findings_skipped INTEGER,
  review_cycles INTEGER,
  total_duration_minutes REAL,
  actions_minutes_used REAL,
  estimated_cost_usd REAL
);

CREATE INDEX idx_findings_tool ON findings(source_tool);
CREATE INDEX idx_findings_category ON findings(category);
CREATE INDEX idx_findings_repo ON findings(repo);
```

### Repo-based
Store learning data on a dedicated branch (e.g., `pr-orchestrator-data`) or in a directory (e.g., `.pr-orchestrator/learning/`). Same file structure as local, but committed to the repo so the whole team benefits.

When using repo storage, batch learning data updates and commit them at the end of each PR review cycle, not after each finding.

## Using Learned Data

### Auto-Skip Rules
When a tool's precision for a category drops below `auto_skip_threshold` (default: 30%) AND there are at least `min_samples_for_auto_skip` data points (default: 10), the system generates an auto-skip rule:

```json
{
  "rule_id": "skip-jules-style-ts",
  "tool": "jules",
  "category": "style",
  "language": "typescript",
  "precision": 0.22,
  "sample_count": 18,
  "action": "auto-skip",
  "annotation": "Auto-skipped: Jules style findings for TypeScript have 22% precision (18 samples). Override with manual review if needed.",
  "created": "2026-05-09T15:00:00Z"
}
```

Auto-skipped findings are still collected and noted in the report, but they're annotated as auto-skipped and don't trigger fixes.

### Triage Boosting
Findings that match patterns of previously-accepted findings get a confidence boost:
- Same tool + same category + same file pattern → +1 confidence level
- Consensus with 2+ tools → +1 confidence level
- Matches a known false-positive pattern → -2 confidence levels

### Tool Ordering Optimization
After enough data, the skill can reorder tool invocations:
1. Run highest-precision tools first
2. Use their findings to pre-filter lower-precision tools (if Tool A already caught it, don't count it against Tool B)
3. Skip tools that consistently provide no unique findings beyond what others catch

## Querying Patterns

### "How is CodeRabbit performing?"
```bash
# Local
cat .pr-orchestrator/learning/profiles/coderabbit.json | jq .

# SQLite
sqlite3 .pr-orchestrator/learning.db "SELECT * FROM tool_profiles WHERE tool='coderabbit'"
```

### "What are the most common false positives?"
```bash
# Local
grep '"was_accurate":false' .pr-orchestrator/learning/findings/*.jsonl | \
  jq -s 'group_by(.source_tool, .category) | map({tool: .[0].source_tool, category: .[0].category, count: length}) | sort_by(-.count)'
```

### "How much are we spending per PR?"
```bash
# Local
cat .pr-orchestrator/learning/workflow/metrics.jsonl | \
  jq -s '{avg_cost: (map(.estimated_cost_usd) | add / length), avg_minutes: (map(.actions_minutes_used) | add / length)}'
```

## Privacy & Security

- Learning data stays local by default — no data leaves the repo/machine
- Finding descriptions are stored as summaries and hashes, not full code
- No source code is stored in learning data
- The `repo` storage option makes data available to the team but keeps it within the repo's access controls
