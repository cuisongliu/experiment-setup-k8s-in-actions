#!/bin/bash

set -eu

readonly SEALOS_CMD=${cmd:-install}

###
readonly INSTALL_SEALOS_VERSION=${sealos_version:-4.1.4}
readonly INSTALL_SEALOS_GIT=${sealosGit:-https://github.com/labring/sealos.git}
readonly INSTALL_GO_ADDR=${goAddr:-https://go.dev/dl/go1.20.linux-amd64.tar.gz}

{
  echo "download buildah in https://github.com/labring/cluster-image/releases/download/depend/buildah.linux.amd64"
  wget -qO "buildah" "https://github.com/labring/cluster-image/releases/download/depend/buildah.linux.amd64"
  chmod a+x buildah
  sudo mv buildah /usr/bin
}
{
  sudo apt-get remove docker docker-engine docker.io containerd runc > /dev/null
  sudo apt-get purge docker-ce docker-ce-cli containerd.io > /dev/null # docker-compose-plugin
  sudo apt-get remove -y moby-engine moby-cli moby-buildx moby-compose > /dev/null
}
{
  case $SEALOS_CMD in
  	install)
  	  echo "download sealos sealctl in https://github.com/labring/sealos/releases/download/v${INSTALL_SEALOS_VERSION}/sealos_${INSTALL_SEALOS_VERSION}_linux_amd64.tar.gz"
  	  sudo wget -q https://github.com/labring/sealos/releases/download/v${INSTALL_SEALOS_VERSION}/sealos_${INSTALL_SEALOS_VERSION}_linux_amd64.tar.gz
  	  sudo tar -zxvf sealos_${INSTALL_SEALOS_VERSION}_linux_amd64.tar.gz sealos &&  chmod +x sealos && sudo mv sealos /usr/bin
  	  sudo tar -zxvf sealos_${INSTALL_SEALOS_VERSION}_linux_amd64.tar.gz sealctl &&  chmod +x sealctl && sudo mv sealctl /usr/bin
  	  ;;
  	install-dev)
  	  {
        wget -qO goNew.tgz ${INSTALL_GO_ADDR} && tar -zxf goNew.tgz && rm -rf goNew.tgz
        mkdir -p /tmp/golang && mv go /tmp/golang
        export PATH="/tmp/golang/go/bin:${PATH}"
        go version
      }
      git clone $INSTALL_SEALOS_GIT
      sudo apt update > /dev/null && sudo apt install -y libgpgme-dev libbtrfs-dev libdevmapper-dev  > /dev/null
      cd sealos
      BINS=sealos make build
      BINS=sealctl make build
      sudo chmod a+x bin/linux_amd64/* && sudo mv bin/linux_amd64/* /usr/bin
      ;;
    *)
      echo "unknown cmd"
      exit 1
      ;;
  esac
}

