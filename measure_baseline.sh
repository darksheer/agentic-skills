#!/bin/bash
completed_activities_file="./tests/fixtures/jules/activities-completed.json"

echo "Baseline loop:"
time {
  for i in {1..10}; do
    for event in planGenerated planApproved progressUpdated artifacts sessionCompleted; do
      if jq -e --arg event "$event" '[.activities[] | select(has($event))] | length > 0' "$completed_activities_file" > /dev/null; then
        true # pass
      else
        false # fail
      fi
    done
  done
}
