## 2024-05-24 - [Optimize test script jq calls]
**Learning:** In bash test suites, repeatedly calling `jq` on the same JSON payload inside a loop or sequence introduces significant process spawning overhead, slowing down the tests.
**Action:** Consolidate multiple scalar extractions from a single JSON block into one `jq` call returning an array mapped via `@tsv`, and assign them simultaneously using `IFS=$'\t' read -r var1 var2 <<< "$(jq ...)"`. Also, replace external math tools like `bc` with native bash arithmetic for integer operations to further reduce overhead.
