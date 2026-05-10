# Repo Health Follow-Up

Generated: 2026-05-10

Mode: `github_pro_babysitter` read-only monitoring. No close, label, rerun, cancel, comment, or merge action was performed.

## Scorecard

| Repo | Default Branch | Open PRs | Issues | Recent Workflow Signal | Health Note |
| --- | --- | ---: | ---: | --- | --- |
| `darksheer/ARC` | `main` | 23 | 3 | Several PR lint failures and in-progress unit/lint checks | No Jules PR should be promoted into this repo without conflict/check review; active PR queue is noisy. |
| `darksheer/arc-powerup` | `main` | 1 | 12 | Dependabot PR has failing Integration Tests; recent main Integration Tests also failed | Good candidate for focused CI follow-up before promoting more Jules changes. |
| `darksheer/Acheron` | `main` | 0 | 48 | Repeated scheduled `f3-snapshot-check` failures on main | No open PR conflict, but recurring scheduled failures should be noted before promoting security/refactor changeSets. |
| `darksheer/ft3` | `master` | 0 | 1 | No recent workflow runs returned | Low automation signal; PRs may need manual/local verification. |
| `darksheer/synapse` | `master` | 1 | unavailable | No recent workflow runs returned | Open PR `#1` is mergeable but has no checks and issues are disabled. |

## Blockers and Risks

- `darksheer/ARC` has many active draft PRs and repeated lint failures on recent PR checks. Jules changeSets touching ARC should be promoted one at a time only after checking file overlap.
- `darksheer/arc-powerup` has a blocked dependency PR and failing Integration Tests in recent history. Avoid assuming Jules changeSets are safe until integration status is understood.
- `darksheer/Acheron` has repeated `f3-snapshot-check` failures on scheduled runs. This may not block targeted code fixes, but it should be included in any PR body/review notes.
- `darksheer/ft3` has no Actions signal from `gh run list`; use local tests or explicit manual review.
- `darksheer/synapse#1` is open and mergeable, but there are no status checks to rely on.

## Actions Not Taken

- No workflow reruns.
- No issue or PR comments.
- No labels.
- No merges or closes.
