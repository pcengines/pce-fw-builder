#!/bin/bash -x

check_if_legacy() {
    tag=$(git describe --tags --abbrev=0)
    case "$tag" in
        4.[0-3]*)
            return 1
            ;;
        4.[4-9]*)
            return 0
            ;;
        v4.[0-3]*)
            return 1
            ;;
        v4.[4-9]*)
            return 0
            ;;
        *)
            echo "ERROR: Tag not recognized $tag"
            exit
            ;;
    esac

}

if [ $# -lt 3 ]; then
    echo "Usage: ./build.sh dev-build <path> <platform> [<menuconfig-param>]"
    echo "  ./build.sh release <tag|branch> <platform> [<menuconfig-param>]"
    echo "  dev-build - build source from <path>"
    echo "  release - pull source and build according to <tag>"
    echo "  <path> - full path to coreboot source"
    echo "  <tag|branch> - tag or branch published on github.com/pcengines/coreboot"
    echo "  <platform> - apu2, apu3, apu4 or apu5"
    echo "  <menuconfig-param> - menuconfig interface, give 'help' for more information"
    exit
fi

if [ "$1" == "dev-build" ];then
    # remove dev-build from options
    shift

    cb_path=$1
    pushd $cb_path
    check_if_legacy
    legacy=$?
    popd

    # remove coreboot path
    shift


    if [ "$legacy" == 1 ]; then
        echo "Build coreboot legacy"
        docker run --rm -it -v $cb_path:/home/coreboot/coreboot  \
            -v $PWD/scripts:/home/coreboot/scripts pcengines/pce-fw-builder-legacy:latest \
            /home/coreboot/scripts/pce-fw-builder.sh $legacy $*
    elif [ "$legacy" == 0 ]; then
        echo "Build coreboot mainline"
        docker run --rm -it -v $cb_path:/home/coreboot/coreboot  \
            -v $PWD/scripts:/home/coreboot/scripts pcengines/pce-fw-builder:latest \
            /home/coreboot/scripts/pce-fw-builder.sh $legacy $*
    else
        echo "ERROR: Exit"
        exit
    fi

elif [ "$1" == "release" ]; then
    if [ -d release ]; then
        sudo rm -rf release
    fi

    # remove release from options
    shift
    mkdir release
    git clone https://review.coreboot.org/coreboot.git release/coreboot
    cd release/coreboot
    git submodule update --init --checkout
    git remote add pcengines https://github.com/pcengines/coreboot.git
    git fetch pcengines
    git checkout $1
    git submodule update --init --checkout
    cd ../..

    VERSION=$1
    OUT_FILE_NAME="$2_${VERSION}.rom"

    # remove tag|branch from options
    shift
    docker run --rm -it -v $PWD/release/coreboot:/home/coreboot/coreboot  \
        -v $PWD/scripts:/home/coreboot/scripts pcengines/pce-fw-builder:latest \
        /home/coreboot/scripts/pce-fw-builder.sh $*


    cd release
    cp coreboot/build/coreboot.rom "${OUT_FILE_NAME}"
    md5sum "${OUT_FILE_NAME}" > "${OUT_FILE_NAME}.md5"
    tar czf "${OUT_FILE_NAME}.tar.gz" "${OUT_FILE_NAME}" "${OUT_FILE_NAME}.md5"

elif [ "$1" == "release-CI" ]; then

    # remove release-CI from options
    shift
    git clone https://review.coreboot.org/coreboot.git /home/coreboot/coreboot
    cd /home/coreboot/coreboot
    git submodule update --init --checkout
    git remote add pcengines https://github.com/pcengines/coreboot.git
    git fetch pcengines
    git checkout $1
    git submodule update --init --checkout
    cd /home/coreboot/pce-fw-builder

    VERSION=$1
    OUT_FILE_NAME="$2_${VERSION}.rom"

    # remove tag|branch from options
    shift

    scripts/pce-fw-builder.sh $*

    pwd
    ls -al /home/coreboot/coreboot/build/

    if [ ! -d /home/coreboot/release ]; then
        mkdir -p /home/coreboot/release
    fi

    cp /home/coreboot/coreboot/build/coreboot.rom /home/coreboot/release/"${OUT_FILE_NAME}"
    cd /home/coreboot/release
    md5sum "${OUT_FILE_NAME}" > "${OUT_FILE_NAME}.md5"
    tar czf "${OUT_FILE_NAME}.tar.gz" "${OUT_FILE_NAME}" "${OUT_FILE_NAME}.md5"
    pwd
    ls -al
    cp "${OUT_FILE_NAME}.tar.gz" /home/coreboot
    ls -al /home/coreboot
fi

