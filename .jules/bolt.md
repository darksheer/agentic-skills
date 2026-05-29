## 2024-05-24 - [Bash Scripting jq batch execution performance optimization]
**Learning:** Calling `jq` multiple times on the same input file is slow due to repeated process startup and file parsing. Batching queries into a single array and outputting them as `@tsv` significantly improves performance in shell scripts.
**Action:** When extracting multiple pieces of information from the same JSON string/file, batch `jq` commands inside a single array block `[...] | @tsv` and read using `IFS=$'\t' read -r var1 var2 ... < <(...)`.
