#!/bin/bash

USERNAME="pcengines"
IMAGE="pce-fw-builder"

# verify arguments
if [[ "$1" =~ [0-9]+\.[0-9]+\.[0-9]+ ]] ;then
    echo "Dockerfile tag: " $1
else
    echo "Invalid argument"
    echo
    echo "Usage: release.sh <tag>"
    echo
    echo "    <tag>    tag describing dockerfiles"
    exit
fi

function errorCheck {
    ERROR_CODE="${?}"
    if [ "${ERROR_CODE}" -ne 0  ]; then
      echo "[ERROR] ${1} : (${ERROR_CODE})"
        exit 1
    fi
}

# for testing
exit

# ensure we're up to date
CURRENT_BRANCH="$(git rev-parse --abbrev-ref HEAD)"
git pull origin $CURRENT_BRANCH
errorCheck "Failed to pull $CURRENT_BRANCH"

# build mainline
docker build -t pcengines/pce-fw-builder -f Dockerfile.ml .
errorCheck "Build mainline failed"

# build legacy
docker build -t pcengines/pce-fw-builder-legacy -f Dockerfile.legacy .
errorCheck "Build legacy failed"

# push mainline
docker push $USERNAME/$IMAGE:latest
errorCheck "Failed to push container: \"USERNAME/$IMAGE:latest\""
docker push $USERNAME/$IMAGE:$version
errorCheck "Failed to push container: \"USERNAME/$IMAGE:$version\""

# push legacy
docker push $USERNAME/$IMAGE-legacy:latest
errorCheck "Failed to push container: \"USERNAME/$IMAGE-legacy:latest\""
docker push $USERNAME/$IMAGE-legacy:$version
errorCheck "Failed to push container: \"USERNAME/$IMAGE-legacy:$version\""
