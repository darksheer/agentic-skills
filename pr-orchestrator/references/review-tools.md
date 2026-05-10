# Review Tool Integration Reference

This document covers detection, invocation, output parsing, and interaction for each supported code review tool. Read the section for the tool you need — don't load the whole file.

## Table of Contents
1. [CodeRabbit](#coderabbit)
2. [OpenAI Codex](#openai-codex)
3. [Google Jules](#google-jules)
4. [Gemini Code Assist](#gemini-code-assist)
5. [Qodo PR-Agent](#qodo-pr-agent)
6. [Graphite Agent](#graphite-agent)
7. [Reviewdog](#reviewdog)
8. [Adding a New Tool](#adding-a-new-tool)

---

## CodeRabbit

### Detection
- **Config file**: `.coderabbit.yaml` in repo root
- **GitHub App**: Check via `gh api /repos/{owner}/{repo}/installations` — look for app named "CodeRabbit" or "coderabbitai"
- **CLI**: Run `coderabbit --version` to check if CLI is installed locally

### Invocation

**Auto-review (default)**: CodeRabbit auto-reviews every PR on open if the GitHub App is installed. No action needed — just wait for it to post.

If CodeRabbit posts a skip status such as "Bot user detected," treat the tool as
`skipped` with a reason. Do not post `@coderabbitai review` automatically for
that PR unless the user explicitly requested an override or config allows
bot-authored PR review triggers.

**On-demand via PR comment**:
```
@coderabbitai review
```
Other useful commands:
```
@coderabbitai full review      # Force a full re-review (not incremental)
@coderabbitai resolve           # Mark all conversations as resolved
@coderabbitai configuration     # Show current config
```

**Via CLI** (works inside Claude Code, Codex CLI, Cursor):
```bash
# Review staged changes
coderabbit review

# Review a specific PR
coderabbit review --pr <number> --repo <owner/repo>
```

The CLI returns structured JSON output, making it ideal for programmatic consumption. Findings are ordered by severity.

### Output Format
CodeRabbit posts two types of comments:
1. **Summary comment** (issue comment): A walkthrough of all changes with a table of findings
2. **Inline comments** (review comments): Specific findings on individual lines

To collect findings, parse both:
- Summary: `GET /repos/{owner}/{repo}/issues/{pr}/comments` — find comment by author `coderabbitai[bot]`
- Inline: `GET /repos/{owner}/{repo}/pulls/{pr}/comments` — filter by user `coderabbitai[bot]`

### Incremental Review
CodeRabbit automatically reviews new commits incrementally. After pushing fixes, it will post a new review covering only the changes since its last review. No need to re-invoke.

### Configuration
Key `.coderabbit.yaml` settings relevant to orchestration:
```yaml
reviews:
  auto_review:
    enabled: true        # Set to false if you want manual trigger only
  path_filters:
    - "!**/*.test.ts"    # Exclude test files from review
  tools:
    ast_grep: true
    ruff: true
    eslint: true
```

---

## OpenAI Codex

### Detection
- **GitHub App**: Check installations for "Codex" or "openai-codex"
- **GitHub Action**: Search `.github/workflows/` for references to `openai/codex-action@v1`
- **CLI**: Run `codex --version` to check if Codex CLI is installed

### Invocation

**Via PR comment** (requires GitHub App):
```
@codex review
@codex review for security     # Focused review
@codex review for performance  # Focused review
```

**Via GitHub Action** (add to workflow):
```yaml
- uses: openai/codex-action@v1
  with:
    openai_api_key: ${{ secrets.OPENAI_API_KEY }}
    mode: review
```

**Via CLI** (inside a coding agent session):
```bash
codex review --pr <number> --repo <owner/repo>
```

### Output Format
Codex posts a PR review with inline comments. It also validates that the PR diff matches the stated intent (title/description).

Collection:
- `GET /repos/{owner}/{repo}/pulls/{pr}/reviews` — find review by user `codex[bot]` or `openai-codex[bot]`
- `GET /repos/{owner}/{repo}/pulls/{pr}/comments` — for inline comments

### Incremental Review
Codex reviews the latest diff. After pushing fixes, post `@codex review` again to re-review.

### Key Capabilities
- **Intent matching**: Compares PR description to actual diff — flags discrepancies
- **Full codebase reasoning**: Reads the whole repo, not just the diff
- **Test execution**: Can run code/tests to validate behavior
- **Model**: Uses GPT-5-Codex (as of Sep 2025) via the Responses API

---

## Google Jules

### Detection
- **GitHub Action**: Search for `google-labs-code/jules-action` in workflows
- **API key**: Check for `JULES_API_KEY` in environment or secrets
- **App**: Check GitHub App installations for "Jules"

### Invocation

**Via GitHub Action**:
```yaml
- uses: google-labs-code/jules-action@v1
  with:
    api_key: ${{ secrets.JULES_API_KEY }}
    task: "Review this PR for security vulnerabilities and performance issues"
```

**Via API** (programmatic):
```bash
curl -X POST https://developers.google.com/jules/api/v1/tasks \
  -H "Authorization: Bearer $JULES_API_KEY" \
  -d '{
    "repo": "owner/repo",
    "pr_number": 42,
    "task_type": "review",
    "instructions": "Review for security and correctness"
  }'
```

**Via PR comment** (if App is installed):
```
@jules review this PR
```

### Output Format
Jules operates asynchronously — it creates a task, runs it in a cloud VM, and posts results. Results come as:
- PR comments with findings
- Sometimes as suggested changes (commit suggestions)

Collection: Poll the Jules API for task completion, or monitor PR comments for `jules[bot]` or `jules-agent[bot]`.

### Async Polling Strategy
Jules tasks run asynchronously in a cloud VM. Use this polling approach:
1. After submitting the task, wait 30 seconds before the first poll
2. Poll every 15 seconds for the first 5 minutes
3. After 5 minutes, poll every 60 seconds
4. Timeout after 15 minutes — if no response, mark Jules as "timed out" in the report
5. Maximum 30 poll attempts total

```bash
# Poll Jules API for task status
curl -s -H "Authorization: Bearer $JULES_API_KEY" \
  "https://developers.google.com/jules/api/v1/tasks/{task_id}" | jq '.status'
# Statuses: PENDING, RUNNING, COMPLETED, FAILED
```

Alternatively, skip API polling and monitor PR comments — Jules posts its findings as PR comments when done. Poll PR comments for new comments by `jules[bot]` or `jules-agent[bot]` using the same interval strategy above.

### Key Capabilities
- **Async execution**: Runs in a secure cloud VM with full build environment
- **Branch creation**: Can create fix branches directly
- **Gemini 2.5 Pro**: Backed by Google's most capable model
- **Scheduled tasks**: Can be set up for recurring security scans

---

## Gemini Code Assist

### Detection
- **GitHub App**: Check installations for "Gemini Code Assist" (GitHub Marketplace)
- **Auto-active**: If installed, it reviews all PRs automatically within ~5 minutes

### Invocation

**Auto-review**: Gemini Code Assist auto-reviews PRs when the GitHub App is installed. No action needed.

**On-demand via PR comment**:
```
/gemini review
/gemini summary         # Get a summary of changes
/gemini help            # List available commands
```

### Output Format
Posts a PR review with:
- A summary comment describing all changes
- Inline review comments with specific findings
- Severity labels on each finding

Collection:
- `GET /repos/{owner}/{repo}/pulls/{pr}/reviews` — find by user `gemini-code-assist[bot]`
- `GET /repos/{owner}/{repo}/pulls/{pr}/comments` — inline findings

### Incremental Review
Auto-reviews new pushes incrementally. Can also manually request re-review with `/gemini review`.

### Key Capabilities
- **MCP support**: Uses Model Context Protocol for tool integration (composable)
- **Speed**: Reviews typically complete in under 5 minutes
- **Gemini 2.5**: Backed by Google's Gemini 2.5 model

---

## Qodo PR-Agent

### Detection
- **GitHub Action**: Search for `qodo-ai/pr-agent` or `Codium-ai/pr-agent` in workflows
- **Docker**: Check for PR-Agent Docker references
- **Config**: Look for `.pr_agent.toml` in repo root

### Invocation

**Via GitHub Action**:
```yaml
- uses: qodo-ai/pr-agent@main
  env:
    OPENAI_KEY: ${{ secrets.OPENAI_KEY }}
  with:
    command: review
```

**Via PR comment**:
```
/review          # Full review
/improve         # Code suggestions
/describe        # Auto-describe the PR
/ask <question>  # Ask about the PR
```

### Output Format
Posts structured PR comments with tables of findings, categorized by type. Also supports inline suggestions.

### Key Capabilities
- **Open source**: Can be self-hosted, no vendor lock-in
- **Multi-model**: Supports Claude, GPT, and other models
- **Configurable prompts**: Highly customizable review focus

---

## Graphite Agent

### Detection
- **GitHub App**: Check for "Graphite" in installations
- **No config needed**: Zero-configuration once the App is installed

### Invocation
Graphite Agent auto-reviews PRs. No manual invocation needed. Reviews complete in under 90 seconds.

### Output Format
Reviews appear in the Graphite PR inbox (a GitHub-synced UI). Findings are also posted as PR review comments.

### Key Capabilities
- **Speed**: Sub-90-second reviews
- **Behavioral impact**: Changes developer behavior 55% of the time when flagging issues
- **No configuration**: Install and go

---

## Reviewdog

### Detection
- **Config**: `.reviewdog.yml` in repo root
- **GitHub Action**: Search for `reviewdog/reviewdog` in workflows

### Invocation
Reviewdog orchestrates linters, not AI reviewers. It's complementary — it handles static analysis while AI tools handle semantic review.

```yaml
# .reviewdog.yml
runner:
  eslint:
    cmd: npx eslint -f json .
    format: json
  ruff:
    cmd: ruff check --output-format=json .
    format: json
```

### Integration
If Reviewdog is configured, let it handle linting and focus the AI reviewers on higher-level concerns (architecture, logic, security). This avoids duplication — AI tools are expensive for catching lint errors that a linter catches instantly.

---

## Adding a New Tool

To support a new review tool, document these four things:

1. **Detection**: How to know if the tool is available (config files, App installations, CLI availability)
2. **Invocation**: How to trigger a review (comment command, API call, Action dispatch, CLI command)
3. **Collection**: How to gather findings (which API endpoints, comment author username, output format)
4. **Incremental support**: Whether the tool supports reviewing only new changes, or needs a full re-review

Add the documentation to this file following the same structure as existing tools. Update the detection table in SKILL.md.
