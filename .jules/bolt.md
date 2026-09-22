## 2024-10-24 - Bash jq batching performance
**Learning:** Sequential `jq` calls on the same JSON file/variable introduce significant process spawning overhead in bash scripts.
**Action:** Batch `jq` extractions into a single array and output as `@tsv`. Use `IFS=$'\t' read -r` to parse the output into bash variables simultaneously. Ensure variables don't contain newlines, and use `// 0` or default operators to prevent empty array fields. When handling potentially null JSON (e.g. mock API calls), use `?` in queries.
