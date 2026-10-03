## 2024-05-24 - Mock JULES API tests
**Learning:** When using mock API data, jq queries need to be safe-guarded against null payload responses using ? (e.g. .sessions[]?) and default operators.
**Action:** Always test API-fetching shell scripts with both valid responses and mock/unauthorized payloads, falling back gracefully.
