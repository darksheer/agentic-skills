\#\# 2025-02-14 - Replace bc with native bash arithmetic
**Learning:** External commands like `bc` incur process overhead and might not be available in all test environments. Native bash integer math `$(( ))` and `awk` are much faster and universally available, preventing silent failures.
**Action:** Always prefer native bash features for math where possible to improve performance and compatibility. Use `awk` for floating point calculation instead of `bc`.
