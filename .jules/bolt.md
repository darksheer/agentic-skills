## 2024-10-24 - Avoiding bc for bash arithmetic
**Learning:** External commands like `bc` may not be installed in the project's default test execution environment (causing silent failures or 'command not found' errors) and spawn subshells unnecessarily, creating performance bottlenecks inside loops.
**Action:** Rely on native bash integer arithmetic `$(( ))` for simple calculations and universally available tools like `awk` for floating point formatting to reduce overhead.
