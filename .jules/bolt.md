## 2024-05-18 - Batching jq queries in bash
**Learning:** In bash test scripts, repeatedly calling `jq` on the same file or payload causes significant subshell and process spawning overhead. Additionally, using `bc` for simple integer math is slow compared to native bash arithmetic.
**Action:** Batch queries into single `jq` calls returning TSV arrays and read them directly using `IFS=$'\t' read -r`. Replace `bc` with `$(( ))` for integer arithmetic.
