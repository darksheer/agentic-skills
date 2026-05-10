# Approval Queue

Generated: 2026-05-10

No items in this queue were executed.

## Immediate Jules Responses

### `AQ-JULES-001`

- Action type: Jules `sendMessage`
- Target: session `2160838485772386426`
- Endpoint: `POST https://jules.googleapis.com/v1alpha/sessions/2160838485772386426:sendMessage`
- Body:

```json
{
  "prompt": "Yes, the relevant function is `packet_filename(proposal: Proposal, *, index: int)` in `src/acheron/proposal_render.py`; the `_proposal_filename` name in the prompt is stale.\n\nDo not change the filename behavior to derive from the `Proposal` object. `prop-XXXX.md` is an intentional placeholder for the current one-based, zero-padded ordinal filename (`prop-0001.md`, `prop-0002.md`, etc.). The index-based naming is documented as deterministic because YAML proposal order is deterministic, and call sites already pass `index`.\n\nTreat the issue as a false-positive wording cleanup around the `XXXX` placeholder, not as a behavior change. If you make a code-health change, update the wording to avoid the scanner looking like it found an XXX/TODO comment, for example by saying `prop-NNNN.md` or \"zero-padded proposal filename\" in both `src/acheron/proposal_render.py` and the matching user-facing help/doc text in `scripts/render_proposal.py`. Keep the implementation `return f\"prop-{index:04d}.md\"` unchanged unless tests prove otherwise."
}
```

- Expected effect: unblock Jules with a conservative, behavior-preserving instruction.
- Risk: low.
- Rollback/cleanup: send a follow-up correction in the same Jules session if needed.

### `AQ-JULES-002`

- Action type: Jules `sendMessage`
- Target: session `12860738400941854823`
- Endpoint: `POST https://jules.googleapis.com/v1alpha/sessions/12860738400941854823:sendMessage`
- Body:

```json
{
  "prompt": "Yes, remove the `before` parameter entirely. It is intentionally unused today (`_ = before`), and `_write_report` reconstructs `report_before` from `after`, so the call site should stop computing/passing `ledger_before` if nothing else uses it.\n\nUse a small frozen dataclass named `ReportContext` for the stable report-generation context: `queue`, `after` (or `ledger_after` if you prefer the clearer field name), `reports_dir`, `finished`, and `sweep_segment`.\n\nKeep `summary` and `missing_items` as explicit keyword-only arguments. They are the finalizer outcome data being appended to the report, so leaving them visible at the call site is clearer than hiding everything in one object.\n\nPlease avoid changing report behavior. This should be a narrow readability refactor: remove the dead `before` plumbing, add the context dataclass, update the call site, and keep the existing tests/behavior intact."
}
```

- Expected effect: unblock Jules with a specific refactor direction.
- Risk: medium-low.
- Rollback/cleanup: send a follow-up correction in the same Jules session if needed.

### `AQ-JULES-003`

- Action type: Jules `sendMessage`
- Target: session `12635365470001464326`
- Endpoint: `POST https://jules.googleapis.com/v1alpha/sessions/12635365470001464326:sendMessage`
- Body:

```json
{
  "prompt": "Please scrub the recommendations that are now obsolete in the live repo instead of presenting them as still missing.\n\nSpecifically, remove or reword recommendations for Husky/lint-staged, semantic-release/release automation, Dependabot/dependency automation, CONTRIBUTING.md, and CODE_OF_CONDUCT.md because those now exist in the current repo. Keep recommendations that are still about real follow-up work, such as additional AI/provider edge-case coverage, explicit contract-test visibility, and any remaining operator-visibility items.\n\nAlso add a short note that your review was produced from the sandbox snapshot at commit `4a76bd6`, so any live-repo drift after that commit was handled by the requested manual scrub rather than by a fresh fetch."
}
```

- Expected effect: allow the older arc-powerup review session to finish with stale recommendations scrubbed.
- Risk: low.
- Rollback/cleanup: no code rollback needed; PR `darksheer/arc-powerup#23` is already merged.

## Promotion Candidates Requiring Future Exact Approval

The following are promotion candidates, not executable approval items. No PR promotion write action is proposed for execution from this queue. Before any one of these can run, a new exact approval item must be generated for the selected session with the concrete clone/fetch path, patch source, branch creation command, patch application command, commit command, push command, `gh pr create` command, PR body, expected effect, and cleanup plan.

| Candidate ID | Session | Repo | Planned Branch | Planned PR Title | Risk |
| --- | --- | --- | --- | --- | --- |
| `AQ-PR-001` | `4035542174610639825` | `darksheer/ARC` | `jules/403554217461/code-cleanup` | `Actionable TODO comment` | medium |
| `AQ-PR-002` | `16315304976651849941` | `darksheer/ARC` | `jules/163153049766/performance` | `N+1 Query when updating Trigger properties` | medium |
| `AQ-PR-003` | `6130824672536530235` | `darksheer/arc-powerup` | `jules/613082467253/code-cleanup` | `Deprecated ValidateArtifactError usage` | medium |
| `AQ-PR-004` | `284973532787307505` | `darksheer/ARC` | `jules/284973532787/security` | `Exposure of ywebsocket port to all interfaces` | high |
| `AQ-PR-005` | `1673735256423943114` | `darksheer/arc-powerup` | `jules/167373525642/security` | `Storm Command Injection via Unescaped Secret Values` | high |
| `AQ-PR-006` | `2073375311782157680` | `darksheer/arc-powerup` | `jules/207337531178/test-coverage` | `Missing test for buildSummary` | medium |
| `AQ-PR-007` | `17640577610687912753` | `darksheer/Acheron` | `jules/176405776106/security` | `Use of unsafe yaml.load` | high |
| `AQ-PR-008` | `3652893734403742411` | `darksheer/Acheron` | `jules/365289373440/refactor` | `Refactor hand-rolled dict validation to use Pydantic v2 schemas` | medium |
| `AQ-PR-009` | `9473316654259999272` | `darksheer/Acheron` | `jules/947331665425/code-cleanup` | `Remove unused parameter before in _write_report` | medium |
| `AQ-PR-010` | `8099504476686591502` | `darksheer/Acheron` | `jules/809950447668/performance` | `Sorting dictionary items in a search loop` | medium |
| `AQ-PR-011` | `1162757910267906627` | `darksheer/ft3` | `jules/116275791026/test-coverage` | `Missing test file for generate_navigator_layer.py` | medium |
| `AQ-PR-012` | `16812050763961344498` | `darksheer/ft3` | `jules/168120507639/code-cleanup` | `Leftover console.log` | medium |
| `AQ-PR-013` | `14574538458682804498` | `darksheer/ft3` | `jules/145745384586/code-cleanup` | `Remove debugging print statement` | medium |
| `AQ-PR-014` | `10537041771509833862` | `darksheer/ft3` | `jules/105370417715/test-coverage` | `Missing error test in validate_unique_ids` | medium |

Default rollback/cleanup for a future approved PR promotion:

1. Delete the created remote branch if the PR should be abandoned.
2. Close the created PR with a note that it was a Jules triage promotion candidate rejected after review.
3. Do not merge without a separate explicit approval.
