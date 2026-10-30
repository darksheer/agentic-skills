#!/bin/bash
completed_activities_file="./tests/fixtures/jules/activities-completed.json"

echo "jq keys array:"
time {
  for i in {1..10}; do
    events=$(jq -r '[.activities[] | keys[]] | unique | @tsv' "$completed_activities_file")
    for event in planGenerated planApproved progressUpdated artifacts sessionCompleted; do
      if [[ -z "${events##*$event*}" ]]; then
        true
      else
        false
      fi
    done
  done
}
