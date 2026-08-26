## 2024-05-24 - Avoid external bc calls for simple math
**Learning:** Found an anti-pattern in the bash test suite (`run_all.sh`) where `bc` was repeatedly called for simple integer arithmetic in scoring loops. Spawning an external `bc` process introduces measurable overhead compared to native bash arithmetic.
**Action:** Use native bash integer math `$(( ))` for integer arithmetic and tools like `awk` for floating point formatting to reduce process spawning overhead.
