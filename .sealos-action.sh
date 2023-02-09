#!/bin/bash

set -eu

readonly IMAGE_PLATFORM=${platform:-linux/amd64}
readonly IMAGE_NAME=${image:-}
readonly IMAGE_HUB_REGISTRY=${registry:-}
readonly IMAGE_HUB_USERNAME=${username:-}
readonly IMAGE_HUB_PASSWORD=${password:-}
readonly SEALOS_CMD=${cmd:-version}
readonly DEBUG=${debug:-}

###
readonly INSTALL_BUILDAH=${install_buildah:-false}
readonly INSTALL_SEALCTL=${install_sealctl:-false}
readonly INSTALL_SEALOS_VERSION=${sealos_version:-4.1.3}

readonly ACTION_DIR=${action_directory:-}
readonly ACTION_WORK_DIR=${RUNNER_WORKSPACE?}
{
  [[ -s Dockerfile ]] && Kubefile="Dockerfile" || Kubefile="Kubefile"
#  if [[ -s init.sh ]]; then
#    bash init.sh "$APP_ARCH" "$APP_NAME" "$APP_VERSION"
#  fi
  DEBUG_FLAG=""
  if [[ "$DEBUG" == true ]]; then
    DEBUG_FLAG="--debug"
  fi

  ACTION_FULL_DIR="$ACTION_WORK_DIR/$ACTION_DIR"

  case $SEALOS_CMD in
    run-k8s)
      sudo -u root sealos run $IMAGE_NAME --single $DEBUG_FLAG
      ;;
    run-app)
      sudo -u root sealos run $IMAGE_NAME  $DEBUG_FLAG
      ;;
    login)
      sudo -u root sealos login $DEBUG_FLAG -u "$IMAGE_HUB_USERNAME" -p "$IMAGE_HUB_PASSWORD" "$IMAGE_HUB_REGISTRY"
      ;;
    build)
      IMAGE_BUILD="${IMAGE_NAME%%:*}:build-$(date +%s)"
      sudo sealos build -t "$IMAGE_BUILD" --platform "$IMAGE_PLATFORM" -f $Kubefile $DEBUG_FLAG .
      sudo sealos tag "$IMAGE_BUILD" "$IMAGE_NAME" && sudo sealos rmi -f "$IMAGE_BUILD"
      ;;
    push)
      sudo sealos push "$IMAGE_NAME" $DEBUG_FLAG && echo "$IMAGE_NAME push success"
  	  ;;
    version)
  	  sudo -u root sealos version
  	  ;;
  	images)
  	  sudo -u root sealos images
  	  ;;
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
