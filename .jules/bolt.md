## 2025-02-23 - Batch jq queries in Bash
**Learning:** Calling `jq` repeatedly within bash scripts (especially loops or to extract individual scalar fields) is a significant bottleneck due to process startup overhead.
**Action:** When extracting multiple values from the same JSON payload, batch them into a single `jq` invocation by constructing an array, passing it through `@tsv`, and loading the fields into bash variables using `IFS=$'\t' read -r var1 var2 ... <<< "$(jq -r '...' file.json)"`.
