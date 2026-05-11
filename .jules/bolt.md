## 2024-05-11 - Batching `jq` Operations in Shell Scripts

**Learning:** Shell scripts that parse large JSON responses multiple times consecutively using separate `jq` processes incur significant performance overhead. Each `jq` execution parses the entire JSON string independently. This anti-pattern can be a measurable bottleneck in CI or testing pipelines.

**Action:** When extracting multiple values or calculating multiple statistics from the same JSON string in a shell script, batch the queries into a single `jq` command that outputs an array formatted as `@tsv`. Use Bash's `read -r var1 var2 ... <<< $(echo "$json" | jq -r '[query1, query2, ...] | @tsv')` to capture the results in one pass.