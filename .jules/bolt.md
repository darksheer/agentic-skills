
## 2024-08-24 - Batching jq queries
**Learning:** Using `jq` with `@tsv` to batch queries can avoid unnecessary looping overhead. Be sure to use `map(. // 0)` or similar to avoid dropping null elements when constructing bash output with `@tsv` and parsing via `read`.
**Action:** Look for opportunities to optimize shell scripts by moving repetitive loops of CLI tools (e.g., `jq`) into a single batched process to save initialization time overhead.
