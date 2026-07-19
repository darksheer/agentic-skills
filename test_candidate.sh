#!/bin/bash
sessions='{"sessions":[{"state":"COMPLETED","outputs":[{"changeSet":{"gitPatch":{"unidiffPatch":"diff --git a/file1 b/file1\n--- a/file1\n+++ b/file1\n@@ -1 +1 @@\n-old\n+new\ndiff --git a/file2 b/file2\n--- a/file2\n+++ b/file2\n@@ -1 +1 @@\n-old2\n+new2"}}}]}]}'
candidate=$(echo "$sessions" | jq '[.sessions[] | select(.state == "COMPLETED" and .outputs != null and (.outputs | length) > 0)][0] // empty')
patch=$(echo "$candidate" | jq -r '.outputs[0].changeSet.gitPatch.unidiffPatch // ""')
echo "Original approach changed files:"
echo "$patch" | grep -c "^diff --git"

IFS=$'\t' read -r candidate2 < <(echo "$sessions" | jq -r '
  [
    ([.sessions[]? | select(.state == "COMPLETED" and .outputs != null and (.outputs | length) > 0)][0] | tostring)
  ] | map(if . == null or . == "" then "-" else . | tostring end) | @tsv
')
patch2=$(echo "$candidate2" | jq -r '.outputs[0].changeSet.gitPatch.unidiffPatch // ""')
echo "TSV approach changed files:"
echo "$patch2" | grep -c "^diff --git"
