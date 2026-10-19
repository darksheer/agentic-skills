## 2024-10-25 - Avoid bc in Bash for Performance and Reliability
**Learning:** External commands like `bc` add process spawning overhead in bash and may not be installed in this project's default test execution environment, potentially causing silent failures.
**Action:** Rely on native bash integer arithmetic `$(( ))` for simple math, and universally available tools like `awk` for floating point formatting to ensure reliability and performance.
