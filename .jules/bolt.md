## 2024-08-03 - Batching jq queries in bash
**Learning:** When repeatedly processing JSON variables in bash using `jq`, calling it sequentially spawns significant subprocess overhead.
**Action:** Instead, combine multiple queries into a single `jq` invocation outputting to `@tsv` using an array format and reading variables using `IFS=$'\t' read -r`.

## 2024-08-03 - Evaluating JSON missing fields and length
**Learning:** Using `(.sessions[]? | select(...) | length)` may evaluate to null if `sessions` is missing, failing downstream assignments correctly. Using `// []` before checking length `(.sessions // [] | length)` is essential for robust parsing.
**Action:** Always handle missing arrays prior to checking their length in batched queries.

## 2024-08-03 - Testing integer fields
**Learning:** Calling `test()` on a null title field throws an error in `jq` and halts execution.
**Action:** Ensure that string matching fields are validated as not null (`select(.title and (.title | test("...")))`) prior to checking regex matches in batched queries.

## 2024-08-03 - Bash performance over bc
**Learning:** Using `bc` in bash scripts is slower compared to using native bash integer arithmetic (`$(( ))`) or `awk`.
**Action:** Substitute arithmetic `bc` commands with native integer math and floating point math with `awk`.
