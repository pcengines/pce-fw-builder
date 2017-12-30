#!/bin/bash

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

    # remove coreboot path
    shift
    docker run --rm -it -v $cb_path:/home/coreboot/coreboot -v $PWD/scripts:/home/coreboot/scripts pcengines/pce-fw-builder:latest \
        /home/coreboot/scripts/pce-fw-builder.sh $*
elif [ "$1" == "release" ]; then
    if [ -d release ]; then
        sudo rm -rf release
    fi

    # remove release from options
    shift
    mkdir release
    git clone https://github.com/pcengines/coreboot.git -b $2

    # remove tag|branch from options
    shift
    cd coreboot
    git submodule update --init --checkout
    cd ..
    docker run --rm -it -v $PWD/release/coreboot:/home/coreboot/coreboot -v $PWD/scripts:/home/coreboot/scripts pcengines/pce-fw-builder:latest \
        /home/coreboot/scripts/pce-fw-builder.sh $*
fi

