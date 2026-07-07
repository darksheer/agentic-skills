## 2024-05-24 - Bash jq query batching
**Learning:** In bash test scripts, calling jq repeatedly on the same output causes significant overhead. Batching queries into a single jq array, then using @tsv and IFS=$'\t' read -r is much more performant. We must handle null checks using ? and map(. // 0) so the lengths aren't corrupted when null is encountered.
**Action:** When performing multiple JSON queries against a single payload, bundle the jq selects into an array block mapping to TSV.
