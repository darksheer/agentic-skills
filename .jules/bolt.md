## 2026-05-10 - Batching jq calls and replacing bc in Bash
**Learning:** Parsing the same large JSON multiple times with separate jq commands inside a bash script creates significant subprocess overhead. The `bc` tool also introduces unnecessary process overhead for simple integer math.
**Action:** Always batch multiple field extractions from the same JSON string/file into a single `jq` call using arrays and `@tsv`, then read them via `IFS=$'\t' read -r`. Avoid using `bc` for integer arithmetic; use native bash `$(( ))` math.
