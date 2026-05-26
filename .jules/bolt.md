## 2023-10-27 - Batching jq calls in bash test suites
**Learning:** In bash test suites that repeatedly query the same JSON file or variable, making individual `jq` calls adds significant process creation overhead. This acts as a hidden performance bottleneck, particularly for larger files or variables.
**Action:** Always batch related JSON queries into a single `jq` execution by constructing arrays and using `@tsv`, then read them simultaneously into variables via `read -r`.
