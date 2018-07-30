#!/bin/bash

USERNAME="pcengines"
IMAGE="pce-fw-builder"
IMAGE_LEGACY=$IMAGE-legacy

function errorCheck {
    ERROR_CODE="${?}"
    if [ "${ERROR_CODE}" -ne 0  ]; then
      echo "[ERROR] ${1} : (${ERROR_CODE})"
        exit 1
    fi
}

# ensure we're up to date
CURRENT_BRANCH="$(git rev-parse HEAD)"
git pull origin $CURRENT_BRANCH
errorCheck "Failed to pull $CURRENT_BRANCH"

MAINLINE_BUILD="false"
LEGACY_BUILD="false"

# get list of tags from most recent
TAG=`git tag -l --sort=-v:refname`

for current_tag in $TAG ; do
    echo "$current_tag:"

    if [ "$MAINLINE_BUILD" == "false" ]; then
        MAINLINE_DIFF=`git diff $CURRENT_BRANCH $current_tag -- Dockerfile.ml`
        if [ "$MAINLINE_DIFF" == "" ]; then
            echo "    Mainline: Dockerfile.ml is the same as $current_tag"
        else
            echo "    Build docker image"

            # change tag of latest docker image
            docker tag $USERNAME/$IMAGE:latest $USERNAME/$IMAGE:$current_tag

            # build mainline
            docker build -t $USERNAME/$IMAGE -f Dockerfile.ml .
            errorCheck "Build mainline failed"

            # push mainline
            docker push $USERNAME/$IMAGE:latest
            errorCheck "Failed to push container: \"USERNAME/$IMAGE:latest\""
            docker push $USERNAME/$IMAGE:$current_tag
            errorCheck "Failed to push container: \"USERNAME/$IMAGE:$current_tag\""

            MAINLINE_BUILD="true"
        fi
    fi

    if [ "$LEGACY_BUILD" == "false" ]; then
        LEGACY_DIFF=`git diff $CURRENT_BRANCH $current_tag -- Dockerfile.legacy`
        if [ "$LEGACY_DIFF" == "" ]; then
            echo "    Legacy: Dockerfile.legacy is the same as $current_tag"
        else
            echo "    Build docker image"

            # change tag of latest docker image
            docker tag $USERNAME/$IMAGE_LEGACY:latest $USERNAME/$IMAGE_LEGACY:$current_tag

            # build legacy
            docker build -t $USERNAME/$IMAGE_LEGACY -f Dockerfile.legacy .
            errorCheck "Build legacy failed"

            # for testing
            exit

            # push legacy
            docker push $USERNAME/$IMAGE_LEGACY:latest
            errorCheck "Failed to push container: \"USERNAME/$IMAGE_LEGACY:latest\""
            docker push $USERNAME/$IMAGE_LEGACY:$current_tag
            errorCheck "Failed to push container: \"USERNAME/$IMAGE_LEGACY:$current_tag\""

            LEGACY_BUILD="true"
        fi
    fi
done
