# Agentic Skills — Codex Guide

## Repository Structure

```text
agentic_skills/
├── .env                         # API keys (JULES_API_KEY, etc.)
├── .claude-plugin/
│   └── marketplace.json         # Claude Code marketplace manifest
├── plugins/
│   └── agentic-skills/
│       ├── .claude-plugin/
│       │   └── plugin.json      # Claude Code plugin manifest
│       └── skills/
│           ├── jules-wrangler/
│           │   ├── SKILL.md
│           │   ├── TODO.md
│           │   └── references/
│           │       ├── jules-api.md
│           │       ├── config-schema.md
│           │       ├── triage-scoring.md
│           │       ├── promotion-workflow.md
│           │       └── digest-template.md
│           └── github-babysitter/
│               ├── SKILL.md
│               └── references/
├── tests/
│   ├── fixtures/
│   └── run_all.sh
├── pr-orchestrator/             # legacy alias docs/work, not public plugin skill
└── github_pro_babysitter/       # legacy alias docs/work, not public plugin skill
```

The Claude Code plugin tree under `plugins/agentic-skills/skills/` is the
canonical source for public skills. Do not add duplicate top-level public
`SKILL.md` folders for `jules-wrangler` or `github-babysitter`.

## Running Tests

```bash
# Recommended local checks for marketplace-ready changes
./tests/run_all.sh structural
./tests/run_all.sh fixtures

# Full suite, including live Jules API checks
./tests/run_all.sh

# Individual live tiers
./tests/run_all.sh api
./tests/run_all.sh pipeline
```

### Prerequisites

- `jq` must be installed
- `.env` file at repo root with `JULES_API_KEY` set for `api` and `pipeline`
- Bash 4+ for arrays

### What Each Tier Tests

**Tier 1 — Structural Validation**:
- `.claude-plugin/marketplace.json` parses as JSON
- `plugins/agentic-skills/.claude-plugin/plugin.json` parses as JSON
- Marketplace source path exists
- `jules-wrangler` and `github-babysitter` contain `SKILL.md`
- Canonical `SKILL.md` files have YAML frontmatter, `name`, and `description`
- Referenced `references/*.md` files exist
- Top-level duplicate canonical skill files do not exist

**Tier 2 — Fixture-Backed Jules Validation**:
- Jules session fixtures parse and classify by state
- Output detection distinguishes `changeSet` and `pullRequest`
- Pull request URLs and source repos parse correctly
- Feedback questions classify as simple or substantive
- Handoff payload uses `target_skill: github-babysitter` and `mode: pr-care`

**Tier 3 — API Contract Tests**:
- Authentication works with `JULES_API_KEY`
- Session, source, and activity response shapes match `references/jules-api.md`
- Session states are known values

**Tier 4 — Dry-Run Pipeline**:
- Fetches real sessions and classifies by state
- Detects named agents such as Bolt and Palette by title pattern
- Analyzes output types
- Simulates triage scoring on a completed session
- Tests question detection on `AWAITING_USER_FEEDBACK` sessions

## Skill Design Conventions

- Public shipped skills live under `plugins/agentic-skills/skills/<name>/`.
- `SKILL.md` starts with YAML frontmatter containing at least `name` and
  `description`.
- Keep `SKILL.md` under 500 lines; use `references/` for detailed docs.
- `jules-wrangler` reads `.jules-wrangler.yml` and only falls back to legacy
  `.jules-triage.yml` for migration.
- `github-babysitter` is the merged public skill for repo-rounds and pr-care.
- `pr-orchestrator` and `github_pro_babysitter` are legacy aliases, not public
  plugin skills.

## Making Changes

1. Run `./tests/run_all.sh structural`.
2. Run `./tests/run_all.sh fixtures` for Jules classification or handoff changes.
3. If API behavior changed, run `./tests/run_all.sh api`.
4. Update `plugins/agentic-skills/skills/jules-wrangler/references/jules-api.md`
   if you discover Jules API shape changes.
5. Do not include generated `tests/results/` artifacts as installable docs.
