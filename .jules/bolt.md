## 2024-05-14 - Replaced `bc` calls with native Bash math and awk

**Learning:** External commands like `bc` are not only slow because they spawn a new process for every mathematical operation in Bash, but they may also be missing in some default test execution environments causing silent failures or "command not found" errors.

**Action:** Rely on native bash integer arithmetic `$(( ))` for integer math and use `awk` for floating-point calculation when needed, to ensure scripts run correctly and reduce process spawning overhead.