## 2024-06-14 - Bash Performance Optimization
**Learning:** Multiple sequential `jq` calls against the same file or string in bash scripts cause unnecessary overhead and parse repetition. Combining them into a single `jq` call outputting a TSV line and reading it with `IFS=$'\t' read -r` is much more performant. Using `?` handles possible nulls when querying empty JSON output.
**Action:** Use batched TSV `jq` extraction to optimize shell scripts that parse JSON fields into variables.
