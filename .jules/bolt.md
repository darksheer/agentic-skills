## 2024-07-01 - Batch jq queries in bash
**Learning:** Batching multiple `jq` queries on the same JSON file or variable into a single query using array construction and `@tsv` significantly reduces subshell overhead.
**Action:** Use `IFS=$'\t' read -r` to avoid shell variable splitting issues and `.sessions[]?` to handle `null` mock inputs.
