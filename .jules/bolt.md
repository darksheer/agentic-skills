## 2024-05-18 - Reduce Process Overhead in Bash Scripts
**Learning:** In bash test suites, making multiple sequential `jq` calls on the same payload incurs significant process spawning overhead. Also, using external commands like `bc` for simple arithmetic introduces similar overhead and risks failure if not installed.
**Action:** Batch multiple `jq` queries into a single call using arrays and `@tsv`, reading the output simultaneously via `IFS=$'\t' read -r ...`. Replace `bc` with native bash integer math `$(( ))` or universally available tools like `awk` for floating point operations.
