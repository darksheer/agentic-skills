## 2025-02-12 - Replacing `bc` with native bash arithmetic for performance
**Learning:** Calling external commands like `bc` in bash scripts within performance-sensitive sections introduces significant process spawning overhead. Bash has built-in integer math which is much faster.
**Action:** Use native bash `$(( ))` for integer arithmetic and reserve `awk` only for required floating-point operations.
