# Signal Sources

This skill does not run review tools. It observes the signals those tools leave.

## PR Review Signals

| Source | Signal | Interpretation |
|--------|--------|----------------|
| CodeRabbit status | success with skip comment | tool installed but skipped; often bot PR policy |
| Codex review | review object/comment | automated semantic review ran |
| Jules comment | `google-labs-jules` issue comment | Jules is attached to the PR |
| GitHub checks | statusCheckRollup/check-runs | CI and review automation state |
| Human reviews | reviewDecision/reviews | approval or requested changes |

## Dependency Bot Signals

Dependabot/Renovate PRs should be evaluated for:
- package and lockfile consistency
- engine/runtime compatibility
- security advisory relevance
- failing checks caused by updated packages
- stale grouped updates that may need rebase or split

## Automation Noise Signals

Repeated bot-created issues with identical title/labels, repeated failing scheduled
workflow runs, and duplicate dependency update attempts should be grouped into one
action item instead of reported as unrelated incidents.
