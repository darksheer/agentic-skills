## 2024-03-24 - Batching jq queries for bash parsing
**Learning:** When using `jq` to parse JSON in bash scripts (like `tests/run_all.sh`), making multiple calls to `jq` on the same large JSON output is a performance bottleneck due to process spawning overhead. Batching queries into a single `jq` array output formatted as `@tsv` and parsing it directly using `IFS=$'\t' read -r` significantly reduces execution time. Also, `jq` optional navigation handles nulls correctly but can drop elements when they are empty, so defaulting to an empty array using `// []` before applying filters ensures the array output is robust and doesn't break bash variable assignment.
**Action:** Replace multiple `jq` calls with single batched `jq` `@tsv` queries, taking care to handle potential null arrays gracefully using `.array_name // []` before array indexing.

## 2024-03-24 - Arithmetic evaluation in bash scripts
**Learning:** Using `bc` in bash loops or frequent calculations introduces large process overhead. External tools like `bc` might also not be available on all environments causing the script to fail. Native bash integer arithmetic `$(( ))` or tools like `awk` (for floating points) perform significantly better.
**Action:** Use native bash arithmetic `$(( ))` for integer math instead of spawning a new `bc` process. If floating point evaluation is needed, use `awk`.
