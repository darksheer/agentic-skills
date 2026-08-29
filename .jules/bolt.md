## 2024-05-13 - [Performance optimization in bash test suite]
**Learning:** In bash test suites, repeatedly executing jq and bc in a loop or across many variable assignments is very slow due to process spawning overhead. Batching queries into a single jq call and using native bash integer math (and awk for floating points) provides measurable improvements.
**Action:** Consolidate jq queries using `@tsv` and `read -r`, and replace `bc` with `$(( ))` or `awk` in bash tests.
