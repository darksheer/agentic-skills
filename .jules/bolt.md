## 2024-05-24 - Batch jq calls for performance
**Learning:** In the bash script `tests/run_all.sh`, multiple `jq` calls were made to repeatedly parse the exact same `sessions` string, which is very inefficient. `jq` startup and parsing time add up significantly when used in this way.
**Action:** Combined multiple `jq` queries into a single call that returns an array of results, outputted as `@tsv`, and parsed them simultaneously into bash variables using `IFS=$'\t' read -r var1 var2 ...`.
