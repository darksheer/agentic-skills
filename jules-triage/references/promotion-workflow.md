# Promotion Workflow

Step-by-step process for promoting a Jules session to a GitHub PR and handing off to github-babysitter pr-care.

---

## Prerequisites

Before promoting, verify:
1. Session state is `COMPLETED`
2. Triage score meets threshold
3. Autonomy mode allows promotion (or human approved)
4. No conflicting open PRs on the same files
5. Target branch exists and is up to date

---

## Workflow A: Session Already Created a PR

When the session used `automationMode: "AUTO_CREATE_PR"`, Jules already opened a PR.

### Steps

1. **Extract PR URL** from session outputs:
   ```json
   session.outputs[].pullRequest.url
   ```

2. **Verify PR is open**:
   ```bash
   gh pr view {number} --repo {owner}/{repo} --json state
   ```
   If closed/merged, log and skip.

3. **Add triage annotation** as a PR comment:
   ```markdown
   ## Jules Triage Assessment
   
   | Attribute | Value |
   |-----------|-------|
   | Session | [{session_title}]({jules_session_url}) |
   | Triage Score | {score}/1.0 |
   | Category | {detected_category} |
   | Tests | {pass/fail/not_run} |
   | Promoted At | {timestamp} |
   | Autonomy | {mode} |
   
   This PR was auto-promoted from a Jules coding session.
   GitHub Babysitter will now manage PR care and merge readiness.
   ```

4. **Add labels**:
   - `jules-triage`
   - Category label (e.g., `bug-fix`, `security`)
   - `auto-promoted` (if no human approval was needed)

5. **Hand off to github-babysitter pr-care**:
   ```
   Review PR #{number} on {owner}/{repo} — promoted from Jules session {session_id}
   ```

---

## Workflow B: No PR Exists — Create One

When the session completed without `AUTO_CREATE_PR`, we need to create the PR manually.

### Steps

1. **Get the session's diff/changes**:
   - List activities to find the final state
   - If file outputs are available, retrieve them
   - If a branch was created by Jules, use it directly

2. **Determine branch strategy**:
   ```
   Branch name: jules/{session_id_short}/{category}
   Example: jules/abc12/bug-fix
   ```

3. **Create branch and apply changes**:
   ```bash
   # If Jules created a branch, use it
   gh api repos/{owner}/{repo}/git/refs \
     --method POST \
     --field ref="refs/heads/jules/{session_short}/{category}" \
     --field sha="{commit_sha}"
   
   # Or if applying from file outputs:
   git checkout -b jules/{session_short}/{category}
   # Apply file changes
   git add -A
   git commit -m "feat: {session_title}

   Promoted from Jules session {session_id}
   Triage score: {score}
   Category: {category}
   
   Signed-off-by: jules-triage"
   git push origin jules/{session_short}/{category}
   ```

4. **Open the PR**:
   ```bash
   gh pr create \
     --repo {owner}/{repo} \
     --base {target_branch} \
     --head jules/{session_short}/{category} \
     --title "{session_title}" \
     --body "$(cat <<'EOF'
   ## Summary
   
   {First 2-3 lines from session prompt}
   
   ## Jules Session Context
   
   - **Session**: [{session_id}]({jules_url})
   - **Category**: {category}
   - **Triage Score**: {score}/1.0
   - **Files Changed**: {file_count}
   - **Tests**: {pass/fail/not_run}
   
   ## What Jules Did
   
   {Plan summary from activities}
   
   ---
   
   *This PR was auto-promoted by jules-triage. GitHub Babysitter will manage PR care.*
   EOF
   )" \
     --label "jules-triage,{category}"
   ```

5. **Hand off to github-babysitter pr-care** (same as Workflow A step 5)

---

## Conflict Detection

Before creating a PR, check for conflicts:

### File-Level Conflicts

```bash
# List open PRs touching the same files
gh pr list --repo {owner}/{repo} --state open --json number,files \
  | jq '[.[] | select(.files[].path as $p | $jules_files | contains([$p]))]'
```

If conflicts found:
- **In `full` mode**: Still promote, but add a conflict warning to the PR body
- **In `approve-high-risk` mode**: Require human approval with conflict details
- **In `approve-all` mode**: Include in digest with conflict flag

### Branch Conflicts

If the target branch has moved significantly since the session ran:
1. Attempt a merge check (dry-run)
2. If merge conflicts exist, flag in digest: "Session may need rebase"
3. In `full` mode, attempt automatic rebase before promoting
4. If rebase fails, defer to human

---

## GitHub Babysitter Handoff

### Structured Handoff Payload

Before invoking github-babysitter, construct a compact handoff payload and include
it in the PR comment/body or local report:

```json
{
  "source_skill": "jules-triage",
  "target_skill": "github-babysitter",
  "mode": "pr-care",
  "session_id": "session_abc123",
  "session_url": "https://jules.google.com/session/abc123",
  "repo": "owner/repo",
  "pr_number": 42,
  "pr_url": "https://github.com/owner/repo/pull/42",
  "category": "security",
  "triage_score": 0.9,
  "tests": "passed|failed|not_run|unknown",
  "promotion_reason": "Score exceeded threshold and scope was within limits",
  "risk_notes": []
}
```

This payload prevents data loss between skills. If a field is unknown, include it
with value `unknown` rather than omitting it.

### What to Pass

When invoking github-babysitter pr-care, provide context:

```
Review PR #{number} on {owner}/{repo}.
Context: This PR was promoted from Jules session {session_id}.
Jules category: {category}. Triage score: {score}.
The session {did/did not} run its own tests.
Prioritize: {any special instructions based on category}
```

### Special Handling by Category

| Category | GitHub Babysitter Guidance |
|----------|--------------------------|
| `security` | "Flag any findings that contradict the security fix" |
| `bug_fix` | "Verify the fix doesn't introduce regressions" |
| `refactor` | "Focus on behavioral equivalence, not style" |
| `performance` | "Look for benchmark results in the session activities" |
| `documentation` | "Light review — focus on accuracy, not style" |

---

## Rollback

If a promoted PR causes issues after merge:

1. The learning system records the failure
2. The session's category/score pattern is noted
3. If multiple failures from the same category/score range, auto-adjust `min_confidence`
4. Consider adding the pattern to `high_risk_categories`

---

## State Tracking

After promotion, record in `.jules-triage-state.json`:

```json
{
  "triaged_sessions": {
    "session_abc123": {
      "triaged_at": "2026-05-09T09:00:00Z",
      "score": 0.85,
      "category": "bug_fix",
      "decision": "promoted",
      "pr_number": 42,
      "pr_repo": "owner/repo",
      "github_babysitter_invoked": true,
      "outcome": null
    }
  }
}
```

The `outcome` field is updated later when the PR is merged/closed:
- `"merged"`: PR was merged successfully
- `"closed"`: PR was closed without merge
- `"reverted"`: PR was merged then reverted
