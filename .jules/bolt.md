## 2024-05-13 - Bash arithmetic overhead and missing 'bc'
**Learning:** Using `bc` for simple math inside bash tests introduces significant process spawning overhead and can cause silent failures because `bc` might not be installed in the project's default test execution environment.
**Action:** Rely on native bash integer arithmetic `$(( ))` for basic math, and universally available tools like `awk` for floating-point formatting to improve script reliability and execution speed.
