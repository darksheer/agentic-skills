## 2025-02-14 - Bash JSON Parsing Performance
**Learning:** Repeatedly evaluating `jq` against the same large JSON payload or file in test scripts causes significant overhead due to subshell spawning and redundant parsing.
**Action:** Batch multiple `.jq` extractions into a single array mapping piped to `@tsv`, then parse into variables simultaneously using `IFS=$'\t' read -r var1 var2 < <(...)`. Ensure `?` is used for safe property access when dealing with potentially null JSON objects, and check values like `.title` before using functions like `test()` that crash on null.
