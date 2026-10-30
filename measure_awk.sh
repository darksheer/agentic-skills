#!/bin/bash
completed_activities_file="./tests/fixtures/jules/activities-completed.json"

echo "Awk keys:"
time {
  for i in {1..10}; do
    keys=$(jq -r '.activities[] | keys[]' "$completed_activities_file" | sort -u)
    for event in planGenerated planApproved progressUpdated artifacts sessionCompleted; do
      if echo "$keys" | grep -q "^${event}$"; then
        true
      else
        false
      fi
    done
  done
}
