# PR-Orchestrator Handoff Plan

Generated: 2026-05-10

Mode: read-only. No PR comments, labels, reviewer triggers, branch writes, or workflow actions were performed.

## Existing PRs

| Session | PR | State | Mergeable | Checks | Handoff Plan |
| --- | --- | --- | --- | --- | --- |
| `1797105403575837045` | `darksheer/synapse#1` | `OPEN` | `MERGEABLE` | none reported | Candidate for read-only `pr-orchestrator` review planning. Do not comment without approval. |
| `5082637263190122120` | `darksheer/ARC#158` | `CLOSED` | `MERGEABLE` | `verify` success | No active handoff. Keep as historical record. |
| `2235897627242375417` | `darksheer/ARC#159` | `MERGED` | `UNKNOWN` | `verify`, `verify-contract` success | No active handoff. Already merged. |
| `12635365470001464326` | `darksheer/arc-powerup#23` | `MERGED` | `UNKNOWN` | all reported checks success | No active handoff. Waiting Jules session can be closed with a response if desired. |

## ChangeSet-Only Promotion Plan

These sessions have patches but no PR. They are not executed. If approved, each needs patch review, a real target branch, branch creation, patch application, commit, push, and `gh pr create`.

| Session | Repo | Base Branch | Suggested Branch | PR Title |
| --- | --- | --- | --- | --- |
| `4035542174610639825` | `darksheer/ARC` | `main` | `jules/403554217461/code-cleanup` | `Actionable TODO comment` |
| `16315304976651849941` | `darksheer/ARC` | `main` | `jules/163153049766/performance` | `N+1 Query when updating Trigger properties` |
| `6130824672536530235` | `darksheer/arc-powerup` | `main` | `jules/613082467253/code-cleanup` | `Deprecated ValidateArtifactError usage` |
| `284973532787307505` | `darksheer/ARC` | `main` | `jules/284973532787/security` | `Exposure of ywebsocket port to all interfaces` |
| `1673735256423943114` | `darksheer/arc-powerup` | `main` | `jules/167373525642/security` | `Storm Command Injection via Unescaped Secret Values` |
| `2073375311782157680` | `darksheer/arc-powerup` | `main` | `jules/207337531178/test-coverage` | `Missing test for buildSummary` |
| `17640577610687912753` | `darksheer/Acheron` | `main` | `jules/176405776106/security` | `Use of unsafe yaml.load` |
| `3652893734403742411` | `darksheer/Acheron` | `main` | `jules/365289373440/refactor` | `Refactor hand-rolled dict validation to use Pydantic v2 schemas` |
| `9473316654259999272` | `darksheer/Acheron` | `main` | `jules/947331665425/code-cleanup` | `Remove unused parameter before in _write_report` |
| `8099504476686591502` | `darksheer/Acheron` | `main` | `jules/809950447668/performance` | `Sorting dictionary items in a search loop` |
| `1162757910267906627` | `darksheer/ft3` | `master` | `jules/116275791026/test-coverage` | `Missing test file for generate_navigator_layer.py` |
| `16812050763961344498` | `darksheer/ft3` | `master` | `jules/168120507639/code-cleanup` | `Leftover console.log` |
| `14574538458682804498` | `darksheer/ft3` | `master` | `jules/145745384586/code-cleanup` | `Remove debugging print statement` |
| `10537041771509833862` | `darksheer/ft3` | `master` | `jules/105370417715/test-coverage` | `Missing error test in validate_unique_ids` |

## Deferred

| Session | Reason |
| --- | --- |
| `2191246595792064854` | Completed with no `changeSet` or PR output. |
| `2516158439401097538` | Completed with no `changeSet` or PR output. |
