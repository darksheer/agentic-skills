## 2024-05-18 - Bash jq Query Batching

**Learning:** When repeatedly querying the same JSON structure using `jq` in bash scripts (like extracting multiple metrics from a large API response in tests), running individual `jq` commands sequentially introduces significant process spawning overhead. Combining multiple queries into a single `jq` array output formatted as TSV (`@tsv`) and reading them simultaneously using `IFS=$'\t' read -r` performs significantly faster. Ensure that `?` operator is used with arrays and missing values are handled to prevent failures on missing `.sessions` or `null` values.

**Action:** Replace sequential `jq` queries on the same JSON source with a batched array query outputting TSV whenever multiple data points are extracted.
