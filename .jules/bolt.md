## 2024-10-10 - Replace bc with bash arithmetic
**Learning:** External commands like 'bc' add process spawning overhead and may not be installed in the project's default test execution environment (causing silent failures or 'command not found' errors).
**Action:** Rely on native bash integer arithmetic `$(( ))` for basic arithmetic and universally available tools like 'awk' (e.g., `awk "BEGIN {printf \"%.2f\", $score / 100}"`) to ensure scripts run correctly and reduce process spawning overhead.
