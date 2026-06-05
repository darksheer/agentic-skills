
## 2024-06-05 - Batching `jq` Queries in Bash Tests
**Learning:** Sequential `jq` calls on the same file or input text string create significant parsing overhead in bash scripts. Repeatedly spawning the `jq` process for individual property lookups makes the test suite slow.
**Action:** Use a single, batched `jq` call with `[ ... ] | @tsv` and `IFS=$'\t' read -r ...` to extract all required properties simultaneously into bash variables. Also, ensure graceful failure handling using `.[]?` when evaluating potentially empty inputs from mock data sources.
