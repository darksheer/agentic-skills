## 2024-11-20 - Batching jq queries and avoiding bc subshells
**Learning:** In bash performance test suites, repeating unbatched `jq` processes on identical JSON files or large string inputs adds massive overhead, and launching `bc` via subshells inside loops or repetitive blocks significantly impacts speed compared to native bash integer math.
**Action:** Combine repeated `jq` queries into a single array passed to `@tsv` and map via `IFS=$'\t' read -r`. Swap out `bc` for `$(( ))` math where only integers are manipulated.
