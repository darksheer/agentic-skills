#!/usr/bin/env bash
# Test runner for agentic-skills
# Run test tiers: structural → fixtures → API contract → dry-run pipeline
#
# Usage:
#   ./tests/run_all.sh             # run everything
#   ./tests/run_all.sh structural  # just structural checks
#   ./tests/run_all.sh fixtures    # fixture-backed Jules tests
#   ./tests/run_all.sh api         # just API contract tests
#   ./tests/run_all.sh pipeline    # just dry-run pipeline

set -euo pipefail
cd "$(dirname "$0")/.."

# Load .env if present
if [ -f .env ]; then
  set -a
  source .env
  set +a
fi

TIER="${1:-all}"
PASS=0
FAIL=0
ERRORS=()

pass() { PASS=$((PASS + 1)); echo "  ✓ $1"; }
fail() { FAIL=$((FAIL + 1)); ERRORS+=("$1"); echo "  ✗ $1"; }

# ─────────────────────────────────────────────────────────────────────────────
# TIER 1: Structural Validation
# ─────────────────────────────────────────────────────────────────────────────
run_structural() {
  echo ""
  echo "═══ TIER 1: Structural Validation ═══"
  echo ""

  marketplace_manifest="./.claude-plugin/marketplace.json"
  plugin_manifest="./plugins/agentic-skills/.claude-plugin/plugin.json"
  plugin_root="./plugins/agentic-skills"
  skills_root="$plugin_root/skills"

  echo "  [Plugin Manifests]"
  if jq -e . "$marketplace_manifest" > /dev/null 2>&1; then
    pass "Marketplace manifest parses as JSON"
  else
    fail "Marketplace manifest is missing or invalid JSON: $marketplace_manifest"
  fi

  if jq -e . "$plugin_manifest" > /dev/null 2>&1; then
    pass "Plugin manifest parses as JSON"
  else
    fail "Plugin manifest is missing or invalid JSON: $plugin_manifest"
  fi

  marketplace_source=$(jq -r '.plugins[]? | select(.name == "agentic-skills") | .source' "$marketplace_manifest" 2>/dev/null || true)
  if [ "$marketplace_source" = "./plugins/agentic-skills" ] && [ -d "$marketplace_source" ]; then
    pass "Marketplace source path exists: $marketplace_source"
  else
    fail "Marketplace source path is missing or unexpected: ${marketplace_source:-<empty>}"
  fi

  if jq -e '.name == "agentic-skills" and .owner.name == "darksheer" and ([.plugins[]? | select(.name == "agentic-skills" and .source == "./plugins/agentic-skills" and .version == "0.1.0")] | length == 1)' "$marketplace_manifest" > /dev/null 2>&1; then
    pass "Marketplace manifest has expected plugin entry"
  else
    fail "Marketplace manifest missing expected plugin entry"
  fi

  if jq -e '.name == "agentic-skills" and .version == "0.1.0" and .author.name == "darksheer"' "$plugin_manifest" > /dev/null 2>&1; then
    pass "Plugin manifest has expected name, version, and author"
  else
    fail "Plugin manifest missing expected name/version/author"
  fi

  for required_skill in jules-wrangler github-babysitter; do
    if [ -f "$skills_root/$required_skill/SKILL.md" ]; then
      pass "Plugin skill exists: $required_skill/SKILL.md"
    else
      fail "Plugin skill missing: $required_skill/SKILL.md"
    fi
  done

  while read -r skill_dir; do
    [ -z "$skill_dir" ] && continue
    skill_name=$(basename "$skill_dir")
    echo "  [$skill_name]"

    if [ ! -f "$skill_dir/SKILL.md" ]; then
      fail "$skill_name: missing SKILL.md"
      echo ""
      continue
    fi

    # Check SKILL.md exists and has frontmatter
    if head -1 "$skill_dir/SKILL.md" | grep -q "^---"; then
      pass "$skill_name: SKILL.md has YAML frontmatter"
    else
      fail "$skill_name: SKILL.md missing YAML frontmatter (must start with ---)"
    fi

    # Check required frontmatter fields
    if grep -q "^name:" "$skill_dir/SKILL.md"; then
      pass "$skill_name: has 'name' field"
    else
      fail "$skill_name: missing 'name' field in frontmatter"
    fi

    if grep -q "^description:" "$skill_dir/SKILL.md"; then
      pass "$skill_name: has 'description' field"
    else
      fail "$skill_name: missing 'description' field in frontmatter"
    fi

    # Check SKILL.md line count (should be under 500)
    lines=$(wc -l < "$skill_dir/SKILL.md")
    if [ "$lines" -le 500 ]; then
      pass "$skill_name: SKILL.md is $lines lines (≤500)"
    else
      fail "$skill_name: SKILL.md is $lines lines (exceeds 500 line guideline)"
    fi

    # Check referenced files exist
    if [ -d "$skill_dir/references" ]; then
      ref_count=$(ls "$skill_dir/references/"*.md 2>/dev/null | wc -l)
      pass "$skill_name: references/ has $ref_count files"

      # Verify each reference mentioned in SKILL.md actually exists
      while read -r ref; do
        [ -z "$ref" ] && continue
        if [ -f "$skill_dir/$ref" ]; then
          pass "$skill_name: $ref exists"
        else
          fail "$skill_name: $ref referenced in SKILL.md but file missing"
        fi
      done < <(grep -Eo 'references/[a-z0-9_-]+\.md' "$skill_dir/SKILL.md" 2>/dev/null | sort -u)
    fi

    echo ""
  done < <(find "$skills_root" -mindepth 1 -maxdepth 1 -type d | sort)

  babysitter_skill="$skills_root/github-babysitter/SKILL.md"
  for required_section in "## Default Invocation" "## Output Policy" "Do not write markdown reports" "Do not default to repo-rounds" "## Execution Contract" "Minimum data collection per repo" "Minimum data collection:" "Definition of done:" "## Active PR State Loop" "blocked-needs-approval" "ready-to-merge"; do
    if grep -q "$required_section" "$babysitter_skill"; then
      pass "github-babysitter: has operational section '$required_section'"
    else
      fail "github-babysitter: missing operational section '$required_section'"
    fi
  done

  babysitter_config="$skills_root/github-babysitter/references/config-schema.md"
  if grep -q "output_local: false" "$babysitter_config"; then
    pass "github-babysitter: local report output defaults off"
  else
    fail "github-babysitter: local report output must default to false"
  fi

  if grep -q "default_mode: pr-care" "$babysitter_config"; then
    pass "github-babysitter: default mode is pr-care"
  else
    fail "github-babysitter: default mode must be pr-care"
  fi

  if [ -e ./jules-triage/SKILL.md ] || [ -e ./github-babysitter/SKILL.md ]; then
    fail "Top-level duplicate canonical skill files must not exist"
  else
    pass "No top-level duplicate canonical skill files"
  fi
}

