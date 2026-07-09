## 2025-01-21 - Optimize JSON Parsing and Arithmetic in test suite
**Learning:** Sequential `jq` calls on identical JSON data and calling external commands like `bc` for simple arithmetic introduce significant and measurable overhead in Bash test suites.
**Action:** Always batch JSON extraction into a single `jq` array and read it simultaneously via `IFS=$'\t' read -r ... < <(jq -r '[...] | @tsv' ...)`. Always use native bash integer math `$(( ))` or tools like `awk` for floating points instead of piping into `bc`.
