## 2024-05-24 - Batch jq queries in bash scripts to improve performance
**Learning:** Calling `jq` multiple times on the same large JSON file or response in bash scripts adds significant overhead due to redundant file I/O, JSON parsing, and process spawning.
**Action:** Always batch queries into a single `jq` call using arrays and `@tsv`, and read them simultaneously into multiple variables using `IFS=$'\t' read -r var1 var2 ... < <(...)`.
