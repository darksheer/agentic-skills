## 2024-07-25 - Shell Scripting Performance Bottlenecks
**Learning:** Sequential `jq` calls on the same payload and repeated subshells invoking `bc` create significant overhead in bash scripts, increasing execution time needlessly.
**Action:** Always batch `jq` extractions using arrays and `@tsv`, mapping them to bash variables via `IFS=$'\t' read -r`. Replace simple math logic dependent on `bc` with native bash arithmetic `$(( ))` or `awk` for floating point operations.
