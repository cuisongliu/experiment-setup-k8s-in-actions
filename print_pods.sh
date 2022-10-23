#!/bin/bash
set -x
NUM=-999
maxCount=10
until [[ $NUM -eq 0 && $maxCount -eq 0 ]]
do
  sleep 10
  maxCount--
  kubectl get pod --field-selector=status.phase!=Running,status.phase!=Completed -A
  NUM=$(kubectl get pod --field-selector=status.phase!=Running,status.phase!=Completed -A | grep -v RESTARTS | wc -l)
done
kubectl get pod -A

