## 2024-09-12 - Batch jq queries with `@tsv`
**Learning:** Sequential `jq` calls on the same payload in shell scripts introduce significant subshell and process spawning overhead.
**Action:** Always batch queries into a single `jq` array evaluation when extracting multiple fields from the same JSON payload, and use `@tsv` with `IFS=$'\t' read -r` to assign them simultaneously in bash.
