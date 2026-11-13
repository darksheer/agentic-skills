## 2024-05-30 - Replace bc with native bash math in test suite
**Learning:** The bash test suite (`tests/run_all.sh`) was repeatedly spawning the external `bc` tool for simple integer arithmetic (`score=$(echo "$score + X" | bc)`), which introduces significant subshell and process overhead in loops. Furthermore, `bc` may not be installed in all test execution environments, causing silent failures.
**Action:** Replace `bc` with native bash integer math (`$(( ))`) for additions, and use `awk` for floating point division (e.g., `awk "BEGIN {printf \"%.2f\", $score / 100}"`). Also, update conditional checks to use bash integer comparisons (`-ge`) instead of string equality checks on `bc` output.

## 2024-10-29 - Batch jq calls for JSON parsing in bash
**Learning:** In the bash test suite (`tests/run_all.sh`), multiple independent `jq` calls were used sequentially on the same file (`sessions-page.json`) to extract counts for `completed`, `awaiting`, `active`, `failed_sessions`, `with_changeset`, `with_pr`, and `no_output`. Spawning a new `jq` process for each extraction creates noticeable overhead.
**Action:** When extracting multiple values from the same JSON source in bash, batch the queries into a single `jq` array and output them as a TSV. Read them into variables simultaneously using `IFS=$'\t' read -r var1 var2 <<< "$(jq -r '[...] | @tsv' file.json)"`.

## 2024-11-23 - Batch jq queries checking JSON key presence in bash loops
**Learning:** In the bash test suite (`tests/run_all.sh`), a `jq -e` query was being run repeatedly in a bash loop for different fields. Spawning a new `jq` process for each extraction creates noticeable overhead.
**Action:** To optimize checking for JSON key presence in bash loops, avoid spawning repeated `jq` processes. Instead, use a single `jq` call to extract unique keys into a space-separated string (e.g., `jq -r '[... | keys[]] | unique | join(" ")'`) and use native bash wildcard matching (e.g., `[[ " $keys " == *" $val "* ]]`).

## 2024-11-23 - Replicate jq -e behavior when batching field checks in bash
**Learning:** When checking if specific JSON fields exist in bash using `jq -e '.field'`, the `jq -e` command explicitly fails if the field resolves to `null` or `false`. If you optimize the bash script by batching key extraction into a string (e.g., using `jq -r '[keys[]] | join(" ")'`) to avoid process spawning overhead, simple key matching (e.g., `[[ " $keys " == *" $field "* ]]`) might incorrectly pass if the field exists but its value is `null` or `false`.
**Action:** To maintain logical equivalence with `jq -e` when batching key extraction, filter out `null` and `false` values first: `jq -r '[to_entries[]? | select(.value != null and .value != false) | .key] | unique | join(" ")'`.
