# Goal: Marketplace-Ready Agentic Skills Distribution

## Objective

Use the Claude Code plugin tree as the single source of truth for public skills,
while keeping Codex installation pointed at the same GitHub skill directories.

## Public Skills

- `jules-wrangler`: canonical Jules session triage and PR promotion skill.
- `github-babysitter`: canonical repo-rounds and pr-care skill.

Legacy aliases are documented for migration only:

- `jules-triage` -> `jules-wrangler`
- `pr-orchestrator` -> `github-babysitter` `pr-care`
- `github_pro_babysitter` -> `github-babysitter` `repo-rounds`

## Canonical Layout

```text
.claude-plugin/marketplace.json
plugins/agentic-skills/.claude-plugin/plugin.json
plugins/agentic-skills/skills/jules-wrangler/SKILL.md
plugins/agentic-skills/skills/jules-wrangler/references/
plugins/agentic-skills/skills/github-babysitter/SKILL.md
plugins/agentic-skills/skills/github-babysitter/references/
```

Top-level public skill folders must not duplicate canonical `SKILL.md` files.
Legacy folders can remain only as migration/support docs outside marketplace
install instructions.

## Install Workflows

Claude Code:

```text
/plugin marketplace add darksheer/agentic-skills
/plugin install agentic-skills@agentic-skills
/plugin marketplace update
```

Codex:

```text
$skill-installer install https://github.com/darksheer/agentic-skills/tree/main/plugins/agentic-skills/skills/jules-wrangler
$skill-installer install https://github.com/darksheer/agentic-skills/tree/main/plugins/agentic-skills/skills/github-babysitter
```

Restart Codex after install or update.

## Validation

```bash
./tests/run_all.sh structural
./tests/run_all.sh fixtures
```

`structural` validates plugin/marketplace manifests, canonical skill
frontmatter, reference links, and absence of duplicate top-level canonical skill
files. `fixtures` validates Jules classification and handoff payload shape.

Generated reports under `tests/results/` are not installable documentation.
