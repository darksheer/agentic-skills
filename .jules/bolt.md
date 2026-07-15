## 2024-07-15 - Batched jq Execution in Bash Tests
**Learning:** Calling `jq` repeatedly in bash scripts introduces significant overhead. Grouping queries into a JSON array and outputting via `@tsv` allows retrieving multiple fields in a single execution. Empty strings must be avoided to prevent bash positional reading errors, and using `.[]?` gracefully handles missing properties.
**Action:** Use arrays mapped to `@tsv` with `IFS=$'\t' read -r` to batch `jq` operations and use placeholder values or `map(. // 0)` to guarantee correct output length.
