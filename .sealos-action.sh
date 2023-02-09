#!/bin/bash

set -eu

readonly SEALOS_CMD=${cmd:-install}

###
readonly INSTALL_BUILDAH=${install_buildah:-true}
readonly INSTALL_SEALCTL=${install_sealctl:-false}
readonly INSTALL_SEALOS_VERSION=${sealos_version:-4.1.3}

readonly ACTION_DIR=${action_directory:-}
readonly ACTION_WORK_DIR=/tmp
{
  ACTION_FULL_DIR="$ACTION_WORK_DIR/$ACTION_DIR"

  case $SEALOS_CMD in
  	install)
  	  sudo -u root UseBuildah=$INSTALL_BUILDAH U make -f ${ACTION_FULL_DIR}/.sealos-action-Makefile buildah
  	  sudo -u root UseSealctl=$INSTALL_SEALCTL U make -f ${ACTION_FULL_DIR}/.sealos-action-Makefile sealctl
  	  sudo -u root SealosVersion=$INSTALL_SEALOS_VERSION U make -f ${ACTION_FULL_DIR}/.sealos-action-Makefile install-sealos
  	  ;;
    *)
      echo "unknown cmd"
      exit 1
      ;;
  esac
}
