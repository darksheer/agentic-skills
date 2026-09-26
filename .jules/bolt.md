## 2024-05-19 - Removed external bc dependency
**Learning:** Calling the external `bc` command for simple arithmetic introduces unnecessary process spawning overhead in bash scripts, which can slow down test execution. Additionally, `bc` might not be installed in all test execution environments.
**Action:** Use native bash integer math `$(( ))` for simple arithmetic and `awk` for floating-point calculations to reduce overhead and improve compatibility.
