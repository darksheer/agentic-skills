## 2024-10-20 - Replace bc with native bash arithmetic
**Learning:** External commands like `bc` add process overhead and might not be installed, causing silent failures or "command not found" errors in the test execution environment.
**Action:** Use native bash integer math `$(( ))` or tools like `awk` for floating points to reduce overhead and prevent failures.
