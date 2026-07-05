## 2024-05-24 - Batching jq Queries in Bash

**Learning:** Substantial overhead is introduced when repeatedly spawning `jq` processes on the same payload.
**Action:** Always batch `jq` queries into single queries using arrays and `@tsv` with `IFS=$'\t' read -r` to extract variables simultaneously.
