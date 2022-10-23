#!/bin/bash
set -x
NUM=-999
until [[ $NUM -eq 0 ]]
do
  sleep 10
  kubectl get pod --field-selector=status.phase!=Running,status.phase!=Completed -A
  NUM=$(kubectl get pod --field-selector=status.phase!=Running,status.phase!=Completed -A | grep -v RESTARTS | wc -l)
done


