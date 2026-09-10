## 2025-02-18 - Batching jq queries for bash script performance
**Learning:** Multiple separate `jq` invocations on the same JSON payload in bash scripts add significant process overhead. Replacing external `bc` calls for simple integer arithmetic with native bash `$(( ))` also improves execution time.
**Action:** When working in bash test scripts, batch `jq` queries using `@tsv` and `IFS=$'\t' read -r`. Avoid using `bc` for integers; use bash integer math `$(( ))` or `awk` instead.
