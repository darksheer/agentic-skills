## 2024-05-24 - Initializing Bolt Journal
**Learning:** Initializing the bolt performance journal.
**Action:** Let's find performance improvements.

## 2024-05-24 - Bash testing performance optimizations
**Learning:** Found multiple instances where jq is called multiple times on the same payload and external 'bc' is used for simple arithmetic inside loops. These subshell and external process calls introduce overhead in bash scripts. The memory says: "Bash scripting performance pattern: When working within the bash test suite, avoid repeatedly calling jq on the same JSON output or file. Instead, batch queries into a single jq call using arrays and @tsv, and read them into variables simultaneously. Use IFS=$'\t' read -r instead of the default read -r to prevent incorrect string splitting when extracted JSON fields contain spaces. Ensure to handle potential null arrays with the ? operator. Avoid calling external commands like bc for simple arithmetic; use native bash integer math $(( )) or tools like awk for floating points to reduce overhead."
**Action:** Replace multiple `jq` calls with a single `@tsv` batch operation. Replace `bc` with native bash integer math `$(( ))` or `awk` for floating point rendering.
