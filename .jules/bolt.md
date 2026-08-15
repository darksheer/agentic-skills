## 2024-08-15 - jq batching in bash scripts
**Learning:** In bash scripts, avoid repeatedly calling external `jq` processes on the same JSON payload, which introduces significant process overhead.
**Action:** Batch multiple `jq` queries into a single call by wrapping them in an array, emitting them using `@tsv`, and loading them simultaneously using `IFS=$'\t' read -r var1 var2 < <(...)`. Ensure `?` operators are used to gracefully handle missing or null inputs.
