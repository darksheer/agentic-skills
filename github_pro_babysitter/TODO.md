# GitHub Pro Babysitter - TODO

## Validation

- [x] Replace copied PR Orchestrator skill content with GitHub health monitoring instructions.
- [x] Validate against a real `darksheer/` repo using read-only `gh` commands.
- [ ] Add automated structural tests for this skill once the repo test suite expands beyond `jules-triage`.
- [ ] Test optional Slack/GitHub issue digest posting with explicit user approval.

## Improvements

- [ ] Add a small fixture-based evaluator for stale PR, failing workflow, and noisy bot issue classification.
- [ ] Add branch protection checks to the health score when the token has permission.
- [ ] Add dependency advisory collection through Dependabot alerts when API permissions allow it.
- [ ] Add a local state file schema for suppressing acknowledged noisy alerts.

## Deferred Access-Dependent Work

- [ ] Verify write-mode actions such as posting digest comments only after the user asks for external writes.
- [ ] Confirm behavior across private repos with different GitHub token permissions.
