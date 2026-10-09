## 2024-05-18 - Optimize bash test runner jq/math
**Learning:** Multiple separate `jq` invocations on the same JSON payload introduce significant process overhead. Additionally, using `bc` for math introduces overhead and fails if not installed.
**Action:** Batch `jq` extractions into a single call returning arrays via `@tsv` and read with `IFS=$'\t' read -r`. Use native bash `$(( ))` for integer math and `awk` for floating point.
