## print pods
```shell
#!/bin/bash
set -x
kubectl get pod -A
kubectl get node

```

## tainit nodes

```shell
#!/bin/bash
sudo kubectl get nodes
NODENAME=$(sudo kubectl get nodes -ojsonpath='{.items[0].metadata.name}')
NODEIP=$(kubectl get nodes -ojsonpath='{.items[0].status.addresses[0].address}')
echo "NodeName=$NODENAME,NodeIP=$NODEIP"
sudo -u root kubectl taint node $NODENAME node-role.kubernetes.io/master-
sudo -u root kubectl taint node $NODENAME node-role.kubernetes.io/control-plane-

```

## check script

```shell
sleep 60
sudo -u root crictl ps -a
sudo -u root cat /etc/hosts
sudo -u root systemctl status kubelet
sudo -u root kubectl get nodes --kubeconfig /etc/kubernetes/admin.conf 
NODENAME=$(sudo -u root kubectl get nodes -ojsonpath='{.items[0].metadata.name}' --kubeconfig /etc/kubernetes/admin.conf )
NODEIP=$(sudo -u root kubectl get nodes -ojsonpath='{.items[0].status.addresses[0].address}' --kubeconfig /etc/kubernetes/admin.conf )
echo "NodeName=$NODENAME,NodeIP=$NODEIP"
sudo -u root kubectl get nodes --kubeconfig /etc/kubernetes/admin.conf 
sudo -u root kubectl get pods -A --kubeconfig /etc/kubernetes/admin.conf 
```
