## 2024-05-24 - Batching jq calls in bash test suite
**Learning:** Repeatedly calling `jq` on the same JSON payload in bash scripts incurs significant process overhead. By constructing an array of queries in `jq` and exporting them as tab-separated values (`@tsv`), bash's `read -r` can populate multiple variables simultaneously, executing `jq` only once.
**Action:** When extracting multiple scalar values from the same JSON string or file in bash, combine them into a single `jq` filter using `[ ... ] | @tsv` and read them directly into variables.
