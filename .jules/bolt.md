## YYYY-MM-DD - [Initial Read]
**Learning:** Need to observe performance.
**Action:** Let's look for bash bottlenecks in tests/run_all.sh.
## YYYY-MM-DD - [Batch jq queries]
**Learning:** Calling `jq` multiple times on the same input in bash is a major performance bottleneck due to process instantiation overhead. Batching queries into an array and using `@tsv` with `read` is ~3-4x faster.
**Action:** When making multiple `jq` queries against the same payload, always batch them into a single `jq` execution returning a `@tsv` string, and read the results into variables using `IFS=$'\t' read -r var1 var2 <<< "$(jq ...)"`.
## YYYY-MM-DD - [Arithmetic operations in bash]
**Learning:** External commands like `bc` are not always available and spawning external processes in a loop adds significant overhead. Basic arithmetic, especially integers, can be handled using native bash `$(( ))` or string-based conditionals. If floating point format is strictly required, `awk` is generally universally available and faster than `bc`.
**Action:** Use native bash integer math `$(( ))` wherever possible. Replace `score=$(echo "$score + X" | bc)` with `score=$((score + X))` for integers. For logical comparisons replace `[ "$(echo "$score >= 70" | bc)" = "1" ]` with `[ "$score" -ge 70 ]`. When floating-point formatting is specifically required (like printing `0.70`), use `awk "BEGIN {printf \"%.2f\", $score / 100}"` instead of `bc`.
