
## 2024-05-24 - [Batching jq calls in bash test scripts]
**Learning:** Invoking `jq` repeatedly on the same JSON file or variable in bash adds process-spawning overhead and can cause null iteration errors when using mocked API outputs.
**Action:** Use arrays and `@tsv` to batch multiple `jq` extractions into a single command, using `IFS=$'\t' read -r` for assignment and the `?` operator to safely handle null inputs.
