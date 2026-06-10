
## 2024-05-18 - Bash jq Batching Optimization
**Learning:** In bash test suites, repeatedly executing `jq` on the same large JSON file or variable introduces significant overhead and can fail unpredictably when encountering `null` arrays from mocked API responses.
**Action:** Always batch related JSON queries into a single `jq` array piped to `@tsv`, reading the output securely via `IFS=$'\t' read -r`. Append the `?` operator (e.g. `.sessions[]?`) to gracefully handle null or missing fields without failing the bash process.
