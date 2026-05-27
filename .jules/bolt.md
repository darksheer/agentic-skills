## 2024-05-27 - [Bash Script Optimization: Batching jq Calls]
**Learning:** Calling `jq` repeatedly on the same JSON file or output creates significant execution overhead in bash scripts. It is a performance anti-pattern specific to shell-based testing and data processing.
**Action:** Always batch queries into a single `jq` call using arrays and `@tsv`, and read them simultaneously into bash variables using `read -r`. Handle potential `null` arrays gracefully with the `?` operator to avoid errors.
