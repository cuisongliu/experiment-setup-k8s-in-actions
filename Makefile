RootfsImage ?= docker.io/labring/kubernetes:v1.24.0
SealosVersion?= 4.1.3
Debug ?=true
UseBuildah ?=false
UseSealctl ?=false
Username ?=
Password ?=
Registry ?=
BuildPlatform ?= linux/amd64
CmdOpts ?=version

get-debug:
ifeq (false, $(Debug))
DEBUG_FLAG=""
else
DEBUG_FLAG="--debug"
endif

buildah:
	$(call uninstallBuildah)
ifeq (true, $(UseBuildah))
	$(call installBuildah)
endif

sealctl:
ifeq (true, $(UseSealctl))
	$(call downloadBin,sealctl,$(SealosVersion))
endif

define test1
@echo $(1)
$(call test2,cccc)
endef

define test2
@echo $(1)
endef
test-flag: get-debug
	echo $(DEBUG_FLAG)
	$(call test1,ccc)

install-sealos: buildah sealctl
	$(call uninstallCRI)
	$(call downloadBin,sealos,$(SealosVersion))

##remove next version
run-k8s: get-debug
	sudo -u root sealos run $(RootfsImage) --single $(DEBUG_FLAG)
	$(call callShell,tainit_node.sh)
	$(call callShell,print_pods.sh)

cmd: get-debug
	$(call cmdFun,$(CmdOpts))

define cmdFun
switch $(1) {
case "run":
	sudo -u root sealos run $(Image) --single $(DEBUG_FLAG)
    $(call callShell,tainit_node.sh)
    $(call callShell,print_pods.sh)
case "login":
	sudo -u root sealos login $(Registry) -u $(Username) -p $(Password) $(DEBUG_FLAG)
case "build":
	[[ -s Dockerfile ]] && Kubefile="Dockerfile" || Kubefile="Kubefile"
	sudo -u root sealos build -t $(Image) --platform $(BuildPlatform) -f $(Kubefile)  . $(DEBUG_FLAG)
case "push":
	sudo -u root sealos push $(Image) $(DEBUG_FLAG)
case "version":
	sudo -u root sealos version
default:
	echo "unknown cmd"
	exit 1
}
endef

cmd: get-debug


define callShell
	@echo "callShell $(1)"
	@chmod a+x $(1)
    @sudo bash $(1)
endef

define installBuildah
	@echo "download buildah in https://github.com/labring/cluster-image/releases/download/depend/buildah.linux.amd64"
	@wget -qO "buildah" "https://github.com/labring/cluster-image/releases/download/depend/buildah.linux.amd64"
    @chmod a+x buildah
    @sudo mv buildah /usr/bin
endef

define uninstallBuildah
	@sudo apt remove buildah -y || true
endef

define downloadBin
	@echo "download $(1) in https://github.com/labring/sealos/releases/download/v$(2)/sealos_$(2)_linux_amd64.tar.gz"
	@sudo wget -q https://github.com/labring/sealos/releases/download/v$(2)/sealos_$(2)_linux_amd64.tar.gz
    @sudo tar -zxvf sealos_$(2)_linux_amd64.tar.gz $(1) &&  chmod +x $(1) && mv $(1) /usr/bin
endef

define uninstallCRI
	@sudo apt-get remove docker docker-engine docker.io containerd runc
    @sudo apt-get purge docker-ce docker-ce-cli containerd.io # docker-compose-plugin
    @sudo apt-get remove -y moby-engine moby-cli moby-buildx moby-compose
endef
