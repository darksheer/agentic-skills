
## 2023-10-12 - Batch JQ queries and avoid external bc
**Learning:** Using sequential `jq` commands inside performance-sensitive loops/scripts introduces process overhead, as does using external commands like `bc` for simple arithmetic.
**Action:** Batch `jq` queries into arrays and output them via `@tsv` to be read into bash variables using `IFS=$'\t' read -r`. Rely on native bash integer arithmetic `$(( ))` or tools like `awk` for floating points to reduce overhead.
