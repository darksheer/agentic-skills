## 2024-05-24 - Bash process overhead optimization
**Learning:** In bash test scripts, repeatedly calling external commands like `jq` or `bc` in sequence or within loops creates significant overhead due to the constant spawning of new processes.
**Action:** Consolidate multiple `jq` queries into a single batched array execution mapped to TSV output, and assign variables simultaneously using `IFS=$'\t' read -r`. Replace external `bc` calculations with native bash integer math `$(( ))` for arithmetic and use `awk` for final floating-point string formatting.
