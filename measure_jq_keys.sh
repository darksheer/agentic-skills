#!/bin/bash
completed_activities_file="./tests/fixtures/jules/activities-completed.json"

echo "Batched jq keys:"
time {
  for i in {1..10}; do
    keys=$(jq -r '[.activities[] | keys[]] | unique | .[]' "$completed_activities_file")
    for event in planGenerated planApproved progressUpdated artifacts sessionCompleted; do
      if echo "$keys" | grep -q "^${event}$"; then
        true # pass
      else
        false # fail
      fi
    done
  done
}
