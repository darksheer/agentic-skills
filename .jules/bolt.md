## 2024-05-24 - Bash jq Batched Extract

**Learning:** When running bash scripts with multiple `jq` calls on the same data, repeatedly parsing the JSON using subshells and pipes is slow. Also, when extracting spaces into multiple variables from a JSON array using `@tsv`, you must prefix `read -r` with `IFS=$'\t'` to ensure spaces inside array elements don't get split into separate variables. Finally, the mock JULES API returns `{"error": "Unauthorized"}`, which lacks `.sessions`. Using `.sessions[]` without `?` throws a `Cannot iterate over null (null)` error.

**Action:** Consolidate multiple related `jq` queries into a single `jq` invocation using a JSON array output formatted with `@tsv`. Read the output into bash variables using `IFS=$'\t' read -r var1 var2 ...`. Use the `?` operator on arrays (like `.sessions[]?`) to gracefully handle null inputs.
