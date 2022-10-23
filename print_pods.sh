#!/bin/bash
set -x
NUM=0
until [[ $NUM -ne 0 ]]
do
  sleep 3
  kubectl get pod --field-selector=status.phase!=Running,status.phase!=Completed
  NUM=$(kubectl get pod --field-selector=status.phase!=Running,status.phase!=Completed -A | grep -v RESTARTS | wc -l)
done
kubectl get pod -A


