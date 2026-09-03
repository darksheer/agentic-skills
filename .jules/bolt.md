## 2024-05-14 - Bash Test Suite Performance Optimizations
**Learning:** Found significant bash execution overhead in `tests/run_all.sh` primarily caused by launching excessive external processes (`jq` and `bc`). Repeating `jq` calls within tight loops on the same JSON payload adds cumulative subshell spawn delays. Furthermore, using `bc` for simple arithmetic, which might not even be installed in minimal execution environments, causes unnecessary overhead and silent failures.
**Action:** When writing or optimizing bash test scripts that parse JSON:
1. Batch multiple jq queries targeting the same JSON blob into a single jq array evaluation combined with `@tsv`, then use `IFS=$'\t' read -r` to cleanly assign variables concurrently.
2. Avoid external utilities like `bc` for integer arithmetic; use native bash evaluation like `score=$((score + 30))`. For floating point calculations, prefer `awk` over `bc` to reduce dependencies and improve speed.
3. Ensure robust handling of null values when batching jq `@tsv` outputs with `if .key then [...] else empty end` structures or null safe navigation to prevent script crashing during `read`.
