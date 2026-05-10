# Review Tool Signals

Use this reference when `pr-care` needs to interpret review automation.

## Detection

| Tool | Common Signal | Default Handling |
| --- | --- | --- |
| CodeRabbit | Status context, check run, comments from `coderabbitai` | Collect output; do not re-trigger on bot/dependency PRs unless approved. |
| Codex | Workflow or comments containing Codex review output | Collect findings and check logs; avoid duplicate invocation. |
| Jules | Jules PR body, branch names, session links, comments | Preserve Jules session context and category. |
| Gemini Code Assist | App comments or `/gemini` output | Collect findings; do not invoke without approval. |
| Qodo PR-Agent | `.github/workflows/*pr-agent*` or bot comments | Treat as optional reviewer; avoid duplicate summaries. |
| Graphite | Graphite app status/review metadata | Use as review signal, not source of truth alone. |
| Reviewdog | Check annotations and linter comments | Treat as high-confidence static analysis when line/rule is clear. |

## Finding Normalization

```text
Finding {
  id
  source
  severity
  category
  file
  line_start
  line_end
  description
  suggested_fix
  comment_url
  raw_data
}
```

Severity values: `critical`, `high`, `medium`, `low`, `info`.

Categories: `security`, `correctness`, `reliability`, `data_integrity`,
`performance`, `test`, `maintainability`, `style`, `docs`, `dependency`.

## Triage Rules

For every finding:

1. Read the relevant code in context.
2. Decide if the finding is accurate.
3. Decide if it applies to this codebase and this PR scope.
4. Decide apply, skip, or defer.
5. Verify with tests/builds when practical.

Prefer applying fixes that are:

- clearly correct
- local to the PR scope
- covered by tests or easy to verify
- high impact or high confidence

Prefer deferring fixes that:

- require broad refactors
- change public API behavior
- need product/security owner input
- belong in a follow-up issue

## Bot and Dependency PRs

Before triggering reviewers or posting comments, identify bot authors such as
`dependabot[bot]`, `renovate[bot]`, GitHub Actions, or another app. If a
reviewer skipped the PR because it is bot-authored, record the skip as a tool
status. Do not override it without explicit approval or config opt-in.

For dependency PRs, prioritize:

- lockfile consistency
- package manager engine compatibility
- security advisories
- release-note breaking changes
- CI status
