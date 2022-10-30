#!/bin/bash

set -eu

readonly IMAGE_PLATFORM=${platform?}
readonly IMAGE_NAME=${image?}
readonly IMAGE_HUB_REGISTRY=${registry?}
readonly IMAGE_HUB_REPO=${repo?}
readonly IMAGE_HUB_USERNAME=${username?}
readonly IMAGE_HUB_PASSWORD=${password?}
readonly SEALOS_CMD=${cmd:-version}
readonly DEBUG=${debug:-}
{
  [[ -s Dockerfile ]] && Kubefile="Dockerfile" || Kubefile="Kubefile"
#  if [[ -s init.sh ]]; then
#    bash init.sh "$APP_ARCH" "$APP_NAME" "$APP_VERSION"
#  fi
  if [[ "$DEBUG" == true ]]; then
    DEBUG_FLAG="--debug"
  fi

  case $(SEALOS_CMD) in
    run)
      sudo -u root sealos run $IMAGE_NAME --single $DEBUG_FLAG
      bash tainit_node.sh
      bash print_pods.sh
      ;;
    login)
      sudo -u root sealos login -u "$IMAGE_HUB_USERNAME" -p "$IMAGE_HUB_PASSWORD" "$IMAGE_HUB_REGISTRY" $DEBUG_FLAG
      ;;
    build)
      IMAGE_BUILD_NAME="$IMAGE_HUB_REGISTRY/$IMAGE_HUB_REPO/$IMAGE_NAME"
      IMAGE_BUILD="${IMAGE_NAME%%:*}:build-$(date +%s)"
      sudo sealos build -t "$IMAGE_BUILD" --platform "$IMAGE_PLATFORM" -f $Kubefile . $DEBUG_FLAG
      sudo sealos tag "$IMAGE_BUILD" "$IMAGE_BUILD_NAME" && sudo sealos rmi -f "$IMAGE_BUILD"
      ;;
    push)
      sudo sealos push "$IMAGE_BUILD_NAME" $DEBUG_FLAG && echo "$IMAGE_BUILD_NAME push success"
  	  ;;
    version)
  	  sudo -u root sealos version
  	  ;;
    *)
      echo "unknown cmd"
      exit 1
      ;;
  esac
}
