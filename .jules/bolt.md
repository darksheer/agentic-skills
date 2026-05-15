## 2026-05-15 - Optimize multiple jq calls
**Learning:** Calling `jq` repeatedly to extract different properties from the same JSON document or file incurs significant overhead due to parsing the JSON multiple times and forking processes multiple times. We can batch multiple queries into a single `jq` call that returns multiple values (e.g., using an array and `@tsv`) and read them into variables simultaneously using bash's `read -r ... <<< $(jq ...)`.
**Action:** When extracting multiple values from a single JSON string or file in bash, combine the `jq` queries into one invocation.
