## 2024-05-24 - Bash Scripting Performance Pattern: Batching jq Calls

**Learning:** When writing bash scripts that repeatedly query the same JSON file or string, running `jq` multiple times incurs significant subshell and execution overhead. In `tests/run_all.sh`, multiple sequential calls to `jq` for session classification and output analysis slowed down the test suite unnecessarily.

**Action:** Consolidate multiple `jq` queries into a single call by constructing an array of results, piping it to `@tsv`, and reading the values simultaneously using `IFS=$'\t' read -r var1 var2 ...`. Use the `?` operator (e.g., `.sessions[]?`) safely to handle potential null arrays.
