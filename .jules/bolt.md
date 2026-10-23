## 2024-05-15 - Replace bc with bash arithmetic in tests
**Learning:** Using external commands like `bc` in a loop adds process spawning overhead. Also, it might not be installed in the default test execution environment.
**Action:** Replace `bc` with native bash integer arithmetic `$(( ))` and tools like `awk` for floating point operations to reduce overhead.
