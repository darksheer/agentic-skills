# Jules Wrangler — TODO

## Phase 1: Validation & Testing

- [x] **Test API connectivity** — Use the API key in `.env` to run a basic `GET /v1alpha/sessions` call and verify authentication works.
- [x] **Test on real sessions** — Run the skill against actual completed Jules sessions. Validate scoring, category detection, and promotion logic.
- [ ] **Test autonomy modes** — Verify each mode (full, approve-high-risk, approve-all) behaves correctly.
- [x] **Test github-babysitter handoff (read-only)** — Existing-PR handoff validated with a Jules-created PR. Write-path PR creation still requires explicit approval.
- [ ] **Test scheduling** — Set up a daily schedule via `/schedule` and confirm it triggers correctly.

## Phase 2: Integration

- [ ] **Wire up Slack notifications** — Test digest posting to a Slack channel via the Slack MCP.
- [ ] **GitHub issue tracking** — Test posting digests as GitHub issues on a tracking repo.
- [ ] **State persistence** — Verify `.jules-wrangler-state.json` correctly tracks sessions across runs.
- [x] **Handoff payload fixture** — Add a fixture test for the structured jules-wrangler to github-babysitter handoff payload documented in `references/promotion-workflow.md`.
- [ ] **Live write-path validation** — Only test `sendMessage`, plan approval, PR creation, PR comments, or handoff invocation after explicit approval and only against a disposable repo/PR.

## Phase 3: Learning System

- [ ] **Outcome tracking** — After promotion, check back on PR status (merged/closed) and record outcomes.
- [ ] **Threshold tuning** — Once 20+ sessions have been triaged, evaluate whether `min_confidence` needs adjustment.
- [ ] **Category accuracy** — Validate that the category detection heuristics are accurate across real sessions.

---

## Additional Skills to Create (from Jules API Audit)

Based on the full Jules API capabilities, these additional skills would extend the ecosystem:

### 1. `jules-task-runner`
**Purpose**: Create Jules sessions from external triggers (GitHub issues, Linear tickets, Slack messages).
**Capabilities used**: `POST /sessions` (create), sourceContext, automationMode
**Trigger**: "Run Jules on issue #42", "Have Jules fix this", "Spawn a Jules session for..."
**Value**: Lets you kick off Jules work without leaving your workflow.

### 2. `jules-monitor`
**Purpose**: Watch active Jules sessions and handle interactive feedback requests.
**Capabilities used**: `GET /sessions` (list/filter by state), `POST /sessions/{id}:sendMessage`, `POST /sessions/{id}:approvePlan`
**Trigger**: "Check on my Jules sessions", "Approve Jules plans", "What does Jules need from me?"
**Value**: Jules often gets stuck waiting for plan approval or user feedback. This skill auto-responds or surfaces questions immediately.

### 3. `jules-repoless`
**Purpose**: Spawn ephemeral cloud dev environments via Jules for quick prototyping, scripts, and one-off tasks.
**Capabilities used**: `POST /sessions` (without sourceContext), file outputs
**Trigger**: "Spin up a Jules environment for...", "Prototype this in Jules", "Quick script via Jules"
**Value**: Instant cloud dev environments without repo setup. Good for spikes, proof-of-concepts, and utility scripts.

### 4. `jules-ci-fixer`
**Purpose**: Automatically create Jules sessions when CI fails, to diagnose and fix the failure.
**Capabilities used**: `POST /sessions` with specific prompts referencing CI logs, GitHub Actions integration via `jules-action`
**Trigger**: Scheduled — watch for failed CI runs. Or "Have Jules fix CI on this branch"
**Value**: Closes the loop on CI failures without human intervention. Jules reads the logs, identifies the fix, and creates a PR.

### 5. `jules-review-responder`
**Purpose**: When Jules performs code reviews (via jules-action on PRs), this skill processes Jules' review comments and decides which to apply.
**Capabilities used**: Activities API (reading review findings), GitHub PR comment API
**Trigger**: "Process Jules' review on PR #42", or scheduled after jules-action runs
**Value**: Jules' reviews often produce many comments. This skill triages them the same way github-babysitter handles other reviewers, but specifically tuned for Jules' output patterns.
