## 2024-05-14 - Bash Performance: Batching jq Calls
**Learning:** In bash test suites, repeatedly spawning `jq` processes to evaluate multiple properties from the same JSON payload incurs massive I/O and parsing overhead.
**Action:** Always batch `jq` queries into arrays and output via `@tsv`. Read multiple extracted values into bash variables simultaneously using `IFS=$'\t' read -r var1 var2 < <(jq -r '[.val1, .val2] | @tsv' file.json)`. Remember to use the `?` operator to safely evaluate queries when inputs may be `null`.
