## 2024-07-11 - Batching jq calls in bash test suite
**Learning:** Invoking the `jq` binary multiple times sequentially in bash scripts introduces significant process-spawning overhead.
**Action:** Always batch related `jq` queries into a single JSON array, output them using `@tsv`, and assign them simultaneously to bash variables using `IFS=$'\t' read -r var1 var2 ... < <(...)`.
