## 2024-05-24 - Bash Script Performance with jq Arrays
**Learning:** Sequential `jq` calls on the same file or string in bash scripts cause massive performance overhead due to process spawning and redundant JSON parsing.
**Action:** When extracting multiple values from the same JSON context, batch queries into a single `jq` array and output via `@tsv`. Read the tab-separated values concurrently using `IFS=$'\t' read -r var1 var2 < <(jq -r '[.query1, .query2] | @tsv')`.
