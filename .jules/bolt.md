## 2024-05-30 - Bash Test Suite jq Parsing Optimization
**Learning:** In the bash test suite, multiple consecutive calls to `jq` reading the same file or parsing the same JSON string represent a significant performance bottleneck.
**Action:** Consolidate multiple related `jq` queries into a single call using arrays and `@tsv`, reading the output into variables simultaneously with `IFS=$'\t' read -r`. Make sure to handle missing items correctly by using the `?` operator.
