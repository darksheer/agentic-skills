## 2024-05-24 - Batching jq Queries in Bash Tests
**Learning:** In bash test scripts, repeatedly calling `jq` on the same large JSON file or payload introduces significant subprocess overhead.
**Action:** Batch scalar/integer metric extractions into a single `jq` call using arrays and `@tsv`, and parse them in bash using `IFS=$'\t' read -r var1 var2 < <(jq -r '...' ...)`. Always check fields for nullness (e.g., `select(.title and (.title | test("...")))`) to prevent runtime failures.
