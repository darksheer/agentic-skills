# agentic-skills

A collection of cross-platform AI agent skills by [darksheer](https://github.com/darksheer). Each skill works across Claude Code, Cursor, Codex CLI, and Gemini — in GUI or CLI.

## Skills

| Skill | Description | Status |
|-------|-------------|--------|
| [pr-orchestrator](./pr-orchestrator/) | End-to-end GitHub PR review orchestration — auto-detects review tools (CodeRabbit, Codex, Jules, Gemini Code Assist), triages findings, applies fixes, re-verifies, and learns from outcomes. | In development |

## What Are Skills?

Skills are portable instruction sets that give AI coding agents specialized capabilities. A skill is a directory containing a `SKILL.md` file (the core instructions) and optional reference files, scripts, and assets. Skills can be installed in Claude Code, shared as `.skill` files, or loaded directly by any agent that reads markdown.

## Repo Structure

```
agentic-skills/
├── README.md
├── pr-orchestrator/        # GitHub PR review orchestration
│   ├── SKILL.md
│   ├── TODO.md
│   └── references/
├── <future-skill>/
│   ├── SKILL.md
│   └── ...
```

## Installation

### Claude Code / Cowork
Each skill directory can be packaged as a `.skill` file (a zip archive) and installed via the skill installer.

### Cursor / Codex CLI / Gemini
Point the agent at the `SKILL.md` file in the skill directory. The agent reads the instructions and follows them. Reference files are loaded on demand.

## Contributing

Skills should follow these conventions:
- Each skill lives in its own directory at the repo root
- `SKILL.md` is required and contains YAML frontmatter (`name`, `description`) plus markdown instructions
- Keep `SKILL.md` under 500 lines; use `references/` for detailed documentation
- Include a `TODO.md` for tracking development progress
- Skills must work across all four target platforms (Claude, Cursor, Codex, Gemini)

## License

Apache License 2.0 — see [LICENSE](./LICENSE) for details.
