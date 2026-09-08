## 2023-10-27 - Batching jq and replacing bc
**Learning:** Repeatedly calling jq on the same JSON payload and spawning subshells for external commands like `bc` adds significant process overhead in bash scripts.
**Action:** Consolidate multiple queries into a single `jq` invocation using arrays and `@tsv`, and replace `bc` with native bash arithmetic `$(( ))` or `awk` for floating point operations.
