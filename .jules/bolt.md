## 2024-05-24 - Bash bc command missing in test environment

**Learning:** The external command `bc` might not be installed in the environment where test suites are executed (causing silent failures or 'command not found' errors). Furthermore, repeatedly calling `bc` introduces process spawning overhead in bash scripts.

**Action:** When performing simple integer arithmetic or basic floating-point formatting, rely on native bash integer arithmetic `$(( ))` or universally available tools like `awk` (e.g., `awk "BEGIN {printf \"%.2f\", $score / 100}"`) instead of `bc` to ensure scripts run correctly while reducing overhead.
