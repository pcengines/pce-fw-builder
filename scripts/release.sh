#!/bin/bash

USERNAME="pcengines"
IMAGE="pce-fw-builder"
IMAGE_LEGACY=$IMAGE-legacy
VERSION="1.50"

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
GIT_TAG=`git tag -l --sort=-v:refname`
echo $GIT_TAG
for CURRENT_GIT_TAG in $GIT_TAG ; do
    echo "$CURRENT_GIT_TAG:"

    if [ "$MAINLINE_BUILD" == "false" ]; then
        MAINLINE_DIFF=`git diff $CURRENT_BRANCH $CURRENT_GIT_TAG -- Dockerfile.ml`
        if [ "$MAINLINE_DIFF" == "" ]; then
            echo "    Mainline: Dockerfile.ml is the same as $CURRENT_GIT_TAG"
        else
            echo "    Build docker image"

            # find last tag of docker image
            DOCKERHUB_TAG=`wget -q https://registry.hub.docker.com/v1/repositories/pcengines/pce-fw-builder/tags -O - |sed -e 's/[][]//g' -e 's/"//g' -e 's/ //g'|tr '}' '\n' |awk -F: '{print $3}'`
            DOCKERHUB_TAG=($DOCKERHUB_TAG)

            NEW_TAG="$VERSION.1"
            if [[ ${DOCKERHUB_TAG[@]} != *"$VERSION."* ]]; then
                echo "There is no docker image with tag $VERSION.X"
            else
                $NEW_TAG=$(echo ${DOCKERHUB_TAG[length-1]} | cut -d "." -f2 | cut -d "_" -f1)
                $NEW_TAG=$NEW_TAG+1
                echo "The last tag of docker image is: "${DOCKERHUB_TAG[length-1]}
                sed 's|'"${DOCKERHUB_TAG[length-1]}"'*|'"$VERSION"'.'"$NEW_TAG"'|' <<<${DOCKERHUB_TAG[length-1]}
            fi

            # change tag of latest docker image
            docker tag $USERNAME/$IMAGE:latest $USERNAME/$IMAGE:$NEW_TAG

            # build mainline
            docker build -t $USERNAME/$IMAGE:latest -f Dockerfile.ml .
            errorCheck "Build mainline failed"

            # push mainline
            docker push $USERNAME/$IMAGE:latest
            errorCheck "Failed to push container: \"USERNAME/$IMAGE:latest\""
            docker push $USERNAME/$IMAGE:$NEW_TAG
            errorCheck "Failed to push container: \"USERNAME/$IMAGE:$NEW_TAG\""

            MAINLINE_BUILD="true"
        fi
    fi

    if [ "$LEGACY_BUILD" == "false" ]; then
        LEGACY_DIFF=`git diff $CURRENT_BRANCH $CURRENT_GIT_TAG -- Dockerfile.legacy`
        if [ "$LEGACY_DIFF" == "" ]; then
            echo "    Legacy: Dockerfile.legacy is the same as $CURRENT_GIT_TAG"
        else
            echo "    Build docker image"

            # find last tag of docker image
            DOCKERHUB_TAG=`wget -q https://registry.hub.docker.com/v1/repositories/pcengines/pce-fw-builder-legacy/tags -O - |sed -e 's/[][]//g' -e 's/"//g' -e 's/ //g'|tr '}' '\n' |awk -F: '{print $3}'`
            DOCKERHUB_TAG=($DOCKERHUB_TAG)

            NEW_TAG="$VERSION.1"
            if [[ ${DOCKERHUB_TAG[@]} != *"$VERSION."* ]]; then
                echo "There is no docker image with tag $VERSION.X"
            else
                $NEW_TAG=$(echo ${DOCKERHUB_TAG[length-1]} | cut -d "." -f2 | cut -d "_" -f1)
                $NEW_TAG=$NEW_TAG+1
                echo "The last tag of docker image is: "${DOCKERHUB_TAG[length-1]}
                sed 's|'"${DOCKERHUB_TAG[length-1]}"'*|'"$VERSION"'.'"$NEW_TAG"'|' <<<${DOCKERHUB_TAG[length-1]}
            fi

            # change tag of latest docker image
            docker tag $USERNAME/$IMAGE_LEGACY:latest $USERNAME/$IMAGE_LEGACY:$NEW_TAG

            # build legacy
            docker build -t $USERNAME/$IMAGE_LEGACY:latest -f Dockerfile.legacy .
            errorCheck "Build legacy failed"

            # push legacy
            docker push $USERNAME/$IMAGE_LEGACY:latest
            errorCheck "Failed to push container: \"USERNAME/$IMAGE_LEGACY:latest\""
            docker push $USERNAME/$IMAGE_LEGACY:$NEW_TAG
            errorCheck "Failed to push container: \"USERNAME/$IMAGE_LEGACY:$VERSION.$NEW_TAG\""

            LEGACY_BUILD="true"
        fi
    fi

    if [[ $MAINLINE_BUILD == "true"  && $LEGACY_BUILD == "true" ]]; then
        exit
    fi
    
done
