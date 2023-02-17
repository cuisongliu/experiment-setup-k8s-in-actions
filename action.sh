#!/bin/bash

set -ex
set -o noglob

readonly SEALOS_CMD=${cmd:-install}

###
readonly INSTALL_SEALOS_VERSION=${sealos_version:-4.1.4}
readonly INSTALL_SEALOS_GIT=${sealosGit:-https://github.com/labring/sealos.git}
readonly INSTALL_SEALOS_GIT_BRANCH=${sealosGitBranch:-main}
readonly PRUNE_CRI=${pruneCRI:-true}
readonly AUTO_FETCH=${autoFetch:-true}
INSTALL_GO_ADDR=${goAddr:-}

# --- helper functions for logs ---
info()
{
    echo '[INFO] ' "$@"
}
fatal()
{
    echo '[ERROR] ' "$@" >&2
    exit 1
}

# --- set arch and suffix, fatal if architecture not supported ---
setup_verify_arch() {
    if [ -z "$ARCH" ]; then
        ARCH=$(uname -m)
    fi
    case $ARCH in
        amd64)
            ARCH=amd64
            SUFFIX=
            ;;
        x86_64)
            ARCH=amd64
            SUFFIX=
            ;;
        arm64)
            ARCH=arm64
            SUFFIX=-${ARCH}
            ;;
        aarch64)
            ARCH=arm64
            SUFFIX=-${ARCH}
            ;;
        *)
            fatal "Unsupported architecture $ARCH"
    esac
}

setup_go_addr() {
    if [[ $INSTALL_GO_ADDR == '' ]]; then
       INSTALL_GO_ADDR="https://go.dev/dl/go1.20.linux-${ARCH}.tar.gz"
    fi
}

install_buildah() {
    info "download buildah in https://github.com/labring/cluster-image/releases/download/depend/buildah.linux.${ARCH}"
    wget -qO "buildah" "https://github.com/labring/cluster-image/releases/download/depend/buildah.linux.${ARCH}"
    chmod a+x buildah
    sudo mv buildah /usr/bin
}

prune_cri() {
  if [[ $PRUNE_CRI == 'true' ]]; then
      {
        info "prune cri doing...."
        sudo apt-get remove -y docker docker-engine docker.io containerd runc > /dev/null
        sudo apt-get purge docker-ce docker-ce-cli containerd.io > /dev/null # docker-compose-plugin
        sudo apt-get remove -y moby-engine moby-cli moby-buildx moby-compose > /dev/null
      }
  fi
}

install_by_version() {
  info "download sealos sealctl in https://github.com/labring/sealos/releases/download/v${INSTALL_SEALOS_VERSION}/sealos_${INSTALL_SEALOS_VERSION}_linux_${ARCH}.tar.gz"
  sudo wget -q https://github.com/labring/sealos/releases/download/v${INSTALL_SEALOS_VERSION}/sealos_${INSTALL_SEALOS_VERSION}_linux_${ARCH}.tar.gz
  sudo tar -zxvf sealos_${INSTALL_SEALOS_VERSION}_linux_${ARCH}.tar.gz sealos &&  chmod +x sealos && sudo mv sealos /usr/bin
  sudo tar -zxvf sealos_${INSTALL_SEALOS_VERSION}_linux_${ARCH}.tar.gz sealctl &&  chmod +x sealctl && sudo mv sealctl /usr/bin
}

install_by_build() {
   {
      wget -qO goNew.tgz ${INSTALL_GO_ADDR} && tar -zxf goNew.tgz && rm -rf goNew.tgz
      mkdir -p /tmp/golang && mv go /tmp/golang
      export PATH="/tmp/golang/go/bin:${PATH}"
      go version
    }
    sudo apt update > /dev/null && sudo apt install -y libgpgme-dev libbtrfs-dev libdevmapper-dev  > /dev/null
    if [[ $AUTO_FETCH == 'true' ]]; then
      info "clone git branch $INSTALL_SEALOS_GIT_BRANCH for repo $INSTALL_SEALOS_GIT"
      git clone -b $INSTALL_SEALOS_GIT_BRANCH $INSTALL_SEALOS_GIT
      cd sealos
    fi
    BINS=sealos make build
    BINS=sealctl make build
    sudo chmod a+x bin/linux_${ARCH}/{sealos,sealctl}
    sudo mv bin/linux_${ARCH}/{sealos,sealctl} /usr/bin
}

{
  setup_verify_arch
  setup_go_addr
  install_buildah
  prune_cri
  case $SEALOS_CMD in
  	install)
  	  install_by_version
  	  ;;
  	install-dev)
  	  install_by_build
      ;;
    *)
      echo "unknown cmd"
      exit 1
      ;;
  esac
}

