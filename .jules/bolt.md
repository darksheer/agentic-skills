## 2024-06-18 - Bash jq batching performance
**Learning:** Calling `jq` repeatedly to extract single fields from the same JSON string or file in bash scripts incurs significant process spawning overhead.
**Action:** Always batch `jq` extractions into a single array using `@tsv` output, and read them simultaneously into bash variables using `IFS=$'\t' read -r var1 var2 ... < <(echo "$json" | jq -r '[.field1, .field2] | @tsv')`.