# ─────────────────────────────────────────────────────────────────────────────
# TIER 2: Fixture-Backed Jules Validation
# ─────────────────────────────────────────────────────────────────────────────
run_fixtures() {
  echo ""
  echo "═══ TIER 2: Fixture-Backed Jules Validation ═══"
  echo ""

  fixture_dir="./tests/fixtures/jules"
  required_files=(
    "sessions-page.json"
    "completed-session-changeSet.json"
    "completed-session-pullRequest.json"
    "awaiting-feedback-simple.json"
    "awaiting-feedback-substantive.json"
    "activities-completed.json"
    "activities-feedback.json"
    "sources.json"
  )

  echo "  [Fixture Presence and JSON Parsing]"
  for fixture in "${required_files[@]}"; do
    path="$fixture_dir/$fixture"
    if [ -f "$path" ]; then
      pass "Fixture exists: $fixture"
    else
      fail "Missing fixture: $fixture"
      continue
    fi

    if jq -e . "$path" > /dev/null 2>&1; then
      pass "Fixture parses as JSON: $fixture"
    else
      fail "Fixture is invalid JSON: $fixture"
    fi
  done

  sessions_file="$fixture_dir/sessions-page.json"
  change_session_file="$fixture_dir/completed-session-changeSet.json"
  pr_session_file="$fixture_dir/completed-session-pullRequest.json"
  completed_activities_file="$fixture_dir/activities-completed.json"
  simple_feedback_file="$fixture_dir/awaiting-feedback-simple.json"
  substantive_feedback_file="$fixture_dir/awaiting-feedback-substantive.json"
  sources_file="$fixture_dir/sources.json"

  echo ""
  echo "  [Session Classification]"
  # ⚡ Bolt: Batch jq operations to avoid spawning multiple processes and parsing the same JSON string repeatedly.
  # This reduces execution overhead significantly.
  read -r completed awaiting active failed_sessions with_changeset with_pr no_output <<< $(jq -r '
    [
      ([.sessions[] | select(.state == "COMPLETED")] | length),
      ([.sessions[] | select(.state == "AWAITING_USER_FEEDBACK")] | length),
      ([.sessions[] | select(.state == "ACTIVE" or .state == "IN_PROGRESS")] | length),
      ([.sessions[] | select(.state == "FAILED")] | length),
      ([.sessions[] | select(.outputs != null) | select(.outputs[]? | has("changeSet"))] | length),
      ([.sessions[] | select(.outputs != null) | select(.outputs[]? | has("pullRequest"))] | length),
      ([.sessions[] | select(.outputs == null or (.outputs | length) == 0)] | length)
    ] | @tsv
  ' "$sessions_file")

  [ "$completed" = "2" ] && pass "Classified 2 completed sessions" || fail "Expected 2 completed sessions, got $completed"
  [ "$awaiting" = "2" ] && pass "Classified 2 awaiting-feedback sessions" || fail "Expected 2 awaiting-feedback sessions, got $awaiting"
  [ "$active" = "1" ] && pass "Classified 1 active/in-progress session" || fail "Expected 1 active/in-progress session, got $active"
  [ "$failed_sessions" = "1" ] && pass "Classified 1 failed session" || fail "Expected 1 failed session, got $failed_sessions"

  echo ""
  echo "  [Output Detection]"

  [ "$with_changeset" = "2" ] && pass "Detected 2 sessions with changeSet output" || fail "Expected 2 sessions with changeSet output, got $with_changeset"
  [ "$with_pr" = "1" ] && pass "Detected 1 session with pullRequest output" || fail "Expected 1 session with pullRequest output, got $with_pr"
  [ "$no_output" = "4" ] && pass "Detected 4 sessions with no output" || fail "Expected 4 sessions with no output, got $no_output"

  patch=$(jq -r '.outputs[]? | .changeSet.gitPatch.unidiffPatch? // empty' "$change_session_file")
  patch_files=$(printf "%s" "$patch" | grep -c "^diff --git" || true)
  [ "$patch_files" = "2" ] && pass "Extracted 2 changed files from changeSet patch" || fail "Expected 2 changed files from patch, got $patch_files"

  echo ""
  echo "  [Scoring Inputs]"
  source_repo=$(jq -r '.sourceContext.source | sub("^sources/github/"; "")' "$change_session_file")
  [ "$source_repo" = "darksheer/Acheron" ] && pass "Parsed sourceContext repo: $source_repo" || fail "Unexpected sourceContext repo: $source_repo"

  title_prompt=$(jq -r '.title + " " + .prompt' "$change_session_file")
  if printf "%s" "$title_prompt" | grep -qiE "(security|vulnerability|CVE|XSS|injection|unsafe)"; then
    pass "Detected security category scoring input"
  else
    fail "Could not detect security category scoring input"
  fi

  if [ "$patch_files" -le 50 ]; then
    pass "Detected scope scoring input within max_files_changed"
  else
    fail "Scope scoring input exceeds max_files_changed"
  fi

  if jq -e '.state == "COMPLETED"' "$change_session_file" > /dev/null; then
    pass "Detected no-error scoring input from COMPLETED state"
  else
    fail "Completed-session fixture is not COMPLETED"
  fi

  if jq -e '[.activities[] | select(has("planApproved"))] | length == 1' "$completed_activities_file" > /dev/null; then
    pass "Detected plan approval scoring input"
  else
    fail "Missing plan approval scoring input"
  fi

  echo ""
  echo "  [Pull Request URL and Source Parsing]"
  pr_ref=$(jq -r '[.outputs[]?.pullRequest.url? // empty][0] | capture("^https://github.com/(?<owner>[^/]+)/(?<repo>[^/]+)/pull/(?<number>[0-9]+)$") | "\(.owner)/\(.repo)#\(.number)"' "$pr_session_file")
  [ "$pr_ref" = "darksheer/synapse#1" ] && pass "Parsed pullRequest URL into $pr_ref" || fail "Unexpected PR reference: $pr_ref"

  if jq -e '.sources | length == 3 and all(.[]; (.name | startswith("sources/github/")) and (.githubRepo.owner != null))' "$sources_file" > /dev/null; then
    pass "Parsed connected source fixtures"
  else
    fail "Source fixtures do not match expected shape"
  fi

  echo ""
  echo "  [Feedback Question Classification]"
  simple_message=$(jq -r '[.activities[] | select(.agentMessaged != null)] | last | .agentMessaged.agentMessage // empty' "$simple_feedback_file")
  substantive_message=$(jq -r '[.activities[] | select(.agentMessaged != null)] | last | .agentMessaged.agentMessage // empty' "$substantive_feedback_file")

  if printf "%s" "$simple_message" | grep -qiE "(satisfied|finalize|proceed|confirm.*good)"; then
    pass "Classified simple confirmation as auto-respondable"
  else
    fail "Simple confirmation was not classified as auto-respondable"
  fi

  if printf "%s" "$substantive_message" | grep -qiE "(satisfied|finalize|proceed|confirm.*good)"; then
    fail "Substantive question was misclassified as simple confirmation"
  else
    pass "Classified substantive question as requiring analysis"
  fi

  echo ""
  echo "  [Activity Event Shape]"
  if jq -e 'all(.activities[]; has("id") and has("name") and has("createTime") and has("originator"))' "$completed_activities_file" > /dev/null; then
    pass "All completed activities have required base fields"
  else
    fail "Completed activities are missing required base fields"
  fi

  for event in planGenerated planApproved progressUpdated artifacts sessionCompleted; do
    if jq -e --arg event "$event" '[.activities[] | select(has($event))] | length > 0' "$completed_activities_file" > /dev/null; then
      pass "Recognized activity event: $event"
    else
      fail "Missing activity event fixture: $event"
    fi
  done

  if jq -e '[.activities[] | select(has("agentMessaged"))] | length == 2' "$fixture_dir/activities-feedback.json" > /dev/null; then
    pass "Recognized agentMessaged feedback activities"
  else
    fail "Missing agentMessaged feedback activities"
  fi

  echo ""
  echo "  [GitHub Babysitter Handoff Payload]"
  handoff=$(jq -n --slurpfile session "$pr_session_file" '{
    source_skill: "jules-wrangler",
    target_skill: "github-babysitter",
    mode: "pr-care",
    session_id: $session[0].id,
    session_url: $session[0].url,
    repo: ($session[0].sourceContext.source | sub("^sources/github/"; "")),
    pr_number: ([ $session[0].outputs[]?.pullRequest.url? // empty ][0] | capture("/pull/(?<number>[0-9]+)$").number | tonumber),
    pr_url: ([ $session[0].outputs[]?.pullRequest.url? // empty ][0]),
    category: "documentation",
    triage_score: 0.9,
    tests: "unknown",
    promotion_reason: "Fixture session has existing pullRequest output and score exceeds threshold",
    risk_notes: []
  }')

  if printf "%s" "$handoff" | jq -e '
    .source_skill == "jules-wrangler" and
    .target_skill == "github-babysitter" and
    .mode == "pr-care" and
    (.session_id | type == "string" and length > 0) and
    (.session_url | test("^https://jules\\.google\\.com/session/")) and
    .repo == "darksheer/synapse" and
    .pr_number == 1 and
    .pr_url == "https://github.com/darksheer/synapse/pull/1" and
    (.category | type == "string" and length > 0) and
    (.triage_score | type == "number") and
    (.tests == "passed" or .tests == "failed" or .tests == "not_run" or .tests == "unknown") and
    (.promotion_reason | type == "string" and length > 0) and
    (.risk_notes | type == "array")
  ' > /dev/null; then
    pass "Generated handoff payload with all required fields"
  else
    fail "Generated handoff payload missing required fields"
  fi
}

# ─────────────────────────────────────────────────────────────────────────────
# TIER 3: API Contract Tests
# ─────────────────────────────────────────────────────────────────────────────
run_api() {
  echo ""
  echo "═══ TIER 3: API Contract Tests ═══"
  echo ""

  if [ -z "${JULES_API_KEY:-}" ]; then
    fail "JULES_API_KEY not set — cannot run API tests"
    return
  fi

  echo "  [Jules API Authentication]"
  # Test basic auth
  response=$(curl -s -w "\n%{http_code}" \
    'https://jules.googleapis.com/v1alpha/sessions?pageSize=1' \
    -H "X-Goog-Api-Key: $JULES_API_KEY")
  http_code=$(echo "$response" | tail -1)
  body=$(echo "$response" | sed '$d')

  if [ "$http_code" = "200" ]; then
    pass "Authentication successful (HTTP 200)"
  else
    fail "Authentication failed (HTTP $http_code)"
    return
  fi

  echo ""
  echo "  [Jules API - List Sessions]"
  # Verify response shape matches what skill documents
  if echo "$body" | jq -e '.sessions' > /dev/null 2>&1; then
    pass "Response has 'sessions' array"
  else
    fail "Response missing 'sessions' array"
  fi

  # Check session object shape
  session=$(echo "$body" | jq '.sessions[0] // empty')
  if [ -n "$session" ]; then
    for field in name id title state createTime sourceContext url; do
      if echo "$session" | jq -e ".$field" > /dev/null 2>&1; then
        pass "Session has '$field' field"
      else
        fail "Session missing '$field' field (documented in jules-api.md)"
      fi
    done

    # Check sourceContext shape
    if echo "$session" | jq -e '.sourceContext.source' > /dev/null 2>&1; then
      pass "sourceContext.source present (format: sources/github/{org}/{repo})"
    else
      fail "sourceContext.source missing"
    fi

    # Check state is a known value
    state=$(echo "$session" | jq -r '.state')
    case "$state" in
      ACTIVE|COMPLETED|FAILED|AWAITING_PLAN_APPROVAL|AWAITING_USER_FEEDBACK|QUEUED|IN_PROGRESS)
        pass "Session state '$state' is a known value"
        ;;
      *)
        fail "Session state '$state' is UNKNOWN — update jules-api.md"
        ;;
    esac
  else
    echo "  ⚠ No sessions available to validate shape"
  fi

  echo ""
  echo "  [Jules API - List Sources]"
  sources_response=$(curl -s \
    'https://jules.googleapis.com/v1alpha/sources' \
    -H "X-Goog-Api-Key: $JULES_API_KEY")

  if echo "$sources_response" | jq -e '.sources' > /dev/null 2>&1; then
    pass "Sources endpoint returns 'sources' array"
    source_count=$(echo "$sources_response" | jq '.sources | length')
    pass "Found $source_count connected sources"

    # Verify source shape
    first_source=$(echo "$sources_response" | jq '.sources[0]')
    if echo "$first_source" | jq -e '.name' > /dev/null 2>&1; then
      pass "Source has 'name' field"
    else
      fail "Source missing 'name' field"
    fi
    if echo "$first_source" | jq -e '.githubRepo.owner' > /dev/null 2>&1; then
      pass "Source has 'githubRepo.owner' field"
    else
      fail "Source missing 'githubRepo.owner' field"
    fi
  else
    fail "Sources endpoint failed or returned unexpected shape"
  fi

  echo ""
  echo "  [Jules API - Activities]"
  # Use a broader session page for reliable activity data. The auth probe above
  # intentionally fetches only one session, which may not be completed.
  activity_sessions=$(curl -s \
    'https://jules.googleapis.com/v1alpha/sessions?pageSize=30' \
    -H "X-Goog-Api-Key: $JULES_API_KEY")
  session_id=$(echo "$activity_sessions" | jq -r '[.sessions[] | select(.state == "COMPLETED")][0].id // empty')
  if [ -n "$session_id" ]; then
    activities_response=$(curl -s \
      "https://jules.googleapis.com/v1alpha/sessions/$session_id/activities?pageSize=5" \
      -H "X-Goog-Api-Key: $JULES_API_KEY")

    if echo "$activities_response" | jq -e '.activities' > /dev/null 2>&1; then
      pass "Activities endpoint returns 'activities' array"
      activity=$(echo "$activities_response" | jq '.activities[0] // empty')
      if [ -n "$activity" ]; then
        if echo "$activity" | jq -e '.name' > /dev/null 2>&1; then
          pass "Activity has 'name' field"
        fi
        if echo "$activity" | jq -e '.createTime' > /dev/null 2>&1; then
          pass "Activity has 'createTime' field"
        fi
        if echo "$activity" | jq -e '.originator' > /dev/null 2>&1; then
          pass "Activity has 'originator' field"
        else
          fail "Activity missing 'originator' field (documented in jules-api.md)"
        fi
      fi
    else
      fail "Activities endpoint failed"
    fi
  else
    echo "  ⚠ No sessions to test activities against"
  fi
}

# ─────────────────────────────────────────────────────────────────────────────
# TIER 4: Dry-Run Pipeline
# ─────────────────────────────────────────────────────────────────────────────
run_pipeline() {
  echo ""
  echo "═══ TIER 4: Dry-Run Pipeline ═══"
  echo ""

  if [ -z "${JULES_API_KEY:-}" ]; then
    fail "JULES_API_KEY not set — cannot run pipeline tests"
    return
  fi

  echo "  [Session Classification]"
  # Fetch sessions and classify them as the skill would
  sessions=$(curl -s \
    'https://jules.googleapis.com/v1alpha/sessions?pageSize=30' \
    -H "X-Goog-Api-Key: $JULES_API_KEY")

  # ⚡ Bolt: Batch jq operations to avoid spawning multiple processes and parsing the same JSON string repeatedly.
  # This reduces execution overhead significantly.
  read -r total completed awaiting active bolt_count palette_count oneoff_count with_changeset with_pr no_output <<< $(echo "$sessions" | jq -r '
    [
      (.sessions | length),
      ([.sessions[] | select(.state == "COMPLETED")] | length),
      ([.sessions[] | select(.state == "AWAITING_USER_FEEDBACK")] | length),
      ([.sessions[] | select(.state == "ACTIVE" or .state == "IN_PROGRESS")] | length),
      ([.sessions[] | select(.title | test("^Bolt|^⚡ Bolt"))] | length),
      ([.sessions[] | select(.title | test("^Palette"))] | length),
      ([.sessions[] | select(.title | test("^Bolt|^⚡ Bolt|^Palette") | not)] | length),
      ([.sessions[] | select(.outputs != null) | select(.outputs[]? | has("changeSet"))] | length),
      ([.sessions[] | select(.outputs != null) | select(.outputs[]? | has("pullRequest"))] | length),
      ([.sessions[] | select(.outputs == null or (.outputs | length) == 0)] | length)
    ] | @tsv
  ')

  pass "Fetched $total sessions: $completed completed, $awaiting awaiting feedback, $active active"

  echo ""
  echo "  [Agent Detection]"
  # Test agent title pattern matching
  pass "Detected agents: Bolt=$bolt_count, Palette=$palette_count, one-off=$oneoff_count"

  echo ""
  echo "  [Output Analysis]"
  # Check how many sessions have changeSets vs pullRequests
  pass "Outputs: $with_changeset with changeSet, $with_pr with pullRequest, $no_output with no output"

  echo ""
  echo "  [Triage Scoring - Dry Run]"
  # Pick a completed session with a changeSet and simulate scoring
  candidate=$(echo "$sessions" | jq '[.sessions[] | select(.state == "COMPLETED" and .outputs != null and (.outputs | length) > 0)][0] // empty')

  if [ -n "$candidate" ] && [ "$candidate" != "null" ]; then
    c_title=$(echo "$candidate" | jq -r '.title')
    c_id=$(echo "$candidate" | jq -r '.id')
    c_source=$(echo "$candidate" | jq -r '.sourceContext.source')
    echo "  Scoring session: $c_title"
    echo "  Source: $c_source"

    # Simulate scoring factors
    score=0

    # Factor: has output (proxy for tests pass) → 0.30
    has_output=$(echo "$candidate" | jq 'if .outputs and (.outputs | length) > 0 then 1 else 0 end')
    if [ "$has_output" = "1" ]; then
      score=$(echo "$score + 30" | bc)
      pass "  Tests/output: +0.30 (has changeSet)"
    fi

    # Factor: scope check
    patch=$(echo "$candidate" | jq -r '.outputs[0].changeSet.gitPatch.unidiffPatch // ""')
    if [ -n "$patch" ]; then
      files_changed=$(echo "$patch" | grep -c "^diff --git" || true)
      if [ "$files_changed" -le 50 ]; then
        score=$(echo "$score + 20" | bc)
        pass "  Scope: +0.20 ($files_changed files, within limit)"
      else
        fail "  Scope: +0.00 ($files_changed files, exceeds limit)"
      fi
    fi

    # Factor: agent match → 0.15
    if echo "$c_title" | grep -qiE "^(Bolt|Palette)"; then
      score=$(echo "$score + 15" | bc)
      pass "  Agent match: +0.15 (known agent)"
    else
      score=$(echo "$score + 8" | bc)
      pass "  Agent match: +0.08 (one-off session)"
    fi

    # Factor: clear intent → 0.15 (has a title)
    if [ ${#c_title} -gt 10 ]; then
      score=$(echo "$score + 15" | bc)
      pass "  Intent clarity: +0.15 (descriptive title)"
    fi

    # Factor: no errors → 0.10 (completed = no errors)
    score=$(echo "$score + 10" | bc)
    pass "  No errors: +0.10 (state=COMPLETED)"

    # Factor: plan approval → 0.10
    score=$(echo "$score + 7" | bc)
    pass "  Plan approval: +0.07 (auto-approved)"

    final_score=$(echo "scale=2; $score / 100" | bc)
    pass "  FINAL SCORE: $final_score (threshold: 0.70)"

    if [ "$(echo "$score >= 70" | bc)" = "1" ]; then
      pass "  DECISION: Would promote to PR ✓"
    else
      echo "  ⚠ DECISION: Below threshold, would include in digest for review"
    fi
  else
    echo "  ⚠ No completed sessions with outputs to score"
  fi

  echo ""
  echo "  [Question Detection - AWAITING_USER_FEEDBACK]"
  awaiting_session=$(echo "$sessions" | jq -r '[.sessions[] | select(.state == "AWAITING_USER_FEEDBACK")][0].id // empty')
  if [ -n "$awaiting_session" ]; then
    activities=$(curl -s \
      "https://jules.googleapis.com/v1alpha/sessions/$awaiting_session/activities?pageSize=50" \
      -H "X-Goog-Api-Key: $JULES_API_KEY")

    last_message=$(echo "$activities" | jq -r '[.activities[] | select(.agentMessaged != null)] | last | .agentMessaged.agentMessage // empty')

    if [ -n "$last_message" ]; then
      # Classify: simple confirmation vs substantive question
      if echo "$last_message" | grep -qiE "(satisfied|finalize|proceed|confirm.*good)"; then
        pass "Detected simple confirmation question (auto-respondable)"
      else
        pass "Detected substantive question (requires codebase analysis)"
      fi
      # Show first 100 chars of the question
      preview=$(echo "$last_message" | head -c 100)
      echo "    Preview: \"$preview...\""
    else
      echo "  ⚠ Could not extract agent message from awaiting session"
    fi
  else
    echo "  ⚠ No AWAITING_USER_FEEDBACK sessions to test"
  fi
}

# ─────────────────────────────────────────────────────────────────────────────
# Run requested tier(s)
# ─────────────────────────────────────────────────────────────────────────────
echo "╔═══════════════════════════════════════════════╗"
echo "║  agentic-skills test suite                    ║"
echo "╚═══════════════════════════════════════════════╝"

case "$TIER" in
  structural) run_structural ;;
  fixtures)   run_fixtures ;;
  api)        run_api ;;
  pipeline)   run_pipeline ;;
  all)
    run_structural
    run_fixtures
    run_api
    run_pipeline
    ;;
  *)
    echo "Unknown tier: $TIER"
    echo "Usage: $0 [structural|fixtures|api|pipeline|all]"
    exit 1
    ;;
esac

# ─────────────────────────────────────────────────────────────────────────────
# Summary
# ─────────────────────────────────────────────────────────────────────────────
echo ""
echo "═══════════════════════════════════════════════"
echo "  Results: $PASS passed, $FAIL failed"
echo "═══════════════════════════════════════════════"

if [ ${#ERRORS[@]} -gt 0 ]; then
  echo ""
  echo "  Failures:"
  for err in "${ERRORS[@]}"; do
    echo "    ✗ $err"
  done
  echo ""
  exit 1
fi

echo ""
echo "  All tests passed ✓"
exit 0
