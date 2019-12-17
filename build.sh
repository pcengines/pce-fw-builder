#!/bin/bash

check_if_legacy() {
    case "$1" in
        v4\.0\.*)
            return 1
            ;;
        v4\.[1-9]*)
            return 0
            ;;
        4\.[1-9][0-9]*)
            return 0
            ;;
        4\.[2-7]*)
            return 1
            ;;
        4\.0*)
            return 1
            ;;
        4\.1[^0-9]*)
            return 1
            ;;
        4\.[8-9]*)
            return 0
            ;;
        *)
            echo "ERROR: Tag not recognized $tag"
            exit
            ;;
    esac
}

usage () {
    echo "usage: $0 <command> [<args>]"
    echo
    echo "Commands:"
    echo "    dev-build    build PC Engines firmware from given path"
    echo "    release      build PC Engines firmware from branch/tag/commit of"
    echo "                 upstream or PC Engines fork of coreboot"
    echo "    release-CI   release command prepared to be run in Gitlab CI"
    echo
    echo "dev-build: $0 dev-build <path> <platform> [<menuconfig_param>]"
    echo "    <path>                path to coreboot source"
    echo "    <platform>            apu1, apu2, apu3, apu4 or apu5"
    echo "    <menuconfig_param>    menuconfig interface, give 'help' for more information"
    echo
    echo "release: $0 release <ref> <platform>"
    echo "    <ref>                 valid reference branch, tag or commit"
    echo "    <platform>            apu1, apu2, apu3, apu4 or apu5"
    echo "    <menuconfig_param>    menuconfig interface, give 'help' for more information"
    exit
}

check_version () {
    product_version=${1//v/}
    semver=( ${product_version//./ }  )
    major="${semver[0]:-0}"
    minor="${semver[1]:-0}"
    patch="${semver[2]:-0}"

    if [ $major -ge 4 ]; then
        if [ $minor -eq 0 -a $patch -le 16 ]; then
            echo "ERROR: version unsupported ($product_version < 4.0.17)"
            exit 1
        elif [ $minor -eq 6 -a $patch -le 9 ]; then
            echo "ERROR: version unsupported ($product_version < 4.6.10)"
            exit 1
        fi
    else
        echo "ERROR: version unsupported ($product_version < 4.0.17 || $product_version < 4.6.10)"
        exit 1
    fi
}

check_sdk_version () {
    product_version=${1//v/}
    semver=( ${product_version//./ }  )
    major="${semver[0]:-0}"
    minor="${semver[1]:-0}"
    patch="${semver[2]:-0}"

    if [ $major -ge 4 ]; then
        if [ $minor -ge 9 ]; then
            # for v4.9.x.x use newer SDK
            sdk_ver=1.52.1
            return 0
        elif [ $minor -lt 9 ]; then
            # for versions < 4.9.x.x use older SDK
            sdk_ver=1.50.1
            return 0
        fi
    fi
    # should not happen
    sdk_ver=latest
}

dev_build() {
    # remove dev-build from options
    shift

    cb_path="`realpath $1`"
    pushd $cb_path
    tag=$(git describe --tags --abbrev=0)
    check_version $tag
    check_if_legacy $tag
    legacy=$?
    popd

    # remove coreboot path
    shift


    if [ "$legacy" == 1 ]; then
        echo "Dev-build coreboot legacy"
        docker run --rm -it -v $cb_path:/home/coreboot/coreboot  \
            -v $PWD/scripts:/home/coreboot/scripts pcengines/pce-fw-builder-legacy:latest \
            /home/coreboot/scripts/pce-fw-builder.sh $legacy $*
    elif [ "$legacy" == 0 ]; then
        sdk_ver=latest
        check_sdk_version $tag
        echo "Dev-build coreboot mainline"
        docker run --rm -it -v $cb_path:/home/coreboot/coreboot  \
            -v $PWD/scripts:/home/coreboot/scripts pcengines/pce-fw-builder:$sdk_ver \
            /home/coreboot/scripts/pce-fw-builder.sh $legacy $*
    else
        echo "ERROR: Exit"
        exit
    fi

}

release() {
    if [ -d release ]; then
        sudo rm -rf release
    fi

    # remove release from options
    shift
    check_version $1
    mkdir release
    git clone https://review.coreboot.org/coreboot.git release/coreboot
    cd release/coreboot
    git submodule update --init --checkout
    git remote add pcengines https://github.com/pcengines/coreboot.git
    git fetch pcengines
    # fetch tags additionally, sometimes git fetch does not find all revisions
    git fetch pcengines -t
    git checkout -f $1
    git submodule update --init --checkout
    tag=$(git describe --tags --abbrev=0 ${1})

    check_if_legacy $tag
    legacy=$?

    cd ../..

    VERSION=$1
    OUT_FILE_NAME="$2_${VERSION}.rom"

    # remove tag|branch from options
    shift

    if [ "$legacy" == 1 ]; then
        echo "Release $1 build coreboot legacy"
        docker run --rm -it -v $PWD/release/coreboot:/home/coreboot/coreboot  \
            -v $PWD/scripts:/home/coreboot/scripts pcengines/pce-fw-builder-legacy:latest \
            /home/coreboot/scripts/pce-fw-builder.sh $legacy $*
    elif [ "$legacy" == 0 ]; then
        sdk_ver=latest
        check_sdk_version $tag
        echo "Release $1 build coreboot mainline"
        docker run --rm -it -v $PWD/release/coreboot:/home/coreboot/coreboot  \
            -v $PWD/scripts:/home/coreboot/scripts pcengines/pce-fw-builder:$sdk_ver \
            /home/coreboot/scripts/pce-fw-builder.sh $legacy $*
    else
        echo "ERROR: Exit"
        exit
    fi

    cd release
    cp coreboot/build/coreboot.rom "${OUT_FILE_NAME}"
    sha256sum "${OUT_FILE_NAME}"
}

release_ci() {
    # remove release-CI from options
    shift
    check_version $1
    git clone https://review.coreboot.org/coreboot.git /home/coreboot/coreboot
    cd /home/coreboot/coreboot
    git submodule update --init --checkout
    git remote add pcengines https://github.com/pcengines/coreboot.git
    git fetch pcengines
    # fetch tags additionally, sometimes git fetch does not find all revisions
    git fetch pcengines -t
    git checkout -f $1
    git submodule update --init --checkout
    check_if_legacy $(git describe --tags --abbrev=0 ${1})
    legacy=$?

    cd /home/coreboot/pce-fw-builder

    VERSION=$1
    OUT_FILE_NAME="$2_${VERSION}.rom"

    # remove tag|branch from options
    shift

    scripts/pce-fw-builder.sh $legacy $*

    pwd
    ls -al /home/coreboot/coreboot/build/

    if [ ! -d /home/coreboot/release ]; then
        mkdir -p /home/coreboot/release
    fi

    cp /home/coreboot/coreboot/build/coreboot.rom /home/coreboot/"${OUT_FILE_NAME}"
    sha256sum /home/coreboot/"${OUT_FILE_NAME}"
}


case "$1" in
    help)
        usage
        ;;
    dev-build)
        dev_build $*
        ;;
    release)
        release $*
        ;;
    release-CI)
        release_ci $*
        ;;
    *)
        usage
        ;;
esac
