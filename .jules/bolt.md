## 2024-05-24 - Batching jq queries and avoiding external math commands in Bash
**Learning:** Sequential `jq` invocations and external command calls like `bc` for simple integer math in bash tests introduce unnecessary process overhead. Repeated `jq` queries over the same JSON payload are noticeably slow in tight loops.
**Action:** Use native bash arithmetic `$(( ))` for integer math, `awk` for floating-point calculations, and combine multiple `jq` extractions into a single array export formatted via `@tsv`, parsed into variables with `IFS=$'\t' read -r`.
