## 2024-05-15 - [Avoid `bc` command overhead in bash tests]
**Learning:** `bc` is called 9 times per session during the dry-run pipeline test for triage scoring. For a set of say 30 sessions, this would be 270 calls. This is a noticeable bottleneck because creating a new process is slow compared to bash internal math. It's especially unnecessary since all math here is integer math except for one division that only needs 2 decimal places.
**Action:** Replace `bc` with native bash arithmetic for integer operations (`$(( ... ))`) and `awk` for floating point division to improve test speed, especially on larger session sets.

## 2024-05-15 - [Batching jq queries in tests]
**Learning:** In `tests/run_all.sh`, the script makes ~10 separate `jq` calls against the same `sessions` JSON data during the dry-run pipeline tests. Calling `jq` repeatedly on the same data involves redundant parsing and process creation overhead.
**Action:** Consolidate multiple sequential `jq` calls into a single query that outputs a TSV array, then read the variables concurrently in bash via `IFS=$'\t' read -r var1 var2 ...`. This improves execution speed significantly.
