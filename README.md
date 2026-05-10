# agentic-skills

Claude Code plugin and Codex-installable skills for agentic coding workflows.

The Claude Code plugin tree is the source of truth. Codex installs the same
skill directories directly from GitHub paths.

## Public Skills

| Skill | Purpose |
| --- | --- |
| `jules-wrangler` | Triage Google Jules sessions, promote approved work to GitHub PRs, and hand PRs to GitHub Babysitter. |
| `github-babysitter` | Run repo-wide health rounds and focused PR care for reviews, CI, and merge readiness. |

Legacy names are migration aliases only:

- `jules-triage` is replaced by `jules-wrangler`.
- `pr-orchestrator` and `github_pro_babysitter` are replaced by `github-babysitter`.

## Repository Layout

```text
agentic-skills/
├── .claude-plugin/
│   └── marketplace.json
├── plugins/
│   └── agentic-skills/
│       ├── .claude-plugin/
│       │   └── plugin.json
│       └── skills/
│           ├── jules-wrangler/
│           │   ├── SKILL.md
│           │   ├── TODO.md
│           │   └── references/
│           └── github-babysitter/
│               ├── SKILL.md
│               └── references/
├── tests/
│   ├── fixtures/
│   └── run_all.sh
├── pr-orchestrator/        # legacy, not shipped in the marketplace plugin
└── github_pro_babysitter/  # legacy, not shipped in the marketplace plugin
```

Generated validation reports under `tests/results/` are not installable skill
documentation.

## Claude Code Install

Add the marketplace:

```text
/plugin marketplace add darksheer/agentic-skills
```

Install the plugin:

```text
/plugin install agentic-skills@agentic-skills
```

Update later:

```text
/plugin marketplace update
```

For local development, run Claude Code against the plugin directory:

```bash
claude --plugin-dir ./plugins/agentic-skills
```

## Codex Install

Install each public skill directly from its GitHub path:

```text
$skill-installer install https://github.com/darksheer/agentic-skills/tree/main/plugins/agentic-skills/skills/jules-wrangler
$skill-installer install https://github.com/darksheer/agentic-skills/tree/main/plugins/agentic-skills/skills/github-babysitter
```

Restart Codex after installing or updating skills.

## Configuration

`jules-wrangler` reads `.jules-wrangler.yml`. During migration it also falls
back to `.jules-triage.yml` when the new config file is absent.

`github-babysitter` reads `.github-babysitter.yml`. It understands legacy
`.pr-orchestrator.yml` and `.github-pro-babysitter.yml` configs for migration,
but new work should use `.github-babysitter.yml`.

## Tests

```bash
./tests/run_all.sh structural
./tests/run_all.sh fixtures
```

`structural` validates plugin and marketplace manifests, canonical skill
frontmatter, and referenced docs. `fixtures` validates Jules session
classification and the Jules-to-GitHub-Babysitter handoff payload.

Live Jules API tiers still exist for contract and dry-run checks:

```bash
./tests/run_all.sh api
./tests/run_all.sh pipeline
```

Those require `JULES_API_KEY` in the environment or repo-root `.env`.

## Release Notes

The plugin and marketplace are both versioned `0.1.0`. Bump
`plugins/agentic-skills/.claude-plugin/plugin.json` and
`.claude-plugin/marketplace.json` together for released updates.

## License

Apache License 2.0. See [LICENSE](./LICENSE).
