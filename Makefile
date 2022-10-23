KubernetesRepo ?= docker.io/labring/kubernetes
KubernetesVersion ?= v1.24.0
ClusterImages ?=
Debug ?=

uninstall-buildah:
	sudo apt remove buildah -y || true

install-buildah:
	wget -qO "buildah" "https://github.com/labring/cluster-image/releases/download/depend/buildah.linux.amd64"
	chmod a+x "buildah"
	sudo cp -a "buildah" /usr/bin

install-sealos:
	sudo wget  https://github.com/labring/sealos/releases/download/v4.1.3/sealos_4.1.3_linux_amd64.tar.gz
	sudo tar -zxvf sealos_4.1.3_linux_amd64.tar.gz sealos &&  chmod +x sealos && mv sealos /usr/bin

install-sealctl:
	sudo wget  https://github.com/labring/sealos/releases/download/v4.1.3/sealos_4.1.3_linux_amd64.tar.gz
	sudo tar -zxvf sealos_4.1.3_linux_amd64.tar.gz sealctl &&  chmod +x sealctl && mv sealctl /usr/bin

uninstall-cri:
	sudo apt-get remove docker docker-engine docker.io containerd runc
	sudo apt-get purge docker-ce docker-ce-cli containerd.io # docker-compose-plugin
	sudo apt-get remove -y moby-engine moby-cli moby-buildx moby-compose

install-k8s:
	sudo -u root sealos run $(k8sRepo):$(k8sVersion) --single --debug
	#sudo -u root sealctl cri socket

taint-k8s:
	sudo -u root kubectl taint node $NAME node-role.kubernetes.io/master-
	sudo -u root kubectl kubectl taint node $NAME node-role.kubernetes.io/control-plane-

nodes:
	sudo kubectl get nodes
