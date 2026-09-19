## 2024-03-05 - Optimize JQ execution and remove BC dependency
**Learning:** In the bash test suite, making repeated `jq` calls on the same file/variable and spawning external processes like `bc` for simple arithmetic creates unnecessary process overhead.
**Action:** When working in bash, batch `jq` queries using arrays and `@tsv`, and parse them with `IFS=$'\t' read -r`. Avoid using `bc` for integer arithmetic; use bash native `$(( ))` or `awk` instead.
