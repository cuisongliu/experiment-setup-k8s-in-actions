#!/bin/bash
sudo kubectl get nodes
NODENAME=$(sudo kubectl get nodes -ojsonpath='{.items[0].metadata.name}')
NODEIP=$(kubectl get nodes -ojsonpath='{.items[0].status.addresses[0].address}')
echo "NodeName=$NODENAME,NodeIP=$NODEIP"
sudo -u root kubectl taint node $NODENAME node-role.kubernetes.io/master-
sudo -u root kubectl taint node $NODENAME node-role.kubernetes.io/control-plane-
