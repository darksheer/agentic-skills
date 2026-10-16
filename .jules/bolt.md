## 2024-10-16 - Batch jq queries
**Learning:** Avoid repeatedly calling jq on the same JSON output or file within bash test suites. It creates significant process overhead. Instead, batch queries into a single jq call using arrays and `@tsv`, and read them into variables simultaneously using `IFS=$'\t' read -r`.
**Action:** Always batch jq queries when parsing the same file multiple times to improve performance.
