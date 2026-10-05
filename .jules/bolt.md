## 2024-10-25 - Avoid external bc process in bash scripts
**Learning:** Using external commands like `bc` in bash for simple math spawns unnecessary subshells, adding process overhead and causing failures if missing.
**Action:** Use native bash integer math `$(( ))` or `awk` for floating point operations instead of `bc`.
