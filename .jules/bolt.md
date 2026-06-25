## 2024-05-13 - [Performance optimization] Batching jq operations for bash scripts

**Learning:** When evaluating performance in bash scripts that parse JSON (especially when reading from files or large API responses), executing multiple `jq` calls sequentially against the same data adds significant overhead due to subshell creations and parsing costs.

**Action:** Whenever possible, batch multiple `jq` queries into a single `jq` invocation using arrays and `@tsv`. Then, map the output to bash variables in one step using `IFS=$'\t' read -r var1 var2 <<< "$(jq -r '[ (.data | length) ] | @tsv' file.json)"`. Remember to handle null values appropriately with the `?` operator to avoid positional offset bugs.
