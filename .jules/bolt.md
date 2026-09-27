## 2024-05-20 - Avoid external binary `bc` for simple bash math
**Learning:** Using external commands like `bc` for simple arithmetic inside bash scripts introduces process spawning overhead and can cause silent failures if the binary is missing in the execution environment.
**Action:** Rely on native bash integer arithmetic (`$(( ))`) and universally available tools like `awk` for floating-point calculations to reduce overhead and improve robustness.
