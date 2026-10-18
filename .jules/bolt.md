## 2024-10-18 - Replacing bc with native bash math and awk
**Learning:** External commands like `bc` incur process overhead and might not be installed in the project's default environment.
**Action:** Rely on native bash integer arithmetic `$(( ))` for simple calculations and use universally available tools like `awk` for floating-point formatting.
