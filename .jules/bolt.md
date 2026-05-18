## 2026-05-18 - Batch jq commands in bash test suite
**Learning:** In bash test suites, repeatedly calling `jq` on the same JSON file or string introduces significant overhead, especially for larger payloads.
**Action:** Group multiple JSON extractions into a single `jq` call returning an array mapped to `@tsv`, and load into bash variables using `read -r`. This minimizes process creation and redundant JSON parsing. Ensure to handle potential `null` arrays with the `?` operator.
