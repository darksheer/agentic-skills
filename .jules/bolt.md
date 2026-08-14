## 2024-05-24 - [Avoid Multiple jq Invocations in Bash Loops]
**Learning:** Calling `jq` repeatedly to extract individual fields from a JSON response is a severe performance bottleneck.
**Action:** Batch the queries into a single `jq` invocation using array construction and the `@tsv` filter.

## 2024-05-24 - [Handle null values in TSV output]
**Learning:** When using `jq` array construction with `@tsv` (e.g. `[ .a, .b ] | @tsv`), if a field evaluates to empty (via `// empty` or missing optional `?` with nothing), the element is completely dropped from the array. This breaks positional mapping when read into bash variables (e.g., `read -r a b c`).
**Action:** Do not use `// empty` inside arrays intended for positional TSV output. Use `map(. // 0)` or let expressions evaluate to `null` so that `jq` outputs an empty string for that field, maintaining the correct number of array elements.
