## 2024-05-24 - Batching jq queries and eliminating bc
**Learning:** Repeatedly invoking jq over the same JSON structure or invoking bc for simple math inside loops creates significant performance overhead due to process forking.
**Action:** When extracting multiple values from a single JSON string in bash, use `jq -r '[...] | @tsv'` to batch the queries and assign them simultaneously with `IFS=$'\t' read -r ...`. Replace `bc` with native bash integer math `$(( ))` where possible to avoid spawning external processes.
