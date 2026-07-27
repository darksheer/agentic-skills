## 2024-07-27 - [Bash Scripting Optimization]
**Learning:** Sequential `jq` calls on the same file or variable introduce significant subprocess overhead. The use of `bc` for simple arithmetic inside bash is also slow. Batching `jq` queries using arrays and `@tsv` and avoiding empty elements enables reading all output at once.
**Action:** Use batch `jq` with `IFS=$'\t' read -r` and native bash integer arithmetic `$(( ))` for improved performance.
