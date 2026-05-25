## 2024-05-25 - Batching jq calls in Bash test scripts
**Learning:** Repeatedly calling `jq` to parse the same JSON file or string in bash scripts incurs significant execution overhead.
**Action:** Batch queries into a single `jq` call using arrays and `@tsv`, reading the output into variables simultaneously with `read -r`. Handle missing arrays gracefully with `?`.
