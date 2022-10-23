#!/bin/bash
NUM=0
until [[ $NUM -ne 0 ]]
do
  kubectl get pod --field-selector=status.phase!=Running,status.phase!=Completed
  NUM=$(kubectl get pod --field-selector=status.phase!=Running,status.phase!=Completed -A | grep -v RESTARTS | wc -l)
  sleep 3
done
kubectl get pod -A


