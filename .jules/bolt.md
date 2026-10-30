## 2024-05-30 - Replace bc with native bash math in test suite
**Learning:** The bash test suite (`tests/run_all.sh`) was repeatedly spawning the external `bc` tool for simple integer arithmetic (`score=$(echo "$score + X" | bc)`), which introduces significant subshell and process overhead in loops. Furthermore, `bc` may not be installed in all test execution environments, causing silent failures.
**Action:** Replace `bc` with native bash integer math (`$(( ))`) for additions, and use `awk` for floating point division (e.g., `awk "BEGIN {printf \"%.2f\", $score / 100}"`). Also, update conditional checks to use bash integer comparisons (`-ge`) instead of string equality checks on `bc` output.

## 2024-10-29 - Batch jq calls for JSON parsing in bash
**Learning:** In the bash test suite (`tests/run_all.sh`), multiple independent `jq` calls were used sequentially on the same file (`sessions-page.json`) to extract counts for `completed`, `awaiting`, `active`, `failed_sessions`, `with_changeset`, `with_pr`, and `no_output`. Spawning a new `jq` process for each extraction creates noticeable overhead.
**Action:** When extracting multiple values from the same JSON source in bash, batch the queries into a single `jq` array and output them as a TSV. Read them into variables simultaneously using `IFS=$'\t' read -r var1 var2 <<< "$(jq -r '[...] | @tsv' file.json)"`.
