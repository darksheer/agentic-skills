# Governance and Security Signals

The babysitter flags risks; it does not make legal or compliance decisions.

## Repository Governance

Flag:
- missing license on public repos when one is expected
- archived repos with open issues or PRs
- default branch workflow failure streaks
- stale open PRs with green checks
- stale bot-created issues that keep reopening
- private repos with unusually old pushes if they are in the active allowlist

## Security-Aware Signals

Flag:
- open issues or PRs labeled `security`, `incident`, `vulnerability`, or `CVE`
- dependency PRs that include security-sensitive packages
- failed secret scans, Semgrep, Trivy, audit, or CodeQL checks
- workflow failures on default branch involving auth, secrets, deploy, or release

## Report Language

Use "flagged for review" and "recommended action." Avoid claiming compliance
pass/fail unless the underlying system explicitly reports that status.
