## 2026-05-21 - Bash jq Optimization
**Learning:** Avoid repeatedly calling `jq` on the same JSON output or file. Instead, batch queries into a single `jq` call using arrays and `@tsv`, and read them into variables simultaneously using `read -r` to reduce execution overhead. Always remember to handle potential null arrays with the `?` operator.
**Action:** Always look for opportunities to combine multiple `jq` queries on the same data into a single query block.
