#!/bin/bash

set -eu

readonly ERR_CODE=127

case $(arch) in
x86_64)
  ARCH=amd64
  ;;
*)
  echo "only support amd64(x86_64)"
  exit $ERR_CODE
  ;;
esac

readonly IMAGE_CACHE_NAME="ghcr.io/labring-actions/cache"
readonly SEALOS_CMD=${cmd:-install}

###
readonly SEALOS=${sealos_version:-4.1.4}
readonly PRUNE_CRI=${pruneCRI:-true}

echo "download buildah"
until sudo docker run --rm -v "/usr/bin:/pwd" -w /tools --entrypoint /bin/sh "$IMAGE_CACHE_NAME:tools-$ARCH" -c "ls -lh && cp -a buildah /pwd"; do
  sleep 3
done

if [[ $PRUNE_CRI == 'true' ]]; then
    {
      echo "prune cri doing...."
      sudo apt-get remove -y docker docker-engine docker.io containerd runc > /dev/null
      sudo apt-get purge docker-ce docker-ce-cli containerd.io > /dev/null # docker-compose-plugin
      sudo apt-get remove -y moby-engine moby-cli moby-buildx moby-compose > /dev/null
    }
fi

{
  case $SEALOS_CMD in
  	install)
  	  echo "download sealos sealctl"
  	  sudo docker run --rm -v "/usr/bin:/pwd" --entrypoint /bin/sh "ghcr.io/labring-actions/cache:sealos-v$SEALOS-$ARCH" -c "cp -a /sealos/sealos /sealos/sealctl /pwd"
  	  ;;
  	install-dev)
      echo "download sealos sealctl for dev"
      sudo docker run --rm -v "/usr/bin:/pwd" --entrypoint /bin/sh ghcr.io/labring/sealos:dev -c "cp -a /usr/bin/sealos /sealos/sealctl /pwd"
      ;;
    *)
      echo "unknown cmd"
      exit 1
      ;;
  esac
}

sealctl version
sealos version

