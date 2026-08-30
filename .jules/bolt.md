## 2024-05-18 - Bash jq Query Batching
**Learning:** Repeatedly calling jq against the same large JSON payload in bash causes process spawning overhead that quickly degrades test script execution speed.
**Action:** Batch multiple jq extractions into a single query using array constructors and `@tsv`, then read them simultaneously into bash variables via `IFS=$'\t' read -r`.
