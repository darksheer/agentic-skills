## 2024-10-26 - Bash Scripting Optimization
**Learning:** In bash scripts, repeatedly spawning external processes like `jq` or `bc` in loops or sequentially introduces significant performance overhead due to process creation time.
**Action:** Use arrays and `@tsv` with `IFS=$'\t' read -r` to batch multiple JSON extractions into a single `jq` invocation. Replace external `bc` calls with native bash arithmetic (`$(( ))`) for integers, and universally available `awk` for floating point operations.
