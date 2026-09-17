## 2024-09-17 - Bash jq batching pattern
**Learning:** Found a sequence of 10 separate `jq` invocations on the same JSON payload in `tests/run_all.sh` (lines 512-534). Each call spawns a new process, adding significant overhead.
**Action:** Use a single `jq` invocation constructing an array of results, outputting as `@tsv`, and read them into variables simultaneously using `IFS=$'\t' read -r ... <<< "$(echo "$payload" | jq -r '[...] | @tsv')"`. Also ensure to double quote the command substitution.
