## 2024-08-28 - Bash Process Overhead Optimization
**Learning:** Calling `jq` and `bc` repeatedly inside bash scripts, especially within loops or sequential checks, introduces significant process spawning overhead (e.g. ~1s vs ~0.1s for 10 queries). Also, `jq`'s `test()` function throws fatal errors if evaluated against a `null` value.
**Action:** Always batch `jq` queries into a single array outputting to `@tsv` and read using `IFS=$'\t' read -r`. Use `awk` or native bash arithmetic `$(( ))` instead of `bc` to minimize external command usage.
