## 2024-08-06 - Optimizing jq calls in bash
**Learning:** Sequential `jq` calls on the same file or input inside bash scripts introduce significant process overhead. By batching queries into arrays and outputting via `@tsv`, they can be read directly into multiple bash variables simultaneously using `IFS=$'\t' read -r`.
**Action:** Always batch multiple `jq` evaluations into a single execution using array constructors `[...] | @tsv` rather than spawning separate `jq` processes for each value.
