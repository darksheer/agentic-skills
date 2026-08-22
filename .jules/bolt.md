## 2024-05-24 - Batching jq queries and replacing bc with native bash math
**Learning:** Calling `jq` and `bc` repeatedly in bash scripts introduces significant process overhead, especially when parsing identical JSON outputs or running simple arithmetic.
**Action:** Always batch `jq` extractions into a single array passed to `@tsv` and read with `IFS=$'\t' read -r`. Avoid using `bc` for simple arithmetic; use native bash `$(())` or `awk` instead.
