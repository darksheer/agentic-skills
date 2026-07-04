## 2024-05-20 - [Batching jq queries for bash performance]
**Learning:** Repeatedly spawning the `jq` process and parsing the same JSON payload in bash scripts is a significant performance bottleneck.
**Action:** Batch multiple `jq` queries into a single array output and use `@tsv` with `IFS=$'\t' read -r` to parse them in bash simultaneously, avoiding multiple process spawns. Always ensure null safety in fields passed to `test()` by checking field existence first.
