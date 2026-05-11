# Compliance and Governance Signals

GitHub Babysitter flags risks; it does not make legal or compliance decisions.

## Project Policies

If present, read:

- `AGENTS.md`
- `CLAUDE.md`
- `CONTRIBUTING.md`
- `SECURITY.md`
- config `compliance.additional_policy_files`

Extract actionable constraints and check whether proposed fixes or merge
recommendations violate them.

## Governance Signals

Flag:

- missing license on public repos when one is expected
- archived repos with open issues or PRs
- default branch workflow failure streaks
- stale open PRs with green checks
- stale bot-created issues that keep reopening
- private active repos with unusually old pushes

## Security-Aware Signals

Flag:

- open issues or PRs labeled `security`, `incident`, `vulnerability`, or `CVE`
- dependency PRs that touch security-sensitive packages
- failed secret scans, Semgrep, Trivy, audit, CodeQL, or dependency review checks
- workflow failures on auth, secrets, deploy, or release paths
- changes touching authentication, authorization, audit logging, encryption,
  credentials, payments, PII, or health data

## Report Language

Use "flagged for review" and "recommended action." Avoid claiming legal or
compliance pass/fail unless the underlying system explicitly reports that
status.
