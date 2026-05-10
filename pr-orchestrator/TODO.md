# PR Orchestrator — TODO

## Phase 1: Validation & Testing

- [ ] **Test on a real PR** — Pick a repo with CodeRabbit or Gemini Code Assist already installed. Run the skill against an open PR to validate detection, invocation, collection, and triage phases end-to-end. Start with a small PR (< 50 changed lines) to keep the feedback loop tight.
- [ ] **Test cross-platform invocation** — Verify the skill works from Claude Code, Cursor, Codex CLI, and Gemini. Confirm the adaptive GitHub layer (MCP → `gh` → API) selects the right tier in each environment.
- [ ] **Test the self-review loop guard** — Intentionally trigger a cycle where the orchestrator pushes a fix and CodeRabbit/Gemini auto-reviews it. Confirm the commit-author filter prevents infinite loops and the `max_iterations` cap holds.
- [ ] **Test autonomy modes** — Run the skill with each autonomy setting (`full`, `approve-high-risk`, `approve-all`) and verify the behavior matches the spec.

## Phase 2: Eval Suite & Benchmarking

- [ ] **Build eval cases using skill-creator** — Create 5-8 test prompts covering: single-tool repo, multi-tool repo, PR with no findings, PR with conflicting findings across tools, PR that touches compliance-sensitive code, and a large PR that tests cost budget enforcement.
- [ ] **Benchmark triage accuracy** — Measure precision/recall of the triage phase against a manually-labeled set of findings. Target: >85% agreement with human triage decisions.
- [ ] **Benchmark cost savings** — Compare Actions minutes used with vs. without the skill's batching and cost-aware strategies on the same set of PRs.

## Phase 3: GitHub Action Wrapper

- [ ] **Create `.github/workflows/pr-orchestrator.yml`** — A GitHub Action that triggers on `pull_request` events (opened, synchronize, reopened) and invokes the skill. Should support configuring which AI coding agent runs it (Claude Code, Codex CLI, etc.).
- [ ] **Add webhook-based monitoring** — For monitor mode, create an optional webhook receiver that can be deployed as a lightweight service (e.g., Cloudflare Worker, Vercel Edge Function) to trigger the skill on PR events without polling.
- [ ] **Label-based trigger** — Support triggering the skill by adding a label (e.g., `orchestrate-review`) to a PR, for teams that want manual control.

## Phase 4: Learning System Bootstrap

- [ ] **Seed initial tool profiles** — Based on published data (CodeRabbit precision studies, Codex review benchmarks, etc.), create starter profiles so the learning system has reasonable priors before accumulating real data.
- [ ] **Build a learning data viewer** — A simple HTML dashboard that visualizes tool precision by category, false positive trends over time, and cost per PR. Could be an artifact or a standalone file.
- [ ] **Implement learning data export** — Support exporting learning data as CSV for teams that want to analyze it in their own tools.

## Phase 5: Skill Polish & Optimization

- [ ] **Description optimization** — Run the skill-creator's `run_loop.py` description optimizer to fine-tune triggering accuracy across edge cases.
- [ ] **Add more review tools** — Extend `references/review-tools.md` with: Amazon CodeGuru, Sourcery, Sweep, Ellipsis, Bito, and any new entrants. Follow the "Adding a New Tool" template.
- [ ] **Config generator** — Add a guided setup mode where the skill inspects a repo and generates a starter `.pr-orchestrator.yml` with sensible defaults based on what's detected.
- [ ] **Reduce SKILL.md token footprint** — Profile how many tokens SKILL.md consumes and look for sections that can be moved to references without hurting usability. Target: < 400 lines for the core file.

## Phase 6: Advanced Features

- [ ] **Multi-PR coordination** — When multiple PRs are open on the same repo, detect conflicts between them and flag in the report (e.g., "PR #42 and PR #45 both modify `auth/handler.ts`").
- [ ] **Review policy engine** — A rule DSL in config that lets teams express policies like "security findings on `src/auth/**` must always be approved by a human" or "style findings from Jules are auto-skipped."
- [ ] **Slack/Teams notifications** — Optional integration to post review summaries to a channel when a PR review cycle completes.
- [ ] **PR merge readiness score** — Compute a 0-100 score based on: findings addressed, test pass rate, compliance status, and human approvals. Surface it as a GitHub status check.
- [ ] **Differential cost reporting** — Show how much the skill saved compared to running all tools naively (no batching, no skipping, no cost-aware ordering).

## Ideas & Research

- [ ] **Consensus threshold tuning** — Research optimal thresholds for consensus scoring. Is 2/3 tools agreeing always the right bar, or should it vary by severity?
- [ ] **Fine-tuned triage model** — Explore whether the learning data could train a lightweight classifier to pre-filter findings before full LLM triage, reducing cost.
- [ ] **Community skill marketplace** — If this skill proves valuable, consider publishing it to the Claude plugin/skill marketplace for others to install and contribute to.
