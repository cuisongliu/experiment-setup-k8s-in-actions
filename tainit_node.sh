#!/bin/bash
sudo kubectl get nodes
NODENAME=$(sudo kubectl get nodes -ojsonpath='{.items[0].metadata.name}')
echo "NodeName=$NODENAME"
sudo -u root kubectl taint node $NODENAME node-role.kubernetes.io/master-
sudo -u root kubectl taint node $NODENAME node-role.kubernetes.io/control-plane-
sudo kubectl get pods -A
