## 2024-07-28 - Batched jq queries for JSON parsing in bash
**Learning:** In the bash test suite, parsing JSON fields separately causes overhead since `jq` is repeatedly invoked on the same JSON output.
**Action:** Batch `jq` queries into a single call using arrays and `@tsv`, and assign them simultaneously using `IFS=$'\t' read -r`. Avoid using `// empty` in the array constructor and handle potential null strings correctly using the `?` operator. Use default array length assignment for null structures `(.field // [] | length)`.
