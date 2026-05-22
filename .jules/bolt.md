## 2024-05-24 - Bash jq query batching
**Learning:** In bash test suites, repeatedly calling `jq` on the same JSON file or variable introduces significant overhead by spawning multiple processes.
**Action:** Always batch related data extraction into a single `jq` query using arrays `[...]` and `@tsv`, and assign results simultaneously via `read -r var1 var2 < <(...)`. Be sure to use the `?` operator (e.g. `.array[]?`) to handle possible null inputs correctly.
